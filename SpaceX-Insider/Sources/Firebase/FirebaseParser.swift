//
//  FirebaseParser.swift
//  SpaceX-Insider
//
//  Created by Sébastien Gousseau on 29/12/2018.
//  Copyright © 2018 Sébastien Gousseau. All rights reserved.
//

import Foundation
import FirebaseDatabase

struct FirebaseParser {
    static func parseSnapshot<T: Decodable>(_ snapshot: DataSnapshot) -> T? {
        do {
            return try parse(snapshot.value) as T
        } catch {
            print(error)
            return nil
        }
    }
    
    static func parse<T>(_ value: Any?) throws -> T where T: Decodable {
        guard let value = value, !(value is NSNull) else {
            throw apiError("Not decodable")
        }
        let data: Data
        if let array = value as? [Any] {
            data = try JSONSerialization.data(withJSONObject: array.filter({ !($0 is NSNull) }), options: .prettyPrinted)
        } else {
            data = try JSONSerialization.data(withJSONObject: value, options: .prettyPrinted)
        }
        return try JSONDecoder().decode(T.self, from: data)
    }
}
