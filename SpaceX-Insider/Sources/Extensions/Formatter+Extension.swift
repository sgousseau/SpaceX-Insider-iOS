//
//  Formatter+Extension.swift
//  SpaceX-Insider
//
//  Created by Sébastien Gousseau on 29/12/2018.
//  Copyright © 2018 Sébastien Gousseau. All rights reserved.
//

import Foundation

extension Formatter {
    struct Date {
        @available(iOS 11.0, *)
        static let iso8601 = ISO8601DateFormatter([.withInternetDateTime, .withFractionalSeconds])
    }
}
