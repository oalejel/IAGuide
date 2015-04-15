//
//  WebViewController.h
//  IAGuide
//
//  Created by Omar Alejel on 4/5/15.
//  Copyright (c) 2015 Omar Alejel. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface WebViewController : UIViewController

@property (nonatomic) NSURL *url;

- (instancetype)initWithURL:(NSURL *)url;
@end
