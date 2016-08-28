//
//  ViewController.swift
//  DayLapse
//
//  Created by Saiday on 7/31/16.
//  Copyright © 2016 saiday. All rights reserved.
//

import UIKit

import PureLayout

class ViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    // MARK: Views
    lazy var shotButton: UIButton = {
        let shotButton = UIButton(type: .system)
        shotButton.setTitle("Shot Shot Shot Shot", for: .normal)
        return shotButton
    }()
    
    lazy var imagePickerController: UIImagePickerController = {
        let imagePickerController = UIImagePickerController()
        imagePickerController.sourceType = .camera
        
        let overlayView = UIView(frame: CGRect(x: 0, y: 0, width: 320, height: 320))
        let blueColor = UIColor.init(red: 255, green: 255, blue: 0, alpha: 0.5)
        overlayView.backgroundColor = blueColor
        overlayView.layer.isOpaque = false
        overlayView.isOpaque = false
        
        imagePickerController.showsCameraControls = false
        imagePickerController.cameraOverlayView = overlayView
        
        return imagePickerController
    }()
    

    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupSubviews()
        initCustomViews()
    }
    
    func setupSubviews() {
        view.addSubview(self.shotButton)
        self.shotButton.autoCenterInSuperview()
        
    }
    
    func initCustomViews() {
        view.backgroundColor = UIColor.white()
        
        self.shotButton.addTarget(self, action: #selector(self.shotButtonTapped), for: .touchUpInside)
    }
    
    func shotButtonTapped() {
        self.imagePickerController.delegate = self
        
        self.present(self.imagePickerController, animated: true, completion: nil)
    }
    
}

