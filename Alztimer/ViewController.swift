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
import CoreMotion
import CoreData

extension ViewController {
}

class ViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate, CreateCollectionColumnDelegate, ExistingCollectionColumnDelegate {
    var currentCollection: PhotoCollection?
    var imagePickerContorller: UIImagePickerController?
    let deviceMotionRecorder = DeviceMotionRecorder()
    
    lazy var createAlbumView: UIView = { [unowned self] in
        let view = CreateCollectionColumn()
        view.delegate = self
        
        return view
        }()
    
    func setupNewImagePickerController(collection: PhotoCollection) -> UIImagePickerController {
        let imagePickerController = UIImagePickerController()
        imagePickerController.sourceType = .camera
        imagePickerController.showsCameraControls = false
        let cameraOverlayView = CameraOverlayView(frame: CGRect(x: 0, y: 0, width: self.view.bounds.width, height: self.view.bounds.height))
        deviceMotionRecorder.enableMotionManager(true)
        deviceMotionRecorder.delegate = cameraOverlayView
        cameraOverlayView.deviceMotionRecorder = deviceMotionRecorder
        cameraOverlayView.setOverlayImage(collection.latestPhoto)
        cameraOverlayView.lastGravityData = collection.gravityDate
        cameraOverlayView.imagePickerController = imagePickerController
        imagePickerController.cameraOverlayView = cameraOverlayView
        
        return imagePickerController
    }
    
    lazy var stackView: UIStackView = {
        let stackView = UIStackView(forAutoLayout: ())
        stackView.axis = .vertical
        stackView.distribution = .fillProportionally
        stackView.alignment = .fill
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
        return scrollView
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupSubviews()
        initCustomViews()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        listCollections(queryExistCollections())
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
        
        view.addSubview(createAlbumView)
        createAlbumView.autoSetDimension(.height, toSize: 50)
        createAlbumView.autoPinEdge(.top, to: .bottom, of: scrollView)
        createAlbumView.autoPinEdgesToSuperviewEdges(with: .zero, excludingEdge: .top)
    }
    
    func initCustomViews() {
        view.backgroundColor = UIColor.white
    }
    
    func queryExistCollections() -> [PhotoCollection] {
        let fetchOptions = PHFetchOptions()
        let albumNamePrefix = kCUSTOM_ALBUM_NAME + "-"
        let predicate = NSPredicate(format: "title BEGINSWITH[c] %@", albumNamePrefix)
        fetchOptions.predicate = predicate
        let collection = PHAssetCollection.fetchAssetCollections(with: .album, subtype: .any, options: fetchOptions)
        
        
        var collections: [PhotoCollection] = []
        
        collection.enumerateObjects({ [unowned self] (albumAsset, start, stop) in
            if let fullName = albumAsset.localizedTitle {
                let photoAsset = PHAsset.fetchAssets(in: albumAsset, options: nil)
                var albumLastModifiedDate = Date.distantPast
                var albumCreatedDate = Date.distantFuture
                var latestPhoto = UIImage()
                var photoThumbnails = [UIImage]()
                photoAsset.enumerateObjects({ (photo, count, stop) in
                    let thumbnail = self.fetchImageFromAsset(asset: photo, size: CGSize(width: 100, height: 100))
                    photoThumbnails.append(thumbnail)
                    
                    if let photoDate = photo.creationDate {
                        if photoDate > albumLastModifiedDate {
                            albumLastModifiedDate = photoDate
                            latestPhoto = self.fetchImageFromAsset(asset: photo, size: CGSize(width: 400, height: 300))
                        }
                        if photoDate < albumCreatedDate {
                            albumCreatedDate = photoDate
                        }
                    }
                })
                let name = String(fullName[albumNamePrefix.index(albumNamePrefix.startIndex, offsetBy: albumNamePrefix.count)...])
                let persistenContainer = (UIApplication.shared.delegate as! AppDelegate).persistentContainer
                let managedAlbum = ManagedAlbum.fetchManagedAlbum(persistenContainer: persistenContainer, localId: albumAsset.localIdentifier)
                let gravityData = managedAlbum?.gravityData()
                let collection = PhotoCollection(uid: albumAsset.localIdentifier, name: name, photosCount: albumAsset.estimatedAssetCount, createdDate: albumCreatedDate, lastModifiedDate: albumLastModifiedDate, latestPhoto: latestPhoto, thumbnails: photoThumbnails, gravityData: gravityData)
                collections.append(collection)
            }
        })
        
        return collections
    }
    
    func fetchImageFromAsset(asset: PHAsset, size: CGSize) -> UIImage {
        let manager = PHImageManager.default()
        let option = PHImageRequestOptions()
        var thumbnail = UIImage()
        option.isSynchronous = true
        manager.requestImage(for: asset, targetSize: size, contentMode: .aspectFit, options: option, resultHandler: {(result, info)->Void in
            thumbnail = result!
        })
        
        return thumbnail
    }
    
    func listCollections(_ collections: [PhotoCollection]) {
        for view in stackView.arrangedSubviews where view is ExistingCollectionColumn {
            stackView.removeArrangedSubview(view)
            view.removeFromSuperview()
        }
        
        for collection in collections {
            let view = ExistingCollectionColumn(collection: collection)
            view.delegate = self
            stackView.addArrangedSubview(view)
        }
    }
    
