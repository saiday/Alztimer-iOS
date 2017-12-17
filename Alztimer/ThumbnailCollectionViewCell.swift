//
//  ThumbnailCollectionViewCell.swift
//  DayLapse
//
//  Created by Saiday on 1/20/17.
//  Copyright © 2017 saiday. All rights reserved.
//

import UIKit

class ThumbnailCollectionViewCell: UICollectionViewCell {
    lazy var imageView: UIImageView = { [unowned self] in
        let view = UIImageView(forAutoLayout: ())
        self.addSubview(view)
        view.autoPinEdgesToSuperviewEdges()
        
        return view
        }()
    
    override func prepareForReuse() {
        super.prepareForReuse()
        imageView.removeFromSuperview()
    }
}
