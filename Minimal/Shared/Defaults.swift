//
//  Defaults.swift
//  Minimal
//
//  Created by Jameson Parker Kirby on 3/10/18.
//  Copyright © 2018 Parker Kirby. All rights reserved.
//

import UIKit

struct UserSettingsDefaultKey {
    static let firstLaunch = "FirstLaunch"
}

/// Storable
///
/// Convenience protocol that wraps UserDefaults down to two methods: store, and retrieve.
/// Save settings with store. Retrieve userDefaults, modify and save the changes by calling store.
public protocol Storable { }

extension Storable where Self: Codable {
    private static var defaultKey: String {
        return String(describing: type(of: self))
    }
    
    func store() {
        UserDefaults.standard.set(try? PropertyListEncoder().encode(self), forKey: Self.defaultKey)
        print(Self.defaultKey)
    }
    
    public static func retrieve() -> Self? {
        if let data = UserDefaults.standard.value(forKey: defaultKey) as? Data {
            return try? PropertyListDecoder().decode(Self.self, from: data)
        }
        return nil
    }
}

struct Defaults: Codable, Storable {
    var accessToken: String?
    var id: String?
    var lastAuthenticated: Date?
    var theme: String
    var font: Int
    var fontSize: CGFloat
    
    @discardableResult init(accessToken: String? = nil, id: String? = nil, lastAuthenticated: Date? = nil, theme: String = Theme.minimalTheme.rawValue, font: Int = FontType.sanFrancisco.rawValue, fontSize: CGFloat = FontSize.normal.rawValue) {
        self.accessToken = accessToken
        self.id = id
        self.lastAuthenticated = lastAuthenticated
        self.theme = theme
        self.font = font
        self.fontSize = fontSize
        self.store()
    }
}