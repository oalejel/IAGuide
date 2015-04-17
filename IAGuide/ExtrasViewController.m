//
//  ExtrasViewController.m
//  IAGuide
//
//  Created by Omar Alejel on 10/25/14.
//  Copyright (c) 2014 Omar Alejel. All rights reserved.
//

#import "ExtrasViewController.h"
#import <MapKit/MapKit.h>
#import <MessageUI/MessageUI.h>

@interface ExtrasViewController () <MFMailComposeViewControllerDelegate, UINavigationControllerDelegate>

@property (nonatomic) BOOL viewAppearedBefore;
@property (nonatomic) NSArray *locations;
@property (nonatomic) NSDictionary *launchOptions;

@end

@implementation ExtrasViewController

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.tabBarItem = [[UITabBarItem alloc] initWithTitle:@"More" image:[UIImage imageNamed:@"more"] selectedImage:[UIImage imageNamed:@"more_selected"]];
    }
    return self;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    if (!self.viewAppearedBefore) {
        [self setBackgroundGradient];
        self.viewAppearedBefore = true;
    }
    
    // Create an MKMapItem to pass to the Maps app
    CLLocationCoordinate2D coordinate = CLLocationCoordinate2DMake(42.603373, -83.226150);
    MKPlacemark *placemark = [[MKPlacemark alloc] initWithCoordinate:coordinate
                                                   addressDictionary:nil];
    MKMapItem *mapItem = [[MKMapItem alloc] initWithPlacemark:placemark];
    [mapItem setName:@"International Academy Central"];

    // Get the "Current User Location" MKMapItem
    MKMapItem *currentLocationMapItem = [MKMapItem mapItemForCurrentLocation];
    self.locations = @[currentLocationMapItem, mapItem];
    self.launchOptions = @{MKLaunchOptionsDirectionsModeKey : MKLaunchOptionsDirectionsModeDriving};
}

- (void)setBackgroundGradient
{
    //create a gradient for the background
    CAGradientLayer *gradientLayer = [CAGradientLayer layer];
    gradientLayer.frame = self.view.frame;
    
    UIColor *firstColor = [UIColor colorWithRed:105.0/255 green:220.0/255 blue:255.0/255 alpha:1.0];
    UIColor *secondColor = [UIColor colorWithRed:0.0 green:0.17 blue:0.9 alpha:1.0];
    gradientLayer.colors = [NSArray arrayWithObjects:(id)firstColor.CGColor, (id)secondColor.CGColor, nil];
    
    [self.view.layer insertSublayer:gradientLayer atIndex:0];
}
- (IBAction)openHomeWebsite:(id)sender
{
    NSURL *websiteurl = [NSURL URLWithString:@"http://www.iatoday.org/international/index.aspx"];
    [[UIApplication sharedApplication] openURL:websiteurl];
}

- (IBAction)openMapApp:(id)sender
{
    Class mapItemClass = [MKMapItem class]; //the following if is important for ios 6 compatibility
    if (mapItemClass && [mapItemClass respondsToSelector:@selector(openMapsWithItems:launchOptions:)])
    {
        
        // Pass the current location and destination map items to the Maps app
        // Set the direction mode in the launchOptions dictionary
        [MKMapItem openMapsWithItems:self.locations
                       launchOptions:self.launchOptions];
    }
}

- (IBAction)viewSourcePressed:(id)sender {
    NSURL *gitURL = [NSURL URLWithString:@"https://github.com/oalejel/IAGuide"];
    [[UIApplication sharedApplication] openURL:gitURL];
}

- (IBAction)feedbackButtonPressed:(id)sender
{
    if ([MFMailComposeViewController canSendMail]) {
        MFMailComposeViewController *mailViewController = [[MFMailComposeViewController alloc] init];
        mailViewController.mailComposeDelegate = self;
        [mailViewController setSubject:@"Feedback for IA Guide"];
        [mailViewController setTitle:@"Send Feedback"];
        [mailViewController setToRecipients:@[@"omalsecondary@gmail.com"]];
        
        [self presentViewController:mailViewController animated:YES completion:nil];
    }
}

- (void)mailComposeController:(MFMailComposeViewController *)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError *)error
{
    [[controller presentingViewController] dismissViewControllerAnimated:YES completion:nil];
}

@end
