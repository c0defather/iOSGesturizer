//
//  GesturizerWindow.swift
//  Gesturizer
//
//  Created by Kuanysh on 2/10/18.
//  Copyright © 2018 Kuanysh. All rights reserved.
//

import UIKit

public class GesturizerWindow: UIWindow {
    var view: GesturizerView!
    
    public func setGestureView(view: GesturizerView) {
        self.view = view
    }
    
    override public func sendEvent(_ event: UIEvent) {
        if event.type == .touches {
            if let count = event.allTouches?.filter({ $0.phase == .began }).count, count > 0 {
                view.touchesBegan(event.allTouches!)
                super.sendEvent(event)
            }
            if let count = event.allTouches?.filter({ $0.phase == .moved }).count, count > 0 {
                view.touchesMoved(event.allTouches!)
                if (!view.forceTouch){
                    super.sendEvent(event)
                }
            }
            if let count = event.allTouches?.filter({ $0.phase == .ended }).count, count > 0 {
                view.touchesEnded(event.allTouches!)
                super.sendEvent(event)
            }
            if let count = event.allTouches?.filter({ $0.phase == .cancelled }).count, count > 0 {
                super.sendEvent(event)
            }
        }
    }
}

