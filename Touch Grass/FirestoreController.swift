//
//  FirestoreContext.swift
//  Touch Grass
//
//  Created by Noah Weeks on 4/11/25.
//
//  Following this tutorial: https://www.youtube.com/watch?v=KzObbPbzm-g

import Foundation
import FirebaseFirestore
import SwiftUI

struct FirestoreController<T: Codable & Firestorable & Equatable> {
    
    @discardableResult static func create(_ document: T, collectionPath: String) async throws -> T {
        let reference = Firestore.firestore().collection(collectionPath).document()
        var updatedDocument = document
        updatedDocument.uid = reference.documentID
        try reference.setData(from: updatedDocument)
        return updatedDocument
    }
    
    @discardableResult static func update(_ document: T, collectionPath: String) throws -> T? {
        guard let uid = document.uid else {
            print("Cannot update document with nil UID")
            return nil
        }
        
        print("Updating document with UID: \(uid)")
        let reference = Firestore.firestore().collection(collectionPath)
        try reference.document(uid).setData(from: document, merge: true)
        return document
    }
    
    @discardableResult static func read(_ uid: String, collectionPath: String) async throws -> T? {
        let reference = Firestore.firestore().collection(collectionPath)
        return try await reference.document(uid).getDocument(as: T.self)
    }
    
    @discardableResult static func delete(_ document: T, collectionPath: String) throws -> T? {
        guard let uid = document.uid else { return nil }
        let reference = Firestore.firestore().collection(collectionPath)
        Task {
            try await reference.document(uid).delete()
        }
        return document
    }
    
    static func listen(uid: String, collectionPath: String, onUpdate: @escaping (T?, Bool) -> Void) -> ListenerRegistration {
        let reference = Firestore.firestore().collection(collectionPath).document(uid)
        return reference.addSnapshotListener { documentSnapshot, error in
            if let error = error {
                print("Error fetching document: \(error)")
                onUpdate(nil, false)
                return
            }
            
            guard let document = documentSnapshot else {
                onUpdate(nil, false)
                return
            }
            
            // Check if the document exists
            if document.exists {
                do {
                    let data = try document.data(as: T.self)
                    onUpdate(data, true)
                } catch {
                    print("Error decoding document: \(error)")
                    onUpdate(nil, true)
                }
            } else {
                // Document doesn't exist
                onUpdate(nil, false)
            }
        }
    }
    
    static func query(collectionPath: String, predicates: [QueryPredicate]) async throws -> [T] {
        let query: Query = getQuery(path: collectionPath, predicates: predicates)
        let snapshot = try await query.getDocuments()
        let documents = snapshot.documents.compactMap { document in
            try? document.data(as: T.self)
        }
        return documents
    }
    
    static func query(collectionPath: String, predicates: [QueryPredicate], lastDocumentSnapshot: Binding<DocumentSnapshot?>) async throws -> [T] {
        let query: Query = getQuery(path: collectionPath, predicates: predicates)
        if let lastDocumentSnapshot = lastDocumentSnapshot.wrappedValue {
            query.start(afterDocument: lastDocumentSnapshot)
        }
        let snapshot = try await query.getDocuments()
        let documents = snapshot.documents.compactMap { document in
            try? document.data(as: T.self)
        }
        lastDocumentSnapshot.wrappedValue = snapshot.documents.last
        return documents
    }
    
    private static func getQuery(path: String, predicates: [QueryPredicate]) -> Query {
        var query: Query = Firestore.firestore().collection(path)
        
        for predicate in predicates {
            switch predicate {
            case let  .isEqualTo(field, value):
                query = query.whereField(field, isEqualTo: value)
            case let  .isIn(field, values):
                query = query.whereField(field, in: values)
            case let  .isNotIn(field, values):
                query = query.whereField(field, notIn: values)
            case let .arrayContains(field, value):
                query = query.whereField(field, arrayContains: value)
            case let .arrayContainsAny(field, values):
                query = query.whereField(field, arrayContainsAny: values)
            case let  .isLessThan(field, value):
                query = query.whereField(field, isLessThan: value)
            case let  .isGreaterThan(field, value):
                query = query.whereField(field, isGreaterThan: value)
            case let  .isLessThanOrEqualTo(field, value):
                query = query.whereField(field, isLessThanOrEqualTo: value)
            case let .isGreaterThanOrEqualTo(field, value):
                query = query.whereField(field, isGreaterThanOrEqualTo: value)
            case let  .orderBy(field, value):
                query = query.order(by: field, descending: value)
            case let  .limitTo(field):
                query = query.limit(to: field)
            case let  .limitToLast(field):
                query = query.limit(toLast: field)
            }
        }
        return query
    }
}
