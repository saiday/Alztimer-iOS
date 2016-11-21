//
//  CurrentAlbum.swift
//  DayLapse
//
//  Created by Saiday on 11/9/16.
//  Copyright © 2016 saiday. All rights reserved.
//

import Foundation

enum CurrentAlbum {
    case none
    case album(name: String, photosCount: Int, lastModified: NSDate)
    
    func getName() -> String {
        switch self {
        case .none:
            return ""
        case .album(let name, _, _):
            return name
        }
    }
}
