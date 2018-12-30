//
//  WikipediaAPI.swift
//  SpaceX-Insider
//
//  Created by Sébastien Gousseau on 30/12/2018.
//  Copyright © 2018 Sébastien Gousseau. All rights reserved.
//

import Foundation
import RxSwift

class WikipediaAPI {
    
    static let sharedAPI = WikipediaAPI() // Singleton
    
    let dependencies: Dependencies = Dependencies.sharedDependencies
    
    let loadingWikipediaData = ActivityIndicator()
    
    private init() {}
    
    private func JSON(_ url: URL) -> Observable<Any> {
        return dependencies.URLSession
            .rx.json(url: url)
            .trackActivity(loadingWikipediaData)
    }
    
    func search(_ query: String) -> Observable<[WikipediaSearchResult]> {
        let escapedQuery = query.URLEscaped
        let urlContent = "http://en.wikipedia.org/w/api.php?action=opensearch&search=\(escapedQuery)"
        let url = URL(string: urlContent)!
        
        return JSON(url)
            .observeOn(dependencies.backgroundWorkScheduler)
            .map { json in
                guard let json = json as? [AnyObject] else {
                    throw apiError("Parsing error")
                }
                
                return try WikipediaSearchResult.parseJSON(json)
            }
            .observeOn(dependencies.mainScheduler)
    }
    
    func articleContent(searchResult: WikipediaSearchResult) -> Observable<WikipediaPage> {
        let escapedPage = searchResult.title.URLEscaped
        guard let url = URL(string: "http://en.wikipedia.org/w/api.php?action=parse&page=\(escapedPage)&format=json") else {
            return Observable.error(apiError("Can't create url"))
        }
        
        return JSON(url)
            .map { jsonResult in
                guard let json = jsonResult as? NSDictionary else {
                    throw apiError("Parsing error")
                }
                
                return try WikipediaPage.parseJSON(json)
            }
            .observeOn(dependencies.mainScheduler)
    }
}
