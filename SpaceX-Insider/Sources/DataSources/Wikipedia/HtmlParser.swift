//
//  HtmlParser.swift
//  SpaceX-Insider
//
//  Created by Sébastien Gousseau on 30/12/2018.
//  Copyright © 2018 Sébastien Gousseau. All rights reserved.
//

import Foundation

struct HtmlParser {
    static func parseImageURLsfromHTML(_ html: NSString) throws -> [URL]  {
        let regularExpression = try NSRegularExpression(pattern: "<img[^>]*src=\"([^\"]+)\"[^>]*>", options: [])
        
        let matches = regularExpression.matches(in: html as String, options: [], range: NSMakeRange(0, html.length))
        
        return matches.map { match -> URL? in
            if match.numberOfRanges != 2 {
                return nil
            }
            
            let url = html.substring(with: match.range(at: 1))
            
            var absoluteURLString = url
            if url.hasPrefix("//") {
                absoluteURLString = "http:" + url
            }
            
            return URL(string: absoluteURLString)
            }.filter { $0 != nil }.map { $0! }
    }
    
    static func parseImageURLsfromHTMLSuitableForDisplay(_ html: NSString) throws -> [URL] {
        return try parseImageURLsfromHTML(html).filter {
            return $0.absoluteString.range(of: ".svg.") == nil
        }
    }

}
