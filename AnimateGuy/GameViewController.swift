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
    //let scene = GameScene(size: CGSize(width: 1024, height: 768))
      if let scene = GameScene(fileNamed: "Level1") {
      
      // retain aspect ratio across devices
      scene.scaleMode = .AspectFill
      
      // debugging
  //    skView.showsFPS = true
  //    skView.showsNodeCount = true
  //    skView.showsPhysics = true
      
      // an optimization
      skView.ignoresSiblingOrder = true
      
      // show the scene
      skView.presentScene(scene)
      
      // add control pad
      let padSide: CGFloat = view.frame.size.height / 4
      let padPadding: CGFloat = view.frame.size.height / 32
      let padFrame = CGRect(x: padPadding,
                            y: skView.frame.size.height - padPadding - padSide,
                            width: padSide,
                            height: padSide)
      
      analogControl = AnalogControl(frame: padFrame)
      view.addSubview(analogControl)
      analogControl.delegate = scene
    }
  }
  
  override func prefersStatusBarHidden() -> Bool {
    return true
  }
  
}
