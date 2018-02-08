//
//  Trigonometric.swift
//  iOSGesturizer
//
//  Created by Kuanysh on 2/8/18.
//  Copyright © 2018 Kuanysh. All rights reserved.
//

import Foundation

public class Trigonometric
{
    // constants
    static let sq2p1 = 2.414213562373095048802e0
    static let sq2m1  = 0.414213562373095048802e0
    static let p4  = 0.161536412982230228262e2
    static let p3  = 0.26842548195503973794141e3
    static let p2  = 0.11530293515404850115428136e4
    static let p1  = 0.178040631643319697105464587e4
    static let p0  = 0.89678597403663861959987488e3
    static let q4  = 0.5895697050844462222791e2
    static let q3  = 0.536265374031215315104235e3
    static let q2  = 0.16667838148816337184521798e4
    static let q1  = 0.207933497444540981287275926e4
    static let q0  = 0.89678597403663861962481162e3
    static let PIO2 = 1.5707963267948966135E0
    static let nan = (0.0/0.0)
    static let PI = 3.141592653589793
    
    // reduce
    private static func mxatan(arg: Double) -> Double {
        var argsq, value: Double
        argsq = arg*arg;
        value = ((((p4*argsq + p3)*argsq + p2)*argsq + p1)*argsq + p0)
        value = value/(((((argsq + q4)*argsq + q3)*argsq + q2)*argsq + q1)*argsq + q0)
        return value*arg
    }
    
    // reduce
    private static func msatan(arg: Double) -> Double {
        if(arg < sq2m1){
            return mxatan(arg: arg)
        }
        if(arg > sq2p1){
            return PIO2 - mxatan(arg: 1/arg)
        }
        return PIO2/2 + mxatan(arg: (arg-1)/(arg+1))
    }
    
    // implementation of atan
    public static func atan(arg: Double) -> Double {
        if(arg > 0){
            return msatan(arg: arg)
        }
        return -msatan(arg: -arg)
    }
    
    // implementation of atan2
    public static func atan2(arg1: inout Double, arg2: Double) -> Double{
        if(arg1+arg2 == arg1){
            if(arg1 >= 0){
                return PIO2
            }
            return -PIO2
        }
        arg1 = atan(arg: arg1/arg2)
        if(arg2 < 0){
            if(arg1 <= 0){
                return arg1 + PI
            }
            return arg1 - PI
        }
        return arg1
    }
    
    // implementation of asin
    public static func asin(arg: inout Double) -> Double {
        var temp: Double
        var sign = 0
        
        if(arg < 0){
            arg = -arg
            sign += 1
        }
        if(arg > 1){
            return nan
        }
        temp = sqrt(1 - arg*arg)
        if(arg > 0.7){
            temp = PIO2 - atan(arg: temp/arg)
        } else{
            temp = atan(arg: arg/temp)
        }
        if(sign > 0){
            temp = -temp
        }
        return temp
    }
    
    // implementation of acos
    public static func acos(arg: inout Double) -> Double {
        if(arg > 1 || arg < -1){
            return nan
        }
        return PIO2 - asin(arg: &arg)
    }
}
