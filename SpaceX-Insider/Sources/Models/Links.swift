//
//  Models.swift
//  SpaceX-Insider
//
//  Created by Sébastien Gousseau on 25/12/2018.
//  Copyright © 2018 Sébastien Gousseau. All rights reserved.
//

import Foundation

struct Links: Codable {
    
    let mission_patch: String?
    let mission_patch_small: String?
    
    let reddit_campaign: String?
    let reddit_launch: String?
    let reddit_recovery: String?
    let reddit_media: String?
    
    let presskit: String?
    
    let article_link: String?
    
    let video_link: String?
    
    let flickr_images: [String]?
    
    let article: String?
    let wikipedia: String?
    
    func firstArticle() -> String? {
        return article ?? wikipedia
    }
}
