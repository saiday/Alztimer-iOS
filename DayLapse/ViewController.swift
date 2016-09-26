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
        imagePickerController.showsCameraControls = false
        let cameraOverlayView = CameraOverlayView(frame: CGRect(x: 0, y: 0, width: self.view.bounds.width, height: self.view.bounds.height))
        cameraOverlayView.imagePickerController = imagePickerController
        imagePickerController.cameraOverlayView = cameraOverlayView
        
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
        view.backgroundColor = UIColor.white
        
        self.shotButton.addTarget(self, action: #selector(self.shotButtonTapped), for: .touchUpInside)
    }
    
    func shotButtonTapped() {
        self.imagePickerController.delegate = self
        self.present(self.imagePickerController, animated: true, completion: nil)
    }
    
    // MARK: ImagePickerControllerDelegate
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String: Any]) {
        print(info)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        print("cancled")
    }
}

// draw a new set of controls
// when user press shot, remove overlay view (cannot do this, confirmed)
// when use photo pressed, save it to disk (create identity folder)
// fetch last photo on folder
