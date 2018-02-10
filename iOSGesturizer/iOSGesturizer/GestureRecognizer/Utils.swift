//
//  Utils.swift
//  iOSGesturizer
//
//  Created by Kuanysh on 2/8/18.
//  Copyright © 2018 Kuanysh Zhunussov. All rights reserved.
//

import UIKit

/* -------------------------------------------------------------------------
 *
 *    $1 Java
 *
 *     This is a Java port of the $1 Gesture Recognizer by
 *    Jacob O. Wobbrock, Andrew D. Wilson, Yang Li.
 *
 *    "The $1 Unistroke Recognizer is a 2-D single-stroke recognizer designed for
 *    rapid prototyping of gesture-based user interfaces."
 *
 *    http://depts.washington.edu/aimgroup/proj/dollar/
 *
 *    Copyright (C) 2009, Alex Olwal, www.olwal.com
 *
 *    $1 Java free software: you can redistribute it and/or modify
 *    it under the terms of the GNU General Public License as published by
 *    the Free Software Foundation, either version 3 of the License, or
 *    (at your option) any later version.
 *
 *    $1 Java is distributed in the hope that it will be useful,
 *    but WITHOUT ANY WARRANTY; without even the implied warranty of
 *    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 *    GNU General Public License for more details.
 *
 *    You should have received a copy of the GNU General Public License
 *    along with $1 Java.  If not, see <http://www.gnu.org/licenses/>.
 *
 *  -------------------------------------------------------------------------
 */

public class Utils
{
    public static var lastTheta: Double = Double(0)
    
    public static func Resample(points: [CGPoint], n: Int) -> [CGPoint]{
        let I = PathLength(points: points) / Double(n - 1)
        var D = 0.0
        
        var srcPts = [CGPoint]()
        for p in points{
            srcPts.append(p)
        }
        var dstPts = [CGPoint]()
        dstPts.append(srcPts[0])
        var i = 1
        while (i < srcPts.count-1){
            let pt1 = srcPts[i-1]
            let pt2 = srcPts[i]
            
            let d = Distance(p1: pt1, p2: pt2)
            if ((D + d) >= I) {
                let qx = pt1.x + CGFloat((I - D) / d) * (pt2.x - pt1.x)
                let qy = pt1.y + CGFloat((I - D) / d) * (pt2.y - pt1.y)
                let q = CGPoint (x: qx, y: qy)
                dstPts.append(q)
                srcPts.insert(q, at: i)
                D = 0.0
            } else {
                D += d
            }
            i+=1
        }
        // somtimes we fall a rounding-error short of adding the last point, so add it if so
        if (dstPts.count == n - 1) {
            dstPts.append(srcPts[srcPts.count - 1])
        }
        
        return dstPts;
    }
    
    
    public static func RotateToZero(points: [CGPoint]) -> [CGPoint] {
        return RotateToZero(points: points, centroid: nil, boundingBox: nil)
    }
    
    
    public static func RotateToZero(points: [CGPoint], centroid: CGPoint?, boundingBox: Rectangle?) -> [CGPoint] {
        let c = Centroid(points: points)
        let first = points[0]
        let theta = atan2(c.y-first.y, c.x-first.x)
        var cent = centroid
        if (cent != nil){
            cent!.x = c.x
            cent!.y = c.y
        }
        
        if (boundingBox != nil){
            BoundingBox(points: points, dst: boundingBox!)
        }
        
        self.lastTheta = Double(theta)
        
        return RotateBy(points: points, theta: Double((-1)*theta))
    }
    
    public static func RotateBy(points: [CGPoint], theta: Double) -> [CGPoint] {
        return RotateByRadians(points: points, radians: theta)
    }
    
    // rotate the points by the given radians about their centroid
    public static func RotateByRadians(points: [CGPoint], radians: Double) -> [CGPoint] {
        var newPoints = [CGPoint]()
        let c = Centroid(points: points)
        
        let cosine = cos(radians)
        let sine = sin(radians)
        
        let cx = c.x;
        let cy = c.y;
        
        for p in points {
            let dx = p.x - cx
            let dy = p.y - cy
            newPoints.append(CGPoint(x: dx * CGFloat(cosine) - dy * CGFloat(sine) + cx, y: dx * CGFloat(sine) + dy * CGFloat(cosine) + cy))
        }
        return newPoints
    }
    
    public static func ScaleToSquare(points: [CGPoint], size: Double) -> [CGPoint] {
        return ScaleToSquare(points: points, size: size, boundingBox: nil)
    }
    
