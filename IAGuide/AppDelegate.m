//
//  AppDelegate.m
//  IAGuide
//
//  Created by Omar Alejel on 8/25/14.
//  Copyright (c) 2014 Omar Alejel. All rights reserved.
//

#import "AppDelegate.h"
#import "MapViewController.h"
#import "ExtrasViewController.h"
#import "GuideViewController.h"
#import "OlympicsViewController.h"
#import "IAGuide-Swift.h"           //import all swift

NSDateFormatter *dateFormatter = nil;
NSDictionary *scheduleTitles = nil;

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
    _window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    
    //global variable used by many classes - keep this early i
    dateFormatter = [[NSDateFormatter alloc] init];
    
    //set the root view controller as the startupcontroller
    GuideViewController *gvc = [[GuideViewController alloc] init];
    MapViewController *mvc = [[MapViewController alloc] init];
    OlympicsViewController *ovc = [[OlympicsViewController alloc] init];
    ExtrasViewController *evc = [[ExtrasViewController alloc] init];
    
    UITabBarController *tbc = [self setupApplicationTabBarController];
    tbc.viewControllers = @[gvc, mvc, ovc, evc];
    tbc.selectedIndex = 0;
    for (UITabBarItem *item in tbc.tabBar.items) {
        item.image = [item.image imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    }
    
    [UIApplication sharedApplication].statusBarStyle = UIStatusBarStyleLightContent;
        
    //still working on this
    scheduleTitles = @{
                        @"L1_Normal":@[@""],
                        @"L2_Normal":@[ @"" ],
                        @"L1_Late":@[],
                        @"L2_Late":@[],
                        @"L1_":@[],
                        };
    
    self.window.rootViewController = tbc;
    
    //initialize window default color, make it visible, and then return yes
    self.window.backgroundColor = [UIColor whiteColor];
    [self.window makeKeyAndVisible];
    return YES;
}

//create & setup the tab bar controller for the app
- (UITabBarController *)setupApplicationTabBarController
    {
        UITabBarController *tabBarController = [[UITabBarController alloc] init];
        tabBarController.tabBar.tintColor = [UIColor yellowColor]; //selected images are yellow

        [[UITabBarItem appearance] setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:[UIColor whiteColor], NSForegroundColorAttributeName, nil] forState:UIControlStateNormal];//unselected text is white
        [UITabBarItem.appearance setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:[UIColor yellowColor], NSForegroundColorAttributeName, nil] forState:UIControlStateSelected];//selected text is yellow
        tabBarController.tabBar.translucent = NO;
        //give tabbar the custom blue color
        tabBarController.tabBar.barTintColor = [UIColor colorWithRed:43.0/255.0 green:132.0/255.0 blue:211.0/255 alpha:1.0];

        return tabBarController;
}

@end
