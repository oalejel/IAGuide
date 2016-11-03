//
//  GuideViewController.m
//  IAGuide
//
//  Created by Omar Alejel on 11/5/14.
//  Copyright (c) 2014 Omar Alejel. All rights reserved.
//

#import "AppDelegate.h"
#import "DetailTableCell.h" //this was originally for classes but can still use here
#import "TodayManager.h"
#import "GuideViewController.h"
#import "MXLCalendar.h"
#import "MXLCalendarEvent.h"
#import "MXLCalendarManager.h"
#import "ClassBlockViewContainer.h"

@interface GuideViewController () <UITableViewDataSource, UITableViewDelegate>

@property (nonatomic) BOOL finishedAnimaton;
@property (nonatomic) BOOL isADay;
@property (nonatomic) BOOL viewAppearedBefore;
@property (nonatomic) ClassBlockViewContainer *scheduleView;
@property (nonatomic) MXLCalendar *eventsCalendar;
@property (nonatomic) NSMutableArray *eventsArray;

@property (nonatomic) UIImage *aImage; //aday
@property (nonatomic) UIImage *bImage; //bday
@property (strong, nonatomic) UIImageView *dayImageView;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *tableLoadingView;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UIView *calendarHeaderView; // dont mess with this

@property (nonatomic) NSDate *lastOpenedDate;

@end

@implementation GuideViewController

#pragma mark - Initializers
- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.tabBarItem = [[UITabBarItem alloc] initWithTitle:@"Today" image:[UIImage imageNamed:@"star"] selectedImage:[UIImage imageNamed:@"star_selected"]];
        self.aImage = [UIImage imageNamed:@"aday"];
        self.bImage = [UIImage imageNamed:@"bday"];
    }
    
    return self;
}

#pragma mark - View life cycle

- (void)viewDidLoad {
    [super viewDidLoad];
    
    //register the ClassCell class with the tableview so it can use it in dequeuereusablecell: method
    [self.tableView registerClass:[DetailTableCell class] forCellReuseIdentifier:@"Cell"];
        
    //the position will be set in viewWillAppear
    self.scheduleView = [[ClassBlockViewContainer alloc] init];
    self.scheduleView.layer.cornerRadius = 5;
    self.scheduleView.layer.masksToBounds = YES;
    
    // Do any additional setup after loading the view from its nib.
    //self.dayImageView.image = [UIImage imageNamed:@"bday"];
    self.tableView.backgroundColor = [UIColor clearColor];
    self.tableView.backgroundView.backgroundColor = [UIColor clearColor];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    
    self.isADay = [[TodayManager sharedClassManager] todayIsAnADay:[NSDate date]]; //get bool value on whether it is an a day
    UIImage *yesterdayImage;
    if (self.isADay) {
        yesterdayImage = self.bImage; //using opposite image so that i can animate a change
    } else {
        yesterdayImage = self.aImage;
    }
    
    self.dayImageView = [[UIImageView alloc] initWithImage:yesterdayImage];
    self.finishedAnimaton = true; //this will be set to false later
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(appIsActive)
                                                 name:UIApplicationDidBecomeActiveNotification
                                               object:nil];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    if (!self.viewAppearedBefore) {
        [self setBackgroundGradient];
        [self updateCurrentEvents];
        
        CGPoint origin = self.calendarHeaderView.frame.origin;
        CGSize size = self.calendarHeaderView.frame.size;
        CGRect rect = CGRectMake(self.view.center.x - (size.width/2), origin.y + size.height, size.width, size.width);
        self.dayImageView.frame = rect;
        [self.view insertSubview:self.dayImageView aboveSubview:self.calendarHeaderView];
    
        //add the scheduleView
        CGRect calendarFrame = self.dayImageView.frame;
        CGFloat centerY = ((calendarFrame.origin.y + calendarFrame.size.height) + (self.tableView.frame.origin.y)) / 2;
        self.scheduleView.center = CGPointMake(self.view.center.x, centerY);
        [self.view insertSubview:self.scheduleView aboveSubview:self.tableView];
        self.lastOpenedDate = [NSDate date];
    } else {
        dateFormatter.dateFormat = @"D";
        if ([dateFormatter stringFromDate:self.lastOpenedDate] != [dateFormatter stringFromDate:[NSDate date]]) {
            //day of month not the same; reset tgings that are time dependent
            [self prepareForNewDay];
            self.lastOpenedDate = [NSDate date];
        }
    }
}

- (void)appIsActive {
    dateFormatter.dateFormat = @"D";
    if ([dateFormatter stringFromDate:self.lastOpenedDate] != [dateFormatter stringFromDate:[NSDate date]]) {
        //day of month not the same; reset tgings that are time dependent
        [self prepareForNewDay];
    }
    self.lastOpenedDate = [NSDate date];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    if (!self.viewAppearedBefore) {
        self.viewAppearedBefore = true;
        [self switchDayImage];
    }
}

