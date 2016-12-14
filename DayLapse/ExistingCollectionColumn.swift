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
    func ExistingCollectionColumnDidTapped(album: Album)
    func ExistingCollectionColumnPhotosDidTapped(image: UIImage, album: Album)
}

class ExistingCollectionColumn: UIView {
    public weak var delegate: ExistingCollectionColumnDelegate?
    
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
        configureColumn(album: album)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setupSubviews() {
        let name = UILabel(forAutoLayout: ())
        addSubview(name)
        name.autoPinEdge(toSuperviewEdge: .top)
        name.autoPinEdge(toSuperviewEdge: .left, withInset: leftPadding)
        name.autoMatch(.height, to: .height, of: self, withMultiplier: 0.5)
        name.autoPinEdge(toSuperviewEdge: .right) // TODO: remove
        self.nameLabel = name
        
        let dummyBottomView = UIView(forAutoLayout: ())
        addSubview(dummyBottomView)
        dummyBottomView.autoPinEdge(.top, to: .bottom, of: name)
        dummyBottomView.autoPinEdge(toSuperviewEdge: .left, withInset: leftPadding)
        dummyBottomView.autoPinEdge(toSuperviewEdge: .bottom)
        dummyBottomView.autoPinEdge(toSuperviewEdge: .right) // TODO: remove
        
        let timestamp = UILabel(forAutoLayout: ())
        dummyBottomView.addSubview(timestamp)
        timestamp.autoPinEdgesToSuperviewEdges(with: .zero, excludingEdge: .bottom)
        timestamp.autoMatch(.height, to: .height, of: dummyBottomView, withMultiplier: 0.5)
        self.timestampLabel = timestamp
        
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
    }
    
    func configureColumn(album: Album) {
        self.nameLabel.text = album.getName()
        self.timestampLabel.text = "2015/12/12"
    }
}
