//
//  ViewController.swift
//  DayLapse
//
//  Created by Saiday on 7/31/16.
//  Copyright © 2016 saiday. All rights reserved.
//

import UIKit

import PureLayout

import Photos

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
        let image = info[UIImagePickerControllerOriginalImage] as! UIImage
        if hasPhotosAuthorized() {
            dayLapseAlbum(albumFound: { (album) in
                PHPhotoLibrary.shared().performChanges({
                    let request = PHAssetChangeRequest.creationRequestForAsset(from: image)
                    reques
                    }, completionHandler: { (success, error) in
                        
                })
            })
        } else {
            let alert = UIAlertController(title: NSLocalizedString("We need your permission to accss photo library", comment: ""), message: "", preferredStyle: .alert)
            self.present(alert, animated: true, completion: nil)
        }
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        print("cancled")
    }
    
    func hasPhotosAuthorized() -> Bool {
        let status = PHPhotoLibrary.authorizationStatus()
        return status == .authorized
    }
    
    func isDaylapseAlbumCreated() -> Bool {
        let userCollections = PHCollectionList.fetchTopLevelUserCollections(with: nil)
        for i in 0 ..< userCollections.count {
            let userAlbum = userCollections.object(at: i)
            if userAlbum.localizedTitle == CUSTOM_ALBUM_NAME {
                return true
            }
        }
        
        return false
    }
    
    func dayLapseAlbum(albumFound: @escaping (PHAssetCollection) -> Void) {
        let fetchOptions = PHFetchOptions()
        fetchOptions.predicate = NSPredicate(format: "title = %@", CUSTOM_ALBUM_NAME)
        let collection = PHAssetCollection.fetchAssetCollections(with: .album, subtype: .any, options: fetchOptions)
        
        if let album = collection.firstObject {
            albumFound(album)
        } else {
            //If not found - Then create a new album
            var assetCollectionPlaceholder: PHObjectPlaceholder
            PHPhotoLibrary.shared().performChanges({
                let createAlbumRequest = PHAssetCollectionChangeRequest.creationRequestForAssetCollection(withTitle: CUSTOM_ALBUM_NAME)
                assetCollectionPlaceholder = createAlbumRequest.placeholderForCreatedAssetCollection
                }, completionHandler: { success, error in
                    
                    if (success) {
                        let collectionFetchResult = PHAssetCollection.fetchAssetCollections(withLocalIdentifiers: [assetCollectionPlaceholder.localIdentifier], options: nil)
                        print(collectionFetchResult)
                        albumFound(collectionFetchResult.firstObject!)
                    }
            })
        }
    }
}

// when use photo pressed, save it to disk (create identity folder)
// fetch last photo on folder