//set the lgiht blue to blue background gradient
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

#pragma mark - Current Events

- (void)updateCurrentEvents
{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
    MXLCalendarManager *manager = [[MXLCalendarManager alloc] init];
    
        [manager scanICSFileAtRemoteURL:[NSURL URLWithString:@"http://www.iatoday.org/_infrastructure/ICalendarHandler.ashx?Tokens=757278"] withCompletionHandler:^(MXLCalendar *calendar, NSData *nilFileData, NSError *error) {
            
            self.eventsCalendar = calendar;
            
            dispatch_async(dispatch_get_main_queue(), ^{ //make sure this happens instantly
                [self.tableView reloadData];
            });
            if (error) {//no connection, try reading from file
                NSLog(@"Error getting data from online: %@", error.description);
                
                [manager scanICSFileAtLocalPath:[self itemArchivePath] withCompletionHandler:^(MXLCalendar *calendar, NSData *nilFileData, NSError *error) {
                    self.eventsCalendar = calendar;
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [self.tableView reloadData];
                    });
                }];
                
            } else {//there is a connection, download for online use
                NSData *calendarFile = [NSData dataWithContentsOfURL:[NSURL URLWithString:@"http://www.iatoday.org/_infrastructure/ICalendarHandler.ashx?Tokens=757278"]];
                
                NSError *writingError;
                [calendarFile writeToFile:[self itemArchivePath] options:0 error:&writingError];
                if (writingError) {
                    NSLog(@"Error writing to file: %@", error);
                }
            }
        }];
    });
    
    [self.tableLoadingView stopAnimating];
}

#pragma mark - A day / B day control

- (void)switchDayImage
{
//    if (self.finishedAnimaton) {
        NSDate *now = [NSDate date];
        //make sure its up to date the moment this is called (for new days)
        self.isADay = [[TodayManager sharedClassManager] todayIsAnADay:now]; //get bool value on whether it is an a day
        
        dateFormatter.dateFormat = @"e";//set format to day of week
        int dayOfWeek = [[dateFormatter stringFromDate:now] intValue];//get number value for weekday
        UIImage *imageToInsert;
        UIImageView *newImageView;
        //
        if (dayOfWeek == 1 || dayOfWeek == 7 || [[TodayManager sharedClassManager] noSchool]) {
            NSDate *testDate = [now dateByAddingTimeInterval:86400];
            for (int i = 0; i < 1000; testDate = [testDate dateByAddingTimeInterval:86400]) {
                //3 if no school that day
                dateFormatter.dateFormat = @"e";//set format to day of week
                int testWeekday = [[dateFormatter stringFromDate:testDate] intValue];//get number value for weekday
                BOOL noBreakBool = [[TodayManager sharedClassManager] dayTypeForDate:testDate] != 3;
                BOOL weekDayBool = (testWeekday != 7) && (testWeekday != 1);
                NSLog(@"Test Weekday: %d, weekdaybool: %@, nobreakbool: %@", testWeekday, weekDayBool ? @"t" : @"f", noBreakBool ? @"t" : @"f");
                if (noBreakBool && weekDayBool) {
                    BOOL nextDayIsADay = [[TodayManager sharedClassManager] todayIsAnADay:testDate];
                    if (nextDayIsADay) {
                        //aday
                        imageToInsert = [UIImage imageNamed:@"nextaday.png"];
                    } else {
                        //bday
                        imageToInsert = [UIImage imageNamed:@"nextbday.png"];
                    }
                    break;//leave the loop
                }
                
                i++;
            }
            
            
        } else {
            //remember that this will handle changing the aday BOOL value for you
            if (self.isADay) {
                //aday
                imageToInsert = self.aImage;
            } else {
                //bday
                imageToInsert = self.bImage;
            }
        }
        
        newImageView = [[UIImageView alloc] initWithImage:imageToInsert];
        newImageView.frame = self.dayImageView.frame;
        [self.view insertSubview:newImageView belowSubview:self.dayImageView];
        self.finishedAnimaton = false;
        CGPoint newCenter = CGPointMake(self.dayImageView.center.x, self.view.frame.size.height + self.dayImageView.frame.size.height);
        
            [UIView animateWithDuration:1.0 delay:0.1 options:UIViewAnimationOptionTransitionNone animations:^{
                self.dayImageView.center = newCenter;
                self.dayImageView.transform = CGAffineTransformMakeRotation(40 * (M_PI/180));
            } completion:^(BOOL finished){
                self.finishedAnimaton = finished;
                [self.dayImageView removeFromSuperview];
                self.dayImageView = nil;
                self.dayImageView = newImageView;
            }];
//    }
}

