//
//  FirebaseEndpoints.swift
//  SpaceX-Insider
//
//  Created by Sébastien Gousseau on 29/12/2018.
//  Copyright © 2018 Sébastien Gousseau. All rights reserved.
//

import Foundation

enum FirebaseResource: String {
    case history = "api/history"
    case missions = "api/missions"
    case launches = "api/launches"
    case landpads = "api/landpads"
    case launchpads = "api/launchpads"
    case cores = "api/cores"
    case capsules = "api/capsules"
    case payloads = "api/payloads"
    case rockets = "api/rockets"
    case dragons = "api/dragons"
    case ships = "api/ships"
}
