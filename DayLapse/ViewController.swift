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

class ViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate, CreateCollectionColumnDelegate {
    var currentAlbum: CurrentAlbum = .none
    lazy var createCollectionView: UIView = { [unowned self] in
        let view = CreateCollectionColumn()
        view.delegate = self
        
        return view
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
    
    lazy var stackView: UIStackView = {
        let stackView = UIStackView(forAutoLayout: ())
        stackView.axis = .vertical
//        stackView.distribution = .equalSpacing
//        stackView.alignment = .center
        stackView.spacing = 30;
        return stackView
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        setupSubviews()
        initCustomViews()
    }
    
    func setupSubviews() {
        let scrollView = UIScrollView(forAutoLayout: ())
        view.addSubview(scrollView)
        scrollView.autoPinEdgesToSuperviewEdges(with: .zero, excludingEdge: .bottom)
        
        stackView.backgroundColor = UIColor.black
        scrollView.addSubview(stackView)
        stackView.autoCenterInSuperview()
        stackView.autoMatch(.width, to: .width, of: scrollView)
        stackView.autoMatch(.height, to: .height, of: scrollView)
        
        view.addSubview(createCollectionView)
        createCollectionView.autoSetDimension(.height, toSize: 50)
        createCollectionView.autoPinEdge(.top, to: .bottom, of: scrollView)
        createCollectionView.autoPinEdgesToSuperviewEdges(with: .zero, excludingEdge: .top)
    }
    
    func initCustomViews() {
        view.backgroundColor = UIColor.white
        
        let view1 = UIView()
        view1.backgroundColor = UIColor.blue
        
        let label = UILabel()
        label.numberOfLines = 0
        label.text = "this is a fucking testthis is a fucking testthis is a fucking testthis is a fucking test"
        
        let button = UIButton(type: .system)
        button.setTitle("test", for: .normal)
        
        // TODO: existing albums

        stackView.addArrangedSubview(button)
        stackView.addArrangedSubview(view1)
        stackView.addArrangedSubview(label)
    }
    
    func createColllectionDidTapped() {
        let alert = UIAlertController(title: "New Collection", message: "name?", preferredStyle: .alert)
        alert.addTextField { (textField) in
            textField.placeholder = "Collection name"
        }
        let submitAction = UIAlertAction(title: "OK", style: .default) { [unowned self](action) in
            let text = alert.textFields?.first?.text
            if let name = text, name.characters.count > 0 {
                self.currentAlbum = .album(name: name, photosCount: 0, lastModified: NSDate())
                self.imagePickerController.delegate = self
                self.present(self.imagePickerController, animated: true, completion: nil)
            }
        }
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        alert.addAction(submitAction)
        alert.addAction(cancelAction)
        self.present(alert, animated: true, completion: nil)
    }
    
    // MARK: ImagePickerControllerDelegate
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String: Any]) {
        print(info)
        let image = info[UIImagePickerControllerOriginalImage] as! UIImage
        photosAuthorizedStatus { [unowned self](authorized) in
            if authorized {
                self.savePhoto(image: image) { (error) in
                    if let err = error {
                        print(err)
                    }
                    
                    picker.dismiss(animated: true, completion: nil)
                }
            } else {
                print("no permission mdfk")
                // FIXME: this alert is persist on screen, bad UX
                self.imagePickerController.dismiss(animated: true, completion: { [unowned self] in
                    let alert = UIAlertController(title: NSLocalizedString("We need your permission to accss photo library", comment: ""), message: "", preferredStyle: .alert)
                    self.present(alert, animated: true, completion: nil)
                })
            }
        }
    }
    
    func photosAuthorizedStatus(completion: @escaping (Bool) -> Void) -> Void {
        let status = PHPhotoLibrary.authorizationStatus()
        if status == .notDetermined {
            PHPhotoLibrary.requestAuthorization({ (status) in
                completion(status == .authorized)
            })
        } else {
            completion(status == .authorized)
        }
    }
    
    func savePhoto(image: UIImage, completion: @escaping (Error?) -> Void) {
        accessDayLapseAlbum(albumFound: { (album) in
            PHPhotoLibrary.shared().performChanges({
                let assetRequest = PHAssetChangeRequest.creationRequestForAsset(from: image)
                let placeholder = assetRequest.placeholderForCreatedAsset
                let photosAsset = PHAsset.fetchAssets(in: album, options: nil)
                let albumChangeRequest = PHAssetCollectionChangeRequest(for: album, assets: photosAsset)
                let assets: NSArray = [placeholder!]
                albumChangeRequest!.addAssets(assets)
                }, completionHandler: { (success, error) in
                    DispatchQueue.main.async {
                        completion(error)
                    }
            })
        })
    }
    
    func accessDayLapseAlbum(albumFound: @escaping (PHAssetCollection) -> Void) {
        let fetchOptions = PHFetchOptions()
        fetchOptions.predicate = NSPredicate(format: "title = %@", kCUSTOM_ALBUM_NAME)
        let collection = PHAssetCollection.fetchAssetCollections(with: .album, subtype: .any, options: fetchOptions)
        
        if let album = collection.firstObject {
            albumFound(album)
        } else {
            // If not found, create new album
            var assetCollectionPlaceholder = PHObjectPlaceholder()
            PHPhotoLibrary.shared().performChanges({
                let createAlbumRequest = PHAssetCollectionChangeRequest.creationRequestForAssetCollection(withTitle: kCUSTOM_ALBUM_NAME)
                assetCollectionPlaceholder = createAlbumRequest.placeholderForCreatedAssetCollection
                }, completionHandler: { success, error in
                    if (success) {
                        let collectionFetchResult = PHAssetCollection.fetchAssetCollections(withLocalIdentifiers: [assetCollectionPlaceholder.localIdentifier], options: nil)
                        albumFound(collectionFetchResult.firstObject!)
                    }
            })
        }
    }
}

// fetch last photo on folder
