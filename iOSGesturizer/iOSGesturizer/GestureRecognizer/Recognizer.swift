//
//  Recognizer.swift
//  iOSGesturizer
//
//  Created by Kuanysh on 2/8/18.
//  Copyright © 2018 Kuanysh. All rights reserved.
//

import UIKit

public class Recognizer
{
    //
    // Recognizer class constants
    //
    public static let NumPoints = 16
    public static let SquareSize = 180.0
    let HalfDiagonal = 0.5 * sqrt(2*SquareSize*SquareSize)
    let AngleRange = 45.0
    let AnglePrecision = 2.0
    public static let Phi = 0.5 * (-1.0 + sqrt(5.0)) // Golden Ratio
    
    public var centroid = CGPoint(x: 0, y: 0)
    public var boundingBox = Rectangle(x: 0, y: 0, width: 0, height: 0)
    
    var bounds = [0, 0, 0, 0]
    
    var Templates = [Template]()
    var RawTemplates = [[CGPoint]]()
    
    init(){
        loadTemplatesDefault()
    }
    
    func loadTemplatesDefault() {
        for i in 0...2 {
            Templates.append(loadTemplate(array: TemplateData.DataRight[i]))
        }
    }
    
    func loadTemplate(array: [Double]) -> Template {
        return Template(points: loadArray(array: array));
    }
    
    func loadArray(array: [Double]) -> [CGPoint] {
        var  v = [CGPoint]()
        for i in 0...array.count-1{
            if (i%2==0){
                let p = CGPoint(x: array[i], y:array[i+1]);
                v.append(p);
            }
        }
        RawTemplates.append(v)
        return v
    }
    
    public func Recognize(points: [CGPoint]) -> Result {
        var points2 = Utils.Resample(points: points, n: Recognizer.NumPoints)
        points2 = Utils.ScaleToSquare(points: points2, size: Recognizer.SquareSize)
        points2 = Utils.TranslateToOrigin(points: points2)
        bounds[0] = Int(boundingBox.X)
        bounds[1] = Int(boundingBox.Y)
        bounds[2] = Int(boundingBox.X + boundingBox.Width)
        bounds[3] = Int(boundingBox.Y + boundingBox.Height)
        
        var t = 0
        
        var b = Double.greatestFiniteMagnitude
        for i in 0...Templates.count-1{
            let d = Utils.DistanceAtBestAngle(points: points2, T: Templates[i], a: -AngleRange, b: AngleRange, threshold: AnglePrecision)
            if (d < b) {
                b = d
                t = i
            }
        }
        let score = 1.0 - (b / HalfDiagonal)
        return Result(score: score, index: t, theta: Utils.lastTheta)
    }
    
    public func Predict(points: [CGPoint]) -> [Result] {
        var answer = [Result]()
        var length = 0.0
        for i in 1...points.count-1{
            length += Utils.Distance(p1: points[i-1], p2: points[i])
        }
        if (length == 0) {
            for i in 0...RawTemplates.count-1{
                answer.append(Result(score: 1, index: i, theta: Utils.lastTheta))
            }
            return answer
        }
        for i in 0...RawTemplates.count-1{
            var l = 0.0
            var curTemp = [CGPoint]()
            curTemp.append(contentsOf: points)
            var t=0
            while (l<length && t+1<RawTemplates[i].count){
                l += Utils.Distance(p1: RawTemplates[i][t], p2: RawTemplates[i][t+1])
                t += 1
            }
            if (length == 0){
                return answer
            }
            
            let deltaX = RawTemplates[i][t-1].x - points[points.count-1].x
            let deltaY = RawTemplates[i][t-1].y - points[points.count-1].y
            for j in t...RawTemplates[i].count-1{
                var p = RawTemplates[i][j]
                p.x -= deltaX
                p.y -= deltaY
                curTemp.append(p)
            }
            curTemp = Utils.Resample(points: curTemp, n: Recognizer.NumPoints)
            curTemp = Utils.ScaleToSquare(points: curTemp, size: Recognizer.SquareSize)
            curTemp = Utils.TranslateToOrigin(points: curTemp)
            bounds[0] = Int(boundingBox.X)
            bounds[1] = Int(boundingBox.Y)
            bounds[2] = Int(boundingBox.X + boundingBox.Width)
            bounds[3] = Int(boundingBox.Y + boundingBox.Height)
            
            let d = Utils.DistanceAtBestAngle(points: curTemp, T: Templates[i], a: -AngleRange, b: AngleRange, threshold: AnglePrecision)
            let score = 1.0 - (d / HalfDiagonal)
            if (score > 0.8){
                answer.append(Result(score: score, index: i, theta: Utils.lastTheta))
            }
        }
        
        return answer
    }
}