    public static func ScaleToSquare(points: [CGPoint], size: Double, boundingBox: Rectangle?) -> [CGPoint] {
        let B = BoundingBox(points: points)
        var newpoints = [CGPoint]()
        for p in points {
            let qx = Double(p.x) * (size / B.Width)
            let qy = Double(p.y) * (size / B.Height)
            newpoints.append(CGPoint(x: qx, y: qy))
        }
        if (boundingBox != nil){ //this will probably not be used as we are more interested in the pre-rotated bounding box -> see RotateToZero
            boundingBox!.copy(src: B)
        }
        return newpoints
    }
    
    public static func TranslateToOrigin(points: [CGPoint]) -> [CGPoint]{
        let c = Centroid(points: points)
        var newpoints = [CGPoint]()
        for i in 0...points.count-1{
            let p = points[i]
            let qx = p.x - c.x;
            let qy = p.y - c.y;
            newpoints.append(CGPoint(x: qx, y: qy))
        }
        return newpoints
    }
    
    public static func  DistanceAtBestAngle(points: [CGPoint], T: Template, a: Double, b: Double, threshold: Double) -> Double {
        let Phi = 0.5 * (-1.0 + sqrt(5.0))//Recognizer.Phi;
        
        var x1 = Phi * a + (1.0 - Phi) * b
        var f1 = DistanceAtAngle(points: points, T: T, theta: x1)
        var x2 = (1.0 - Phi) * a + Phi * b
        var f2 = DistanceAtAngle(points: points, T: T, theta: x2)
        var b2 = b
        var a2 = a
        while (abs(b2 - a2) > threshold) {
            if (f1 < f2){
                b2 = x2
                x2 = x1
                f2 = f1
                x1 = Phi * a2 + (1.0 - Phi) * b2
                f1 = DistanceAtAngle(points: points, T: T, theta: x1)
            } else {
                a2 = x1
                x1 = x2
                f1 = f2
                x2 = (1.0 - Phi) * a2 + Phi * b2
                f2 = DistanceAtAngle(points: points, T: T, theta: x2)
            }
        }
        return min(f1, f2);
    }
    
    public static func DistanceAtAngle(points: [CGPoint], T: Template, theta: Double) -> Double {
        let newpoints = RotateBy(points: points, theta: theta);
        return PathDistance(path1: newpoints, path2: T.mPoints)
    }
    
    //    #region Lengths and Rects
    
    public static func BoundingBox(points: [CGPoint]) -> Rectangle {
        var minX = CGFloat.greatestFiniteMagnitude
        var maxX = CGFloat.leastNormalMagnitude
        var minY = CGFloat.greatestFiniteMagnitude
        var maxY = CGFloat.leastNormalMagnitude
        
        for p in points {
            if (p.x < minX){
                minX = p.x
            }
            if (p.x > maxX){
                maxX = p.x
            }
            
            if (p.y < minY){
                minY = p.y
            }
            if (p.y > maxY){
                maxY = p.y
            }
        }
        
        return Rectangle(x: Double(minX), y: Double(minY), width: Double(maxX - minX), height: Double(maxY - minY))
    }
    
    public static func BoundingBox(points: [CGPoint], dst: Rectangle){
        var minX = CGFloat.leastNormalMagnitude
        var maxX = CGFloat.greatestFiniteMagnitude
        var minY = CGFloat.leastNormalMagnitude
        var maxY = CGFloat.greatestFiniteMagnitude
        
        for p in points {
            if (p.x < minX){
                minX = p.x
            }
            if (p.x > maxX){
                maxX = p.x
            }
            
            if (p.y < minY){
                minY = p.y
            }
            if (p.y > maxY){
                maxY = p.y
            }
        }
        
        dst.X = Double(minX);
        dst.Y = Double(minY);
        dst.Width = Double(maxX - minX);
        dst.Height = Double(maxY - minY);
    }
    
    public static func Distance(p1: CGPoint, p2: CGPoint) -> Double{
        let dx = p2.x - p1.x
        let dy = p2.y - p1.y
        return sqrt(Double(dx * dx + dy * dy))
    }
    
    // compute the centroid of the points given
    public static func Centroid(points: [CGPoint]) -> CGPoint {
        var xsum = CGFloat(0);
        var ysum = CGFloat(0);
        
        for p in points{
            xsum+=p.x
            ysum+=p.y
        }
        return CGPoint(x: xsum / CGFloat(points.count), y: ysum / CGFloat(points.count))
    }
    
    public static func PathLength(points: [CGPoint]) -> Double{
        var length = Double(0)
        for i in 1...points.count-1{
            length += Distance(p1: points[i - 1], p2: points[i])
        }
        return length
    }
    
    // computes the 'distance' between two point paths by summing their corresponding point distances.
    // assumes that each path has been resampled to the same number of points at the same distance apart.
    public static func PathDistance(path1: [CGPoint],path2: [CGPoint]) ->Double {
        var distance = Double(0)
        for i in 0...path1.count-1{
            distance += Distance(p1: path1[i], p2: path2[i])
        }
        return distance / Double(path1.count)
    }
    
}
