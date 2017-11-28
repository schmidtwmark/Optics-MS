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
    
    var textView : UITextField?
    
    
    
    /// Handles set up of the view
    ///
    /// - Parameter view: the view
    override func didMove(to view: SKView) {
        easyButton.position = CGPoint(x: size.width * 0.7, y: size.height * 4/5)
        easyButton.name = Easy
        addChild(easyButton)
        
        mediumButton.position = CGPoint(x: size.width * 0.7, y: size.height * 3/5)
        mediumButton.name = Medium
        addChild(mediumButton)
        
        hardButton.position = CGPoint(x: size.width * 0.7, y: size.height * 2/5)
        hardButton.name = Hard
        addChild(hardButton)
        
        expertButton.position = CGPoint(x: size.width * 0.7, y: size.height * 1/5)
        expertButton.name = Expert
        addChild(expertButton)
        
        textView = UITextField(frame: CGRect(x: 0, y: 0, width: 200, height: 40))
        textView!.center = CGPoint(x: size.width * 0.3, y: size.height/2)
        textView?.alpha = 0
        textView?.placeholder = "Enter your name"
        textView?.backgroundColor = .white
        textView?.borderStyle = .roundedRect
        
        view.addSubview(textView!)
        UIView.animate(withDuration: 1.5, animations: {
            self.textView!.alpha = 1.0
        })
        
    
        
    }
    
    
    /// Handles a touch down event
    ///
    /// - Parameters:
    ///   - touches: the set of touches
    ///   - event: the event
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        var difficulty : Difficulty
        let touch = touches.first
        let touchLocation = touch!.location(in: self)
        if let node = self.nodes(at: touchLocation).first {
            switch node.name! {
            case Easy:
                difficulty = .Easy
            case Medium:
                difficulty = .Medium
            case Hard:
                difficulty = .Hard
            case Expert:
                difficulty = .Expert
            default:
                difficulty = .Debug
                print("AHHH")
            }
            
            if let view = view {
                let transition = SKTransition.fade(withDuration: 1)
                let scene = GameScene(size: self.size, difficulty: difficulty, name: (textView?.text)!)
                view.presentScene(scene, transition: transition)
                self.textView!.removeFromSuperview()
                
            }
        }
        
        
        
        
        
    }
    
    
}