    func launchCamera() {
        if let collection = currentCollection {
            let imagePickerController = setupNewImagePickerController(collection: collection)
            imagePickerController.delegate = self
            
            if let previousImagePickerController = self.imagePickerContorller, previousImagePickerController.isBeingPresented {
                previousImagePickerController.dismiss(animated: false, completion: nil)
            }
            
            self.imagePickerContorller = imagePickerController
            self.present(imagePickerController, animated: true, completion: nil)
        }
    }
    
    // MARK: CreateCollectionColumnDelegate
    func createColllectionDidTapped() {
        let alert = UIAlertController(title: "New Collection", message: "name?", preferredStyle: .alert)
        alert.addTextField { (textField) in
            textField.placeholder = "Collection name"
        }
        let submitAction = UIAlertAction(title: "OK", style: .default) { [unowned self](action) in
            let text = alert.textFields?.first?.text
            if let name = text, name.count > 0 {
                self.currentCollection = PhotoCollection(name: name)
                self.launchCamera()
            }
        }
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        alert.addAction(submitAction)
        alert.addAction(cancelAction)
        self.present(alert, animated: true, completion: nil)
    }
    
    // MARK: ExistingCollectionColumnDelegate
    func existingCollectionShotTapped(collection: PhotoCollection) {
        self.currentCollection = collection
        launchCamera()
    }
    
    func existingCollectionColumnPhotosDidTapped(image: UIImage, collection: PhotoCollection) {
        // not yet
    }
    
    // MARK: ImagePickerControllerDelegate
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String: Any]) {
        picker.dismiss(animated: true, completion: nil)

        // TODO: store device motion
        let deviceMotion = deviceMotionRecorder.motionManager.deviceMotion
        let image = info[UIImagePickerControllerOriginalImage] as! UIImage
        photosAuthorizedStatus { [unowned self](authorized) in
            if authorized {
                self.savePhoto(image: image, deviceMotion: deviceMotion) { (error) in
                    if let err = error {
                        print(err)
                    }
                    
                }
            } else {
                // TODO: guide user got to app settings and dismiss
                let alert = UIAlertController(title: NSLocalizedString("We need your permission to accss photo library", comment: ""), message: "", preferredStyle: .alert)
                self.present(alert, animated: true, completion: nil)
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
    
    func savePhoto(image: UIImage, deviceMotion: CMDeviceMotion?, completion: @escaping (Error?) -> Void) {
        guard let currentCollection = self.currentCollection else {
            return
        }
        
        accessDayLapseAlbum(collection: currentCollection, albumFound: { (albumAsset, collection) in
            PHPhotoLibrary.shared().performChanges({
                let assetRequest = PHAssetChangeRequest.creationRequestForAsset(from: image)
                let placeholder = assetRequest.placeholderForCreatedAsset
                let albumChangeRequest = PHAssetCollectionChangeRequest(for: albumAsset)
                let assets: NSArray = [placeholder!]
                albumChangeRequest!.addAssets(assets)
                }, completionHandler: { (success, error) in
                    if success {
                        // store device motion data
                        let persistenContainer = (UIApplication.shared.delegate as! AppDelegate).persistentContainer
                        // TODO: create duplicate collection name and take shot will crash here
                        let fetchedAlbum = ManagedAlbum.fetchManagedAlbum(persistenContainer: persistenContainer, localId: collection.uid!)
                        let managedAlbum = fetchedAlbum ?? ManagedAlbum(context: persistenContainer.viewContext)
                        
                        let managedGravityData = ManagedDeviceMotionGravity(context: persistenContainer.viewContext)
                        managedGravityData.x = deviceMotion?.gravity.x ?? 0
                        managedGravityData.y = deviceMotion?.gravity.y ?? 0
                        managedGravityData.z = deviceMotion?.gravity.z ?? 0
                        managedAlbum.latestDeviceMotionGravity = managedGravityData
                        managedAlbum.localIdentifier = collection.uid
                        var coreDataError: RunTimeError?
                        do {
                            try managedAlbum.managedObjectContext?.save()
                        } catch {
                            print("save managedalbum error")
                            coreDataError = RunTimeError(debugMessage: "save managedalbum error")
                        }
                        
                        DispatchQueue.main.async {
                            completion(coreDataError)
                        }
                    } else {
                        DispatchQueue.main.async {
                            completion(error)
                        }
                    }
            })
        })
    }
    
    func accessDayLapseAlbum(collection: PhotoCollection, albumFound: @escaping (PHAssetCollection, PhotoCollection) -> Void) {
        if let collectionUID = collection.uid,
            let albumAsset = PHAssetCollection.fetchAssetCollections(withLocalIdentifiers: [collectionUID], options: nil).firstObject {
            albumFound(albumAsset, collection)
        } else {
            // If not found, create new album
            var collection = collection
            let albumName = kCUSTOM_ALBUM_NAME + "-" + collection.name
            var assetCollectionPlaceholder = PHObjectPlaceholder()
            
            PHPhotoLibrary.shared().performChanges({
                let createAlbumRequest = PHAssetCollectionChangeRequest.creationRequestForAssetCollection(withTitle: albumName)
                assetCollectionPlaceholder = createAlbumRequest.placeholderForCreatedAssetCollection
                }, completionHandler: { success, error in
                    if (success) {
                        let collectionFetchResult = PHAssetCollection.fetchAssetCollections(withLocalIdentifiers: [assetCollectionPlaceholder.localIdentifier], options: nil)
                        collection = collection.alertUid(assetCollectionPlaceholder.localIdentifier)
                        albumFound(collectionFetchResult.firstObject!, collection)
                    }
            })
        }
    }
}
