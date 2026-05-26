//
//  ProfileService.swift
//  watr
//
//  Created by Vincent Todd on 5/19/26.
//

import Foundation

class ProfileService {
    
    static let shared = ProfileService()
    
    private let key = "userProfile"
    
    func save(profile: UserProfile) {
        if let encoded = try? JSONEncoder().encode(profile) {
            UserDefaults.standard.set(encoded, forKey: key)
        }
    }
    
    func load() -> UserProfile? {
        guard let data = UserDefaults.standard.data(forKey: key),
              let profile = try? JSONDecoder().decode(UserProfile.self, from: data) else {
            return nil
        }
        return profile
    }
    
    func clear() {
        UserDefaults.standard.removeObject(forKey: key)
    }
}
