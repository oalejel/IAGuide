//
//  MapViewController.m
//  IASchoolGuide
//
//  Created by Omar Alejel on 8/21/14.
//  Copyright (c) 2014 Omar Alejel. All rights reserved.
//

#import "MapViewController.h"
#import "InfoViewController.h"//contains room info
#import "LocationStore.h"
#import "LocationTable.h"//table with room (maybe class) choices
#import "OutlineOverlayRenderer.h"
//#import "StartupViewController.h"

#import "IAGuide-Swift.h"//this will allow swift files to interact with objc

@interface MapViewController ()
/// @brief setting this to 'true' sets the tableview search rooms by teacher
@property (nonatomic) BOOL filterByTeacher;
@property (nonatomic) BOOL inputViewIsToggled;
@property (nonatomic) BOOL isEditing;
@property (nonatomic) BOOL viewAppearedBefore; //to be used in viewwillappear to check if this happened
@property (nonatomic) CGRect inputViewRect;//used to return inputview frame to original size after animation
@property (nonatomic) LocationTable *locationTable;
@property (nonatomic) MKCoordinateRegion initialMapRegion;//locatation of school
@property (nonatomic, strong) CLLocationManager *locationManager; //ask for location services permission
@property (weak, nonatomic) IBOutlet MKMapView *mapView;//shows room locations/pinview callouts trigger InfoViewController
@property (weak, nonatomic) IBOutlet UIButton *toggleButton; //toggle table with room/teacher choices
@property (weak, nonatomic) IBOutlet UITextField *searchField;//to search by room/possibly teachers
@property (weak, nonatomic) IBOutlet UIView *headerView;//blue box above map that says "find your way"
@property (weak, nonatomic) IBOutlet UIView *inputView;//contains textfield and tableview
@property (weak, nonatomic) IBOutlet UISegmentedControl *filterSegmentControl;

@end


@implementation MapViewController //methods are defined here

#pragma mark - Initializers
- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:@"MapViewController" bundle:[NSBundle mainBundle]];
    if (self)
    {
        UIImage *image = [UIImage imageNamed:@"compass"];
        UIImage *selImage = [UIImage imageNamed:@"compass_sel"];
        self.tabBarItem = [[UITabBarItem alloc] initWithTitle:@"Map"
                                                        image:image
                                                selectedImage:selImage];
    }
    
    return self;
}

#pragma mark - View Setup
- (void)viewDidLoad //ib outlets can only have properties set after view is loaded
{
    [super viewDidLoad];
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        //ask for location services permission
        self.locationManager = [[CLLocationManager alloc] init];
        self.locationManager.delegate = self;
        
        if ([self.locationManager respondsToSelector:@selector(requestWhenInUseAuthorization)]) {
            [self.locationManager requestWhenInUseAuthorization];
            [self.locationManager startUpdatingLocation];//might need to take out of if statement
        }
    });
    
    //set up the mapView
    self.mapView.delegate = self;
    self.mapView.mapType = MKMapTypeSatellite;
    self.mapView.showsUserLocation = YES;
    self.mapView.userTrackingMode = MKUserTrackingModeNone; //so map does not adjust its focus to current loc.
    self.mapView.zoomEnabled = NO;
    self.mapView.scrollEnabled = NO;
    self.mapView.alpha = 0.0; //Once it renders, it will change its alpha
    
    [self setLocation];//set mapview location to IA's location
    [self setCamera];//rotate map so that school entrance faces down
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    if (!self.viewAppearedBefore) {
        [self setBackgroundGradient];
        [self addSchoolOverlayToMap];//might want to change when this happens
    }
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    if (!self.viewAppearedBefore) {
        //set the textfield delegate to self
        self.searchField.delegate = self;
        
        [self.filterSegmentControl addTarget:self action:@selector(roomTableFilterChanged:) forControlEvents:UIControlEventValueChanged];
        
        //needs adjustment
        self.inputViewRect = self.inputView.frame;
        CGRect tableRect = CGRectMake(0, 100, [self.view bounds].size.width, self.view.frame.size.height - 120 - self.tabBarController.tabBar.frame.size.height);
        
        self.locationTable = [[LocationTable alloc] initWithTableviewFrame:tableRect homeController:self];
        [self.inputView insertSubview:self.locationTable atIndex:0];
        self.viewAppearedBefore = true;
    }
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


