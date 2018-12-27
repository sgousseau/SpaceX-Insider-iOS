//
//  Mission.swift
//  SpaceX-Insider
//
//  Created by Sébastien Gousseau on 26/12/2018.
//  Copyright © 2018 Sébastien Gousseau. All rights reserved.
//

import Foundation
import Differentiator

struct Mission: Codable, IdentifiableType {
    typealias Identity = String
    
    var identity: String {
        return mission_id
    }
    
    let mission_name: String
    let mission_id: String
    let manufacturers: [String]
    let payload_ids: [String]
    let wikipedia: String?
    let website: String?
    let twitter: String?
    let description: String
}
