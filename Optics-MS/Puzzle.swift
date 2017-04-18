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
}

class Puzzle {
    
    var lens : Lens
    var originAngle : CGFloat
    var solutionY : CGFloat
    var showStatus : ShowStatus

    
    /// Creates a puzzle with given parameters
    ///
    /// - Parameters:
    ///   - lens: the lens
    ///   - originAngle: the angle of the originline
    ///   - solutionY: the height of the solution switch
    ///   - showStatus: the showstatus of the puzzle
    init(lens : Lens, originAngle : CGFloat, solutionY : CGFloat, showStatus : ShowStatus) {
        self.lens = lens
        self.originAngle = originAngle
        self.solutionY = solutionY
        self.showStatus = showStatus
    }
    
    
    /// Generates a random puzzle
    ///
    /// - Parameters:
    ///   - d: the difficulty of the puzzle
    ///   - frameHeight: the frame height
    ///   - lensHeight: the height of the lens
    ///   - showStatus: the show status of the puzzle
    init(randomWithDifficulty d : Difficulty, frameHeight : CGFloat, lensHeight : CGFloat, showStatus : ShowStatus){
        var solutionRange : ClosedRange<CGFloat>
        var angleRange : ClosedRange<CGFloat>
        
        switch d {
        case .Easy:
            lens = Lens(leftRadius: 250.0, rightRadius: 250.0, height: lensHeight, refractionIndex: 1.5)
            solutionRange = (-frameHeight * 0.5) ... (frameHeight * 0.5)
            angleRange = 0.0 ... 0.0
        case .Medium:
            let radiusRange : ClosedRange<CGFloat> = 200.0 ... 400.0
            let random = Puzzle.generateRandomNumber(withinRange: radiusRange)
            lens = Lens(leftRadius: random, rightRadius: random, height: lensHeight, refractionIndex: 1.5)
            solutionRange = (-frameHeight * 0.6) ... (frameHeight * 0.6)
            angleRange = 0.0 ... 0.0
            
        case .Hard:
            let radiusRange : ClosedRange<CGFloat> = 200.0 ... 400.0
            let random = Puzzle.generateRandomNumber(withinRange: radiusRange)
            lens = Lens(leftRadius: random, rightRadius: random, height: lensHeight, refractionIndex: 1.5)
            solutionRange = (-frameHeight * 0.7) ... (frameHeight * 0.7)
            angleRange = -10.0 ... 10.0
        case .Expert:
            let radiusRange : ClosedRange<CGFloat> = 200.0 ... 400.0
            let left = Puzzle.generateRandomNumber(withinRange: radiusRange)
            let right = Puzzle.generateRandomNumber(withinRange: radiusRange)
            lens = Lens(leftRadius: left, rightRadius: right, height: lensHeight, refractionIndex: 1.5)
            solutionRange = (-frameHeight * 0.8) ... (frameHeight * 0.8)
            angleRange = -12.0 ... 12.0
        }
        
        solutionY = Puzzle.generateRandomNumber(withinRange: solutionRange)
        originAngle = Puzzle.generateRandomNumber(withinRange: angleRange)
        self.showStatus = showStatus
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

