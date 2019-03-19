//
//  LoadIndicatorView.swift
//  Test
//
//  Created by Дмитрий on 28.02.2018.
//  Copyright © 2018 Gulyagin Dmitry. All rights reserved.
//

import UIKit

/// Анимированый индикатор загрузки ввиде спасательного круга
@IBDesignable
class LoadIndicatorView: UIView {
    @IBInspectable var lifebuoyRatio: CGFloat = 0.4
    @IBInspectable var lifebuoyColor: UIColor = UIColor.white
    @IBInspectable var lifebuoyMarkingRatio: CGFloat = 0.08
    @IBInspectable var lifebuoyMarkingColor: UIColor = #colorLiteral(red: 0.8789684971, green: 0.2757321082, blue: 0.2435907531, alpha: 1)
    
    private let lifebuoyLayer = CAShapeLayer()
    private let lifebuoyMarkingLayer = CAShapeLayer()
    
    var isAnimating: Bool = false
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInit()
    }
    
    // Функция awakeFromNib() не будет вызываться в IB, весь код единоразово влияющий на внешний вид этого UIView писать здесь:
    private func commonInit() {
        self.layer.addSublayer(lifebuoyLayer)
        lifebuoyLayer.addSublayer(lifebuoyMarkingLayer)
        NotificationCenter.default.addObserver(self, selector: #selector(appMovedToForeground), name: UIApplication.willEnterForegroundNotification, object: nil)
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self, name: UIApplication.willEnterForegroundNotification, object: nil)
    }
        
    @objc private func appMovedToForeground() {
        startAnimating()
    }
    
    override func draw(_ rect: CGRect) {
        // constants
        let radius =  min(rect.height / 2, rect.width / 2)
        
        // lifebuoy
        let lifebuoyPath = UIBezierPath()
        lifebuoyPath.addArc(withCenter: CGPoint(x: rect.midX, y: rect.midY),
                            radius: lifebuoyRatio * radius,
                            startAngle: 0, endAngle: CGFloat.pi * 2, clockwise: true)
        lifebuoyPath.move(to: CGPoint(x: rect.midX + radius, y: rect.midY))
        lifebuoyPath.addArc(withCenter: CGPoint(x: rect.midX, y: rect.midY),
                            radius: radius,
                            startAngle: CGFloat.pi * 2, endAngle: 0, clockwise: false)
        
        lifebuoyLayer.frame = rect
        lifebuoyLayer.fillColor = lifebuoyColor.cgColor
        lifebuoyLayer.path = lifebuoyPath.cgPath
        
        let lifebuoyMarkingPath = UIBezierPath()
        // Marking for lifebuoy
        for segment in 0 ..< 4 {
            let startAngel = CGFloat(segment) * CGFloat.pi / 2 - CGFloat.pi * lifebuoyMarkingRatio
            let endAngel = CGFloat(segment) * CGFloat.pi / 2 + CGFloat.pi * lifebuoyMarkingRatio
            
            lifebuoyMarkingPath.move(to: CGPoint(x: cos(startAngel) * lifebuoyRatio * radius + rect.midX,
                                                 y: sin(startAngel) * lifebuoyRatio * radius + rect.midY))
            lifebuoyMarkingPath.addArc(withCenter: CGPoint(x: rect.midX, y: rect.midY),
                                       radius: lifebuoyRatio * radius,
                                       startAngle: startAngel, endAngle: endAngel, clockwise: true)
            lifebuoyMarkingPath.addArc(withCenter: CGPoint(x: rect.midX, y: rect.midY),
                                       radius: radius,
                                       startAngle: endAngel, endAngle: startAngel, clockwise: false)
            lifebuoyMarkingPath.addLine(to: CGPoint(x: cos(startAngel) * lifebuoyRatio * radius + rect.midX,
                                                    y: sin(startAngel) * lifebuoyRatio * radius + rect.midY))
        }
        lifebuoyMarkingLayer.frame = rect
        lifebuoyMarkingLayer.fillColor = lifebuoyMarkingColor.cgColor
        lifebuoyMarkingLayer.path = lifebuoyMarkingPath.cgPath
    }
    
    private func lifebuoyAnimations() -> CAAnimationGroup {
        let rotationAnimation = CABasicAnimation(keyPath: "transform.rotation")
        rotationAnimation.fromValue = 0
        rotationAnimation.toValue = CGFloat.pi * 4
        rotationAnimation.timingFunction = CAMediaTimingFunction(name: CAMediaTimingFunctionName.linear)
        
        let scaleInAnimation = CABasicAnimation(keyPath: "transform.scale")
        scaleInAnimation.fromValue = 1
        scaleInAnimation.toValue = 0.6
        scaleInAnimation.duration = 2
        scaleInAnimation.timingFunction = CAMediaTimingFunction(name: CAMediaTimingFunctionName.easeIn)
        
        let scaleOutAnimation = CABasicAnimation(keyPath: "transform.scale")
        scaleOutAnimation.fromValue = scaleInAnimation.toValue
        scaleOutAnimation.toValue = scaleInAnimation.fromValue
        scaleOutAnimation.duration = 1
        scaleOutAnimation.beginTime = scaleInAnimation.duration
        scaleOutAnimation.timingFunction = CAMediaTimingFunction(name: CAMediaTimingFunctionName.easeOut)
        
        let groupAnimation = CAAnimationGroup()
        groupAnimation.animations = [rotationAnimation, scaleInAnimation, scaleOutAnimation]
        groupAnimation.duration = 3
        groupAnimation.repeatCount = .infinity
        groupAnimation.isRemovedOnCompletion = true
        
        return groupAnimation
    }
    
    func startAnimating() {
        isAnimating = true
        lifebuoyLayer.removeAnimation(forKey: "mainAnimation")
        lifebuoyLayer.add(self.lifebuoyAnimations(), forKey: "mainAnimation")
    }
    
    func stopAnimating() {
        isAnimating = false
        lifebuoyLayer.removeAnimation(forKey: "mainAnimation")
    }
}

