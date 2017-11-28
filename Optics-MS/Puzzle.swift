//
//  Puzzle.swift
//  Optics-MS
//
//  Created by Mark Schmidt on 4/18/17.
//  Copyright © 2017 Mark Schmidt. All rights reserved.
//

import Foundation
import SpriteKit

enum ShowStatus : String {
    case showAll = "showAll" // shows all lines throughout the lens
    case showInterior = "showInterior" // shows only the origin and interior
    case showOrigin = "showOrigin" // shows only the origin line
    
}

enum Difficulty : String {
    // Increasing solution range width
    case Easy = "easy" //Constant lens radius, no angle
    case Medium = "medium" //Random symmetric lens, no angle
    case Hard = "hard" //Random symmetric lens, angled input
    case Expert = "expert" //Random asymmetric lens, angled input
    case Debug = "debug"
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
    
    init(data : Data) {
        var jsonObject : [String : Any]
        do {
            jsonObject = try JSONSerialization.jsonObject(with: data) as! [String : Any]
        } catch {
            print("Unable to deserialize Lens")
            jsonObject = [:]
        }
        print(jsonObject)
        
        lens = Lens(withData: (jsonObject["lens"] as! String).data(using: .utf8)!)
        originAngle = jsonObject["originAngle"] as! CGFloat
        solutionY = jsonObject["solutionY"] as! CGFloat
        attempts = jsonObject["attempts"] as! Int
        showStatus = ShowStatus(rawValue: jsonObject["showStatus"] as! String)!
        difficulty = Difficulty(rawValue: jsonObject["difficulty"] as! String)!
    }
    
    ///Returns a json string representing the puzzle
    func serialize() -> Data {
        let jsonObject = [
            "lens" : String(data: lens.serialize(), encoding: .utf8)!,
            "originAngle" : originAngle,
            "solutionY" : solutionY,
            "attempts" : attempts,
            "showStatus" : showStatus.rawValue,
            "difficulty" : difficulty.rawValue
            
            ] as [String : Any]
        if JSONSerialization.isValidJSONObject(jsonObject) {
            do {
                let rawData = try JSONSerialization.data(withJSONObject: jsonObject)
                return rawData
            } catch {
                print("Unable to serialize lens valid")
                return Data()
            }
        } else {
            print("Unable to serialize lens")
            return Data()
        }
    }
    
    
    /// Randomizes the light position, keeping other aspects the same
    ///
    /// - Parameter frameHeight: <#frameHeight description#>
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
    
    
    
    /// Increments the show status variable
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

