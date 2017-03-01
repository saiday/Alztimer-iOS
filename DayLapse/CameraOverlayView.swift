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

class CameraOverlayView: UIView, DeviceMotionRecorderDelegate {
    weak var overlayView: UIImageView!
    weak var shotButton: UIButton!
    weak var previewButton: UIButton!
    weak var cancelButton: UIButton!
    weak var matchingView: DeviceMotionMatchingView!
    weak var currentGravityXLabel, currentGravityYLabel, currentGravityZLabel: UILabel!
    weak var lastGravityXLabel, lastGravityYLabel, lastGravityZLabel: UILabel!
    weak var imagePickerController: UIImagePickerController?
    weak var deviceMotionRecorder: DeviceMotionRecorder?
    var lastGravityData: (Double, Double, Double)? {
        didSet {
            if let data = lastGravityData {
                self.lastGravityXLabel.text = "\(data.0)"
                self.lastGravityYLabel.text = "\(data.1)"
                self.lastGravityZLabel.text = "\(data.2)"
                
                matchingView.originGravityData = data
            }
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupSubviews()
        initCustomViews()
        setupBindings()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public func setOverlayImage(image: UIImage?) {
        if let image = image {
            overlayView.image = image
        }
    }
    
    func setupBindings() {
        _ = overlayView.rx.observe(Bool.self, #keyPath(UIView.hidden)).subscribe(onNext: { [unowned self] (isHidden) in
            self.previewButton.isSelected = isHidden!
            })
    }
    
    func setupSubviews() {
        let overlayView = UIImageView(forAutoLayout: ())
        let screenWidth = UIScreen.main.bounds.size.width
        let cameraPreviewRatio: CGFloat = 4.0 / 3.0
        overlayView.autoSetDimensions(to: CGSize(width: screenWidth, height: screenWidth * cameraPreviewRatio))
        overlayView.layer.isOpaque = false
        overlayView.isOpaque = false
        self.addSubview(overlayView)
        overlayView.autoPinEdge(toSuperviewEdge: .top)
        overlayView.autoAlignAxis(toSuperviewAxis: .vertical)
        self.overlayView = overlayView
        
        let currentGravityXLabel = UILabel(forAutoLayout: ())
        self.addSubview(currentGravityXLabel)
        currentGravityXLabel.autoPinEdge(toSuperviewEdge: .left)
        currentGravityXLabel.autoPinEdge(toSuperviewEdge: .top)
        self.currentGravityXLabel = currentGravityXLabel
        
        let currentGravityYLabel = UILabel(forAutoLayout: ())
        self.addSubview(currentGravityYLabel)
        currentGravityYLabel.autoPinEdge(toSuperviewEdge: .left)
        currentGravityYLabel.autoPinEdge(.top, to: .bottom, of: currentGravityXLabel)
        self.currentGravityYLabel = currentGravityYLabel

        let currentGravityZLabel = UILabel(forAutoLayout: ())
        self.addSubview(currentGravityZLabel)
        currentGravityZLabel.autoPinEdge(toSuperviewEdge: .left)
        currentGravityZLabel.autoPinEdge(.top, to: .bottom, of: currentGravityYLabel)
        self.currentGravityZLabel = currentGravityZLabel
        
        let lastGravityXLabel = UILabel(forAutoLayout: ())
        self.addSubview(lastGravityXLabel)
        lastGravityXLabel.autoPinEdge(toSuperviewEdge: .right)
        lastGravityXLabel.autoPinEdge(toSuperviewEdge: .top)
        self.lastGravityXLabel = lastGravityXLabel
        
        let lastGravityYLabel = UILabel(forAutoLayout: ())
        self.addSubview(lastGravityYLabel)
        lastGravityYLabel.autoPinEdge(toSuperviewEdge: .right)
        lastGravityYLabel.autoPinEdge(.top, to: .bottom, of: lastGravityXLabel)
        self.lastGravityYLabel = lastGravityYLabel
        
        let lastGravityZLabel = UILabel(forAutoLayout: ())
        self.addSubview(lastGravityZLabel)
        lastGravityZLabel.autoPinEdge(toSuperviewEdge: .right)
        lastGravityZLabel.autoPinEdge(.top, to: .bottom, of: lastGravityYLabel)
        self.lastGravityZLabel = lastGravityZLabel
        
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
        previewButton.autoAlignAxis(.horizontal, toSameAxisOf: controlsView, withMultiplier: 0.5)
        previewButton.autoPinEdge(toSuperviewEdge: .right, withInset: 20)
        self.previewButton = previewButton
        
        let cancelButton = UIButton(type: .system)
        cancelButton.setTitle(NSLocalizedString("Cancel", comment: ""), for: .normal)
        controlsView.addSubview(cancelButton)
        cancelButton.autoAlignAxis(toSuperviewAxis: .horizontal)
        cancelButton.autoPinEdge(toSuperviewEdge: .left, withInset: 20)
        self.cancelButton = cancelButton
        
        let matchingView = DeviceMotionMatchingView(forAutoLayout: ())
        matchingView.autoSetDimensions(to: CGSize(width: 50, height: 50))
        controlsView.addSubview(matchingView)
        matchingView.autoAlignAxis(.horizontal, toSameAxisOf: controlsView, withMultiplier: 1.5)
        matchingView.autoPinEdge(toSuperviewEdge: .right, withInset: 20)
        self.matchingView = matchingView
    }
    
    func initCustomViews() {
        overlayView.alpha = 0.5
        
        shotButton.addTarget(self, action: #selector(shotTapped), for: .touchUpInside)
        previewButton.addTarget(self, action: #selector(previewTapped), for: .touchUpInside)
        cancelButton.addTarget(self, action: #selector(cancelTapped), for: .touchUpInside)
    }
    
    func shotTapped() {
        overlayView.isHidden = true
        if let picker = imagePickerController {
            picker.takePicture()
        }
        
        if let recorder = deviceMotionRecorder {
            recorder.enableMotionManager(false)
        }
    }
    
    func previewTapped() {
        overlayView.isHidden = !overlayView.isHidden
    }
    
    func cancelTapped() {
        if let picker = imagePickerController {
            picker.dismiss(animated: true, completion: nil)
        }
        
        if let recorder = deviceMotionRecorder {
            recorder.enableMotionManager(false)
        }
    }
    
    // MARK: DeviceMotionRecorderDelegate
    func deviceMotionRecorderDidUpdate(gravityData: (Double, Double, Double)) {
        self.matchingView.gravityData = gravityData
        self.matchingView.setNeedsDisplay()
        self.currentGravityXLabel.text = "\(gravityData.0)"
        self.currentGravityYLabel.text = "\(gravityData.1)"
        self.currentGravityZLabel.text = "\(gravityData.2)"
    }
}
