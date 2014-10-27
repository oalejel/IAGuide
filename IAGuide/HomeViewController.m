//
//  HomeViewController.m
//  IASchoolGuide
//
//  Created by Omar Alejel on 8/21/14.
//  Copyright (c) 2014 Omar Alejel. All rights reserved.
//

#import "HomeViewController.h"
#import "Location.h"
#import "LocationStore.h"
#import "OutlineOverlayRenderer.h"
#import "OutlineOverlay.h"

@interface HomeViewController () 

@property (nonatomic, weak) IBOutlet MKMapView *mapView;
@property (nonatomic, weak) IBOutlet UITextField *searchField;
@property (nonatomic) CGRect textFieldReturnPoint;
@property (nonatomic) CGRect mapViewReturnPoint;
@property (nonatomic) BOOL isEditing;

@end

@implementation HomeViewController

#pragma mark - Initializers
- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    if (self)
    {
        //override intialization process - not much with the view should be done
        self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
        UIImage *image = [UIImage imageNamed:@"compass"];
        self.tabBarItem = [[UITabBarItem alloc] initWithTitle:@"Map" image:image tag:0];
    }
    
    return self;
}

#pragma mark - View Setup
//the reason these properties are set here is the fact that the nib with the mapView is not loaded until viewDidLoad
- (void)viewDidLoad
{
    [super viewDidLoad];
    
    //set the textfield delegate to self
    self.searchField.delegate = self;
    
    //set up the mapView
    self.mapView.delegate = self;
    self.mapView.mapType = MKMapTypeSatellite;
    self.mapView.showsUserLocation = YES;
    self.mapView.zoomEnabled = NO;
    self.mapView.scrollEnabled = NO;
    
    [self setBackgroundGradient];
    [self setLocation];
    [self setCamera];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self addSchoolOverlayToMap];
}

- (void)setLocation
{
    //give the map a start location
    CLLocationDegrees lat = 42.603373;
    CLLocationDegrees lon = -83.226150;
    CLLocationCoordinate2D coordinate = CLLocationCoordinate2DMake(lat, lon);
    
    MKCoordinateRegion schoolRegion = MKCoordinateRegionMakeWithDistance(coordinate, 155, 0);
    MKCoordinateRegion region = [self.mapView regionThatFits:schoolRegion];
    [self.mapView setRegion:region];
}

