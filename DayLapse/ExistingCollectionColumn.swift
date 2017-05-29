//
//  ExistingCollectionColumn.swift
//  DayLapse
//
//  Created by Saiday on 12/15/16.
//  Copyright © 2016 saiday. All rights reserved.
//

import UIKit

import PureLayout
import AFDateHelper

protocol ExistingCollectionColumnDelegate: class {
    func existingCollectionShotTapped(collection: PhotoCollection)
    func existingCollectionColumnPhotosDidTapped(image: UIImage, collection: PhotoCollection)
}

class ExistingCollectionColumn: UIView, UICollectionViewDelegateFlowLayout, UICollectionViewDataSource {
    let thumbnailCellIdentifier = "thumbnailCellIdentifier"
    public weak var delegate: ExistingCollectionColumnDelegate?
    
    var collection: PhotoCollection?
    let padding: CGFloat = 20
    
    weak var nameLabel: UILabel!
    weak var createdDateLabel: UILabel!
    weak var updatedDateLabel: UILabel!
    weak var countLabel: UILabel!
    weak var highlightImage: UIImageView!
    weak var shotButton: UIButton!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupSubviews()
        initCustomViews()
    }
    
    convenience init(collection: PhotoCollection) {
        self.init(frame: .zero)
        self.collection = collection
        configureColumn(collection)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setupSubviews() {
        let contentView = UIView(forAutoLayout: ())
        addSubview(contentView)
        contentView.autoPinEdgesToSuperviewEdges(with: UIEdgeInsetsMake(padding, padding, 0, padding))
        
        let highlightImage = UIImageView(forAutoLayout: ())
        contentView.addSubview(highlightImage)
        highlightImage.autoPinEdge(toSuperviewEdge: .left)
        highlightImage.autoSetDimension(.height, toSize: 100)
        highlightImage.autoMatch(.width, to: .height, of: highlightImage)
        highlightImage.autoAlignAxis(toSuperviewAxis: .horizontal)
        highlightImage.autoPinEdge(toSuperviewEdge: .bottom)
        self.highlightImage = highlightImage
        
        let countLabel = UILabel(forAutoLayout: ())
        highlightImage.addSubview(countLabel)
        countLabel.autoSetDimension(.width, toSize: 25, relation: .greaterThanOrEqual)
        countLabel.autoSetDimension(.height, toSize: 25)
        countLabel.autoPinEdge(toSuperviewEdge: .right)
        countLabel.autoPinEdge(toSuperviewEdge: .top)
        self.countLabel = countLabel
        
        let indicator = UIImageView(forAutoLayout: ())
        indicator.image = #imageLiteral(resourceName: "camera")
        highlightImage.addSubview(indicator)
        indicator.autoPinEdge(toSuperviewEdge: .right)
        indicator.autoPinEdge(toSuperviewEdge: .bottom)
        indicator.autoMatch(.height, to: .height, of: highlightImage, withMultiplier: 0.2)
        indicator.autoMatch(.width, to: .height, of: indicator)
        
        let shotButton = UIButton(type: .system)
        contentView.addSubview(shotButton)
        shotButton.autoPinEdge(.top, to: .top, of: highlightImage)
        shotButton.autoPinEdge(.right, to: .right, of: highlightImage)
        shotButton.autoPinEdge(.left, to: .left, of: highlightImage)
        shotButton.autoPinEdge(.bottom, to: .bottom, of: highlightImage)
        self.shotButton = shotButton
        
        let nameLabel = UILabel(forAutoLayout: ())
        contentView.addSubview(nameLabel)
        nameLabel.autoPinEdge(toSuperviewEdge: .top)
        nameLabel.autoPinEdge(.left, to: .right, of: highlightImage, withOffset: padding)
        nameLabel.autoPinEdge(toSuperviewEdge: .right)
        self.nameLabel = nameLabel
        
        let createdDateLabel = UILabel(forAutoLayout: ())
        contentView.addSubview(createdDateLabel)
        createdDateLabel.autoPinEdge(.top, to: .bottom, of: nameLabel)
        createdDateLabel.autoPinEdge(.left, to: .right, of: highlightImage, withOffset: padding)
        createdDateLabel.autoPinEdge(toSuperviewEdge: .right)
        self.createdDateLabel = createdDateLabel
        
        let updatedDateLabel = UILabel(forAutoLayout: ())
        contentView.addSubview(updatedDateLabel)
        updatedDateLabel.autoPinEdge(.top, to: .bottom, of: createdDateLabel)
        updatedDateLabel.autoPinEdge(.left, to: .left, of: createdDateLabel)
        updatedDateLabel.autoPinEdge(toSuperviewEdge: .right)
        self.updatedDateLabel = updatedDateLabel
        
    }
    
    func initCustomViews() {
        highlightImage.contentMode = .scaleAspectFill
        highlightImage.clipsToBounds = true
        
        countLabel.font = UIFont.systemFont(ofSize: 13)
        countLabel.textAlignment = .center
        countLabel.backgroundColor = UIColor(colorLiteralRed: 1, green: 1, blue: 1, alpha: 0.4)
        
        nameLabel.font = UIFont.systemFont(ofSize: 20)
        
        createdDateLabel.font = UIFont.systemFont(ofSize: 11)
        updatedDateLabel.font = UIFont.systemFont(ofSize: 11)
        
        shotButton.addTarget(self, action: #selector(shotTapped), for: .touchUpInside)
    }
    
    func shotTapped() {
        if let collection = collection {
            self.delegate?.existingCollectionShotTapped(collection: collection)
        }
    }
    
    func configureColumn(_ collection: PhotoCollection) {
        nameLabel.text = collection.name
        createdDateLabel.text = collection.createdDate?.toString()
        updatedDateLabel.text = collection.lastModifiedDate?.toString()
        countLabel.text = String(describing: collection.photosCount)
        highlightImage.image = collection.latestPhoto
    }
    
    // MARK: CollectionView delegate, datasource
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if let count = collection?.thumbnails?.count {
            return count
        }
        return 0
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: thumbnailCellIdentifier, for: indexPath) as! ThumbnailCollectionViewCell
        cell.imageView.image = collection?.thumbnails?[indexPath.row]
        
        return cell
    }
}
