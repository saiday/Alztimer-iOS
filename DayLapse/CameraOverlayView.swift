//
//  CameraOverlayView.swift
//  DayLapse
//
//  Created by Saiday on 9/17/16.
//  Copyright © 2016 saiday. All rights reserved.
//

import UIKit

import PureLayout
import RxSwift
import RxCocoa

class CameraOverlayView: UIView {
    weak var overlayView: UIView!
    weak var shotButton: UIButton!
    weak var previewButton:UIButton!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupSubviews()
        initCustomViews()
        setupBindings()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setupBindings() {
        _ = overlayView.rx.observe(Bool.self, #keyPath(UIView.hidden)).subscribe(onNext: { [unowned self] (isHidden) in
            self.previewButton.isSelected = isHidden!
            })
        overlayView.rx.observe(Bool.self, #keyPath(UIView.hidden)).subscribe(onNext: <#T##((Bool?) -> Void)?##((Bool?) -> Void)?##(Bool?) -> Void#>, onError: <#T##((Error) -> Void)?##((Error) -> Void)?##(Error) -> Void#>, onCompleted: <#T##(() -> Void)?##(() -> Void)?##() -> Void#>, onDisposed: <#T##(() -> Void)?##(() -> Void)?##() -> Void#>)
    }
    
    func setupSubviews() {
        let overlayView = UIView(forAutoLayout: ())
        let screenWidth = UIScreen.main.bounds.size.width
        let cameraPreviewRatio: CGFloat = 4.0 / 3.0
        overlayView.autoSetDimensions(to: CGSize(width: screenWidth, height: screenWidth * cameraPreviewRatio))
        overlayView.layer.isOpaque = false
        overlayView.isOpaque = false
        self.addSubview(overlayView)
        overlayView.autoPinEdge(toSuperviewEdge: .top)
        overlayView.autoAlignAxis(toSuperviewAxis: .vertical)
        self.overlayView = overlayView
        
        let controlsView = UIView(forAutoLayout: ())
        self.addSubview(controlsView)
        controlsView.autoPinEdgesToSuperviewEdges(with: UIEdgeInsets.zero, excludingEdge: .top)
        controlsView.autoPinEdge(.top, to: .bottom, of: overlayView)
        
        let shotButton = UIButton(type: .custom)
        shotButton.setImage(UIImage(named: "shot"), for: .normal)
        shotButton.setImage(UIImage(named: "shot_highlight"), for: .highlighted)
        controlsView.addSubview(shotButton)
        shotButton.autoCenterInSuperview()
        self.shotButton = shotButton
        
        let previewButton = UIButton(type: .custom)
        previewButton.setImage(UIImage(named: "preview"), for: .normal)
        previewButton.setImage(UIImage(named: "preview_disabled"), for: .selected)
        controlsView.addSubview(previewButton)
        previewButton.autoAlignAxis(toSuperviewAxis: .horizontal)
        previewButton.autoPinEdge(toSuperviewEdge: .right, withInset: 20)
        self.previewButton = previewButton
    }
    
    func initCustomViews() {
        let blueColor = UIColor.init(red: 255, green: 255, blue: 0, alpha: 0.5)
        overlayView.backgroundColor = blueColor

        shotButton.addTarget(self, action: #selector(shotTapped), for: .touchUpInside)
        previewButton.addTarget(self, action: #selector(previewTapped), for: .touchUpInside)
    }
    
    func shotTapped() {
        overlayView.isHidden = true
    }
    
    func previewTapped() {
        overlayView.isHidden = !overlayView.isHidden
    }
}
