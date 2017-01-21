//
//  DeviceMotionRecorder.swift
//  DayLapse
//
//  Created by Saiday on 1/24/17.
//  Copyright © 2017 saiday. All rights reserved.
//

import UIKit

import CoreMotion

class DeviceMotionRecorder: NSObject {
    let motionManager = CMMotionManager()
    
    func enableMotionManager(_ enable: Bool) {
        if enable {
            motionManager.deviceMotionUpdateInterval = 0.01
            motionManager.startDeviceMotionUpdates()
        } else {
            motionManager.stopDeviceMotionUpdates()
        }
    }

}
