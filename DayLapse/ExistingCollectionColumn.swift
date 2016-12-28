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

class ExistingCollectionColumn: UIView {
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
        nameLabel.autoMatch(.height, to: .height, of: self, withMultiplier: 0.5)
        nameLabel.autoPinEdge(toSuperviewEdge: .right) // TODO: remove
        self.nameLabel = nameLabel
        
        let dummyBottomView = UIView(forAutoLayout: ())
        addSubview(dummyBottomView)
        dummyBottomView.autoPinEdge(.top, to: .bottom, of: nameLabel)
        dummyBottomView.autoPinEdge(toSuperviewEdge: .left, withInset: leftPadding)
        dummyBottomView.autoPinEdge(toSuperviewEdge: .bottom)
        dummyBottomView.autoPinEdge(toSuperviewEdge: .right) // TODO: remove
        
        let timestamp = UILabel(forAutoLayout: ())
        dummyBottomView.addSubview(timestamp)
        timestamp.autoPinEdgesToSuperviewEdges(with: .zero, excludingEdge: .bottom)
        timestamp.autoMatch(.height, to: .height, of: dummyBottomView, withMultiplier: 0.5)
        self.timestampLabel = timestamp
        
        let shotButton = UIButton(type: .custom)
        addSubview(shotButton)
        shotButton.autoPinEdgesToSuperviewEdges(with: .zero)
        self.shotButton = shotButton
        
        let layout: UICollectionViewFlowLayout = UICollectionViewFlowLayout()
        layout.sectionInset = UIEdgeInsets(top: 20, left: 10, bottom: 10, right: 10)
        layout.itemSize = CGSize(width: 90, height: 120)
        let collection = UICollectionView(frame: .zero, collectionViewLayout: layout)
        dummyBottomView.addSubview(collection)
        collection.autoPinEdgesToSuperviewEdges(with: .zero, excludingEdge: .top)
        collection.autoMatch(.height, to: .height, of: dummyBottomView, withMultiplier: 0.5)
        self.photosCollection = collection
    }
    
    func initCustomViews() {
        self.nameLabel.font = UIFont.systemFont(ofSize: 20)
        
        self.photosCollection.backgroundColor = UIColor.yellow
        
        self.shotButton.addTarget(self, action: #selector(columnTapped), for: .touchUpInside)
    }
    
    func columnTapped() {
        if let album = album {
            self.delegate?.existingCollectionColumnDidTapped(album: album)
        }
    }
    
    func configureColumn(album: Album) {
        self.nameLabel.text = album.getName()
        self.timestampLabel.text = "2015/12/12"
    }
}
