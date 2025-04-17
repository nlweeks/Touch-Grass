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
    var email: String
    var firstName: String?
    var lastName: String?
    var gender: UserGender?
    
    var fullName: String {
        (firstName ?? "") + " " + (lastName ?? "")
    }
    
    // MARK: Location
    var chosenLocation: String?
    
    // MARK: Education & Job
    var educationLevel: EducationLevel?
    var college: String?
    var professionCategory: ProfessionCategory?
    var jobTitle: String?
    
    // MARK: Personal Info
    var drinksAlcohol: Bool?
    var usesCannabis: Bool?
    var dietaryRestrictions: [DietaryRestriction]?
    
    // MARK: Interests & Preferences
    var hobbies: [Hobbies]?
    var foodPreferences: [FoodPreference]?
    
}

extension Profile {
    enum UserGender: String, Codable, CaseIterable {
        case male
        case female
        case nonbinary
        case other
    }
    
    enum EducationLevel: String, Codable, CaseIterable {
        case highSchool = "High School"
        case associates = "Associates"
        case undergraduate = "Undergraduate"
        case graduate = "Graduate"
        case doctorate = "Doctorate"
        case other = "Other"
    }
    
    enum ProfessionCategory: String, Codable, CaseIterable {
        case agriculture = "Agriculture, Forestry & Fishing"
        case mining = "Mining, Quarrying & Oil and Gas Extraction"
        case utilities = "Utilities"
        case construction = "Construction"
        case manufacturing = "Manufacturing"
        case wholesaleTrade = "Wholesale Trade"
        case retailTrade = "Retail Trade"
        case transportation = "Transportation & Warehousing"
        case information = "Information"
        case finance = "Finance & Insurance"
        case realEstate = "Real Estate & Rental & Leasing"
        case professionalServices = "Professional, Scientific & Technical Services"
        case management = "Management of Companies & Enterprises"
        case administrativeSupport = "Administrative & Support & Waste Management Services"
        case education = "Educational Services"
        case healthcare = "Health Care & Social Assistance"
        case artsEntertainment = "Arts, Entertainment & Recreation"
        case accommodationFood = "Accommodation & Food Services"
        case publicAdministration = "Public Administration"
        case otherServices = "Other Services (except Public Administration)"
        case military = "Military"
        case unemployed = "Unemployed"
        case student = "Student"
        case retired = "Retired"
        case other = "Other"
    }
    
    enum Hobbies: String, Codable, CaseIterable {
        case hiking
        case reading
        case cooking
        case photography
        case traveling
        case sports
        case gaming
        case painting
        case writing
        case dancing
        case knitting
        case yoga
        case meditation
        case gardening
        case woodworking
        case fishing
        case birdWatching
        case playingMusic
        case singing
        case acting
        case pottery
        case calligraphy
        case baking
        case running
        case cycling
        case swimming
        case surfing
        case skiing
        case snowboarding
        case martialArts
        case rockClimbing
        case skateboarding
        case homeImprovement
        case carRestoration
        case volunteering
        case podcasting
        case blogging
        case coding
        case _3dPrinting
        case chess
        case boardGames
        case puzzles
        case astrology
        case tarot
        case wineTasting
        case coffeeBrewing
        case makeup
        case fashion
        case journaling
        case watchingMovies
        case other
        
        var displayName: String {
            switch self {
            case ._3dPrinting: return "3D Printing"
            case .birdWatching: return "Bird Watching"
            case .playingMusic: return "Playing Music"
            case .homeImprovement: return "Home Improvement"
            case .carRestoration: return "Car Restoration"
            case .boardGames: return "Board Games"
            case .watchingMovies: return "Watching Movies"
            case .coffeeBrewing: return "Coffee Brewing"
            default:
                // Convert camelCase to Title Case
                return rawValue
                    .replacingOccurrences(of: "([a-z])([A-Z])", with: "$1 $2", options: .regularExpression)
                    .capitalized
            }
        }
        
        var emoji: String {
            switch self {
            case .hiking: return "🥾"
            case .reading: return "📚"
            case .cooking: return "🍳"
            case .photography: return "📷"
            case .traveling: return "✈️"
            case .sports: return "🏀"
            case .gaming: return "🎮"
            case .painting: return "🎨"
            case .writing: return "✍️"
            case .dancing: return "💃"
            case .knitting: return "🧶"
            case .yoga: return "🧘"
            case .meditation: return "🧘‍♂️"
            case .gardening: return "🌱"
            case .woodworking: return "🪵"
            case .fishing: return "🎣"
            case .birdWatching: return "🐦"
            case .playingMusic: return "🎸"
            case .singing: return "🎤"
            case .acting: return "🎭"
            case .pottery: return "🏺"
            case .calligraphy: return "🖋️"
            case .baking: return "🧁"
            case .running: return "🏃"
            case .cycling: return "🚴"
            case .swimming: return "🏊"
            case .surfing: return "🏄"
            case .skiing: return "🎿"
            case .snowboarding: return "🏂"
            case .martialArts: return "🥋"
            case .rockClimbing: return "🧗"
            case .skateboarding: return "🛹"
            case .homeImprovement: return "🔧"
            case .carRestoration: return "🚗"
            case .volunteering: return "❤️"
            case .podcasting: return "🎙️"
            case .blogging: return "📝"
            case .coding: return "💻"
            case ._3dPrinting: return "🖨️"
            case .chess: return "♟️"
            case .boardGames: return "🎲"
            case .puzzles: return "🧩"
            case .astrology: return "🔮"
            case .tarot: return "🃏"
            case .wineTasting: return "🍷"
            case .coffeeBrewing: return "☕"
            case .makeup: return "💄"
            case .fashion: return "👗"
            case .journaling: return "📓"
            case .watchingMovies: return "🎬"
            case .other: return "✨"
            }
        }
    }
    
    enum FoodPreference: String, Codable, CaseIterable {
        case italian = "Italian"
        case mexican = "Mexican"
        case chinese = "Chinese"
        case japanese = "Japanese"
        case indian = "Indian"
        case thai = "Thai"
        case ethiopian = "Ethiopian"
        case mediterranean = "Mediterranean"
        case american = "American"
        case french = "French"
        case korean = "Korean"
        case vietnamese = "Vietnamese"
        case middleEastern = "Middle Eastern"
        case seafood = "Seafood"
        case barbecue = "Barbecue"
        case sushi = "Sushi"
        case dessert = "Dessert"
        case other = "Other"
    }

    enum DietaryRestriction: String, Codable, CaseIterable {
        case vegetarian = "Vegetarian"
        case vegan = "Vegan"
        case glutenFree = "Gluten-Free"
        case dairyFree = "Dairy-Free"
        case nutFree = "Nut-Free"
        case shellfishFree = "Shellfish-Free"
        case halal = "Halal"
        case kosher = "Kosher"
        case lowCarb = "Low Carb"
        case paleo = "Paleo"
        case keto = "Keto"
        case other = "Other"
    }

}