- (void)setCamera
{
    MKMapCamera *camera = [self.mapView.camera copy];
    [camera setHeading:179.0];
    [self.mapView setCamera:camera];
    //keep it from changing after this - this might actually not be necessary
    self.mapView.rotateEnabled = NO;
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

- (void)addSchoolOverlayToMap
{
    CLLocationCoordinate2D array[4] = {CLLocationCoordinate2DMake(42.602941, -83.225584),
        CLLocationCoordinate2DMake(42.602941, -83.226743),
        CLLocationCoordinate2DMake(42.603796, -83.226743),
        CLLocationCoordinate2DMake(42.603796, -83.225584)};
    
    
    MKPolygon *polygon = [MKPolygon polygonWithCoordinates:array count:4];
    [self.mapView addOverlay:polygon];
}

#pragma mark - Delegate & Map
- (void)mapView:(MKMapView *)mapView regionDidChangeAnimated:(BOOL)animated
{
    if (self.isEditing) {
        [self animateKeyboardReturn:self.searchField];
    }
    
    //get the region information for the current location
    float latitude = mapView.region.center.latitude;
    float longitude = mapView.region.center.longitude;
    float latDelta = mapView.region.span.latitudeDelta;
    float lonDelta = mapView.region.span.longitudeDelta;
    
    NSLog(@"Region lat: %f, long: %f, latD: %f, lonD: %f", latitude, longitude, latDelta, lonDelta);
}

- (MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(id<MKAnnotation>)annotation
{
    //this statement is important since the userlocation view is sent through here
    //you might want to change the current location pin view so it's just a circle
    if ([annotation isKindOfClass:[Location class]]) {
        
        MKPinAnnotationView *annotationPin = (MKPinAnnotationView *)[self.mapView dequeueReusableAnnotationViewWithIdentifier:@"AnnotationView"];
        
        //might not need this later
        if (!annotationPin) {
            annotationPin = [[MKPinAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:@"AnnotationPin"];
        }
        annotationPin.canShowCallout = YES;
        annotationPin.draggable = YES;
        return annotationPin;
        
    } else {
        MKAnnotationView *pinView = [[MKAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:@"CurrentLocationAnnotation"];
        //create a circle image based on the file for user loc.
        UIImage *image = [UIImage imageNamed:@"Circle2"];
        pinView.image = image;
        
        return pinView;
    }
}

- (void)mapView:(MKMapView *)mapView didAddAnnotationViews:(NSArray *)views
{
    for (MKPinAnnotationView *pinView in views) {
        [self.mapView selectAnnotation:pinView.annotation animated:YES];
    }
}

- (MKOverlayRenderer *)mapView:(MKMapView *)mapView rendererForOverlay:(id<MKOverlay>)overlay
{
    OutlineOverlayRenderer *renderer = [[OutlineOverlayRenderer alloc] initWithOverlay:overlay];
    return renderer;
}

- (void)mapView:(MKMapView *)mapView annotationView:(MKAnnotationView *)view didChangeDragState:(MKAnnotationViewDragState)newState fromOldState:(MKAnnotationViewDragState)oldState
{
    if (newState == MKAnnotationViewDragStateEnding) {
            CLLocationCoordinate2D droppedAt = view.annotation.coordinate;
            NSLog(@"Pin dropped at %f,%f", droppedAt.latitude, droppedAt.longitude);
    }
}

- (void)addLocationToMap:(Location *)location
{
    [self.mapView addAnnotation:location];
}

#pragma mark - Search Field methods
- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    NSLog(@"Should end editing");
    [self animateKeyboardReturn:textField];
    
    return YES;
}

//problem - on large screens, the views arent moving upwards
- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField
{
    self.isEditing = YES;
    
    CGRect zeroRect = CGRectMake(0, 0, 0, 0);
    
    //check if these values are unset
    if (self.mapViewReturnPoint.origin.x ==  zeroRect.origin.x) {
        self.mapViewReturnPoint = self.mapView.frame;
    }
    
    if (self.textFieldReturnPoint.origin.x ==  zeroRect.origin.x) {
        self.textFieldReturnPoint = self.searchField.frame;
    }
    
    if (self.searchField.textColor == [UIColor redColor]) {
        self.searchField.textColor = [UIColor blackColor];
    }
    
    //change this animation speed value to look smoother
    [UIView animateWithDuration:0.3 animations:^{
        CGPoint centerPoint = self.view.center;
        //fix this return point to look better
        CGPoint searchFieldPoint = CGPointMake(centerPoint.x, (self.searchField.frame.size.height / 2) + (self.mapView.frame.size.height / 2) + 19);
        self.searchField.center = searchFieldPoint;
        self.mapView.center = CGPointMake(centerPoint.x, 0);
    }];
    
    return YES;
}

- (void)animateKeyboardReturn:(UITextField *)textField
{
    //is the view the thing that resigns the first responder
    [textField resignFirstResponder];
    self.isEditing = NO;
    [UIView animateWithDuration:0.3 animations:^{
        self.mapView.frame = self.mapViewReturnPoint;
        self.searchField.frame = self.textFieldReturnPoint;
    }];
}

- (IBAction)searchFieldReturned:(UITextField *)sender {
    NSString *text = sender.text;
    int textInt = [text intValue];
    
    NSNumber *number = [NSNumber numberWithInt:textInt];
    Location *searchedLocation = [[LocationStore sharedStore] locationForRoomNumber:number];
    if (!searchedLocation) {
        self.searchField.textColor = [UIColor redColor];
        return;
    }
    
    [self.mapView removeAnnotations:self.mapView.annotations];
    [self addLocationToMap:searchedLocation];
}

#pragma mark - Touch Events
- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    if (self.isEditing) {
        [self animateKeyboardReturn:self.searchField];
    }
}

@end
