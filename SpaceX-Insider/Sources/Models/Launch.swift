//
//  Launch.swift
//  SpaceX-Insider
//
//  Created by Sébastien Gousseau on 26/12/2018.
//  Copyright © 2018 Sébastien Gousseau. All rights reserved.
//

import Foundation
import Differentiator

struct Launch: Codable, IdentifiableType {
    typealias Identity = String
    
    var identity: String {
        return mission_name
    }
    
    let flight_number: Int
    let mission_name: String
    let mission_id: [String]?
    let launch_year: String
    let launch_date_unix: Int64
    let launch_date_utc: String
    let launch_date_local: String
    let is_tentative: Bool
    let tentative_max_precision: String
    let tbd: Bool
    let rocket: Rocket
}

struct Rocket: Codable, IdentifiableType {
    typealias Identity = String
    
    var identity: String {
        return rocket_id
    }
    
    let rocket_id: String
    let rocket_name: String
    let rocket_type: String
    let first_stage: RocketFirstStage?
    let second_stage: RocketSecondStage
    let fairings: Fairings?
    let ships: [String]?
    let telemetry: Telemetry?
    let launch_site: LaunchSite?
    let launch_success: Bool?
    let links: Links?
    let details: String?
    let upcoming: Bool?
    let static_fire_date_utc: String?
    let static_fire_date_unix: Int64?
}

struct RocketFirstStage: Codable {
    let cores: [RocketCore]
}

struct RocketCore: Codable {
    let core_serial: String?
    let flight: Int?
    let block: Int?
    let gridfins: Bool?
    let legs: Bool?
    let reused: Bool?
    let land_success: Bool?
    let land_intent: Bool?
    let landing_type: String?
    let landing_vehicule: String?
}

struct RocketSecondStage: Codable {
    let block: Int?
    let payloads: [StagePayload]
}

struct OrbitParams: Codable {
    let reference_system: String?
    let regime: String?
    let longitude: Double?
    let semi_major_axis_km: Double?
    let eccentricity: Double?
    let periapsis_km: Double?
    let apoapsis_km: Double?
    let inclination_deg: Double?
    let period_min: Double?
    let lifespan_years: Double?
    let epoch: String?
    let mean_motion: Double?
    let raan: Double?
    let arg_of_pericenter: Double?
    let mean_anomaly: Double?
}

struct StagePayload: Codable {
    let payload_id: String
    let norad_id: [Int]?
    let reused: Bool
    let customers: [String]
    let nationality: String?
    let manufacturer: String?
    let payload_type: String?
    let payload_mass_kg: Double?
    let payload_mass_lbs: Double?
    let orbit: String
    let orbit_params: OrbitParams?
}

struct Fairings: Codable {
    let reused: Bool?
    let recovery_attempt: Bool?
    let recovered: Bool?
    let ship: String?
}

struct Telemetry: Codable {
    let flight_club: String?
}

struct LaunchSite: Codable {
    let site_id: String
    let site_name: String
    let site_name_long: String
}
