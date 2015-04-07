//
//  AnalogControl.swift
//  AnimateGuy
//
//  Created by Jacob Mensch on 4/7/15.
//  Copyright (c) 2015 uB. All rights reserved.
//

import UIKit


protocol AnalogControlPositionChange {
  func analogControlPositionChanged(
    analogControl: AnalogControl, position: CGPoint)
}

class AnalogControl: UIView {

    /*
    // Only override drawRect: if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func drawRect(rect: CGRect) {
        // Drawing code
    }
    */
  
  let baseCenter: CGPoint
  let knobImageView: UIImageView
  
  var relativePosition: CGPoint!
  
  var delegate: AnalogControlPositionChange?
  
  override init(frame viewFrame: CGRect) {
    
    baseCenter = CGPoint(x: viewFrame.size.width / 2,
                         y: viewFrame.size.height / 2)
    
    knobImageView = UIImageView(image: UIImage(named: "knob"))
    knobImageView.frame.size.width /= 2
    knobImageView.frame.size.height /= 2
    knobImageView.center = baseCenter
    
    super.init(frame: viewFrame)
    
    userInteractionEnabled = true
    
    let baseImageView = UIImageView(frame: bounds)
    baseImageView.image = UIImage(named: "base")
    addSubview(baseImageView)
    
    addSubview(knobImageView)
    
    assert(CGRectContainsRect(bounds, knobImageView.bounds), "Analog control should be larger than the knob in size")
  }

  required init(coder aDecoder: NSCoder) {
    fatalError("NSCoding not supported")
  }
  
  func updateKnobWithPosition(position:CGPoint) {
    //1
    var positionToCenter = position - baseCenter
    var direction: CGPoint
    
    if positionToCenter == CGPointZero {
      direction = CGPointZero
    } else {
      direction = positionToCenter.normalized()
    }
    
    //2
    let radius = frame.size.width/2
    var length = positionToCenter.length()
    
    //3
    if length > radius {
      length = radius
      positionToCenter = direction * radius
    }
    
    let relPosition = CGPoint(x: direction.x * (length/radius),
      y: direction.y * (length/radius))
    
    knobImageView.center = baseCenter + positionToCenter
    relativePosition = relPosition
    
    delegate?.analogControlPositionChanged(self,
      position: relativePosition)
    
  }
  
  override func touchesBegan(touches: NSSet,
    withEvent event: UIEvent) {
      
      let touchLocation = touches.anyObject()!.locationInView(self)
      updateKnobWithPosition(touchLocation)
  }
  
  override func touchesMoved(touches: NSSet,
    withEvent event: UIEvent) {
      
      let touchLocation = touches.anyObject()!.locationInView(self)
      updateKnobWithPosition(touchLocation)
  }
  
  override func touchesEnded(touches: NSSet,
    withEvent event: UIEvent) {
      
      updateKnobWithPosition(baseCenter)
  }
  
  override func touchesCancelled(touches: NSSet,
    withEvent event: UIEvent) {
      
      updateKnobWithPosition(baseCenter)
  }

  
}
