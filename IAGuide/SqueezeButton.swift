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

    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        super.touchesBegan(touches, withEvent: event)
        press()
    }

    override func touchesEnded(touches: Set<UITouch>, withEvent event: UIEvent?) {
        super.touchesEnded(touches, withEvent: event)
        rescaleButton()
    }
    
    func press() {
        UIView.animateKeyframesWithDuration(0.4, delay: 0.0, options: UIViewKeyframeAnimationOptions.CalculationModeCubic, animations: { () -> Void in
            self.transform = CGAffineTransformScale(self.transform, 0.9, 0.9)
            }) { (done) -> Void in
                
        }
    }
    
    func rescaleButton() {
        UIView.animateKeyframesWithDuration(0.2, delay: 0.0, options: UIViewKeyframeAnimationOptions.CalculationModeCubic, animations: { () -> Void in
            self.transform = CGAffineTransformScale(self.transform, 1/0.9, 1/0.9)
            }) { (done) -> Void in
                
        }
    }
}
