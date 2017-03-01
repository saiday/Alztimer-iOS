//
//  RunTimeError.swift
//  DayLapse
//
//  Created by Saiday on 3/2/17.
//  Copyright © 2017 saiday. All rights reserved.
//

import Foundation

struct RunTimeError: Error, CustomDebugStringConvertible {
    var debugMessage: String
    
    public var debugDescription: String {
        return debugMessage
    }
}
