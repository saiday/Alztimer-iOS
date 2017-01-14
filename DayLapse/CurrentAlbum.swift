//
//  CurrentAlbum.swift
//  DayLapse
//
//  Created by Saiday on 11/9/16.
//  Copyright © 2016 saiday. All rights reserved.
//

import Foundation

enum Album {
    case existingAlbum(name: String, photosCount: Int, lastModified: Date)
    case newAblum(name: String)
    
    func getName() -> String {
        switch self {
        case .existingAlbum(let name, _, _):
            return name
        case .newAblum(let name):
            return name
        }
    }
    
    func getReadableDate() -> String {
        switch self {
        case .existingAlbum(_, _, let date):
            let formatter = DateFormatter()
            formatter.dateStyle = .long
            formatter.timeStyle = .none
            
            return formatter.string(from: date)
        default:
            return "none"
        }
    }
}
