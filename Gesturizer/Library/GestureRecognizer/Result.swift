//
//  Result.swift
//  iOSGesturizer
//
//  Created by Kuanysh on 2/8/18.
//  Copyright © 2018 Kuanysh. All rights reserved.
//

import Foundation

public class Result
{
    public var Index: Int
    public var Score: Double
    public var Theta: Double
    
    init(score: Double, index: Int, theta: Double) {
        self.Score = score
        self.Index = index
        self.Theta = theta
    }
}
