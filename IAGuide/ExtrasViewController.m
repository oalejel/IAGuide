//
//  ExtrasViewController.m
//  IAGuide
//
//  Created by Omar Alejel on 10/25/14.
//  Copyright (c) 2014 Omar Alejel. All rights reserved.
//

#import "ExtrasViewController.h"

@implementation ExtrasViewController

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.tabBarItem = [[UITabBarItem alloc] initWithTabBarSystemItem:UITabBarSystemItemMore tag:1];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self setBackgroundGradient];
}

- (void)setBackgroundGradient
{
    //create a gradient for the background
    CAGradientLayer *gradientLayer = [CAGradientLayer layer];
    gradientLayer.frame = self.view.frame;
    
    UIColor *firstColor = [UIColor colorWithRed:147.0/255 green:200.0/255 blue:252.0/255 alpha:1.0];
    UIColor *secondColor = [UIColor colorWithRed:102.0/255 green:94.0/255 blue:190.0/255 alpha:1.0];
    gradientLayer.colors = [NSArray arrayWithObjects:(id)firstColor.CGColor, (id)secondColor.CGColor, nil];
    
    [self.view.layer insertSublayer:gradientLayer atIndex:0];
}

@end
