//
//  KeychainStorage.swift
//  PRtify
//
//  Created by Insu Byeon on 2023/09/25.
//  Copyright © 2023 is.byeon. All rights reserved.
//

import SwiftUI
import KeychainAccess
import Logging

@propertyWrapper
public struct KeychainStorage<Value: Codable>: DynamicProperty {
    private let keychain: Keychain = Keychain()
    private let key: String
    private let logger = Logger(category: "KeychainStorage")
    
    @State private var value: Value?
    
    public var wrappedValue: Value? {
        get { value }
        nonmutating set {
            do {
                if let newValue {
                    let encodedValue = try JSONEncoder().encode(newValue)
                    try keychain.set(encodedValue, key: key)
                } else {
                    try keychain.remove(key)
                }
                
                self.value = newValue
            } catch {
                try? Keychain().remove(key)
                logger.error("KeychainStorage set error: \(error.localizedDescription)")
            }
        }
    }
    
    public var projectedValue: Binding<Value?> {
        Binding(get: { wrappedValue }, set: { wrappedValue = $0 })
    }
    
    public init(wrappedValue: Value? = nil, _ key: String) {
        self.key = key

        do {
            if let data = try Keychain().getData(key) {
                let decodedValue = try JSONDecoder().decode(Value.self, from: data)
                _value = State(initialValue: decodedValue)
            } else {
                _value = State(initialValue: wrappedValue)
            }
        } catch {
            logger.error("KeychainStorage Keychain().getData (\(key)) - \(error.localizedDescription)")
        }
    }
}
