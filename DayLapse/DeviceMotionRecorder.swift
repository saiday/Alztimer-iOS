//
//  DeviceMotionRecorder.swift
//  DayLapse
//
//  Created by Saiday on 1/24/17.
//  Copyright © 2017 saiday. All rights reserved.
//

import UIKit

import CoreMotion

protocol DeviceMotionRecorderDelegate: class {
    func deviceMotionRecorderDidUpdate(gravityData: (Double, Double, Double))
}


class DeviceMotionRecorder: NSObject {
    weak var delegate: DeviceMotionRecorderDelegate?

    let motionManager = CMMotionManager()
    
    func enableMotionManager(_ enable: Bool) {
        if enable {
            motionManager.deviceMotionUpdateInterval = 0.01
            motionManager.startDeviceMotionUpdates(to: .main, withHandler: { [unowned self] (deviceMotion, error) in
                if let delegate = self.delegate {
                    var gravityData: (Double, Double, Double) = (0, 0, 0)
                    if let deviceMotion = deviceMotion {
                        gravityData.0 = deviceMotion.gravity.x
                        gravityData.1 = deviceMotion.gravity.y
                        gravityData.2 = deviceMotion.gravity.z
                    }
                    delegate.deviceMotionRecorderDidUpdate(gravityData: gravityData)
                }
            })
        } else {
            motionManager.stopDeviceMotionUpdates()
        }
    }

}
