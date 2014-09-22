//
//  HomeViewController.m
//  IASchoolGuide
//
//  Created by Omar Alejel on 8/21/14.
//  Copyright (c) 2014 Omar Alejel. All rights reserved.
//

#import "HomeViewController.h"
#import "LocationsSliderView.h"

@interface HomeViewController () 

@property (nonatomic, weak) IBOutlet MKMapView *mapView;
@property (nonatomic, weak) IBOutlet UITextField *searchField;
@property (nonatomic) CGRect textFieldReturnPoint;
@property (nonatomic) CGRect mapViewReturnPoint;
@property (nonatomic) BOOL isEditing;

@end

@implementation HomeViewController

- (instancetype)init
{
    self = [super init];
  
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    //set the textfield delegate to self
    self.searchField.delegate = self;
    self.textFieldReturnPoint = self.searchField.frame;
    
    //set up the mapView
    self.mapView.mapType = MKMapTypeSatellite;
    self.mapView.delegate = self;
    [self setBackgroundGradient];
    self.mapViewReturnPoint = self.mapView.frame;
    
    
//    UIView *view = [[UIView alloc] initWithFrame:self.mapView.frame];
//    view.backgroundColor = [UIColor orangeColor];
//    [self.view insertSubview:view belowSubview:self.mapView];
//    
//    UIView *secondView = [[UIView alloc] initWithFrame:self.searchField.frame];
//    view.backgroundColor = [UIColor blueColor];
//    [self.view insertSubview:secondView belowSubview:self.searchField];
//    
    //give the map a start location
    CLLocationDegrees lat = 42.603363;
    CLLocationDegrees lon = -83.226143;
    CLLocationCoordinate2D coordinate = CLLocationCoordinate2DMake(lat, lon);
    MKCoordinateRegion region = MKCoordinateRegionMakeWithDistance(coordinate, 0.001000, 0.001500);
    
    [self.mapView setRegion:region animated:YES];
}

- (void)mapView:(MKMapView *)mapView regionDidChangeAnimated:(BOOL)animated
{
    //get the region information for the current location
    float latitude = mapView.region.center.latitude;
    float longitude = mapView.region.center.longitude;
    float latDelta = mapView.region.span.latitudeDelta;
    float lonDelta = mapView.region.span.longitudeDelta;
    
    NSLog(@"Region lat: %f, long: %f, latD: %f, lonD: %f", latitude, longitude, latDelta, lonDelta);
    
    
    
    
    
    
    if (self.isEditing) {
        [self animateKeyboardReturn:self.searchField];
    }
}

#pragma mark - Simple Private Functions
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

#pragma mark - Delegate
- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField
{
    self.isEditing = YES;
    //change this animation speed value to look smother
    [UIView animateWithDuration:0.3 animations:^{
        CGPoint centerPoint = self.view.center;
        self.searchField.center = centerPoint;
        self.mapView.center = CGPointMake(centerPoint.x, 70);
    }];
    
    return YES;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [self animateKeyboardReturn:textField];
    NSLog(@"Should end editing");
    return YES;
}

- (void)animateKeyboardReturn:(UITextField *)textField
{
    self.isEditing = NO;
    //is the view the thing that resigns the first responder
    [textField resignFirstResponder];
    [UIView animateWithDuration:1.0 animations:^{
        self.mapView.frame = self.mapViewReturnPoint;
        self.searchField.frame = self.textFieldReturnPoint;
    }];
}

@end
