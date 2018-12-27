//
//  History.swift
//  SpaceX-Insider
//
//  Created by Sébastien Gousseau on 26/12/2018.
//  Copyright © 2018 Sébastien Gousseau. All rights reserved.
//

import Foundation

struct History: Codable {
    let id: Int
    let title: String
    let details: String
    let event_date_unix: Int64
    let event_date_utc: String
    let flight_number: Int?
    let links: Links?
}
