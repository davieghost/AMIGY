//
//  GameViewController.swift
//  AnimateGuy
//
//  Created by Jacob Mensch on 4/7/15.
//  Copyright (c) 2015 uB. All rights reserved.
//

import UIKit
import SpriteKit

class GameViewController: UIViewController {
  
  var analogControl: AnalogControl!
  
  override func viewDidLoad() {
    
    super.viewDidLoad()
    let skView = self.view as SKView
    
    // ...........................................................
    
    // makes the scene the size of the view (regardless of device)
    // can't depend on a regular coordinate system
    // images DON'T scale
    // let scene = GameScene(size: skView.bounds.size)
    
    // makes the view a fixed size
    // regular coordinate system across devices
    // images scale
    let scene = GameScene(size: CGSize(width: 1024, height: 768))
    
    // ...........................................................
    
    // retain aspect ratio across devices
    scene.scaleMode = .AspectFill
    
    // set gravity to zero (just for the first couple seconds)
    //  scene.physicsWorld.gravity = CGVector(dx: 0, dy: 0)
    
    // debugging
    //    skView.showsFPS = true
    //    skView.showsNodeCount = true
    //    skView.showsPhysics = true
    
    // an optimization
    skView.ignoresSiblingOrder = true
    
    // show the scene
    skView.presentScene(scene)
    
    let padSide: CGFloat = view.frame.size.height / 4
    let padPadding: CGFloat = view.frame.size.height / 32
    
    analogControl = AnalogControl(frame: CGRectMake(padPadding,
      skView.frame.size.height - padPadding - padSide,
      padSide, padSide))
    
    view.addSubview(analogControl)
    
    analogControl.delegate = scene
  }
  
  override func prefersStatusBarHidden() -> Bool {
    return true
  }
  
}