#pragma mark - TableView

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSUInteger integer = [self.eventsArray count] + 1; //to show cell saying no more
    
    return integer;
}
-(NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    return @"IA Okma Events";
}
- (void)tableView:(UITableView *)tableView willDisplayHeaderView:(UIView *)view forSection:(NSInteger)section
{
    if (view.class == [UITableViewHeaderFooterView class]) {
        UITableViewHeaderFooterView *headerView = (UITableViewHeaderFooterView *)view;
        headerView.backgroundView.backgroundColor = [UIColor grayColor];
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:@"Cell"];
    cell.textLabel.textColor = [UIColor whiteColor];
    cell.backgroundView.backgroundColor = [UIColor clearColor];
    cell.backgroundColor = [UIColor clearColor];

    if (self.eventsArray.count == indexPath.row) { //last object will be nil
        cell.textLabel.text = @"That's it for the Month!";
        cell.detailTextLabel.text = nil;
        return cell;
    }
    cell.detailTextLabel.textColor = [UIColor whiteColor];
    cell.textLabel.adjustsFontSizeToFitWidth = YES;
    
    MXLCalendarEvent *event = [self.eventsArray objectAtIndex:indexPath.row];
    
    NSString *eventName = [event eventSummary];
    //remove redundancy//
    eventName = [eventName stringByReplacingOccurrencesOfString:@"IA Okma - " withString:@""];
    eventName = [eventName stringByReplacingOccurrencesOfString:@"IA Okma-" withString:@""];
    cell.textLabel.text = eventName;
    
    dateFormatter.dateStyle = NSDateFormatterMediumStyle;
    //set date for event and location of event in one string
    if (event.eventLocation) {
        cell.detailTextLabel.text = [NSString stringWithFormat:@"%@, %@",[dateFormatter stringFromDate:event.eventStartDate], event.eventLocation];
    } else {
        cell.detailTextLabel.text = [dateFormatter stringFromDate:event.eventStartDate];
    }
    
    return  cell;
}

#pragma mark - Setter methods

//called whenever self.eventsCalendar is set
- (void)setEventsCalendar:(MXLCalendar *)eventsCalendar
{
    if (!self.eventsArray) {
        self.eventsArray = [[NSMutableArray alloc] initWithCapacity:10];
    }
    
    NSDate *today = [NSDate date];
    dateFormatter.dateFormat = @"d";
    int dayOfMonth = [[dateFormatter stringFromDate:today] intValue];
    dateFormatter.dateFormat = @"M";//set to month format
    int monthNumber = [[dateFormatter stringFromDate:today] intValue];
    dateFormatter.dateFormat = @"y";//set to year format
    int year = [[dateFormatter stringFromDate:today] intValue];
    
    NSDictionary *daysInMonths = @{@1:@31, @2:@28, @3:@31, @4:@30, @5:@31, @6:@30, @7:@31, @8:@31, @9:@30, @10:@31, @11:@30, @12:@31};
    int daysLeft = [[daysInMonths objectForKey:@(monthNumber)] intValue] - dayOfMonth;
    if (monthNumber == 3 && year % 4 == 0) {
        daysLeft = 29 - dayOfMonth;
    }
    
    for (int i = 0; i < daysLeft; i++) {
        NSDate *newDate = [today dateByAddingTimeInterval:i * 86400];
        dateFormatter.dateFormat = @"d";
        int testDayOfMonth = [[dateFormatter stringFromDate:newDate] intValue];
        dateFormatter.dateFormat = @"M";//set to month format
        int testMonthNumber = [[dateFormatter stringFromDate:newDate] intValue];
        
        for (MXLCalendarEvent *event in eventsCalendar.events) {
            dateFormatter.dateFormat = @"M";//must set month again since reiteration will change dateFormat
            if ([[dateFormatter stringFromDate:event.eventStartDate] intValue] == testMonthNumber) {
                dateFormatter.dateFormat = @"d"; //set to day format
                int f = [[dateFormatter stringFromDate:event.eventStartDate] intValue];
                if (f == testDayOfMonth) {
                    [self.eventsArray addObject:event];
                }
            }
        }
    }
}

//awesome:
- (void)prepareForNewDay {
    dispatch_async(dispatch_get_main_queue(), ^{
        [[TodayManager sharedClassManager] resetForNewDate];
        [self switchDayImage];
        [self updateCurrentEvents];
    });
   
}

#pragma Mark - File functions
//returns the file path for storing the events calendar file
- (NSString *)itemArchivePath
{
    NSArray *documentDirectiories = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentDirectory = [documentDirectiories firstObject];
    
    return [documentDirectory stringByAppendingPathComponent:@"calendar.ics"];
}

@end
