//
//  String+Extension.swift
//  SpaceX-Insider
//
//  Created by Sébastien Gousseau on 25/12/2018.
//  Copyright © 2018 Sébastien Gousseau. All rights reserved.
//

import Foundation

extension String {
    
    func url() -> URL? {
        return URL(string: self)
    }
}
