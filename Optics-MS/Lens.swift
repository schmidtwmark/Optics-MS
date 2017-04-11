//
//  Lens.swift
//  Optics-MS
//
//  Created by Mark Schmidt on 4/11/17.
//  Copyright © 2017 Mark Schmidt. All rights reserved.
//

import Foundation
import SpriteKit



class Lens {
    
    var leftAngle : CGFloat
    var rightAngle : CGFloat
    
    var height : CGFloat
    
    
    var leftCircle : Circle
    var rightCircle : Circle
    
    /// Creates a new lens object with given radii centered at (0, 0)
    ///
    /// - Parameters:
    ///   - lr: radius of left lens
    ///   - rr: radius of right lens
    ///   - h: height of the lens
    init(leftRadius lr: CGFloat, rightRadius rr: CGFloat, height h: CGFloat) {
        leftCircle = Circle()
        rightCircle = Circle()
        leftCircle.radius = lr
        rightCircle.radius = rr
        height = h
        
        
        leftAngle = asin(height / leftCircle.radius)
        let leftLensDistance = cos(leftAngle) * leftCircle.radius
        leftCircle.center = CGPoint(x: leftLensDistance, y: 0)
        
        rightAngle = asin(height / rightCircle.radius)
        let rightLensDistance = cos(rightAngle) * rightCircle.radius
        rightCircle.center = CGPoint(x: -rightLensDistance, y: 0)
    }
    
    
    /// Moves the lens to the center of the frame
    ///
    /// - Parameters:
    ///   - w: width of the frame
    ///   - h: height of the frame
    func moveToCenter(frameWidth w: CGFloat, frameHeight h: CGFloat){
        leftCircle.center.x += w/2
        leftCircle.center.y += h/2
        
        rightCircle.center.x += w/2
        rightCircle.center.y += h/2
    }
    
    func calculateLeftLensIntersection(incidentLine line: Line) -> CGPoint {
      return CGPoint()
    }
    
    
}


