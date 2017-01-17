//
//  GameScene.swift
//  Optics-MS
//
//  Created by Mark Schmidt on 12/27/16.
//  Copyright © 2016 Mark Schmidt. All rights reserved.
//

import SpriteKit
import GameplayKit

class GameScene: SKScene {

    let LightCategoryName = "light"
    let OriginRayCategoryName = "origin"
    let NormalAlphaCategoryName = "normalAlpha"
    let NormalBetaCategoryName = "normalBeta"
    let InteriorRayCategoryName = "interior"
    let FinalRayCategoryName = "final"
    let FocalPointCategoryName = "focus"
    
    
    var isFingerOnLight = false
    
    let radius : CGFloat = 20.0
    let refractionIndex : CGFloat = 1.5
    
    let lensRadius1 : CGFloat = 350.0
    let lensRadius2 : CGFloat = 350.0
    
    var lightY : CGFloat!
    
    var height, angle1, distance1, angle2, distance2 : CGFloat!
    var center1, center2 : CGPoint!
    var path1 : UIBezierPath!
    var path2 : UIBezierPath!
    
    var a, b, c : CGPoint!
    
    
    override func didMove(to view: SKView) {
        super.didMove(to: view)

        let light = SKShapeNode(circleOfRadius: radius)
        light.lineWidth = 1
        light.fillColor = .white
        light.strokeColor = .blue
        light.glowWidth = 2.0
        light.name = LightCategoryName
        
        light.position = CGPoint(x: size.width * 0.1, y: size.height/2)
        lightY = light.position.y
        addChild(light)
        
        height = size.height * 0.2
        angle1 = asin(height / lensRadius1)
        distance1 = cos(angle1) * lensRadius1
        center1 = CGPoint(x: size.width/2 - distance1, y: size.height/2)
        
        //print("height = \(height) lensRadius1 = \(lensRadius1) angle1 = \(angle1)  distance1 = \(distance1)")
        
        path1 = UIBezierPath(arcCenter: center1, radius: lensRadius1, startAngle: -angle1, endAngle: angle1, clockwise: true)
        let lens1 = SKShapeNode(path: path1.cgPath)
        addChild(lens1)
        
        
        angle2 = asin(height / lensRadius2)
        distance2 = cos(angle2) * lensRadius2
        center2 = CGPoint(x: size.width/2 + distance2, y: size.height/2)
        
        path2 = UIBezierPath(arcCenter: center2, radius: lensRadius2, startAngle: CGFloat.pi - angle2, endAngle: CGFloat.pi + angle2, clockwise: true)
        
        let lens2 = SKShapeNode(path: path2.cgPath)
        addChild(lens2)
        /*
        //draw focal point
        let focalPoint = SKShapeNode(circleOfRadius: radius)
        focalPoint.lineWidth = 1
        focalPoint.fillColor = .white
        focalPoint.strokeColor = .blue
        focalPoint.glowWidth = 2.0
        focalPoint.name = FocalPointCategoryName
        //lensmaker's equation
        let f = (refractionIndex - 1) * (1 / lensRadius2 - 1 / lensRadius1 + ((refractionIndex - 1) * (distance1 + distance2))/(refractionIndex * lensRadius1 * lensRadius2))
        
        focalPoint.position = CGPoint(x: 1/f, y: lightY)
        
        addChild(focalPoint)
        */
        updateRays()
        
        
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        let touch = touches.first
        let touchLocation = touch!.location(in: self)
        if let node = self.nodes(at: touchLocation).first {
            if node.name == LightCategoryName {
                print("Touched light")
                isFingerOnLight = true
            }
        }
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        if isFingerOnLight {
            let touch = touches.first
            let touchLocation = touch!.location(in: self)
            let previousLocation = touch!.previousLocation(in: self)
            
            let light = childNode(withName: LightCategoryName) as! SKShapeNode
            
            lightY = light.position.y + (touchLocation.y - previousLocation.y)
            
            
            lightY = max(lightY, size.height * 0.1)
            lightY = min(lightY, size.height * 0.9)
            
            light.position = CGPoint(x: light.position.x, y: lightY)
           
            updateRays()
            
            
        }
    }
    