#pragma mark - Delegate & Map
//This function sets the mapView's location
- (void)setLocation
{
    //give the map a start location
    CLLocationDegrees lat = 42.603373;
    CLLocationDegrees lon = -83.226150;
    CLLocationCoordinate2D coordinate = CLLocationCoordinate2DMake(lat, lon);
    
    //watchthe y value here
    MKCoordinateRegion schoolRegion = MKCoordinateRegionMakeWithDistance(coordinate, 155, 100);
    MKCoordinateRegion region = [self.mapView regionThatFits:schoolRegion];
    [self.mapView setRegion:region];
    self.initialMapRegion = self.mapView.region;
}

//sets the map's angle
- (void)setCamera
{
    MKMapCamera *camera = [self.mapView.camera copy];
    [camera setHeading:179.0];
    [self.mapView setCamera:camera];
    //keep it from changing after this - this might actually not be necessary
    self.mapView.rotateEnabled = NO;
}

//changes the alpha of the mapview after it loads so things do look laggy
- (void)mapViewDidFinishRenderingMap:(MKMapView *)mapView fullyRendered:(BOOL)fullyRendered
{
        [UIView animateWithDuration:0.5 animations:^{
            self.mapView.alpha = 1.0;
        }];
}

//sets up pins on the map
- (MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(id<MKAnnotation>)annotation
{
    //this statement is important since the userlocation view is sent through here
    //you might want to change the current location pin view so it's just a circle
    if ([annotation isKindOfClass:[Location class]]) {
        
        MKPinAnnotationView *annotationPin = (MKPinAnnotationView *)[self.mapView dequeueReusableAnnotationViewWithIdentifier:@"Annotation"];
        
        //might not need this later
        if (!annotationPin) {
            annotationPin = [[MKPinAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:@"Annotation"];
        }
        
        annotationPin.canShowCallout = YES;
        annotationPin.draggable = NO;
        
        annotationPin.rightCalloutAccessoryView = [UIButton buttonWithType:UIButtonTypeDetailDisclosure];
        
        return annotationPin;
    } else if (annotation == self.mapView.userLocation) {
        MKAnnotationView *pinView = [[MKAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:@"CurrentLocationAnnotation"];
        pinView.canShowCallout = YES;
        UIImage *image = [UIImage imageNamed:@"Circle"];
        UIImage *secondImage = [UIImage imageWithCGImage:image.CGImage scale:3.5 orientation:UIImageOrientationUp];
        pinView.image = secondImage;
        
        return pinView;
    } else {
        return nil;
    }
}

/*!
 * @discussion Creates shapes for overlays to put on the map
 */
- (void)addSchoolOverlayToMap
{
    //create a circle and with a given center and radius and a polygon to put the map image in
    CLLocationCoordinate2D array[4] = {CLLocationCoordinate2DMake(42.602941, -83.225584),
        CLLocationCoordinate2DMake(42.602941, -83.226743),
        CLLocationCoordinate2DMake(42.603796, -83.226743),
        CLLocationCoordinate2DMake(42.603796, -83.225584)};
    
    MKCircle *circle = [MKCircle circleWithCenterCoordinate:CLLocationCoordinate2DMake(42.603373, -83.226150) radius:400];
    [self.mapView addOverlay:circle];
    
    MKPolygon *polygon = [MKPolygon polygonWithCoordinates:array count:4];
    [self.mapView addOverlay:polygon];
}

//this function returns overlay renderers for a white circle that is put behind IA's map image and the map image itself
- (MKOverlayRenderer *)mapView:(MKMapView *)mapView rendererForOverlay:(id<MKOverlay>)overlay
{
    //only mkcircles and the map outline polygon should go here
    if ([overlay isKindOfClass:[MKCircle class]]) {
        MKCircleRenderer *circleRenderer = [[MKCircleRenderer alloc] initWithCircle:overlay];
        circleRenderer.fillColor = [UIColor whiteColor];
        circleRenderer.alpha = 0.6;
        
        return circleRenderer;
    } else if ([overlay isKindOfClass:[MKPolygon class]]) {
        OutlineOverlayRenderer *renderer = [[OutlineOverlayRenderer alloc] initWithOverlay:overlay];
        
        return renderer;
    } else {
        return nil;
    }
}

//I this function to select
- (void)mapView:(MKMapView *)mapView didAddAnnotationViews:(NSArray *)views //might not need for loop?
{
    for (MKPinAnnotationView *pinView in views) {
        [self.mapView selectAnnotation:pinView.annotation animated:YES];
    }
}

//this function creates an InfoViewCOntroller to show info on a class's schedule
- (void)mapView:(MKMapView *)mapView annotationView:(MKAnnotationView *)view calloutAccessoryControlTapped:(UIControl *)control
{
    //if a custom annotation was tapped: open a view controller with some info
    if ([view.annotation isKindOfClass:[Location class]]) {
        Location *loc = (Location *)view.annotation;
        InfoViewController *ivc = [[InfoViewController alloc] initWithRoomNumber:(int)loc.roomNumber]; // you might want to have a strong property for this so you do not have to constantly waste memory on new ones
        UINavigationController *nvc = [[UINavigationController alloc] initWithRootViewController:ivc];
        nvc.navigationBar.barTintColor = [UIColor colorWithRed:0.2 green:0.4 blue:0.9 alpha:1.0];
        nvc.navigationBar.tintColor = [UIColor whiteColor];
        NSDictionary *attrib = @{ NSForegroundColorAttributeName : [UIColor whiteColor] };
        nvc.navigationBar.titleTextAttributes = attrib;
        
        ivc.navigationItem.title = [NSString stringWithFormat:@"%@ Schedule", loc.title];
        [self presentViewController:nvc animated:YES completion:nil];
    }
}

#pragma mark - Search Field Delegate
- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    if (self.isEditing) {
        self.isEditing = false;
        [self.searchField resignFirstResponder];
        if (self.inputViewIsToggled) {
            [self toggleLocationTable:self];
        }
        
        NSString *text = textField.text;
        int textInt = [text intValue];
        
        NSNumber *roomNumber = [NSNumber numberWithInt:textInt];
        Location *roomLocation = [[LocationStore sharedStore] locationForRoomNumber:roomNumber];
        
        if (!roomLocation) {
            self.searchField.textColor = [UIColor redColor];
            return YES;
        }
        
        [self addLocationToMap:roomLocation];
        
        return YES;
    }
    return NO;
}

//problem - on large screens, the views arent moving upwards
- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField
{
    self.isEditing = YES;
    
    if (self.searchField.textColor == [UIColor redColor]) {
        self.searchField.textColor = [UIColor darkGrayColor];
    }
    
    if (self.initialMapRegion.center.latitude != self.mapView.region.center.latitude) {
        [self.mapView setCenterCoordinate:self.initialMapRegion.center animated:YES];
    }
    
    return YES;
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    if (self.inputViewIsToggled && self.filterByTeacher) {
        [self.locationTable reloadTableWithFilterString:string];
    }
    
    return YES;
}

#pragma mark - Touch Events
- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    if (self.isEditing) {
        [self textFieldShouldReturn:self.searchField];
    }
}

- (IBAction)toggleLocationTable:(id)sender {
     UIView *inputView = self.inputView; //just a pointer

    if (!self.inputViewIsToggled) {
        self.inputViewIsToggled = true;
        CGFloat superViewHeight = self.view.bounds.size.height;
        CGPoint point = inputView.frame.origin;
        CGSize size = inputView.frame.size;
        int k = self.tabBarController.tabBar.frame.size.height;
        
        [UIView animateWithDuration:0.7 animations:^{
            inputView.frame = CGRectMake(point.x, point.y, size.width, superViewHeight - k);
        }];
    } else {
        self.inputViewIsToggled = false;
        //go back to the default 
        [self.filterSegmentControl setSelectedSegmentIndex:0];
        self.filterByTeacher = NO;
        [UIView animateWithDuration:0.7 animations:^{
            inputView.frame = self.inputViewRect;
        }];
    }
}

- (void)showRoomLocationWithRoomNumber:(NSNumber *)number
{
    [self toggleLocationTable:self]; //check to make sure that its ok for the sender to be self
    
    [self addLocationToMap:[[LocationStore sharedStore] locationForRoomNumber:number]];
}

/*!
 * @discussion just like superclass method of addAnnotation: but removes old annotations
 * @param location Location object that is added to map View
 */
- (void)addLocationToMap:(Location *)location
{
    [self.mapView removeAnnotations:self.mapView.annotations];
    [self.mapView addAnnotation:location];
}

- (void)roomTableFilterChanged:(UISegmentedControl *)sender {
    if (sender.selectedSegmentIndex == 1) {
        self.filterByTeacher = YES;
    } else {
        self.filterByTeacher = NO;
    }
}

- (void)setFilterByTeacher:(BOOL)filterByTeacher
{
    [self.locationTable reloadTableWithTeacherFilter:filterByTeacher];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    
    //will clear big dictionary containing room info if run out of memory
    [[LocationStore sharedStore] clearDataForMemoryWarning];
    [self.mapView removeAnnotations:self.mapView.annotations];
}

@end
