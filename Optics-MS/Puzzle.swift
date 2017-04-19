//
//  Puzzle.swift
//  Optics-MS
//
//  Created by Mark Schmidt on 4/18/17.
//  Copyright © 2017 Mark Schmidt. All rights reserved.
//

import Foundation
import SpriteKit

enum ShowStatus {
    case showAll // shows all lines throughout the lens
    case showInterior // shows only the origin and interior
    case showOrigin // shows only the origin line
    
}

enum Difficulty {
    // Increasing solution range width
    case Easy //Constant lens radius, no angle
    case Medium //Random symmetric lens, no angle
    case Hard //Random symmetric lens, angled input
    case Expert //Random asymmetric lens, angled input
    case Debug
}



/// A Puzzle is essentially a configuration for a GameScene
class Puzzle {
    
    var lens : Lens
    var originAngle : CGFloat
    var solutionY : CGFloat
    var showStatus : ShowStatus
    var difficulty : Difficulty
    
    var attempts = 0

    
    /// Creates a puzzle with given parameters
    ///
    /// - Parameters:
    ///   - lens: the lens
    ///   - originAngle: the angle of the originline
    ///   - solutionY: the height of the solution switch
    ///   - showStatus: the showstatus of the puzzle
    init(lens : Lens, originAngle : CGFloat, solutionY : CGFloat, showStatus : ShowStatus, difficulty : Difficulty) {
        self.lens = lens
        self.originAngle = originAngle
        self.solutionY = solutionY
        self.showStatus = showStatus
        self.difficulty = difficulty
    }
    
    
    /// Generates a random puzzle
    ///
    /// - Parameters:
    ///   - d: the difficulty of the puzzle
    ///   - frameHeight: the frame height
    ///   - lensHeight: the height of the lens
    ///   - showStatus: the show status of the puzzle
    init(randomWithDifficulty d : Difficulty, frameHeight : CGFloat, lensHeight : CGFloat){
        var solutionRange : ClosedRange<CGFloat>
        var angleRange : ClosedRange<CGFloat>
        self.difficulty = d
        switch d {
        case .Easy:
            lens = Lens(leftRadius: 250.0, rightRadius: 250.0, height: lensHeight, refractionIndex: 1.5)
            solutionRange = (frameHeight/2 - frameHeight/5) ... (frameHeight/2 + frameHeight/5)
            angleRange = 0.0 ... 0.0
        case .Medium:
            let radiusRange : ClosedRange<CGFloat> = 250.0 ... 350.0
            let random = Puzzle.generateRandomNumber(withinRange: radiusRange)
            lens = Lens(leftRadius: random, rightRadius: random, height: lensHeight, refractionIndex: 1.5)
            solutionRange = (frameHeight/2 - frameHeight/4) ... (frameHeight/2 + frameHeight/4)
            angleRange = 0.0 ... 0.0
            
        case .Hard:
            let radiusRange : ClosedRange<CGFloat> = 250.0 ... 350.0
            let random = Puzzle.generateRandomNumber(withinRange: radiusRange)
            lens = Lens(leftRadius: random, rightRadius: random, height: lensHeight, refractionIndex: 1.5)
            solutionRange = (frameHeight/2 - frameHeight/3) ... (frameHeight/2 + frameHeight/3)
            angleRange = -CGFloat.pi/15 ... CGFloat.pi/15
        case .Expert:
            let radiusRange : ClosedRange<CGFloat> = 200.0 ... 400.0
            let left = Puzzle.generateRandomNumber(withinRange: radiusRange)
            let right = Puzzle.generateRandomNumber(withinRange: radiusRange)
            lens = Lens(leftRadius: left, rightRadius: right, height: lensHeight, refractionIndex: 1.5)
            solutionRange = (frameHeight/2 - frameHeight/3.7) ... (frameHeight/2 + frameHeight/3.7)
            angleRange = -CGFloat.pi/10 ... CGFloat.pi/10
        case .Debug:
            lens = Lens(leftRadius: 250.0, rightRadius: 350.0, height: lensHeight, refractionIndex: 1.5)
            solutionRange = (frameHeight/2 - frameHeight/3.5) ... (frameHeight/2 + frameHeight/3.5)
            angleRange = -CGFloat.pi/10 ... CGFloat.pi/10
        }
        
        solutionY = Puzzle.generateRandomNumber(withinRange: solutionRange)
        originAngle = Puzzle.generateRandomNumber(withinRange: angleRange)
        print("[Puzzle] origin angle: \(originAngle)")
        self.showStatus = .showAll
        
    }
    
    func randomizeLightPosition(frameHeight : CGFloat) {
        var solutionRange : ClosedRange<CGFloat>
        
        switch difficulty {
        case .Easy:
            solutionRange = (frameHeight/2 - frameHeight/4) ... (frameHeight/2 + frameHeight/4)
        case .Medium:
            solutionRange = (frameHeight/2 - frameHeight/3) ... (frameHeight/2 + frameHeight/3)
        case .Hard:
            solutionRange = (frameHeight/2 - frameHeight/3.5) ... (frameHeight/2 + frameHeight/3.5)
        case .Expert:
            solutionRange = (frameHeight/2 - frameHeight/3.7) ... (frameHeight/2 + frameHeight/3.7)
        case .Debug:
            solutionRange = (frameHeight/2 - frameHeight/3.5) ... (frameHeight/2 + frameHeight/3.5)
        }
        
        solutionY = Puzzle.generateRandomNumber(withinRange: solutionRange)
    }
    
    func incrementStatus() {
        switch showStatus {
        case .showAll:
            showStatus = .showInterior
        case .showInterior:
            showStatus = .showOrigin
        case .showOrigin:
            print("[Increment Status] this should not happen")
            showStatus = .showAll
        }
    }
    
    
    static var seeded = false
    /// Gets a random CGFloat
    ///
    /// - Returns: a CGFloat [0,1]
    static func randomFractional() -> CGFloat {
        
        if !Puzzle.seeded {
            let time = Int(NSDate().timeIntervalSinceReferenceDate)
            srand48(time)
            Puzzle.seeded = true
        }
        
        return CGFloat(drand48())
    }
    
    
    /// Gets a random float within the range
    ///
    /// - Parameter r: the closed range
    /// - Returns: a CGFloat within the range
    static func generateRandomNumber(withinRange r : ClosedRange<CGFloat>) -> CGFloat{
        var number = randomFractional()
        number *= (r.upperBound - r.lowerBound)
        number += r.lowerBound
        return number

    }
    
    
}

