//
//  MenuScene.swift
//  Optics-MS
//
//  Created by Mark Schmidt on 4/18/17.
//  Copyright © 2017 Mark Schmidt. All rights reserved.
//

import Foundation
import SpriteKit
import GameplayKit

let Easy = "Easy"
let Medium = "Medium"
let Hard = "Hard"
let Expert = "Expert"


class MenuScene : SKScene {
    let easyButton = SKLabelNode(text: "Easy")
        let mediumButton = SKLabelNode(text: "Medium")
    
    let hardButton = SKLabelNode(text: "Hard")
    let expertButton = SKLabelNode(text: "Expert")
    
    override func didMove(to view: SKView) {
        easyButton.position = CGPoint(x: size.width/2, y: size.height * 4/5)
        easyButton.name = Easy
        mediumButton.position = CGPoint(x: size.width/2, y: size.height * 3/5)
        mediumButton.name = Medium
        hardButton.position = CGPoint(x: size.width/2, y: size.height * 2/5)
        hardButton.name = Hard
        expertButton.position = CGPoint(x: size.width/2, y: size.height * 1/5)
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        var difficulty : Difficulty
        let touch = touches.first
        let touchLocation = touch!.location(in: self)
        if let node = self.nodes(at: touchLocation) {
            switch node.name {
            case Easy:
                difficulty = .Easy
            case Medium:
                difficulty = .Medium
            case Hard:
                difficulty = .Hard
            case Expert:
                difficulty = .Expert
            }
        }
        
        if let view = view {
            let transition:SKTransition.fade(withDuration: 1)
            let scene = GameScene(size: self.size, difficulty: difficulty)
            self.view?.presentScene(scene, transition: transition)
        }
        
        
        
    }
    
    
}
