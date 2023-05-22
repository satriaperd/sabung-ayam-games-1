//
//  GameScene.swift
//  Sabung Ayam
//
//  Created by Satria Perdana on 18/05/23.
//

import SpriteKit
import GameplayKit

class FightingScene: SKScene {
    
    // Player Node
    var player1: SKNode?
    var player2: SKNode?
    
    // Health Bar Properties
    var player1HealthBar: SKNode?
    var player2HealthBar: SKNode?
    var player1HealthBarBackground: SKNode?
    var player2HealthBarBackground: SKNode?
    
    var maxPlayerHealth: CGFloat = 100
    var currentPlayer1Health: CGFloat = 100
    var currentPlayer2Health: CGFloat = 100
    
    // Movement Button Node
    var joystick: SKNode?
    var joystickKnob: SKNode?
    
    // Attack Button Node
    var attackButton: SKNode?
    var skillButton: SKNode?
    var attackButtonAction: Bool = false
    var skillButtonAction: Bool = false
    
    // Damage Hit
    var hitBoxSprite: SKSpriteNode?
    var hitBoxAction: Bool = false
    var damageAttack: CGFloat = 20
    
    // Movement Button Action
    var joystickAction: Bool = false
    var knobRadius: CGFloat = 48.0
    var jumpAction: Bool = false
    var jumpHeight: CGFloat = 200
    var jumpThreshold: CGFloat = 15
    
    // Movement Measure
    var movementButtonRadius : CGFloat = 56.0
    
    // Sprite Engine
    var previousTimeInterval: TimeInterval = 0
    var playerFacingRight: Bool = true
    var playerSpeed: CGFloat = 4.0
    var currentMovement: CGFloat = 0

    //Player State
    var playerStateMachine : GKStateMachine!
    
    // Frame Border
    var bottomBorder = SKShapeNode()
    var upperBorder = SKShapeNode()
    var leftBorder = SKShapeNode()
    var rightBorder = SKShapeNode()
    
    // Indikator Testing Loop
    var indikatorAngka : Int = 1
    
    override func didMove(to view: SKView) {
        
        // Player
        player1 = childNode(withName: "player1")
        player2 = childNode(withName: "player2")
        
        // Player Health Bar
        player1HealthBar = childNode(withName: "player1HealthBar")
        player2HealthBar = childNode(withName: "player2HealthBar")
        player1HealthBarBackground = childNode(withName: "player1HealthBarBackground")
        player2HealthBarBackground = childNode(withName: "player2HealthBarBackground")
        
        // Movement Button
        joystick = childNode(withName: "joystick")
        joystickKnob = joystick?.childNode(withName: "knob")
        
        // Attack Button
        attackButton = childNode(withName: "attackButton")
        skillButton = childNode(withName: "skillButton")
        
        // Hit Box Player
        hitBoxSprite = SKSpriteNode()
               
        // Player State Machine
        playerStateMachine = GKStateMachine(states: [
        JumpingState(playerNode: player1!),
        WalkingState(playerNode: player1!),
        IdleState(playerNode: player1!),
        LandingState(playerNode: player1!),
        ])
        
        // Frame Border
        leftBorder.physicsBody = SKPhysicsBody(rectangleOf: CGSize(width: 1, height: frame.height))
        leftBorder.physicsBody?.affectedByGravity = false
        leftBorder.physicsBody?.isDynamic = false
        leftBorder.position = CGPoint(x: -frame.width / 2, y: 0)
        addChild(leftBorder)
        
        rightBorder.physicsBody = SKPhysicsBody(rectangleOf: CGSize(width: 1, height: frame.height))
        rightBorder.physicsBody?.affectedByGravity = false
        rightBorder.physicsBody?.isDynamic = false
        rightBorder.position = CGPoint(x: frame.width / 2, y: 0)
        addChild(rightBorder)
        
        upperBorder.physicsBody = SKPhysicsBody(rectangleOf: CGSize(width: frame.width, height: 1))
        upperBorder.physicsBody?.affectedByGravity = false
        upperBorder.physicsBody?.isDynamic = false
        upperBorder.position = CGPoint(x: 0, y: -frame.height / 2)
        addChild(upperBorder)
        
        bottomBorder.physicsBody = SKPhysicsBody(rectangleOf: CGSize(width: frame.width, height: 1))
        bottomBorder.physicsBody?.affectedByGravity = false
        bottomBorder.physicsBody?.isDynamic = false
        bottomBorder.position = CGPoint(x: 0, y: frame.height / 2)
        addChild(bottomBorder)
        
        playerStateMachine.enter(IdleState.self)
    }
}

