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
    
    var lightY : CGFloat?
    var height : CGFloat?
    
    var puzzle : Puzzle?
    
    var leftIntersection : CGPoint?
    var rightIntersection : CGPoint?
    var solution = false
    var generateNewPuzzle = false
    
    let attemptsNode = SKLabelNode(fontNamed: "Chalkduster")
    
    
    
    init(size: CGSize, difficulty : Difficulty) {
        super.init(size: size)
        height = size.height/4
        
        puzzle = Puzzle(randomWithDifficulty: difficulty, frameHeight: size.height, lensHeight: height!)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    /// Starting method, called when the view is moved to this scene
    ///
    /// - Parameter view: the view
    override func didMove(to view: SKView) {
        super.didMove(to: view)
        let light = SKShapeNode(circleOfRadius: 30.0)
        light.lineWidth = 1
        light.fillColor = .white
        light.strokeColor = .blue
        light.glowWidth = 2.0
        light.name = LightCategoryName
        
        light.position = CGPoint(x: size.width * 0.1, y: size.height/2)
        lightY = light.position.y
        addChild(light)
        
        //var lens = Lens(leftRadius: 250.0, rightRadius: 350.0, height: height!, refractionIndex: refractionIndex)
        puzzle?.lens.moveToCenter(frameWidth: size.width, frameHeight: size.height)
        
        let leftLensPath = UIBezierPath(arcCenter: puzzle!.lens.leftCircle.center, radius: puzzle!.lens.leftCircle.radius, startAngle: CGFloat.pi - puzzle!.lens.leftAngle, endAngle: CGFloat.pi + puzzle!.lens.leftAngle, clockwise: true)
        let leftLens = SKShapeNode(path: leftLensPath.cgPath)
        addChild(leftLens)
        
        let rightLensPath = UIBezierPath(arcCenter: puzzle!.lens.rightCircle.center, radius: puzzle!.lens.rightCircle.radius, startAngle: -puzzle!.lens.rightAngle, endAngle: puzzle!.lens.rightAngle, clockwise: true)
        let rightLens = SKShapeNode(path: rightLensPath.cgPath)
        addChild(rightLens)
        
        let target = SKShapeNode(circleOfRadius: 30.0)
        target.lineWidth = 1
        target.fillColor = .black
        target.strokeColor = .red
        target.glowWidth = 2.0
        target.name = TargetCategoryName
        
        attemptsNode.position = CGPoint(x: size.width - 20, y: size.height - 20 )
        attemptsNode.verticalAlignmentMode = .top
        attemptsNode.horizontalAlignmentMode = .right
        attemptsNode.text = formatAttempts(attempts: 0)
        addChild(attemptsNode)
        
        //targetY = CGFloat(arc4random_uniform(UInt32(size.height)))
        target.position = CGPoint(x: size.width * 0.9, y: puzzle!.solutionY)
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
        //print(self.nodes(at: touchLocation))
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
                let minimum : CGFloat? = size.height/2 - height! - size.width * 0.4 * tan(puzzle!.originAngle)
                let maximum : CGFloat? = size.height/2 + height! - size.width * 0.4 * tan(puzzle!.originAngle)
                
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
            line.lineWidth = 3
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
        if generateNewPuzzle {
            self.puzzle? = Puzzle(randomWithDifficulty: self.puzzle!.difficulty, frameHeight: self.size.height, lensHeight: self.height!)
            puzzle?.lens.moveToCenter(frameWidth: size.width, frameHeight: size.height)
            attemptsNode.text = formatAttempts(attempts: 0)
            generateNewPuzzle = false
        }
        let light = childNode(withName: LightCategoryName) as! SKShapeNode
        let startPosition = light.position
        
        
        let originLine = Line(fromPoint: startPosition, andAngle: puzzle!.originAngle)
        let result = puzzle?.lens.handleIncidentRay(ray: originLine)
        leftIntersection = result?.0
        rightIntersection = result?.1
        
        drawLine(betweenPoints: startPosition, and: leftIntersection!, name: OriginRayCategoryName, color: .white)
        
        if(puzzle!.showStatus == .showAll || puzzle!.showStatus == .showInterior) {
            drawLine(betweenPoints: leftIntersection!, and: rightIntersection!, name: InteriorRayCategoryName, color: .white)
        } else {
            drawLine(betweenPoints: leftIntersection!, and: rightIntersection!, name: InteriorRayCategoryName, color: .clear)
        }
        
        if let exitLine = result?.2 {
            let right = CGPoint(x: size.width, y: exitLine.solveY(forX: size.width))
            
            if(puzzle!.showStatus == .showAll) {
                drawLine(betweenPoints: rightIntersection!, and: right, name: FinalRayCategoryName, color: .white)
            } else {
                drawLine(betweenPoints: rightIntersection!, and: right, name: FinalRayCategoryName, color: .clear)
            }
            let c = Circle(radius: 30.0, center: CGPoint(x: size.width * 0.9, y: puzzle!.solutionY))
            let target = childNode(withName: TargetCategoryName) as! SKShapeNode

            if calculateLineCircleIntersection(line: exitLine, circle: c) != nil {
                if puzzle!.showStatus == .showAll {
                    target.fillColor = .white
                }
                print("Line is correctly placed!")
                solution = true
            } else {
                target.fillColor = .black
                solution = false
            }
            
        } else {
            for child in children {
                if child.name == FinalRayCategoryName {
                    child.removeFromParent()
                }
            }
            let target = childNode(withName: TargetCategoryName) as! SKShapeNode
            target.fillColor = .black
            solution = false
            
        }

    }
    
    
    /// Handles what happens when a player passes a puzzle
    /// It incremements the show status until a player passes ShowOrigin with this lens configuration
    /// After ShowOrigin is passed, a new puzzle is generated and play restarts
    func handlePass() {
        print("Passed!")
        let originRay = childNode(withName: OriginRayCategoryName) as! SKShapeNode
        let interiorRay = childNode(withName: InteriorRayCategoryName) as! SKShapeNode
        let exitRay = childNode(withName: FinalRayCategoryName) as? SKShapeNode
        let target = childNode(withName: TargetCategoryName) as! SKShapeNode
        target.fillColor = .white
        originRay.strokeColor = .white
        let originAction = colorTransitionAction(fromColor: originRay.strokeColor, toColor: .green, duration: 1.5)
        let interiorAction = colorTransitionAction(fromColor: interiorRay.strokeColor, toColor: .green, duration: 1.4)
        interiorRay.run(interiorAction)
        
        let exitAction = colorTransitionAction(fromColor: (exitRay?.strokeColor)!, toColor: .green, duration: 1.4)
        exitRay?.run(exitAction)
        originRay.run(originAction) {
            if self.puzzle!.showStatus == .showOrigin {
                self.generateNewPuzzle = true
            } else {
                self.puzzle?.incrementStatus()
                self.puzzle?.randomizeLightPosition(frameHeight: self.size.height)
                
            }
            target.position = CGPoint(x: self.size.width * 0.9, y: self.puzzle!.solutionY)
            target.fillColor = .black
        }
        
        self.updateRays()

    
    
      
        
    }
    
    func handleFailure() {
        print("Failed :(")
        let originRay = childNode(withName: OriginRayCategoryName) as! SKShapeNode
        let interiorRay = childNode(withName: InteriorRayCategoryName) as! SKShapeNode
        let exitRay = childNode(withName: FinalRayCategoryName) as? SKShapeNode
        originRay.strokeColor = .red
        interiorRay.strokeColor = .red
        exitRay?.strokeColor = .red
        puzzle?.attempts += 1
        attemptsNode.text = formatAttempts(attempts: puzzle!.attempts)
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
            
            //print("leftIntersection: \(leftIntersection!.y) rightIntersection: \(rightIntersection!.y) target: \(targetY!)")
            var matches = true
            let epsilon : CGFloat = 30.0
            
            var local = false
            for i in (left-5)..<(left+5) {
                let val = positions![i]
                if(abs(val - leftIntersection!.y) <= epsilon){
                    local = true
                }
                
            }
            matches = matches && local
            local = false
            for i in (right-5)..<(right+5){
                let val = positions![i]

                if(abs(val - rightIntersection!.y) <= epsilon){
                    local = true
                }
               
            }
            
            matches = matches && local
            local = false
            var nonzero = false
            for i in (end-10)...(end+10) {
                let val = positions![i]
                if val > 0.0 {
                    nonzero = true
                }
                if(abs(val - puzzle!.solutionY) <= epsilon){
                    local = true
                }
            }
            matches = matches && local
            
            
            print("Matches: \(matches) Solution: \(solution)")
            if matches && solution {
                
                handlePass()
                
            } else if nonzero {
                handleFailure()

                
            }
        }
    }
    
    func formatAttempts(attempts : Int) -> String {
        return "Attempts: \(attempts)"
    }
    
    
    
    
    var frgba = [CGFloat(0.0), CGFloat(0.0), CGFloat(0.0), CGFloat(0.0)]
    var trgba = [CGFloat(0.0), CGFloat(0.0), CGFloat(0.0), CGFloat(0.0)]
    func lerp(a : CGFloat, b : CGFloat, fraction : CGFloat) -> CGFloat
    {
        return (b-a) * fraction + a
    }
    
    func colorTransitionAction(fromColor : UIColor, toColor : UIColor, duration : Double = 1.5) -> SKAction
    {
        fromColor.getRed(&frgba[0], green: &frgba[1], blue: &frgba[2], alpha: &frgba[3])
        toColor.getRed(&trgba[0], green: &trgba[1], blue: &trgba[2], alpha: &trgba[3])
        
        return SKAction.customAction(withDuration: duration, actionBlock: { (node : SKNode!, elapsedTime : CGFloat) -> Void in
            let fraction = CGFloat(elapsedTime / CGFloat(duration))
            let transColor = UIColor(red: self.lerp(a: self.frgba[0], b: self.trgba[0], fraction: fraction),
                                     green: self.lerp(a: self.frgba[1], b: self.trgba[1], fraction: fraction),
                                     blue: self.lerp(a: self.frgba[2], b: self.trgba[2], fraction: fraction),
                                     alpha: self.lerp(a: self.frgba[3], b: self.trgba[3], fraction: fraction))
            (node as! SKShapeNode).strokeColor = transColor
        }
        )
    }
    
    
    
}
