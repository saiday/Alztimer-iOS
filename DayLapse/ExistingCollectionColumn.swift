//
//  ExistingCollectionColumn.swift
//  DayLapse
//
//  Created by Saiday on 12/15/16.
//  Copyright © 2016 saiday. All rights reserved.
//

import UIKit

import PureLayout

protocol ExistingCollectionColumnDelegate: class {
    func existingCollectionShotTapped(album: Album)
    func existingCollectionColumnPhotosDidTapped(image: UIImage, album: Album)
}

class ExistingCollectionColumn: UIView, UICollectionViewDelegateFlowLayout, UICollectionViewDataSource {
    let thumbnailCellIdentifier = "thumbnailCellIdentifier"
    public weak var delegate: ExistingCollectionColumnDelegate?
    
    var album: Album? = nil
    let padding: CGFloat = 20
    
    weak var nameLabel: UILabel!
    weak var timestampLabel: UILabel!
    weak var photosCollection: UICollectionView!
    weak var highlightImage: UIImageView!
    weak var shotButton: UIButton!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupSubviews()
        initCustomViews()
    }
    
    convenience init(album: Album) {
        self.init(frame: .zero)
        self.album = album
        configureColumn(album: album)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setupSubviews() {
        let contentView = UIView(forAutoLayout: ())
        addSubview(contentView)
        contentView.autoPinEdgesToSuperviewEdges(with: UIEdgeInsetsMake(padding, padding, padding, padding))
        
        let highlightImage = UIImageView(forAutoLayout: ())
        contentView.addSubview(highlightImage)
        highlightImage.autoPinEdge(toSuperviewEdge: .left)
        highlightImage.autoSetDimension(.height, toSize: 150)
        highlightImage.autoMatch(.width, to: .height, of: highlightImage)
        highlightImage.autoAlignAxis(toSuperviewAxis: .horizontal)
        self.highlightImage = highlightImage
        
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
        
        let timestamp = UILabel(forAutoLayout: ())
        contentView.addSubview(timestamp)
        timestamp.autoPinEdge(.top, to: .bottom, of: nameLabel)
        timestamp.autoPinEdge(.left, to: .right, of: highlightImage, withOffset: padding)
        timestamp.autoPinEdge(toSuperviewEdge: .right)
        self.timestampLabel = timestamp
        
        let layout: UICollectionViewFlowLayout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.sectionInset = UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)
        layout.itemSize = CGSize(width: 100, height: 100)
        let collection = UICollectionView(frame: .zero, collectionViewLayout: layout)
        contentView.addSubview(collection)
        collection.autoPinEdge(.top, to: .bottom, of: timestamp)
        collection.autoPinEdge(.left, to: .right, of: highlightImage, withOffset: padding)
        collection.autoPinEdge(toSuperviewEdge: .right)
        collection.autoPinEdge(toSuperviewEdge: .bottom)
        collection.autoSetDimension(.height, toSize: 120)
        self.photosCollection = collection
    }
    
    func initCustomViews() {
        highlightImage.contentMode = .scaleAspectFill
        highlightImage.clipsToBounds = true
        
        photosCollection.showsHorizontalScrollIndicator = false
        
        nameLabel.font = UIFont.systemFont(ofSize: 20)
        
        photosCollection.backgroundColor = .clear
        photosCollection.delegate = self
        photosCollection.dataSource = self
        photosCollection.register(ThumbnailCollectionViewCell.self, forCellWithReuseIdentifier: thumbnailCellIdentifier)
        
        shotButton.addTarget(self, action: #selector(shotTapped), for: .touchUpInside)
    }
    
    func shotTapped() {
        if let album = album {
            self.delegate?.existingCollectionShotTapped(album: album)
        }
    }
    
    func configureColumn(album: Album) {
        nameLabel.text = album.name()
        timestampLabel.text = album.readableDate()
        highlightImage.image = album.latestPhotoImage()
    }
    
    // MARK: CollectionView delegate, datasource
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if let album = album {
            return album.thumbnails().count
        }
        return 0
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: thumbnailCellIdentifier, for: indexPath) as! ThumbnailCollectionViewCell
        cell.imageView.image = album?.thumbnails()[indexPath.row]
        
        return cell
    }
}