// MARK: Touches

extension FightingScene {
    
    // Touch Began
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        for touch in touches {
            
            // Joystick Control
            if let joystickKnob = joystickKnob {
                let location = touch.location(in: joystick!)
                joystickAction = joystickKnob.frame.contains(location)
            }
            
            // Attack Button Here
            if let attackButton = attackButton {
                
                let location = touch.location(in: self)
                if attackButton.contains(location) {
                    attackButtonAction = true
                }
            }
            
            jumpAction = true
        }
    }
    
    // Touch Moved
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let joystick = joystick else { return }
        guard let joystickKnob = joystickKnob else { return }
        
        if !joystickAction { return }
        
        for touch in touches {
            let position = touch.location(in: joystick)
            
            let length = sqrt(pow(position.y, 2) + pow(position.x, 2))
            let angle = atan2(position.y, position.x)
            
            if knobRadius > length {
                joystickKnob.position = position
            } else {
                joystickKnob.position = CGPoint(x: cos(angle) * knobRadius, y: sin(angle) * knobRadius)
            }
            
            let yPosition = joystickKnob.position.y
            
            // Jump Indicator
            if yPosition > jumpThreshold {
                    playerJump()
            }
        }
    }
    
    // Touch Ended
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        for touch in touches {
            let xJoystickCoordinate = touch.location(in: joystick!).x
//            let yJoystickCoordinate = touch.location(in: joystick!).y
            
            let xLimit = CGFloat(200)
//            let yLimit = CGFloat(200)
            
            if xJoystickCoordinate > -xLimit && xJoystickCoordinate < xLimit {
                resetKnobPosition()
            }
            
            if let attackButton = attackButton {
                
                let location = touch.location(in: self)
                if attackButton.contains(location) {
                    attackButtonAction = false
                    chickenAttack(state: false)
                }
            }
        }
    }
}

// MARK: Action

extension FightingScene {
    
    // Reset Knob Position
    func resetKnobPosition(){
        let initalPosition = CGPoint(x: 0, y: 0)
        let moveBack = SKAction.move(to: initalPosition, duration: 0.1)
        moveBack.timingMode = .linear
        joystickKnob?.run(moveBack)
        joystickAction = false
    }
}

// MARK: Game Loop

extension FightingScene {
    override func update(_ currentTime: TimeInterval) {
        let deltaTime = currentTime - previousTimeInterval
        previousTimeInterval = currentTime
        
        guard let joystickKnob = joystickKnob else { return }
        
        let xPosition = Double(joystickKnob.position.x)
//        let yPosition = joystickKnob.position.y
        
        let displacement = CGVector(dx: deltaTime * xPosition * playerSpeed, dy: 0)
        let move = SKAction.move(by: displacement, duration: 0)
        
        let faceAction : SKAction!
        let movingRight = xPosition > 0
        let movingLeft = xPosition < 0
        
        if movingLeft && playerFacingRight {
            playerFacingRight = false
            let faceMovement = SKAction.scaleX(to: -1, duration: 0.0)
            faceAction = SKAction.sequence([move, faceMovement])
        } else if movingRight && !playerFacingRight {
            playerFacingRight = true
            let faceMovement = SKAction.scaleX(to: 1, duration: 0.0)
            faceAction = SKAction.sequence([move, faceMovement])
        }
        else {
            faceAction = move
        }
        
        player1?.run(faceAction)
        chickenAttack(state: true)
    }
}

// Function
extension FightingScene {
    
    func playerJump() {
        guard let player1 = player1 else { return }

        if jumpAction {

            if player1.position.y <= jumpThreshold {
                let jumpImpulse = CGVector(dx: 0, dy: jumpHeight)
                player1.physicsBody?.applyImpulse(jumpImpulse)

                playerStateMachine.enter(JumpingState.self)
            }

            jumpAction = false
        }


    }
    