    func updateRays() {
      
        
        //let angle : CGFloat = 0.0

        
        //handle angles
        let light = childNode(withName: LightCategoryName) as! SKShapeNode
        let startPosition = light.position
        
        let angle : CGFloat = CGFloat.pi / 8
        //let angle : CGFloat = 0.0
        
        let originSlope = atan(angle)
        // y = originSlope(x) + originb
        let originb = -originSlope * startPosition.x + startPosition.y
        
        let originA = originSlope * originSlope + 1
        let originB = 2 * (originb * originSlope - center2.x - center2.y * originSlope)
        let originC = center2.y * center2.y + center2.x * center2.x + originb * originb - 2 * center2.y * originb - lensRadius2 * lensRadius2
        let originDiscriminant = sqrt(originB * originB - 4 * originA * originC)
        let ax = (-originB - originDiscriminant) / (2 * originA)
        let ay = originSlope * ax + originb
        
        let a = CGPoint(x: ax, y: ay)
        
        if(ay > size.height/2 + height || ay < size.height / 2 - height){
            for child in children {
                if child.name == NormalAlphaCategoryName || child.name == NormalBetaCategoryName || child.name == InteriorRayCategoryName || child.name == FinalRayCategoryName {
                    child.removeFromParent()
                }
                let y = angle > 0 ? size.height : 0
                let endPoint = CGPoint(x: (y - originb) / originSlope, y: y)
                let apath = UIBezierPath()
                apath.move(to: startPosition)
                apath.addLine(to: endPoint)
                if let originRay = childNode(withName: OriginRayCategoryName) as? SKShapeNode {
                    originRay.path = apath.cgPath
                } else {
                    let originRay = SKShapeNode(path: apath.cgPath)
                    originRay.name = OriginRayCategoryName
                    addChild(originRay)
                }

            }
            return
        }
        // ORIGIN RAY
        //let ax = distance2 + size.width/2 - cos(asin((lightY - size.height/2)/lensRadius2)) * lensRadius2
        //let ay = lightY!
        
        
        let apath = UIBezierPath()
        apath.move(to: startPosition)
        apath.addLine(to: a)
        if let originRay = childNode(withName: OriginRayCategoryName) as? SKShapeNode {
            originRay.path = apath.cgPath
        } else {
            let originRay = SKShapeNode(path: apath.cgPath)
            originRay.name = OriginRayCategoryName
            addChild(originRay)
        }
        
        // INTERIOR RAY
        
         /*NORMAL LINE TESTING */
        let napath = UIBezierPath()
        napath.move(to: a)
        napath.addLine(to: center2)
        if let normalRay = childNode(withName: NormalAlphaCategoryName) as? SKShapeNode {
            normalRay.path = napath.cgPath
        } else {
            let normalRay = SKShapeNode(path: napath.cgPath)
            normalRay.strokeColor = .cyan
            normalRay.name = NormalAlphaCategoryName
            addChild(normalRay)
        }
        
        
        
        let normalSlope = (center2.y - a.y)/(center2.x - a.x)
        
        let normalAngle = atan(normalSlope) //if slope is negative, angle will be negative
        let alpha = angle - normalAngle
        
        let r_alpha = asin(sin(alpha)/refractionIndex) + normalAngle
        let m = atan(r_alpha)

        /*
        let normalAngle = atan(normalSlope)
        let alpha = normalAngle + angle
        let r_alpha = asin(sin(alpha)/refractionIndex)
        var m = atan(r_alpha)
        if (angle > 0 && m < 0) || (angle < 0 && m > 0){
            m = -m
        }
        
        */
        //print("alpha = \(alpha), normalAngle = \(normalAngle), angle = \(angle), r_alpha = \(r_alpha)")
        let b = -m * a.x + a.y
        
        let A = m * m + 1
        let B = 2 * (b * m - center1.x - center1.y * m)
        let C = center1.y * center1.y + center1.x * center1.x + b * b - 2 * center1.y * b - lensRadius1 * lensRadius1
        let discriminant = sqrt(B * B - 4 * A * C)
        let bx1 = (-B + discriminant)/(2 * A)
        let by1 = m * bx1 + b
        
        
        
        let bpoint = CGPoint(x: bx1, y: by1)
        
        let bpath = UIBezierPath()
        bpath.move(to: a)
        bpath.addLine(to: bpoint)
        if let interiorRay = childNode(withName: InteriorRayCategoryName) as? SKShapeNode {
            interiorRay.path = bpath.cgPath
        } else {
            let interiorRay = SKShapeNode(path: bpath.cgPath)
            interiorRay.name = InteriorRayCategoryName
            addChild(interiorRay)
        }
 
        
        //get the other normal line
        let nbpath = UIBezierPath()
        nbpath.move(to: bpoint)
        nbpath.addLine(to: center1)
        if let normalRay = childNode(withName: NormalBetaCategoryName) as? SKShapeNode {
            normalRay.path = nbpath.cgPath
        } else {
            let normalRay = SKShapeNode(path: nbpath.cgPath)
            normalRay.strokeColor = .cyan
            normalRay.name = NormalBetaCategoryName
            addChild(normalRay)
        }
        let betaNormalSlope = (center1.y - bpoint.y) / (center1.x - bpoint.x)
        let normal = atan(betaNormalSlope)
        let incidentSlope = (bpoint.y - a.y) / (bpoint.x - a.x)
        let incident = atan(incidentSlope)
        
        let beta = incident - normal
        let temp = sin(beta) * refractionIndex
        //var offset : CGFloat = 0.0
        /*if temp > 1 {
            offset = 2/3
            temp = sin(beta - asin(1/refractionIndex)) * refractionIndex
        } else if temp < -1 {
            offset = 2/3
            temp = sin(beta - asin(1/refractionIndex)) * refractionIndex
        }*/
        
        if temp > 1 || temp < -1 {
            if let finalRay = childNode(withName: FinalRayCategoryName) as? SKShapeNode {
                finalRay.removeFromParent()
            }
            return
        }
        let r_beta = asin(temp) + normal
        let mb = atan(r_beta)
        //print("temp = \(temp), r_beta = \(r_beta * 180 / CGFloat.pi), beta = \(beta * 180 / CGFloat.pi)" )
        let edgePoint = CGPoint(x: size.width, y: mb * (size.width - bpoint.x) + bpoint.y)
        
        let finalPath = UIBezierPath()
        finalPath.move(to: bpoint)
        finalPath.addLine(to: edgePoint)
        if let finalRay = childNode(withName: FinalRayCategoryName) as? SKShapeNode {
            finalRay.path = finalPath.cgPath
        } else {
            let finalRay = SKShapeNode(path: finalPath.cgPath)
            finalRay.name = FinalRayCategoryName
            addChild(finalRay)
        }
    }
    
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        isFingerOnLight = false
    }
    
    
    
}
