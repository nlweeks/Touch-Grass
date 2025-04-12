//
//  Profile.swift
//  Touch Grass
//
//  Created by Noah Weeks on 4/11/25.
//

import Foundation
import FirebaseFirestore

struct Profile: Codable, Firestorable, Equatable {
    @DocumentID var uid: String?
    var name: String?
    var email: String
    var photoURL: URL?
}
