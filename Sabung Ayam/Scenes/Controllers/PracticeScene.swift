//
//  PracticeScene.swift
//  Sabung Ayam
//
//  Created by Satria Perdana on 19/05/23.
//

import Foundation
import SpriteKit

class PracticeScene : SKScene {
    
    override func didMove(to view: SKView) {
        bgFightArena()
        groundArena()
    }
    
}

// MARK: Function
extension PracticeScene {
    
    func bgFightArena() {
        let bgImage = SKSpriteNode(imageNamed: "background")
        bgImage.name = "background"
        bgImage.position = CGPoint(x: 0.5, y: 0.5)
        addChild(bgImage)
    }
    
    func groundArena() {
        let groundArena = SKSpriteNode(imageNamed: "ground")
        groundArena.name = "ground"
        groundArena.position = CGPoint(x: 0.5, y: 1.0)
        addChild(groundArena)
    }
    
}
