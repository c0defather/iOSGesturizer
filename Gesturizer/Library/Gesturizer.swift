//
//  Gesturizer.swift
//  Gesturizer
//
//  Created by Kuanysh on 2/8/18.
//  Copyright © 2018 Kuanysh. All rights reserved.
//

import UIKit

public class Gesturizer {
    // MARK: Constants
    
    static let DEFAULT_TOUCH_PRESSURE = 0.8
    static let DEFAULT_BRUSH_SIZE: CGFloat = 2.0
    static let DEFAULT_OPACITY: CGFloat = 1.0
    static let DEFAULT_COLORS = [
        UIColor(red: 186.0/255, green: 34.0/255, blue: 34.0/255, alpha: 1.0),
        UIColor(red: 27.0/255, green: 149.0/255, blue: 27.0/255, alpha: 1.0),
        UIColor(red: 24.0/255, green: 14.0/255, blue: 197.0/255, alpha: 1.0)
    ]
    
    // MARK: Properties
    
    var view: UIImageView!
    var brushSize: CGFloat = DEFAULT_BRUSH_SIZE
    var colors: [UIColor] = DEFAULT_COLORS
    var dollar: Dollar!
    
    var lastPoint = CGPoint.zero // Last point touched
    var lastDrawedPoint = CGPoint.zero // Last point drawed
    var lastPointForce = CGPoint.zero // First point touched with force
    
    var userPathForce = [CGPoint]() // Touch path with force
    var forceTouch = false
    
    // MARK: Constructors
    public init (view: UIImageView) {
        self.view = view
        self.dollar = Dollar() // Initialize 1$
    }
    
    // MARK: Methods
    func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        if let touch = touches.first { // If touches just began
            lastPoint = touch.location(in: self.view)
        }
    }
    
    func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        if let touch = touches.first {
            let currentPoint = touch.location(in: self.view)
            if (touch.force/touch.maximumPossibleForce > 0.5 || userPathForce.count > 2){
                if (!forceTouch) {
                    userPathForce.removeAll()
                    dollar.clear()
                    forceTouch = true
                }
                dollar.addPoint(x: Int(currentPoint.x), y: Int(currentPoint.y))
                
                if (lastPointForce == CGPoint.zero){
                    lastPointForce = currentPoint
                }
                
                if (dollar.points.count > 2){
                    self.view.image = nil
                    let results = dollar.predict()
                    if (results.count > 0) {
                        for i in 0...results.count-1{
                            let curColor = colors[i]
                            let res = results[i]
                            let points = dollar.recognizer.RawTemplates[res.Index]
                            drawPoints(points,color:curColor, strokeSize: self.brushSize*CGFloat(res.Score)*CGFloat(res.Score)*CGFloat(2)*CGFloat(5-results.count))
                        }
                        lastDrawedPoint = currentPoint
                    }
                }
                userPathForce.append(currentPoint)
            }else{
                forceTouch = false
                self.view.image = nil
                lastPoint = CGPoint.zero
                lastDrawedPoint = CGPoint.zero
                lastPointForce = CGPoint.zero
            }
            lastPoint = currentPoint
        }
    }
    func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.image = nil
        dollar.recognize()
        let res = dollar.result
        if (res.Score as Double! > 0.8) {
            
        } else {
            
        }
        userPathForce.removeAll()
        dollar.clear()
        
        lastPoint = CGPoint.zero
        lastDrawedPoint = CGPoint.zero
        lastPointForce = CGPoint.zero
    }
    func drawPoints(_ points: [CGPoint], color: UIColor, strokeSize: CGFloat){
        UIGraphicsBeginImageContext(self.view.frame.size)
        self.view.image?.draw(in: CGRect(x: 0, y: 0, width: self.view.frame.width, height: self.view.frame.height))
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
        
        self.view.image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
    }
    
    func drawLines(_ fromPoint:CGPoint,toPoint:CGPoint, color: UIColor) {
        UIGraphicsBeginImageContext(self.view.frame.size)
        self.view.image?.draw(in: CGRect(x: 0, y: 0, width: self.view.frame.width, height: self.view.frame.height))
        let context = UIGraphicsGetCurrentContext()
        
        context?.move(to: CGPoint(x: fromPoint.x, y: fromPoint.y))
        context?.addLine(to: CGPoint(x: toPoint.x, y: toPoint.y))
        
        context?.setBlendMode(CGBlendMode.normal)
        context?.setLineCap(CGLineCap.round)
        context?.setLineWidth(brushSize)
        context?.setStrokeColor(color.cgColor)
        
        context?.strokePath()
        
        self.view.image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
    }
}
extension UIColor {
    func lighter(by percentage:CGFloat=30.0) -> UIColor? {
        return self.adjust(by: abs(percentage) )
    }
    
    func darker(by percentage:CGFloat=30.0) -> UIColor? {
        return self.adjust(by: -1 * abs(percentage) )
    }
    
    func adjust(by percentage:CGFloat=30.0) -> UIColor? {
        var r:CGFloat=0, g:CGFloat=0, b:CGFloat=0, a:CGFloat=0;
        if(self.getRed(&r, green: &g, blue: &b, alpha: &a)){
            return UIColor(red: min(r + percentage/100, 1.0),
                           green: min(g + percentage/100, 1.0),
                           blue: min(b + percentage/100, 1.0),
                           alpha: a)
        }else{
            return nil
        }
    }
}
