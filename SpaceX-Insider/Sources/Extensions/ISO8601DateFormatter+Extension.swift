//
//  ISO8601DateFormatter+Extension.swift
//  SpaceX-Insider
//
//  Created by Sébastien Gousseau on 29/12/2018.
//  Copyright © 2018 Sébastien Gousseau. All rights reserved.
//

import Foundation

extension ISO8601DateFormatter {
    convenience init(_ formatOptions: Options, timeZone: TimeZone? = nil) {
        self.init()
        self.formatOptions = formatOptions
        self.timeZone = timeZone ?? TimeZone(secondsFromGMT: 0)
    }
}
