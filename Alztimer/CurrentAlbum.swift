////
////  CurrentAlbum.swift
////  DayLapse
////
////  Created by Saiday on 11/9/16.
////  Copyright © 2016 saiday. All rights reserved.
////
//
//import Foundation
//
//import UIKit
//
//enum Album {
//    case existingAlbum(uid: String, name: String, photosCount: Int, dates: (created: Date, lastModified: Date), latestPhoto: UIImage?, photosThumbnail: [UIImage], gravityData: (Double, Double, Double))
//    case newAblum(name: String)
//    
//    func name() -> String {
//        switch self {
//        case .existingAlbum(_, let name, _, _, _, _, _):
//            return name
//        case .newAblum(let name):
//            return name
//        }
//    }
//    
//    func createdDate() -> String {
//        switch self {
//        case .existingAlbum(_, _, _, let (created, _), _, _, _):
//            let formatter = DateFormatter()
//            formatter.dateStyle = .long
//            formatter.timeStyle = .none
//            
//            return formatter.string(from: created)
//        default:
//            return "none"
//        }
//    }
//    
//    func lastModifiedDate() -> String {
//        switch self {
//        case .existingAlbum(_, _, _, let (_, lastModified), _, _, _):
//            let formatter = DateFormatter()
//            formatter.dateStyle = .long
//            formatter.timeStyle = .none
//            
//            return formatter.string(from: lastModified)
//        default:
//            return "none"
//        }
//    }
//    
//    func latestPhotoImage() -> UIImage? {
//        switch self {
//        case .existingAlbum(_, _, _, _, let photo, _, _):
//            return photo
//        default:
//            return nil
//        }
//    }
//    
//    func thumbnails() -> [UIImage] {
//        switch self {
//        case .existingAlbum(_, _, _, _, _, let thumbnails, _):
//            return thumbnails
//        default:
//            return []
//        }
//    }
//    
//    func uid() -> String {
//        switch self {
//        case .existingAlbum(let uid, _, _, _, _, _, _):
//            return uid
//        default:
//            return ""
//        }
//    }
//    
//    func gravityData() -> (Double, Double, Double) {
//        switch self {
//        case .existingAlbum(_, _, _, _, _, _, let gravity):
//            return gravity
//        default:
//            return (0, 0, 0)
//        }
//    }
//    
//    func photosCount() -> Int {
//        switch self {
//        case .existingAlbum(_, _, let count, _, _, _, _):
//            return count
//        default:
//            return 0
//        }
//    }
//
//    func dates() -> (Date, Date) {
//        switch self {
//        case .existingAlbum(_, _, _, let dates, _, _, _):
//            return dates
//        default:
//            return (Date(timeIntervalSince1970: 0), Date(timeIntervalSince1970: 0))
//        }
//    }
//    
//    func alertUid(uid: String) -> Album {
//        return Album.existingAlbum(uid: uid, name: name(), photosCount: photosCount(), dates: dates(), latestPhoto: latestPhotoImage(), photosThumbnail: thumbnails(), gravityData: gravityData())
//    }
//}
