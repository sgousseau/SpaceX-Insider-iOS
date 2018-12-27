//
//  DataFeedController.swift
//  SpaceX-Insider
//
//  Created by Sébastien Gousseau on 25/12/2018.
//  Copyright © 2018 Sébastien Gousseau. All rights reserved.
//

import UIKit
import RxSwift
import RxSwiftExt
import RxCocoa
import FirebaseDatabase
import RxFirebase
import Differentiator
import RxDataSources

struct CollectionSection {
    var header: String
    var items: [Item]
}

struct CollectionItem: IdentifiableType, Equatable {
    
    static func == (lhs: CollectionItem, rhs: CollectionItem) -> Bool {
        return lhs.identity == rhs.identity
    }
    
    typealias Identity = String
    var identity: Identity {
        return title + date
    }
    
    var title: String
    var date: String
    var detail: String
    var imageUrlString: String
    //var links: [Links]
}

extension CollectionSection : AnimatableSectionModelType {
    typealias Item = CollectionItem
    
    var identity: String {
        return header
    }
    
    init(original: CollectionSection, items: [Item]) {
        self = original
        self.items = items
    }
}

class DataFeedController: UIViewController {
    @IBOutlet weak var collectionView: UICollectionView!
    
    var historyRelay = BehaviorRelay<[History]>(value: [])
    var launchesRelay = BehaviorRelay<[Launch]>(value: [])
    
    var datasource: RxCollectionViewSectionedAnimatedDataSource<CollectionSection>
    
    var disposeBag: DisposeBag!
    
    required init?(coder aDecoder: NSCoder) {
        func configureHistoryCell(_ cell: UICollectionViewCell, item: CollectionItem) {
            guard let historyCell = cell as? DataFeedCollectionCell else {
                return
            }
            
            historyCell.titleLabel.text = item.title
            historyCell.dateLabel.text = item.date
            historyCell.detailLabel.text = item.detail
            
            if let url = item.imageUrlString.url() {
                historyCell.downloadableImage = DefaultImageService.sharedImageService.imageFromURL(url, reachabilityService: DefaultReachabilityService.sharedReachabilityService)
            }
        }
        
        let animation = AnimationConfiguration(insertAnimation: UITableViewRowAnimation.left, reloadAnimation: UITableViewRowAnimation.automatic, deleteAnimation: UITableViewRowAnimation.fade)
        
        datasource = RxCollectionViewSectionedAnimatedDataSource<CollectionSection>(animationConfiguration: animation, decideViewTransition: { (_, _, _) -> ViewTransition in
            return ViewTransition.animated
            
        }, configureCell: { (source, collection, indexPath, item) -> UICollectionViewCell in
            let cell = collection.dequeueReusableCell(withReuseIdentifier: "DataFeedCollectionCell", for: indexPath)
            
            configureHistoryCell(cell, item: item)
            
            return cell
            
        }, configureSupplementaryView: { (source, collection, title, indexPath) -> UICollectionReusableView in
            return UICollectionReusableView.init()
            
        }, moveItem: { (source, indexA, indexB) in
            
        }) { (source, indexPath) -> Bool in
            return false
        }
        
        disposeBag = DisposeBag()
        
        super.init(coder: aDecoder)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        collectionDatasource()
            .bind(to: collectionView.rx.items(dataSource: datasource))
            .disposed(by: disposeBag)
    }

    func collectionDatasource() -> Observable<[CollectionSection]> {
//        let historyRef = Database.database().reference(withPath: "/api/history").rx.observeEvent(.value)
//            .map({ snap -> [History]? in self.parseSnapshot(snap) }).unwrap()
//            .map(historySection)
//
        let launchesRef = Database.database().reference(withPath: "/api/launches").rx.observeEvent(.value)
            .map({ snap -> [Launch]? in self.parseSnapshot(snap) }).unwrap()//.map({ $0.filter({ $0.rocket.links != nil }) })
            .map(launchesSection)
        
        return launchesRef.map({[ $0 ]})
    }
    
    func historySection(_ data: [History]) -> CollectionSection {
        let items = data.map({
            CollectionItem(title: $0.title, date: $0.event_date_utc, detail: $0.details, imageUrlString: $0.links?.firstArticle() ?? "")
        })
        return CollectionSection(header: "History", items: items)
    }
    
    func launchesSection(_ data: [Launch]) -> CollectionSection {
        let items = data.map({
            CollectionItem(title: $0.mission_name, date: $0.launch_date_utc, detail: $0.rocket.rocket_name, imageUrlString: $0.rocket.links?.flickr_images?.first ?? "")
        })
        
        return CollectionSection(header: "Launches", items: items)
    }
    
    func parseSnapshot<T: Decodable>(_ snapshot: DataSnapshot) -> T? {
        do {
            return try parse(snapshot.value) as T
        } catch {
            print(error)
            return nil
        }
    }
    
    func parse<T>(_ value: Any?) throws -> T where T: Decodable {
        guard let value = value, !(value is NSNull) else {
            throw apiError("Not decodable")
        }
        if let array = value as? [Any] {
            let data = try JSONSerialization.data(withJSONObject: array.filter({ !($0 is NSNull) }), options: .prettyPrinted)
            return try JSONDecoder().decode(T.self, from: data)
        } else {
            let data = try JSONSerialization.data(withJSONObject: value, options: .prettyPrinted)
            return try JSONDecoder().decode(T.self, from: data)
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using [segue destinationViewController].
        // Pass the selected object to the new view controller.
    }
}

class DataFeedCollectionCell: UICollectionViewCell {
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var stackView: UIStackView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var detailLabel: UILabel!
    @IBOutlet weak var linksCollection: UICollectionView!
    
    var disposeBag: DisposeBag!
    var downloadableImage: Observable<DownloadableImage>?{
        didSet{
            let disposeBag = DisposeBag()
            
            self.downloadableImage?
                .asDriver(onErrorJustReturn: DownloadableImage.offlinePlaceholder)
                .drive(imageView.rx.downloadableImageAnimated(CATransitionType.fade.rawValue))
                .disposed(by: disposeBag)
            
            self.disposeBag = disposeBag
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        linksCollection!.register(DataFeedLinkCollectionCell.self, forCellWithReuseIdentifier: "DataFeedLinkCollectionCell")
    }
}

class DataFeedLinkCollectionCell: UICollectionViewCell {
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
}
