//
//  Dollar.swift
//  iOSGesturizer
//
//  Created by Kuanysh on 2/8/18.
//  Copyright © 2018 Kuanysh. All rights reserved.
//

import UIKit

class Dollar{
    var x,y: Int!
    var state: Int!
    
    var key = Int(-1)
    
    var gesture = true
    var points = [CGPoint]()
    
    var recognizer: Recognizer!
    var result = Result(score: 0, index: -1, theta: Utils.lastTheta)
    
    var active = true
    
    var gestureSet: Int!
    
    init(){
        recognizer = Recognizer()
    }
    
    public func getPoints() -> [CGPoint] {
        return points
    }
    
    public func addPoint(x: Int, y: Int) {
        if (active){
            points.append(CGPoint(x: x, y: y))
        }
    }
    
    public func recognize() {
        
        if (!active){
            return
        }
        
        if (points.count == 0){
            return
        }
        
        result = recognizer.Recognize(points: points)
        
    }
    
    public func predict() -> [Result]{
        if (!active){
            return [Result]()
        }
        
        if (points.count == 0){
            return [Result]()
        }
        return recognizer.Predict(points: points)
    }
    
    
    public func clear() {
        points.removeAll()
        result.Score = 0
        result.Index = -1
    }
}
