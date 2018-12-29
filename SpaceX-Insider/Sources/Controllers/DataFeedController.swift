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


indirect enum Section: AnimatableSectionModelType {
    case menu(items: [Item])
    case history(items: [Item])
    case launches(items: [Item])
    case missions(items: [Item])
    case landpads(items: [Item])
    case launchpads(items: [Item])
    case capsules(items: [Item])
    case cores(items: [Item])
    case ships(items: [Item])
    case rockets(items: [Item])
    
    typealias Item = SectionItem
    
    var identity: String {
        switch self {
        case .menu: return "menu"
        case .history: return "history"
        case .launches: return "launches"
        case .missions: return "missions"
        case .landpads: return "landpads"
        case .launchpads: return "launchpads"
        case .capsules: return "capsules"
        case .cores: return "cores"
        case .ships: return "ships"
        case .rockets: return "rockets"
        }
    }
    
    var items: [Item] {
        switch self {
        case .menu(let items): return items.map({ $0 })
        case .history(let items): return items.map({ $0 })
        case .launches(let items): return items.map({ $0 })
        case .missions(let items): return items.map({ $0 })
        case .landpads(let items): return items.map({ $0 })
        case .launchpads(let items): return items.map({ $0 })
        case .capsules(let items): return items.map({ $0 })
        case .cores(let items): return items.map({ $0 })
        case .ships(let items): return items.map({ $0 })
        case .rockets(let items): return items.map({ $0 })
        default: return []
        }
    }
    
    init(original: Section, items: [Item]) {
        self = original
    }
}

enum SectionItemStyle {
    case opaque
    case light
    case translucent
    case flat
}

enum SectionItem: IdentifiableType, Equatable {
    
    case square(title: String, date: String, imageUrlString: String, style: SectionItemStyle)
    case rectangle(title: String, date: String, detail: String, imageUrlString: String, style: SectionItemStyle)
    case bigSquare(title: String, date: String, detail: String, imageUrlString: String, otherImagesUrlString: [String], style: SectionItemStyle)
    
    static func == (lhs: SectionItem, rhs: SectionItem) -> Bool {
        return lhs.identity == rhs.identity
    }
    
    typealias Identity = String
    var identity: Identity {
        return title + date
    }
    
    var title: String {
        switch self {
        case .square(let title, _, _, _): return title
        case .rectangle(let title, _, _, _, _): return title
        case .bigSquare(let title, _, _, _, _, _): return title
        default: return ""
        }
    }
    
    var date: String {
        switch self {
        case .square(_, let date, _, _): return date
        case .rectangle(_, let date, _, _, _): return date
        case .bigSquare(_, let date, _, _, _, _): return date
        }
    }
    
    var detail: String {
        switch self {
        case .square: return ""
        case .rectangle(_, _, let detail, _, _): return detail
        case .bigSquare(_, _, let detail, _, _, _): return detail
        }
    }
    
    var imageUrlString: String {
        switch self {
        case .square(_, _, let url, _): return url
        case .rectangle(_, _, let url, _, _): return url
        case .bigSquare(_, _, let url, _, _, _): return url
        }
    }
    
    var links: [Links] {
        switch self {
        default: return []
        }
    }
}

class DataFeedController: UIViewController {
    @IBOutlet weak var collectionView: UICollectionView!
    
    var datasource: RxCollectionViewSectionedAnimatedDataSource<Section>
    
    var disposeBag: DisposeBag!
    
    required init?(coder aDecoder: NSCoder) {
        func configureHistoryCell(_ cell: UICollectionViewCell, item: SectionItem) {
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
        
        datasource = RxCollectionViewSectionedAnimatedDataSource<Section>(animationConfiguration: animation, decideViewTransition: { (_, _, _) -> ViewTransition in
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
        
        topLevelDataSource()
            .bind(to: collectionView.rx.items(dataSource: datasource))
            .disposed(by: disposeBag)
    }

    func topLevelDataSource() -> Observable<[Section]> {
        return Observable.just([topLevelSection()])
    }

    func collectionDatasource() -> Observable<[Section]> {
        let historyRef = Database.database().reference(withPath: FirebaseResource.history.rawValue).rx.observeEvent(.value)
            .map({ snap -> [History]? in FirebaseParser.parseSnapshot(snap) }).unwrap()
            .map(historySection)

        let launchesRef = Database.database().reference(withPath: FirebaseResource.launches.rawValue).rx.observeEvent(.value)
            .map({ snap -> [Launch]? in FirebaseParser.parseSnapshot(snap) }).unwrap()
            .map(launchesSection)

        return Observable.combineLatest([historyRef, launchesRef]) { $0 }
    }
    
    func topLevelSection() -> Section {
        let items = [SectionItem.rectangle(title: "History", date: "2018-09-12", detail: "Navigate over SpaceX history facts", imageUrlString: "", style: .opaque),
                     SectionItem.rectangle(title: "Launches", date: "2018-11-12", detail: "Upcoming and past launches", imageUrlString: "", style: .opaque),
                     SectionItem.rectangle(title: "Missions", date: "2018-11-12", detail: "All SpaceX missions", imageUrlString: "", style: .opaque)]
        
        return Section.menu(items: items)
    }
    
    func historySection(_ data: [History]) -> Section {
        let items = data.map({
            SectionItem.rectangle(title: $0.title, date: $0.event_date_utc, detail: $0.details, imageUrlString: $0.links?.firstArticle() ?? "", style: .opaque)
        })
        return Section.history(items: items)
    }
    
    func launchesSection(_ data: [Launch]) -> Section {
        let items = data.map({
            SectionItem.rectangle(title: $0.mission_name, date: $0.launch_date_utc, detail: $0.rocket.rocket_name, imageUrlString: $0.rocket.links?.flickr_images?.first ?? "", style: .opaque)
        })
        
        return Section.launches(items: items)
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