    // Update Heatlh Bar
    func updateHealthBars(player1Health: CGFloat, player2Health: CGFloat) {
        
        // Calculate Healthbar for each player
        let player1HealthbarPercentage = player1Health / maxPlayerHealth
        let player2HealthbarPercentage = player2Health / maxPlayerHealth
        
        // Calculate the new width for the health bar
        player1HealthBar?.xScale = player1HealthbarPercentage
        player2HealthBar?.xScale = player2HealthbarPercentage
    }
    
    
    // Function Attack
    func chickenAttack(state: Bool = false){
        
        hitBoxSprite = SKSpriteNode(color: .green, size: CGSize(width: 24, height: 24))
        hitBoxSprite?.position = CGPoint(x: 40, y: -12)
        hitBoxSprite?.zPosition = 10
        
        if attackButtonAction && state {
            player1?.addChild(hitBoxSprite!)
            
            /* Notes: Create hit damage to decrease healthbar
                if hitbox in enemy
                    enemy.health - damage
             */
            
        } else {
            player1?.removeAllChildren()
        }
    }
}

// OLD CODE
/*
extension FightingScene {
    
    // Touch Began
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        for touch in touches {
            let touchLocation = touch.location(in: self)
            
            // check if button movement was pressed
            if let node = self.atPoint(touchLocation) as? SKSpriteNode {
                switch node {
                    
                case rightButton :
                    rightButtonAction = true
                    player1?.physicsBody?.velocity.dx = 500
                    
                case upButton:
                    upButtonAction = true
                    player1?.physicsBody?.velocity.dy = 500
                    
                case leftButton:
                    leftButtonAction = true
                    player1?.physicsBody?.velocity.dx = -500
                    
                default:
                    print("idle")
                }
            }
                        
            // Old Code
            /*
            if let node = self.atPoint(touchLocation) as? SKSpriteNode {
                switch node {
                    
                case upButton:
                    upButtonAction = true
                    upButton?.alpha = 1.0
                    player1?.physicsBody?.velocity.dy = playerSpeed * 4
                    print("up button")
                    
                case rightButton:
                    rightButtonAction = true
                    player1?.physicsBody?.velocity.dx = playerSpeed
                    print("right button")
                    
                case leftButton:
                    leftButtonAction = true
                    player1?.physicsBody?.velocity.dx = -100
                    print("left button")
                default :
                    print("test")
                    
                }
            }
            */
        }
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?)  {
        for touch in touches {
            let touchLocation = touch.location(in: self)
            
            if let node = self.atPoint(touchLocation) as? SKSpriteNode {
                switch node {
                    
                case rightButton :
                    rightButtonAction = false
                    player1?.physicsBody?.velocity.dx = 500
                    
                case upButton:
                    upButtonAction = false
                    player1?.physicsBody?.velocity.dy = 500
                    
                case leftButton:
                    leftButtonAction = false
                    player1?.physicsBody?.velocity.dx = -500
                    
                default:
                    print("idle")
                }
            }
        }
    }
    
    
    /*
     extension FightingScene {
     
     override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
     for touch in touches {
     let touchLocation = touch.location(in: self)
     
     if rightButtonAction {
     rightButtonAction = rightButton!.contains(touchLocation)
     rightButton?.alpha = 1.0
     } else if leftButtonAction {
     leftButtonAction = leftButton!.contains(touchLocation)
     } else { return }
     }
     }
     override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
     }
     override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
     for touch in touches {
     let touchLocation = touch.location(in: self)
     
     if !rightButtonAction {
     rightButtonAction = rightButton!.contains(touchLocation)
     rightButton?.alpha = 0.4
     } else if !leftButtonAction {
     leftButtonAction = leftButton!.contains(touchLocation)
     } else { return }
     }
     }
     }
     */
}


extension FightingScene {
    
    func movePlayer() {
        
    }
    
}
 
  func playerJump() {
      let jumpHeight: CGFloat = 10
      let currentY = player1?.position.y ?? 0.0
      player1?.position.y = currentY + jumpHeight
      jumpAction = false
      let jumpDuration: TimeInterval = 0.5
      let jumpAction = SKAction.moveBy(x: 0, y: jumpHeight, duration: jumpDuration)
      player1?.run(jumpAction)
  }
*/
