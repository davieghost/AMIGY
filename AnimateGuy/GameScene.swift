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
  let man = SKSpriteNode(imageNamed: "man0")
  var manScale = CGFloat(0.75)
  var velocity = CGPointZero
  var manAnimation: SKAction!
  var manTextures: [SKTexture] = []
  var crouched = false

  // debugging
  let debugOn = false
  
  //////////////// DID MOVE TO VIEW /////////////////
  
  override func didMoveToView(view: SKView) {
    
    backgroundLayer = childNodeWithName("backgroundLayer") as SKSpriteNode
    
    // set up playableRect
    let maxAspectRatio: CGFloat = 16.0 / 9.0
    let playableHeight = size.width / maxAspectRatio
    let playableMargin = (size.height - playableHeight) / 2.0
    playableRect = CGRect(x: 0, y: playableMargin, width: size.width, height: playableHeight)
    
    // set up edge loop
    let physicsRect = CGRect(x: 0,
                             y: playableRect.minY + 10,
                             width: playableRect.width,
                             height: 3 * playableRect.height)
    physicsBody = SKPhysicsBody(edgeLoopFromRect: physicsRect)
    
    // set up man
    man.setScale(manScale)
    man.position = CGPoint(x: 400, y: 240)
    man.zPosition = 100
    man.lightingBitMask = 1
    addChild(man)
    man.physicsBody = SKPhysicsBody(rectangleOfSize: man.size)
    man.physicsBody?.restitution = 0.0
    man.physicsBody?.usesPreciseCollisionDetection = true
    
    // set up walking animation
    for i in 2...12 {
      manTextures.append(SKTexture(imageNamed: "man\(i)"))
    }
    manAnimation = SKAction.repeatActionForever(
      SKAction.animateWithTextures(manTextures, timePerFrame: 0.08))
    
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
    
    // adjust background layer position.y
  //  backgroundLayer.position.y = -0.3 * (man.position.y - 230.5)
  }
  
  ///////////////// TOUCH HANDLING ///////////////////
  
  override func touchesBegan(touches: NSSet, withEvent event: UIEvent) {
//    let touch = touches.anyObject() as UITouch
//    let touchLocation = touch.locationInNode(self)
//    sceneTouched(touchLocation)
  }
  
  func sceneTouched(touchLocation: CGPoint) {}
  
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
  func startAnimation() {
    if man.actionForKey("animation") == nil {
      man.runAction(
        SKAction.repeatActionForever(manAnimation),
        withKey: "animation")
    }
  }
  
  func stopAnimation() {
    man.removeActionForKey("animation")
    man.texture = SKTexture(imageNamed: "man0")
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
    
    let airRotations = 1.0
    let duration = 1.0
    
    let rotationDirection = man.xScale > 0 ? CGFloat(-2 * airRotations * M_PI) : CGFloat(2 * airRotations * M_PI)
    let rotate = SKAction.rotateByAngle(rotationDirection, duration: duration)
    let shrink = SKAction.sequence([
      SKAction.scaleBy(0.8, duration: duration / 2),
      SKAction.scaleBy(1.25, duration: duration / 2)])
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
  
  func throw() {
    let projectile = SKSpriteNode(imageNamed: "a_button")
    projectile.position.x = man.position.x + projectile.size.width / 2
    projectile.position.y = man.position.y + 30
    projectile.size = CGSize(width: 50, height: 50)
    addChild(projectile)
    
    projectile.physicsBody = SKPhysicsBody(circleOfRadius: CGFloat(projectile.size.width / 2))
    projectile.runAction(
      SKAction.sequence([
        SKAction.runBlock({projectile.physicsBody!.applyImpulse(CGVector(dx: 50, dy: 70))}),
        SKAction.waitForDuration(10),
        SKAction.removeFromParent()]))
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
    throw()
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
