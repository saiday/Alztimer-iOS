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
}
