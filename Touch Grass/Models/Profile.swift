//
//  Profile.swift
//  Touch Grass
//
//  Created by Noah Weeks on 4/11/25.
//

import Foundation

struct Profile: Codable, Firestorable, Equatable {
    var uid: String?
    var name: String?
    var email: String
    var photoURL: URL?
}
