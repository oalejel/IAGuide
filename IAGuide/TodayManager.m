//
//  CurrentClassManager.m
//  IAGuide
//
//  Created by Omar Alejel on 12/20/14.
//  Copyright (c) 2014 Omar Alejel. All rights reserved.
//

#import "AppDelegate.h"
#import "TodayManager.h"
#import "ClassBlockViewContainer.h"

@interface TodayManager ()

@property (nonatomic) NSTimer *firstLunchTimer;
@property (nonatomic) NSTimer *secondLunchTimer;

@property (nonatomic) NSArray *schedulesArray;//this array contains first lunch at index 0, 2nd at 1, late start lunch 1 at 2, latestart lunch 2 at 3, halfday lunch1 at 4, and halfday lunch2 @ 5
//@property (nonatomic) DayType *typeOfDay;

@end

@implementation TodayManager

- (instancetype)init//dont use this
{
    @throw [NSException exceptionWithName:@"Do not use init method for current class manager" reason:@"use sharedClassManager class method" userInfo:nil];
}

+ (instancetype)sharedClassManager {
    static id _sharedInstance = nil;
    static dispatch_once_t oncePredicate;
    dispatch_once(&oncePredicate, ^{
        _sharedInstance = [[self alloc] initPrivate];
    });
    return  _sharedInstance;
}

- (void)setDelegate:(ClassBlockViewContainer *)delegate
{
    //only set this value if it was not previously set
    if (!self.delegate) {
        _delegate = delegate;
    }
}

- (instancetype)initPrivate
{
    self = [super init];
    
    if (self) {
        NSString *path = [[NSBundle mainBundle] pathForResource:@"ShortDays" ofType:@"plist"];
        NSArray *irregularDays = [NSArray arrayWithContentsOfFile:path];
        
        NSDate *today = [NSDate date];
        dateFormatter.dateFormat = @"M";//month format
        int month = [[dateFormatter stringFromDate:today] intValue];//will be 1-12
        dateFormatter.dateFormat = @"D"; //day format
        int day = [[dateFormatter stringFromDate:today] intValue];
        
        int dayType = 0;//if 1, then latestart, if 2, then halfday, if 3, then no school
        
        int index = 0;
        for (NSNumber *number in irregularDays) {
            if (index % 2 == 0) {
                int numberMonth = (number.intValue - (number.intValue % 100)) / 100;
                if (month == numberMonth) {//the month in the number will be held in the 100s place
                    int numberDay = number.intValue % 100;
                    if (day == numberDay) {
                        dayType = [irregularDays[index + 1] intValue];
                        break;
                    }
                }
            }
            index++;
        }
        
        //determine the type of day
        switch (dayType) {
            case 1:
                typeOfDay = Late;
                break;
            case 2:
                typeOfDay = Half;
                break;
            case 3:
                typeOfDay = NoSchool;
                break;
            default:
                typeOfDay = Standard;
        }
    }
    
    [self setUpSchedulesArray];
    
    return self;
}

- (void)setUpSchedulesArray
{
    //the hours are in military format
    self.schedulesArray = @[@[@0, @745, @915, @925, @1055, @1130, @1305, @1435, @2359],
                            @[@0, @745, @915, @925, @1100, @1230, @1305, @1435, @2359],
                            
                            @[@0, @930, @1035, @1040, @1145, @1220, @1330, @1435, @2359],
                            @[@0, @930, @1035, @1040, @1150, @1255, @1330, @1435, @2359],
                            //half day only one schedule - last label should be nothing
                            @[@0, @745, @845, @850, @955, @1100, @1100, @1200, @2359]
                            ]; //!account for pm!! (EX: 105 would be 1:05)
}

