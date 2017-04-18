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
    let TargetCategoryName = "target"
    
    
    var isFingerOnLight = false
    var isDragging = false
    var positions : [CGFloat]?
    let refractionIndex : CGFloat = 1.5
    
   
    var lightY : CGFloat?
    var targetY : CGFloat?
    let angle : CGFloat = 0.0
    var height : CGFloat?
    var lens : Lens?
    
    var leftIntersection : CGPoint?
    var rightIntersection : CGPoint?
    
    
    
    /// Starting method, called when the view is moved to this scene
    ///
    /// - Parameter view: the view
    override func didMove(to view: SKView) {
        super.didMove(to: view)
        height = size.height/4
        let light = SKShapeNode(circleOfRadius: 20.0)
        light.lineWidth = 1
        light.fillColor = .white
        light.strokeColor = .blue
        light.glowWidth = 2.0
        light.name = LightCategoryName
        
        light.position = CGPoint(x: size.width * 0.1, y: size.height/2)
        lightY = light.position.y
        addChild(light)
        
        lens = Lens(leftRadius: 250.0, rightRadius: 350.0, height: height!, refractionIndex: refractionIndex)
        lens?.moveToCenter(frameWidth: size.width, frameHeight: size.height)
        
        let leftLensPath = UIBezierPath(arcCenter: (lens?.leftCircle.center)!, radius: (lens?.leftCircle.radius)!, startAngle: CGFloat.pi-(lens?.leftAngle)!, endAngle: CGFloat.pi + (lens?.leftAngle)!, clockwise: true)
        let leftLens = SKShapeNode(path: leftLensPath.cgPath)
        addChild(leftLens)
        
        let rightLensPath = UIBezierPath(arcCenter: (lens?.rightCircle.center)!, radius: (lens?.rightCircle.radius)!, startAngle: -(lens?.rightAngle)!, endAngle: (lens?.rightAngle)!, clockwise: true)
        let rightLens = SKShapeNode(path: rightLensPath.cgPath)
        addChild(rightLens)
        
        let target = SKShapeNode(circleOfRadius: 20.0)
        target.lineWidth = 1
        target.fillColor = .black
        target.strokeColor = .red
        target.glowWidth = 2.0
        target.name = TargetCategoryName
        
        targetY = CGFloat(arc4random_uniform(UInt32(size.height)))
        target.position = CGPoint(x: size.width * 0.9, y: targetY!)
        addChild(target)
        updateRays()
        
        
    }
    
    
    /// Handles beginning touches
    ///
    /// - Parameters:
    ///   - touches: the set of touches
    ///   - event: the event
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        print("Touches began")
        positions = Array(repeating: 0.0, count: Int(size.width))

        let touch = touches.first
        let touchLocation = touch!.location(in: self)
        print(self.nodes(at: touchLocation))
        for node in self.nodes(at: touchLocation) {
            if node.name == LightCategoryName {
                print("Touched light")
                isFingerOnLight = true
                return
            }
        }
        
        isDragging = true
        print("Beginning drag")
        positions?[Int(touchLocation.x)] = touchLocation.y
    }
    
    
    /// Handles touch movement
    /// Handles dragging from the light separately from dragging
    /// a confirmation
    ///
    /// - Parameters:
    ///   - touches: the set of touches
    ///   - event: the event
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        if isFingerOnLight {
            let touch = touches.first
            let touchLocation = touch!.location(in: self)
            var found = false
            for node in self.nodes(at: touchLocation) {
                if node.name == LightCategoryName {
                    found = true
                    break;
                }
            }
            if(found) {
                let previousLocation = touch!.previousLocation(in: self)
                
                let light = childNode(withName: LightCategoryName) as! SKShapeNode
                
                lightY = light.position.y + (touchLocation.y - previousLocation.y)
                let minimum : CGFloat? = size.height/2 - height! - size.width * 0.4 * tan(angle)
                let maximum : CGFloat? = size.height/2 + height! - size.width * 0.4 * tan(angle)
                
                lightY = max(lightY!, minimum!)
                lightY = min(lightY!, maximum!)
                
                light.position = CGPoint(x: light.position.x, y: lightY!)
                updateRays()

            } else {
                isFingerOnLight = false
                isDragging = true
                print("Beginning drag")
                positions = Array(repeating: 0.0, count: Int(size.width))
                positions?[Int(touchLocation.x)] = touchLocation.y
                
            }
        } else if isDragging {
            let touch = touches.first
            let touchLocation = touch!.location(in: self)
            print(touchLocation)
            positions?[Int(touchLocation.x)] = touchLocation.y
        }
        

    }
    
    
    /// Draws a line using a cgpath
    ///
    /// - Parameters:
    ///   - p: the path
    ///   - name: the name of the line
    ///   - color: the color of the line
    func drawLine(withPath p : CGPath, name : String, color: UIColor) {
        if let line = childNode(withName: name) as? SKShapeNode {
            line.path = p
            line.strokeColor = color
        } else {
            let line = SKShapeNode(path: p)
            line.strokeColor = color
            line.name = name
            addChild(line)
        }
    }
    
    
    /// Draws a line between two points
    ///
    /// - Parameters:
    ///   - p1: the first point
    ///   - p2: the second point
    ///   - name: the name of the line ( so it will be reused )
    ///   - color: the color of the line
    func drawLine(betweenPoints p1 : CGPoint, and p2 : CGPoint, name : String, color : UIColor) {
        let path = UIBezierPath()
        path.move(to: p1)
        path.addLine(to: p2)
        drawLine(withPath: path.cgPath, name: name, color: color)
    }
    
    
    /// Updates the incident rays when the light source is moved
    func updateRays() {
        let light = childNode(withName: LightCategoryName) as! SKShapeNode
        let startPosition = light.position
        
        
        let originLine = Line(fromPoint: startPosition, andAngle: angle)
        let result = lens?.handleIncidentRay(ray: originLine)
        leftIntersection = result?.0
        rightIntersection = result?.1
        
        
        drawLine(betweenPoints: startPosition, and: leftIntersection!, name: OriginRayCategoryName, color: .white)
        drawLine(betweenPoints: leftIntersection!, and: rightIntersection!, name: InteriorRayCategoryName, color: .white)
        if let exitLine = result?.2 {
            let right = CGPoint(x: size.width, y: exitLine.solveY(forX: size.width))
            drawLine(betweenPoints: rightIntersection!, and: right, name: FinalRayCategoryName, color: .white)
            let c = Circle(radius: 20.0, center: CGPoint(x: size.width * 0.9, y: targetY!))
            let target = childNode(withName: TargetCategoryName) as! SKShapeNode

            if calculateLineCircleIntersection(line: exitLine, circle: c) != nil {
                target.fillColor = .white
            } else {
                target.fillColor = .black
            }
            
        } else {
            for child in children {
                if child.name == FinalRayCategoryName {
                    child.removeFromParent()
                }
            }
            let target = childNode(withName: TargetCategoryName) as! SKShapeNode
            target.fillColor = .black
            
        }

    }
    
    
    /// Handles the end of a touch event, updating the dragging
    ///
    /// - Parameters:
    ///   - touches: the set of touches
    ///   - event: the event
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        print("Touch ended")
        isFingerOnLight = false
        if(isDragging){
            
            //TODO: Refactor and extract this part
            isDragging = false
            
            
            let left = Int(leftIntersection!.x)
            let right = Int(rightIntersection!.x)
            let end = Int(size.width * 0.9)
            
            print("leftIntersection: \(leftIntersection!.y) rightIntersection: \(rightIntersection!.y) target: \(targetY!)")
            var matches = true
            let epsilon : CGFloat = 10.0
            
            var local = false
            for i in (left-5)..<(left+5) {
                let val = positions![i]
                print(val)
                if(abs(val - leftIntersection!.y) <= epsilon){
                    local = true
                }
                
            }
            matches = matches && local
            local = false
            print("right")
            for i in (right-5)..<(right+5){
                let val = positions![i]
                print(val)

                if(abs(val - rightIntersection!.y) <= epsilon){
                    local = true
                }
               
            }
            matches = matches && local
            local = false
            print("end")
            for i in (end-5)...(end+5) {
                let val = positions![i]
                print(val)

                if(abs(val - targetY!) <= epsilon){
                    local = true
                }
            }
            matches = matches && local
            
            
            let originRay = childNode(withName: OriginRayCategoryName) as! SKShapeNode
            let interiorRay = childNode(withName: InteriorRayCategoryName) as! SKShapeNode
            let exitRay = childNode(withName: FinalRayCategoryName) as? SKShapeNode
            
            if(matches){
                originRay.strokeColor = .green
                interiorRay.strokeColor = .green
                exitRay?.strokeColor = .green
            } else {
                originRay.strokeColor = .red
                interiorRay.strokeColor = .red
                exitRay?.strokeColor = .red
            }

        }
        
    }
    
    
    
}
