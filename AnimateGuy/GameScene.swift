//
//  GameScene.swift
//  AnimateGuy
//
//  Created by Jacob Mensch on 4/7/15.
//  Copyright (c) 2015 uB. All rights reserved.
//

import SpriteKit

class GameScene: SKScene, AnalogControlPositionChange, ButtonPress {
  
  // loop timing
  var lastUpdateTime: NSTimeInterval = 0
  var dt: NSTimeInterval = 0
  
  // area bounds
  var playableRect: CGRect!
  var backgroundLayer: SKSpriteNode!
  
  // character
  let man = SKSpriteNode(imageNamed: "man1.png")
  var manScale = CGFloat(0.5)
  var velocity = CGPointZero
  var manAnimation: SKAction!
  var manTextures: [SKTexture] = []
  var crouched = false

  // debugging
  let debugOn = false
  
  //////////////// DID MOVE TO VIEW /////////////////
  
  override func didMoveToView(view: SKView) {
    
    // set up playableRect
    let maxAspectRatio: CGFloat = 16.0 / 9.0
    let playableHeight = size.width / maxAspectRatio
    let playableMargin = (size.height - playableHeight) / 2.0
    playableRect = CGRect(x: 0, y: playableMargin, width: size.width, height: playableHeight)
    
    // set up edge loop
    let physicsRect = CGRect(x: 0, y: playableRect.minY + 10, width: playableRect.width, height: 3 * playableRect.height)
    physicsBody = SKPhysicsBody(edgeLoopFromRect: physicsRect)
    
    // set up background
//    let background = SKSpriteNode(imageNamed: "background1")
//    background.size = size
//    background.anchorPoint = CGPointZero
//    background.position = CGPointZero
//    addChild(background)
    
    backgroundLayer = childNodeWithName("backgroundLayer") as SKSpriteNode
    
    // set up man
    man.setScale(manScale)
    man.position = CGPoint(x: 400, y: 240)
    man.zPosition = 100
    addChild(man)
    man.physicsBody = SKPhysicsBody(rectangleOfSize: man.size)
    man.physicsBody?.restitution = 0.0
    
    // set up manTextures for animation
    for i in 1...3 {
      manTextures.append(SKTexture(imageNamed: "man\(i)"))
    }
    
    
    
    manAnimation = getAnimation()
    
    if debugOn { debugDrawPlayableArea(view) }
  }
  
  //////////////////// UPDATE ///////////////////////
  
  override func update(currentTime: CFTimeInterval) {
    
    // update the time interval
    dt = lastUpdateTime > 0 ? currentTime - lastUpdateTime : dt
    lastUpdateTime = currentTime
    
    // turn the man in the right direction (if he isn't jumping)
    if man.actionForKey("jumping") == nil {
      if velocity.x < 0 {
        man.xScale = -1 * manScale
      } else if velocity.x > 0 {
        man.xScale = manScale
      }
    }
    
    // move the man
    moveSprite(man, velocity: velocity)
  }
  
  ///////////////// TOUCH HANDLING ///////////////////
  
  override func touchesBegan(touches: NSSet, withEvent event: UIEvent) {
//    let touch = touches.anyObject() as UITouch
//    let touchLocation = touch.locationInNode(self)
//    sceneTouched(touchLocation)
  }
  
  func sceneTouched(touchLocation: CGPoint) {
//    moveToward(touchLocation)
  }
  
  //////////////////////////// GENERAL SPRITE MOVEMENT ////////////////////////////
  
  func moveSprite(sprite: SKSpriteNode, velocity: CGPoint) {
    let amountToMove = velocity * CGFloat(dt)
    sprite.position += amountToMove
    
    // adjust background
    if (sprite.position.x > self.frame.width / 2.0 && backgroundLayer.position.x > -924) ||
       (sprite.position.x < self.frame.width / 4.0 && backgroundLayer.position.x < -100) {
        
      backgroundLayer.position.x -= amountToMove.x
      sprite.position.x -= amountToMove.x
    }
  }
  
  //////////////////////////// MAN ////////////////////////////
  
  // ANIMATION FUNCTIONS
  func getAnimation() -> SKAction {
    let time = 0.2
    return SKAction.repeatActionForever(
      SKAction.animateWithTextures(manTextures, timePerFrame: time))
  }
  
  func startAnimation() {
    if man.actionForKey("animation") == nil {
      man.runAction(
        SKAction.repeatActionForever(manAnimation),
        withKey: "animation")
    }
  }
  
  func stopAnimation() {
    man.removeActionForKey("animation")
    man.texture = SKTexture(imageNamed: "man1")
  }
  
  // MOVE
  func moveToward(location: CGPoint) {
    let direction = location.x - man.position.x
    velocity = CGPoint(x: direction, y: 0)
    
    startAnimation()
  }

  // JUMP
  func jump() {
    man.physicsBody?.applyImpulse(CGVector(dx: 0, dy: 1200))
    
    let airRotations = 2.0
    let duration = 1.0
    
    let rotationDirection = man.xScale > 0 ? CGFloat(-2 * airRotations * M_PI) : CGFloat(2 * airRotations * M_PI)
    let rotate = SKAction.rotateByAngle(rotationDirection, duration: duration)
    let shrink = SKAction.sequence([
      SKAction.scaleBy(0.5, duration: duration / 2),
      SKAction.scaleBy(2.0, duration: duration / 2)])
    let rotateAndShrink = SKAction.group([rotate, shrink])
    man.runAction(rotateAndShrink, withKey: "jumping")
  }
  
  func crouch() {
    crouched = true
    man.yScale /= 2
  }
  
  func uncrouch() {
    crouched = false
    man.yScale *= 2
  }
  
  ///////////////// CONTROL PAD ///////////////////
  
  func analogControlPositionChanged(analogControl: AnalogControl, position: CGPoint) {
    
    // turn the guy upright
    if position.y > 0.5 {
      man.zRotation = CGFloat(0)
      velocity = CGPointZero
      stopAnimation()
    }
    
    if position.y > 0.5 {
      if !crouched {
        crouch()
      }
    } else {
      if crouched {
        uncrouch()
      }
    }
    
    // x-axis motion
    if abs(position.x) < 0.1 {
      velocity.x = 0
      stopAnimation()
    } else {
      velocity.x = 500 * position.x
      startAnimation()
    }
  
    // jumping
    if man.actionForKey("jumping") == nil {
      if position.y < -0.5 {
        jump()
      }
    }
  }
  
  ///////////////// BUTTONS /////////////////////
  
  func buttonPressed(buttonControl: ButtonControl, buttonLetter: Character) {
   // println("Button pressed = \(buttonLetter)")
    if man.actionForKey("jumping") == nil {
      jump()
    }
  }
  
  ////////////////// DEBUGGING //////////////////
  
  func debugDrawPlayableArea(view: SKView) {
    
    println("scene.frame = \(self.frame)")
    
    // playableRect in red
    let shape = SKShapeNode()
    let path = CGPathCreateMutable()
    CGPathAddRect(path, nil, playableRect)
    shape.path = path
    shape.strokeColor = SKColor.redColor()
    shape.lineWidth = 4.0
    shape.zPosition = 1000
    addChild(shape)
    println("playableRect = \(playableRect)")
    
    println("view.frame = \(view.frame)")
    
    println("-------------------------------------")
    
  }
}