//just to get an index related to the classBlockView label tags
- (int)findCurrentClassForFirstLunch:(BOOL)firstLunch
{
    NSDate *now = [NSDate date];
    dateFormatter.dateFormat = @"m";
    int now_Minutes = [[dateFormatter stringFromDate:now] intValue];
    dateFormatter.dateFormat = @"H"; //the hours are in military format
    int now_Hours = [[dateFormatter stringFromDate:now] intValue];
    dateFormatter.dateFormat = @"s";
    int now_Seconds = [[dateFormatter stringFromDate:now] intValue];
    int now_TotalMinutes = now_Minutes + (now_Hours * 60);
    int now_TotalSeconds = (now_TotalMinutes * 60) + now_Seconds;
    
    int indexForDayType = 0;
    
    switch (typeOfDay) {
        case Standard:
            indexForDayType = 0; //will also go for index 1 for second luch schedule
            break;
        case Late:
            indexForDayType = 2;
            break;
        case Half:
            indexForDayType = 4; //no 1st and 2nd lunch schedules
            break;
        default:
            break;
    }
    
    //add 1 to the index since secondlunch is located one index away from the lunch1 schedule. It also cant be a half day because there is a universal half day schedule
    if (!firstLunch && typeOfDay != Half && typeOfDay != NoSchool) {
        indexForDayType++;
    }
    
    //compare # of seconds in day, if greater, then look at previous index for current class
    int currentIndex = 0;
    for (NSNumber *number in (NSArray *)self.schedulesArray[indexForDayType]) {
        int minutes = number.intValue % 100;
        int hours = (number.intValue - minutes) / 100;
        int totalMinutes = minutes + (hours * 60);
        double totalSeconds = totalMinutes * 60;
        //need the <= since we are only comparing hours and minutes . if last minute of day, then accept that too, but
        if (now_TotalSeconds <= totalSeconds) {
            //create a timer for the next change in class
            int timeInterval = totalSeconds - now_TotalSeconds;
            NSTimer *timer;
            if (firstLunch) {
                timer = self.firstLunchTimer;
            } else {
                timer = self.secondLunchTimer;
            }
            
            NSNumber *lunchViewIndex;
            if (firstLunch) {
                lunchViewIndex = @0;
            } else {
                lunchViewIndex = @1;
            }
            
            NSNumber *labelIndex = [NSNumber numberWithInt:currentIndex];
            NSArray *arguments = @[labelIndex, lunchViewIndex];
            
            timer = [NSTimer timerWithTimeInterval:timeInterval target:self selector:@selector(notifyDelegate:) userInfo:arguments repeats:NO];
            [[NSRunLoop mainRunLoop] addTimer:timer forMode:NSDefaultRunLoopMode];
            
            return currentIndex - 1;
        } else if (number.intValue == 2359) {
            //sorry future reader for the verbosity here, i promise it wont happen again ;)
            int timeInterval = [(NSNumber *)[(NSArray *)self.schedulesArray[indexForDayType] firstObject] intValue] + 1.0;
            NSNumber *labelIndex = [NSNumber numberWithInt:currentIndex];
            NSNumber *lunchViewIndex;
            if (firstLunch) {
                lunchViewIndex = @0;
            } else {
                lunchViewIndex = @1;
            }
            NSArray *arguments = @[labelIndex, lunchViewIndex];
            NSTimer *tomorrowClassTimer = [NSTimer timerWithTimeInterval:timeInterval target:self selector:@selector(notifyDelegate:) userInfo:arguments repeats:NO];
            [[NSRunLoop mainRunLoop] addTimer:tomorrowClassTimer forMode:NSDefaultRunLoopMode];
            
            return 0;
        }
        
        currentIndex++;
    }
    
    @throw [NSException exceptionWithName:@"no value matched in findCurrentClass method" reason:@"check findCurrentClass" userInfo:nil];
}

- (void)notifyDelegate:(NSTimer *)timer
{
    NSArray *userInfo = [timer userInfo];
    
    int labelIndex = [userInfo[0] intValue];
    int viewIndex = [userInfo[1] intValue];
    
    [self.delegate highlightClassLabelAtIndex:labelIndex forViewIndex:viewIndex];
}

- (BOOL)todayIsAnADay:(NSDate *)date
{
    NSDictionary *monthInfoDictionary = @{
                                          @12: @[@YES], //december of 2014. Key is month, [0:(odd is A day), 1:exception, 2:exception]
                                          @1: @[@NO, @20], @2: @[@NO, @23],
                                          @3: @[@YES], @4: @[@NO], @5: @[@NO, @26],
                                          @6: @[@NO]
                                          };
    
    dateFormatter.dateFormat = @"M"; //this date formatter variable is a global variable in the app delegate
    NSNumberFormatter *numberFormatter = [[NSNumberFormatter alloc] init];
    
    NSNumber *monthNumber = [numberFormatter numberFromString:[dateFormatter stringFromDate:date]];
    
    NSArray *monthArray = [monthInfoDictionary objectForKey:monthNumber];
    
    dateFormatter.dateFormat = @"d";
    int dayOfMonth = [[dateFormatter stringFromDate:date] intValue];
    BOOL todayIsOdd = false;
    if (dayOfMonth % 2 == 1) {
        todayIsOdd = true;
    }
    BOOL isADay = NO;
    int rule = [[monthArray objectAtIndex:0] intValue];
    NSLog(@"today is odd: %d, odds are aday: %d", todayIsOdd ? 1 : 0, rule ? 1 : 0);
    if ((todayIsOdd && rule) || (!todayIsOdd && !rule)) {
        isADay = true;
    }
    
    for (NSUInteger i = 2; i <= [monthArray count]; i++) {
        
        int exceptionDay = [[monthArray objectAtIndex:(i-1)] intValue];
        if (([monthArray count] >= i) && (dayOfMonth >= exceptionDay)) {
            isADay = !isADay; // invert value
        }
    }
    
    return isADay;
}

- (BOOL)noSchool
{
    BOOL noSchoolBool = false;
    if (typeOfDay == NoSchool) {
        noSchoolBool = TRUE;
    }
    
    return noSchoolBool;
}

- (BOOL)halfDay
{
    BOOL halfDayBool = FALSE;
    if (typeOfDay == Half) {
        halfDayBool = TRUE;
    }
    
    return halfDayBool;
}

- (BOOL)lateStart
{
    BOOL lateBool = false;
    if (typeOfDay == Late) {
        lateBool = TRUE;
    }
    
    return lateBool;
}

@end
