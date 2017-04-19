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
    
    var leftLensDistance : CGFloat
    var rightLensDistance : CGFloat
    
    
    var refractionIndex : CGFloat
    /// Creates a new lens object with given radii centered at (0, 0)
    ///
    /// - Parameters:
    ///   - lr: radius of left lens
    ///   - rr: radius of right lens
    ///   - h: height of the lens
    init(leftRadius lr: CGFloat, rightRadius rr: CGFloat, height h: CGFloat, refractionIndex : CGFloat) {
        leftCircle = Circle()
        rightCircle = Circle()
        leftCircle.radius = lr
        rightCircle.radius = rr
        height = h
        self.refractionIndex = refractionIndex
        
        leftAngle = asin(height / leftCircle.radius)
        leftLensDistance = cos(leftAngle) * leftCircle.radius
        leftCircle.center = CGPoint(x: leftLensDistance, y: 0)
        
        rightAngle = asin(height / rightCircle.radius)
        rightLensDistance = cos(rightAngle) * rightCircle.radius
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
    
    
    /// Calculates the intersection with the left lens
    ///
    /// - Parameter line: the incident line
    /// - Returns: the point of intersection or nil if there is no intersection
    func calculateLeftLensIntersection(incidentLine line: Line) -> CGPoint? {
        if let points = calculateLineCircleIntersection(line: line, circle: leftCircle) {
            let range = (leftCircle.center.x - leftCircle.radius) ..< (leftCircle.center.x - leftCircle.radius + leftLensDistance)
            
            if(range.contains(points.0.x)){
                return points.0
            }
            if(range.contains(points.1.x)) {
                return points.1
            }
            return nil
        }
        return nil
        
    }
    
    
    /// Calculates intersection point with the right lens
    ///
    /// - Parameter line: the incident line
    /// - Returns: the intersection point or nil if it does not exist
    func calculateRightLensIntersection(incidentLine line: Line) -> CGPoint? {
        if let points = calculateLineCircleIntersection(line: line, circle: rightCircle) {
            
            let range = (rightCircle.center.x + rightCircle.radius - rightLensDistance) ..< (rightCircle.center.x + rightCircle.radius + 0.01)
            
            if(range.contains(points.0.x)){
                return points.0
            }
            if(range.contains(points.1.x)) {
                return points.1
            }
            return nil
        }
        return nil
    }
    
    /// Bends the light of an incoming ray
    ///
    /// - Parameter ray: the incoming ray
    /// - Returns: The first incident point, the second incident point, and a line for the outgoing ray
    func handleIncidentRay(ray : Line) -> (CGPoint, CGPoint, Line?) {
        let intersection = calculateLeftLensIntersection(incidentLine: ray)
        //there is an intersection, time to draw the rest
        let leftNormal = calculateNormalLine(toCircle: leftCircle, atPoint: intersection!)
        
        let alpha = calculateAngleBetweenLines(a: leftNormal!, b: ray)
        let beta = calculateRefractionAngle(incidentAngle: alpha, refractionIndex: 1/refractionIndex)
        let interiorLine = Line(fromPoint: intersection!, andAngle: beta!, relativeTo: leftNormal!)
        
        let rightIntersection = calculateRightLensIntersection(incidentLine: interiorLine)
        let rightNormal = calculateNormalLine(toCircle: rightCircle, atPoint: rightIntersection!)

        let theta = calculateAngleBetweenLines(a: rightNormal!, b: interiorLine)
        let phi = calculateRefractionAngle(incidentAngle: theta, refractionIndex: refractionIndex)
        if phi == nil {
            return (intersection!, rightIntersection!, nil)
            
        } else {
            let exitLine = Line(fromPoint: rightIntersection!, andAngle: phi!, relativeTo: rightNormal!)
            return (intersection!, rightIntersection!, exitLine)
        }
    }


}


