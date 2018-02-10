//
//  Template.swift
//  iOSGesturizer
//
//  Created by Kuanysh on 2/8/18.
//  Copyright © 2018 Kuanysh. All rights reserved.
//

import UIKit

public class Template
{
    var mPoints: [CGPoint]!
    init (points: [CGPoint]){
        self.mPoints = Utils.Resample(points: points, n: Recognizer.NumPoints);
        self.mPoints = Utils.ScaleToSquare(points: self.mPoints, size: Recognizer.SquareSize);
        self.mPoints = Utils.TranslateToOrigin(points: self.mPoints);
    }
}
