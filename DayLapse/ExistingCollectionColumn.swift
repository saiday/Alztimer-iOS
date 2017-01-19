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
    func existingCollectionColumnDidTapped(album: Album)
    func existingCollectionColumnPhotosDidTapped(image: UIImage, album: Album)
}

class ExistingCollectionColumn: UIView, UICollectionViewDelegateFlowLayout, UICollectionViewDataSource {
    let thumbnailCellIdentifier = "thumbnailCellIdentifier"
    public weak var delegate: ExistingCollectionColumnDelegate?
    
    var album: Album? = nil
    let leftPadding: CGFloat = 20
    
    weak var nameLabel: UILabel!
    weak var timestampLabel: UILabel!
    weak var photosCollection: UICollectionView!
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
        let nameLabel = UILabel(forAutoLayout: ())
        addSubview(nameLabel)
        nameLabel.autoPinEdge(toSuperviewEdge: .top)
        nameLabel.autoPinEdge(toSuperviewEdge: .left, withInset: leftPadding)
        nameLabel.autoMatch(.height, to: .height, of: self, withMultiplier: 0.2)
        nameLabel.autoPinEdge(toSuperviewEdge: .right)
        self.nameLabel = nameLabel
        
        let shotButton = UIButton(type: .custom)
        addSubview(shotButton)
        shotButton.autoPinEdgesToSuperviewEdges(with: .zero)
        self.shotButton = shotButton
        
        let dummyBottomView = UIView(forAutoLayout: ())
        addSubview(dummyBottomView)
        dummyBottomView.autoPinEdge(.top, to: .bottom, of: nameLabel)
        dummyBottomView.autoPinEdge(toSuperviewEdge: .left, withInset: leftPadding)
        dummyBottomView.autoPinEdge(toSuperviewEdge: .bottom)
        dummyBottomView.autoPinEdge(toSuperviewEdge: .right)
        
        let timestamp = UILabel(forAutoLayout: ())
        dummyBottomView.addSubview(timestamp)
        timestamp.autoPinEdgesToSuperviewEdges(with: .zero, excludingEdge: .bottom)
        timestamp.autoMatch(.height, to: .height, of: dummyBottomView, withMultiplier: 0.1)
        self.timestampLabel = timestamp
        
        let layout: UICollectionViewFlowLayout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.sectionInset = UIEdgeInsets(top: 20, left: 10, bottom: 10, right: 10)
        layout.itemSize = CGSize(width: 100, height: 100)
        let collection = UICollectionView(frame: .zero, collectionViewLayout: layout)
        dummyBottomView.addSubview(collection)
        collection.autoPinEdgesToSuperviewEdges(with: .zero, excludingEdge: .top)
        collection.autoMatch(.height, to: .height, of: dummyBottomView, withMultiplier: 0.9)
        collection.autoSetDimension(.height, toSize: 110)
        self.photosCollection = collection
    }
    
    func initCustomViews() {
        nameLabel.font = UIFont.systemFont(ofSize: 20)
        
        photosCollection.backgroundColor = .clear
        photosCollection.delegate = self
        photosCollection.dataSource = self
        photosCollection.register(ThumbnailCollectionViewCell.self, forCellWithReuseIdentifier: thumbnailCellIdentifier)
        
        shotButton.addTarget(self, action: #selector(columnTapped), for: .touchUpInside)
    }
    
    func columnTapped() {
        if let album = album {
            self.delegate?.existingCollectionColumnDidTapped(album: album)
        }
    }
    
    func configureColumn(album: Album) {
        self.nameLabel.text = album.name()
        self.timestampLabel.text = album.readableDate()
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
