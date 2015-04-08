//
//  ButtonControl.swift
//  AnimateGuy
//
//  Created by Jacob Mensch on 4/8/15.
//  Copyright (c) 2015 uB. All rights reserved.
//

import UIKit

protocol ButtonPress {
  func buttonPressed(buttonControl: ButtonControl, buttonLetter: Character)
}

class ButtonControl: UIView {

  let buttonImageView: UIImageView
  var buttonLetter: Character = "Z"
  var delegate: ButtonPress?
  
  override init(frame viewFrame: CGRect) {
    buttonImageView = UIImageView(image: UIImage(named: "a_button"))
    super.init(frame: viewFrame)
    userInteractionEnabled = true
    addSubview(buttonImageView)
  }
  
  required init(coder aDecoder: NSCoder) {
    fatalError("NSCoding not supported")
  }
  
  override func touchesBegan(touches: NSSet, withEvent event: UIEvent) {
    delegate?.buttonPressed(self, buttonLetter: self.buttonLetter)
  }
}
