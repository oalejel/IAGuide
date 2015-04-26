//
//  I.swift
//  IAGuide
//
//  Created by Omar Alejel on 4/25/15.
//  Copyright (c) 2015 Omar Alejel. All rights reserved.
//

import UIKit

@objc class Me: UIViewController {
    
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var button: UIButton!
    
    @IBAction func `continue`(sender: AnyObject) {
        presentingViewController?.dismissViewControllerAnimated(true, completion: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        imageView.layer.cornerRadius = 20
        imageView.layer.masksToBounds = true
        button.setImage(UIImage(named: "press"), forState: .Highlighted)
    }
}
