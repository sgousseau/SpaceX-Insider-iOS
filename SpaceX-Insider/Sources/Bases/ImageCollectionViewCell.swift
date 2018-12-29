//
//  ImageCollectionViewCell.swift
//  SpaceX-Insider
//
//  Created by Sébastien Gousseau on 29/12/2018.
//  Copyright © 2018 Sébastien Gousseau. All rights reserved.
//

import Foundation
import UIKit
import RxSwift
import RxCocoa

public class ImageCollectionViewCell: UICollectionViewCell {
    @IBOutlet var imageOutlet: UIImageView!
    
    var disposeBag: DisposeBag?
    
    var downloadableImage: Observable<DownloadableImage>?{
        didSet{
            let disposeBag = DisposeBag()
            
            self.downloadableImage?
                .asDriver(onErrorJustReturn: DownloadableImage.offlinePlaceholder)
                .drive(imageOutlet.rx.downloadableImageAnimated(CATransitionType.fade.rawValue))
                .disposed(by: disposeBag)
            
            self.disposeBag = disposeBag
        }
    }
    
    override public func prepareForReuse() {
        super.prepareForReuse()
        
        downloadableImage = nil
        disposeBag = nil
    }
    
    deinit {
    }
}
