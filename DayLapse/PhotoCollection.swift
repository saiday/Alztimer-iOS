//
//  PhotoCollection.swift
//  
//
//  Created by Saiday on 5/29/17.
//
//

import UIKit

struct PhotoCollection {
    var uid: String?
    var name: String
    var photosCount: Int = 0
    var createdDate: Date?
    var lastModifiedDate: Date?
    var latestPhoto: UIImage?
    var thumbnails: [UIImage]?
    var gravityDate: GravityData?
    
    init(uid: String, name: String, photosCount: Int, createdDate: Date, lastModifiedDate: Date, latestPhoto: UIImage, thumbnails: [UIImage]?, gravityData: GravityData?) {
        self.uid = uid
        self.name = name
        self.photosCount = photosCount
        self.createdDate = createdDate
        self.lastModifiedDate = lastModifiedDate
        self.latestPhoto = latestPhoto
        self.thumbnails = thumbnails
        self.gravityDate = gravityData
    }
    
    init(name: String) {
        self.name = name
    }
    
    mutating func alertUid(_ uid: String) -> PhotoCollection {
        self.uid = uid
        return self
    }
}
