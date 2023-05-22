//
//  ChickenState.swift
//  Sabung Ayam
//
//  Created by Satria Perdana on 20/05/23.
//

import Foundation
import SpriteKit
import GameplayKit

fileprivate let characterAnimationKey = "Sprite Animation"

class PlayerState: GKState {
    
    unowned var playerNode: SKNode
    
    init(playerNode: SKNode) {
        self.playerNode = playerNode
        
        super.init()
    }
}

// MARK: Jumping Chicken
class JumpingState: PlayerState {
    
    var hasFinishedJumping: Bool = false
    
    override func isValidNextState(_ stateClass: AnyClass) -> Bool {
        if hasFinishedJumping && stateClass is LandingState.Type { return true }
        
        return false
    }
    
    override func didEnter(from previousState: GKState?) {
        
        playerNode.removeAction(forKey: characterAnimationKey)
        
        hasFinishedJumping = false
        playerNode.run(.applyForce(CGVector(dx: 0, dy: 75), duration: 0.1))
        
        Timer.scheduledTimer(withTimeInterval: 0.1, repeats: false) { (timer) in
            self.hasFinishedJumping = true
        }
    }
}

class LandingState: PlayerState {
    override func isValidNextState(_ stateClass: AnyClass) -> Bool {
        
        switch stateClass {
        case is LandingState.Type, is JumpingState.Type: return false
        default: return true
        }
    }
    
    override func didEnter(from previousState: GKState?) {
        stateMachine?.enter(IdleState.self)
    }
    
}

class IdleState: PlayerState {
    override func isValidNextState(_ stateClass: AnyClass) -> Bool {
        
        switch stateClass {
        case is LandingState.Type, is IdleState.Type: return false
        default: return true
        }
    }
    
    override func didEnter(from previousState: GKState?) {
        playerNode.removeAllActions()
    }
    
}

class WalkingState: PlayerState {
    override func isValidNextState(_ stateClass: AnyClass) -> Bool {
        
        switch stateClass {
        case is LandingState.Type, is WalkingState.Type: return false
        default: return true
        }
    }
    
    override func didEnter(from previousState: GKState?) {
        playerNode.removeAllActions()
    }
}

