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

class ViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate, CreateCollectionColumnDelegate, ExistingCollectionColumnDelegate {
    var currentAlbum: Album?
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
    
    lazy var navigationBar: UINavigationBar = {
        let navigationBar = UINavigationBar(forAutoLayout: ())
        navigationBar.autoSetDimension(.height, toSize: 64)
        navigationBar.topItem?.title = "Test"
        return navigationBar
    }()
    
    lazy var scrollView: UIScrollView = {
        let scrollView = UIScrollView(forAutoLayout: ())
        scrollView.contentInset = UIEdgeInsets(top: 64, left: 0, bottom: 0, right: 0)
        return scrollView;
    }()
    
    // MARK: entry point
    override func viewDidLoad() {
        super.viewDidLoad()
        setupSubviews()
        initCustomViews()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        listAlbums(queryExistAlbums())
    }
    
    func setupSubviews() {
        view.addSubview(navigationBar)
        navigationBar.autoPinEdgesToSuperviewEdges(with: .zero, excludingEdge: .bottom)
        
        view.addSubview(scrollView)
        scrollView.autoPinEdgesToSuperviewEdges(with: .zero, excludingEdge: .bottom)
        
        stackView.backgroundColor = UIColor.black
        scrollView.addSubview(stackView)
        stackView.autoPinEdgesToSuperviewEdges(with: .zero)
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
        
        stackView.addArrangedSubview(button)
        stackView.addArrangedSubview(view1)
        stackView.addArrangedSubview(label)
    }
    
    func queryExistAlbums() -> [Album] {
        let fetchOptions = PHFetchOptions()
        let albumNamePrefix = kCUSTOM_ALBUM_NAME + "-"
        let predicate = NSPredicate(format: "title BEGINSWITH[c] %@", albumNamePrefix)
        fetchOptions.predicate = predicate
        let collection = PHAssetCollection.fetchAssetCollections(with: .album, subtype: .any, options: fetchOptions)
        
        
        var albums: [Album] = []
        
        collection.enumerateObjects({ (albumAsset, start, stop) in
            if let fullName = albumAsset.localizedTitle {
                let photoAsset = PHAsset.fetchAssets(in: albumAsset, options: nil)
                var albumLastModified = Date.distantPast
                photoAsset.enumerateObjects({ (photo, count, stop) in
                    if let photoDate = photo.creationDate, photoDate > albumLastModified {
                        albumLastModified = photoDate
                    }
                })
                let name = fullName.substring(from: albumNamePrefix.index(albumNamePrefix.startIndex, offsetBy: albumNamePrefix.characters.count))
                let album = Album.existingAlbum(name: name, photosCount: albumAsset.estimatedAssetCount, lastModified: albumLastModified)
                albums.append(album)
            }
        })
        
        return albums
    }
    
    func listAlbums(_ albums: [Album]) {
        for view in stackView.arrangedSubviews where view is ExistingCollectionColumn {
            stackView.removeArrangedSubview(view)
            view.removeFromSuperview()
        }
        
        for album in albums {
            let view = ExistingCollectionColumn(album: album)
            view.delegate = self
            stackView.addArrangedSubview(view)
        }
    }
    
    func launchCamera() {
        self.imagePickerController.delegate = self
        if self.imagePickerController.isBeingPresented {
            self.imagePickerController.dismiss(animated: false, completion: nil)
        }
        self.present(self.imagePickerController, animated: true, completion: nil)
    }
    
    // MARK: CreateCollectionColumnDelegate
    func createColllectionDidTapped() {
        let alert = UIAlertController(title: "New Collection", message: "name?", preferredStyle: .alert)
        alert.addTextField { (textField) in
            textField.placeholder = "Collection name"
        }
        let submitAction = UIAlertAction(title: "OK", style: .default) { [unowned self](action) in
            let text = alert.textFields?.first?.text
            if let name = text, name.characters.count > 0 {
                self.currentAlbum = .newAblum(name: name)
                self.launchCamera()
            }
        }
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        alert.addAction(submitAction)
        alert.addAction(cancelAction)
        self.present(alert, animated: true, completion: nil)
    }
    
    // MARK: ExistingCollectionColumnDelegate
    func existingCollectionColumnDidTapped(album: Album) {
        self.currentAlbum = album
        launchCamera()
    }
    
    func existingCollectionColumnPhotosDidTapped(image: UIImage, album: Album) {
        // not yet
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
        guard let album = self.currentAlbum else {
            return
        }
        
        accessDayLapseAlbum(album: album, albumFound: { (album) in
            PHPhotoLibrary.shared().performChanges({
                let assetRequest = PHAssetChangeRequest.creationRequestForAsset(from: image)
                let placeholder = assetRequest.placeholderForCreatedAsset
                let albumChangeRequest = PHAssetCollectionChangeRequest(for: album)
                let assets: NSArray = [placeholder!]
                albumChangeRequest!.addAssets(assets)
                }, completionHandler: { (success, error) in
                    DispatchQueue.main.async {
                        completion(error)
                    }
            })
        })
    }
    
    func accessDayLapseAlbum(album: Album, albumFound: @escaping (PHAssetCollection) -> Void) {
        let fetchOptions = PHFetchOptions()
        let albumName = kCUSTOM_ALBUM_NAME + "-" + album.getName()
        let predicate = NSPredicate(format: "title = %@", albumName)
        fetchOptions.predicate = predicate
        let collection = PHAssetCollection.fetchAssetCollections(with: .album, subtype: .any, options: fetchOptions)
        
        if let album = collection.firstObject {
            albumFound(album)
        } else {
            // If not found, create new album
            var assetCollectionPlaceholder = PHObjectPlaceholder()
            PHPhotoLibrary.shared().performChanges({
                let createAlbumRequest = PHAssetCollectionChangeRequest.creationRequestForAssetCollection(withTitle: albumName)
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
