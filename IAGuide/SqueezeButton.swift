//
//  SqueezeButton.swift
//  Expense Tracker
//
//  Created by Omar Alejel on 6/30/15.
//  Copyright © 2015 omar alejel. All rights reserved.
//

import UIKit


class SqueezeButton: UIButton {
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
//     Only override drawRect: if you perform custom drawing.
//     An empty implementation adversely affects performance during animation.

    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        press()
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesEnded(touches, with: event)
        rescaleButton()
    }
    
    func press() {
        UIView.animateKeyframes(withDuration: 0.4, delay: 0.0, options: UIViewKeyframeAnimationOptions.calculationModeCubic, animations: { () -> Void in
            self.transform = self.transform.scaledBy(x: 0.9, y: 0.9)
            }) { (done) -> Void in
                
        }
    }
    
    func rescaleButton() {
        UIView.animateKeyframes(withDuration: 0.2, delay: 0.0, options: UIViewKeyframeAnimationOptions.calculationModeCubic, animations: { () -> Void in
            self.transform = self.transform.scaledBy(x: 1/0.9, y: 1/0.9)
            }) { (done) -> Void in
                
        }
    }
}
