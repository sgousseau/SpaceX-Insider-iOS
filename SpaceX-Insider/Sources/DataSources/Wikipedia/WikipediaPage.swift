//
//  WikipediaPage.swift
//  SpaceX-Insider
//
//  Created by Sébastien Gousseau on 30/12/2018.
//  Copyright © 2018 Sébastien Gousseau. All rights reserved.
//

import Foundation

struct WikipediaPage {
    let title: String
    let text: String
    
    // tedious parsing part
    static func parseJSON(_ json: NSDictionary) throws -> WikipediaPage {
        guard
            let parse = json.value(forKey: "parse"),
            let title = (parse as AnyObject).value(forKey: "title") as? String,
            let t = (parse as AnyObject).value(forKey: "text"),
            let text = (t as AnyObject).value(forKey: "*") as? String else {
                throw apiError("Error parsing page content")
        }
        
        return WikipediaPage(title: title, text: text)
    }
}

