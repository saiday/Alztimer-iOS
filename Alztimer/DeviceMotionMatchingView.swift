//
//  DeviceMotionMatchingView.swift
//  DayLapse
//
//  Created by Saiday on 2/12/17.
//  Copyright © 2017 saiday. All rights reserved.
//

import UIKit

import PureLayout

class DeviceMotionMatchingView: UIView {
    var gravityData: (Double, Double, Double) = (0, 0, 0)
    var originGravityData: GravityData?
    weak var oval1: CAShapeLayer!
    weak var oval2: CAShapeLayer!
    weak var oval3: CAShapeLayer!

    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupSubviews()
        initCustomViews()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func draw(_ rect: CGRect) {
        drawRingFittingInsideView()
    }
    
    func drawRingFittingInsideView() -> () {
        let minSize: CGFloat = min(bounds.size.width, bounds.size.height)
        let origin: CGFloat = minSize / 2
        let quarterSize: CGFloat = minSize / 4
        let lineWidth: CGFloat = 1


        if let data = originGravityData {
            self.oval1.path = ovalPath(arcCenter: CGPoint(x: axisValueTransform(old: CGFloat(gravityData.0 - data.x), max: minSize), y: origin), radius: CGFloat(quarterSize - (lineWidth / 2)))
            self.oval2.path = ovalPath(arcCenter: CGPoint(x: origin, y: axisValueTransform(old: CGFloat(gravityData.1 - data.y), max: minSize)), radius: CGFloat(quarterSize - (lineWidth / 2)))
            self.oval3.path = ovalPath(arcCenter: CGPoint(x: origin, y: origin), radius: (quarterSize - (lineWidth / 2)) * CGFloat((gravityData.2 - data.z + 1)))
        }
    }
    
    func axisValueTransform(old: CGFloat, max: CGFloat) -> CGFloat {
        // -1 ... 1 -> 0 ... max
        let average = max / 2
        let new = (old + 1) * average
        return new
    }
    
    func ovalPath(arcCenter: CGPoint, radius: CGFloat) -> CGPath {
        let circlePath = UIBezierPath(
            arcCenter: arcCenter,
            radius: radius,
            startAngle: CGFloat(0),
            endAngle: CGFloat(M_PI * 2),
            clockwise: true)
        
        return circlePath.cgPath
    }
    
    func setupSubviews() {
        let lineWidth: CGFloat = 1

        let oval1 = CAShapeLayer()
        oval1.fillColor = UIColor(red: 1, green: 0, blue: 0, alpha: 0.5).cgColor
        oval1.strokeColor = UIColor.red.cgColor
        oval1.lineWidth = lineWidth
        
        let oval2 = CAShapeLayer()
        oval2.fillColor = UIColor(red: 0, green: 1, blue: 0, alpha: 0.5).cgColor
        oval2.strokeColor = UIColor.green.cgColor
        oval2.lineWidth = lineWidth
        
        let oval3 = CAShapeLayer()
        oval3.fillColor = UIColor(red: 0, green: 0, blue: 1, alpha: 0.5).cgColor
        oval3.strokeColor = UIColor.blue.cgColor
        oval3.lineWidth = lineWidth
        
        layer.addSublayer(oval1)
        layer.addSublayer(oval2)
        layer.addSublayer(oval3)
        
        self.oval1 = oval1
        self.oval2 = oval2
        self.oval3 = oval3
    }
    
    func initCustomViews() {
        self.backgroundColor = UIColor.clear
    }
}
