//
//  CurrentAlbum.swift
//  DayLapse
//
//  Created by Saiday on 11/9/16.
//  Copyright © 2016 saiday. All rights reserved.
//

import Foundation

import UIKit

enum Album {
    case existingAlbum(name: String, photosCount: Int, lastModified: Date, latestPhoto: UIImage, photosThumbnail: [UIImage])
    case newAblum(name: String)
    
    func getName() -> String {
        switch self {
        case .existingAlbum(let name, _, _, _, _):
            return name
        case .newAblum(let name):
            return name
        }
    }
    
    func getReadableDate() -> String {
        switch self {
        case .existingAlbum(_, _, let date, _, _):
            let formatter = DateFormatter()
            formatter.dateStyle = .long
            formatter.timeStyle = .none
            
            return formatter.string(from: date)
        default:
            return "none"
        }
    }
    
    func getLatestPhotoImage() -> UIImage? {
        switch self {
        case .existingAlbum(_, _, _, let photo, _):
            return photo
        default:
            return nil
        }
    }
}
