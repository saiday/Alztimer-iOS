//
//  CreateCollectionColumn.swift
//  DayLapse
//
//  Created by Saiday on 10/10/16.
//  Copyright © 2016 saiday. All rights reserved.
//

import UIKit

import PureLayout

protocol CreateCollectionColumnDelegate: class {
    func createColllectionDidTapped()
}

class CreateCollectionColumn: UIView {
    weak var delegate: CreateCollectionColumnDelegate?
    
    weak var button: UIButton!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupSubviews()
        initCustomViews()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func setupSubviews() {
        let button = UIButton(type: .system)
        addSubview(button)
        button.autoCenterInSuperview()
        self.button = button
    }
    
    func initCustomViews() {
        backgroundColor = UIColor.darkGray
        
        button.setTitle(NSLocalizedString("Create new collection", comment: ""), for: .normal)
        button.addTarget(self, action: #selector(buttonTapped), for: .touchUpInside)
    }
    
    func buttonTapped() {
        if let delegate = self.delegate {
            delegate.createColllectionDidTapped()
        }
    }
}
