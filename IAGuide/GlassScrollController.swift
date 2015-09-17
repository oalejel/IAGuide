//
//  GlassScrollController.swift
//  IAGuide
//
//  Created by Omar Alejel on 7/20/15.
//  Copyright © 2015 Omar Alejel. All rights reserved.
//

/*
    - create it
    - set the view controllers
    - set the start Index
    - set it as the root view controller or something
*/

import UIKit

class GlassScrollController: UIViewController, UIScrollViewDelegate {
    var numberOfPages = 0
    var scrollView: UIScrollView!
    let bounds = UIScreen.mainScreen().bounds
    
    override func loadView() {
        scrollView = UIScrollView(frame: bounds)
        scrollView.pagingEnabled = true
        
        view = scrollView
    }
    
    func scrollViewDidScroll(scrollView: UIScrollView) {
        //create a glass-like refraction effect
        
    }
    
    func setViewControllers(controllers: [UIViewController]) {
        numberOfPages = controllers.count
        let contentWidth = bounds.size.width * CGFloat(numberOfPages)
        scrollView.contentSize = CGSizeMake(contentWidth, bounds.size.height)
        for (index, vc) in controllers.enumerate() {
            addChildViewController(vc)
            let subview = vc.view
            scrollView.addSubview(subview)
            subview.frame = CGRectMake(CGFloat(index) * bounds.size.width, 0, bounds.size.width, bounds.size.height)
            view.addSubview(subview)
        }
    }
    
    func setStartIndex(index: Int) {
        let screenWidth = bounds.size.width
        scrollView.contentOffset = CGPointMake(CGFloat(index) * screenWidth, 0)
    }
}

