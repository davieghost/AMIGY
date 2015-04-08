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

  ///////////////// PROPERTIES //////////////////
  
  let baseCenter: CGPoint
  let knobImageView: UIImageView
  
  var relativePosition: CGPoint!
  
  var delegate: AnalogControlPositionChange?
  
  /////////////// INITIALIZATION ///////////////
  
  override init(frame viewFrame: CGRect) {
    
    baseCenter = CGPoint(x: viewFrame.size.width / 2,
                         y: viewFrame.size.height / 2)
    
    knobImageView = UIImageView(image: UIImage(named: "knob"))
    
//    knobImageView.frame.size.width /= 2
//    knobImageView.frame.size.height /= 2
    knobImageView.frame.size = CGSize(width: 50, height: 50)
    
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
  
  //////////////// UPDATE KNOB POSITION //////////////
  
  func updateKnobWithPosition(position: CGPoint) {

    var positionToCenter = position - baseCenter
    let direction = positionToCenter == CGPointZero ? CGPointZero : positionToCenter.normalized()
    let radius = frame.size.width / 2
    var length = positionToCenter.length()
    
    if length > radius {
      length = radius
      positionToCenter = direction * radius
    }
    
    let relPosition = CGPoint(x: direction.x * (length/radius),
                              y: direction.y * (length/radius))
    
    knobImageView.center = baseCenter + positionToCenter
    relativePosition = relPosition
    
    delegate?.analogControlPositionChanged(self, position: relativePosition)
  }
  
  ///////////////// TOUCH HANDLERS ///////////////
  
  override func touchesBegan(touches: NSSet, withEvent event: UIEvent) {
    let touchLocation = touches.anyObject()!.locationInView(self)
    updateKnobWithPosition(touchLocation)
  }
  
  override func touchesMoved(touches: NSSet, withEvent event: UIEvent) {
    let touchLocation = touches.anyObject()!.locationInView(self)
    updateKnobWithPosition(touchLocation)
  }
  
  override func touchesEnded(touches: NSSet, withEvent event: UIEvent) {
    updateKnobWithPosition(baseCenter)
  }
  
  override func touchesCancelled(touches: NSSet, withEvent event: UIEvent) {
    updateKnobWithPosition(baseCenter)
  }
}
