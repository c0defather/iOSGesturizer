//
//  Rectangle.swift
//  iOSGesturizer
//
//  Created by Kuanysh on 2/8/18.
//  Copyright © 2018 Kuanysh. All rights reserved.
//

import Foundation
public class Rectangle {
    public var X: Double
    public var Y: Double
    public var Width: Double
    public var Height: Double
    
    init (x: Double, y: Double, width: Double, height: Double){
        self.X = x;
        self.Y = y;
        self.Width = width;
        self.Height = height;
    }
    
    public func copy(src: Rectangle){
        X = src.X;
        Y = src.Y;
        Width = src.Width;
        Height = src.Height;
    }
}

