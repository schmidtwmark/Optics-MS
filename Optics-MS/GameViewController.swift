//
//  GameViewController.swift
//  Optics-MS
//
//  Created by Mark Schmidt on 12/27/16.
//  Copyright © 2016 Mark Schmidt. All rights reserved.
//

import UIKit
import SpriteKit
import GameplayKit

class GameViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        super.viewDidLoad()
        let scene = GameScene(size: view.bounds.size, difficulty: .Hard)
        let skView = view as! SKView
        skView.showsFPS = true
        skView.showsNodeCount = true
        skView.ignoresSiblingOrder = true
        scene.scaleMode = .resizeFill
        skView.presentScene(scene)
    }

    

    override var prefersStatusBarHidden: Bool {
        return true
    }
}
