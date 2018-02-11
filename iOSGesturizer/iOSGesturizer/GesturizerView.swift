//
//  Gesturizer.swift
//  Gesturizer
//
//  Created by Kuanysh on 2/8/18.
//  Copyright © 2018 Kuanysh. All rights reserved.
//

import UIKit

public class GesturizerView: UIImageView {
    // MARK: Constants
    
    static let TRAINING_MODE_ACTIVATION_TIME = 1.0
    static let DEFAULT_TOUCH_PRESSURE = 0.8
    static let DEFAULT_BRUSH_SIZE: CGFloat = 10.0
    static let DEFAULT_OPACITY: CGFloat = 1.0
    static let DEFAULT_COLORS = [
        UIColor(red: 186.0/255, green: 34.0/255, blue: 34.0/255, alpha: 1.0),
        UIColor(red: 27.0/255, green: 149.0/255, blue: 27.0/255, alpha: 1.0),
        UIColor(red: 24.0/255, green: 14.0/255, blue: 197.0/255, alpha: 1.0)
    ]
    
    // MARK: Properties
    public var gestureHandler: (_ index: Int) -> () = {_ in
        print(index)
    }
    var brushSize: CGFloat = DEFAULT_BRUSH_SIZE
    var colors: [UIColor] = DEFAULT_COLORS
    var dollar = Dollar()
    public var names: [String] = ["Cut", "Copy", "Paste"]
    var timer = Timer()
    var time = 0.0
    
    var lastPoint = CGPoint.zero // Last point touched
    var lastPointForce = CGPoint.zero // First point touched with force
    
    var userPathForce = [CGPoint]() // Touch path with force
    var forceTouch = false
    
    // MARK: Constructors
   
    public init() {
        super.init(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height))
        timer = Timer.scheduledTimer(timeInterval: 0.01, target: self, selector: #selector(runTimedCode), userInfo: nil, repeats: true)
    }
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    // MARK: Methods
    
    func touchesBegan(_ touches: Set<UITouch>) {
        if let touch = touches.first { // If touches just began
            lastPoint = touch.location(in: self)
        }
    }
    
    func touchesMoved(_ touches: Set<UITouch>) {
        
        if let touch = touches.first {
            let currentPoint = touch.location(in: self)
            if (touch.force/touch.maximumPossibleForce > 0.5 || userPathForce.count > 0){
                if (!forceTouch) {
                    userPathForce.removeAll()
                    dollar.clear()
                    forceTouch = true
                    let generator = UIImpactFeedbackGenerator(style: .medium)
                    generator.impactOccurred()
                }
                dollar.addPoint(x: Int(currentPoint.x), y: Int(currentPoint.y))
                if (lastPointForce == CGPoint.zero){
                    lastPointForce = currentPoint
                }
                
                if (dollar.points.count > 1){
                    self.image = nil
                    for view in self.subviews{
                        view.removeFromSuperview()
                    }
                    let results = dollar.predict()
                    if (results.count > 0) {
                        for i in 0...results.count-1{
                            let res = results[i]
                            let curColor = colors[res.Index]
                            let points = dollar.recognizer.RawTemplates[res.Index]
                            if (time > GesturizerView.TRAINING_MODE_ACTIVATION_TIME) {
                                drawPoints(points, text: names[res.Index], color:curColor, strokeSize: self.brushSize*CGFloat(res.Score)*CGFloat(res.Score))
                            }
                        }
                    }
                }
                userPathForce.append(currentPoint)
            }else{
                forceTouch = false
                self.image = nil
                lastPoint = CGPoint.zero
                lastPointForce = CGPoint.zero
            }
            lastPoint = currentPoint
        }
    }
    func touchesEnded(_ touches: Set<UITouch>) {
        self.image = nil
        for view in self.subviews{
            view.removeFromSuperview()
        }
        dollar.recognize()
        let res = dollar.result
        if (res.Score as Double! > 0.8) {
            self.gestureHandler(res.Index)
        } else {
            
        }
        userPathForce.removeAll()
        dollar.clear()
        lastPoint = CGPoint.zero
        lastPointForce = CGPoint.zero
    }
    func drawPoints(_ points: [CGPoint], text: String, color: UIColor, strokeSize: CGFloat){
        UIGraphicsBeginImageContext(self.frame.size)
        self.image?.draw(in: CGRect(x: 0, y: 0, width: self.frame.width, height: self.frame.height))
        let context = UIGraphicsGetCurrentContext()
        let deltaX = points[0].x - lastPointForce.x
        let deltaY = points[0].y - lastPointForce.y
        var length = 0.0
        if (userPathForce.count > 1){
            for i in 1...userPathForce.count-1{
                length += Utils.Distance(p1: userPathForce[i-1], p2: userPathForce[i])
            }
        }
        
        var l = 0.0
        var t = 1
        while (l < length && t<points.count-1){
            l += Utils.Distance(p1: points[t], p2: points[t+1])
            context?.move(to: CGPoint(x: points[t-1].x-deltaX, y: points[t-1].y-deltaY))
            context?.addLine(to: CGPoint(x: points[t].x-deltaX, y: points[t].y-deltaY))
            t += 1
        }
        context?.setBlendMode(CGBlendMode.normal)
        context?.setLineCap(CGLineCap.round)
        context?.setLineWidth(strokeSize)
        let newc = color.darker()
        context?.setStrokeColor((newc?.cgColor)!)
        
        context?.strokePath()
        
        for i in t...points.count-1{
            context?.move(to: CGPoint(x: points[i-1].x-deltaX, y: points[i-1].y-deltaY))
            context?.addLine(to: CGPoint(x: points[i].x-deltaX, y: points[i].y-deltaY))
        }
        context?.setBlendMode(CGBlendMode.normal)
        context?.setLineCap(CGLineCap.round)
        context?.setLineWidth(strokeSize)
        context?.setStrokeColor(color.cgColor)
        context?.strokePath()
        
        self.image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        let last = points.last!
        let label = UILabel(frame:CGRect(origin: CGPoint(x: last.x-deltaX-25,y :last.y-deltaY-10), size: CGSize(width: 50, height: 20)))
        label.text = text
        label.font = UIFont.systemFont(ofSize: 14.0)
        label.layer.borderWidth = 2.0
        label.layer.backgroundColor = UIColor.white.cgColor
        label.layer.cornerRadius = 5.0
        label.layer.borderColor = color.cgColor
        label.textColor = color
        label.textAlignment = NSTextAlignment.center
        self.addSubview(label)
    }
    
    @objc public func runTimedCode() {
        if (forceTouch) {
            time += 0.01
        } else {
            time = 0.0
        }
    }
}

