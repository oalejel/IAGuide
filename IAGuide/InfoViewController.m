//
//  InfoViewController.m
//  IAGuide
//
//  Created by Omar Alejel on 11/6/14.
//  Copyright (c) 2014 Omar Alejel. All rights reserved.
// 

#import "InfoViewController.h"
#import "DetailTableCell.h"

@interface InfoViewController ()

@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (nonatomic) NSDictionary *classesDictionary;
@property (nonatomic) NSArray *teachersArray;
@property (nonatomic) BOOL teacherMode;
@property (nonatomic) int teacherCode;
@property (nonatomic) NSArray *teacherInfo;

@end

@implementation InfoViewController

#pragma mark - Initializers

//if you are looking at a teachers scheulde
- (instancetype)initWithTeacherCode:(int)teacherCode
{
    self = [super initWithNibName:@"InfoViewController" bundle:nil];
    if (self) {
        self.teacherMode = TRUE;
        self.teacherCode = teacherCode;//the code a teacher has in a class dictionary
    }
    
    return self;
}

//if you are looking at a room schedule
- (instancetype)initWithRoomNumber:(int)number
{
    self = [super initWithNibName:@"InfoViewController" bundle:nil];
    self.roomNumber = number;
    return self;
}

#pragma mark - View life cycle

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    UIBarButtonItem *doneButton = [[UIBarButtonItem alloc] initWithTitle:@"Done" style:UIBarButtonItemStyleDone target:self action:@selector(dismiss)];
    self.navigationItem.rightBarButtonItem = doneButton;
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    
    [self.tableView registerClass:[DetailTableCell class] forCellReuseIdentifier:@"cell"];
    
    NSString *classPath = [[NSBundle mainBundle] pathForResource:@"Classes" ofType:@"plist"];
    self.classesDictionary = [NSDictionary dictionaryWithContentsOfFile:classPath];
    
    NSString *teacherPath = [[NSBundle mainBundle] pathForResource:@"Teachers" ofType:@"plist"];
    self.teachersArray = [NSArray arrayWithContentsOfFile:teacherPath];
    
    //give them 0 values
    NSMutableArray *sem1Classes = [@[@0, @0, @0, @0, @0, @0, @0, @0] mutableCopy];
    NSMutableArray *sem2Classes = [@[@0, @0, @0, @0, @0, @0, @0, @0] mutableCopy];
    
    if (self.teacherMode) {
        for (NSString *key in self.classesDictionary) {
            NSArray *teachers = self.classesDictionary[key];
            for (int i = 0; i < 8; i++) {
                int fullCode = [(NSString *)teachers[i] intValue];
                int upper = (fullCode - (fullCode % 100)) / 100;
                int lower = fullCode % 100;
                //check if teacher EVER teaches in this class
                if (self.teacherCode == upper || self.teacherCode == lower) {
                    NSString *classString = (NSString *)teachers[i + 8];
                    NSString *sem1String;
                    NSString *sem2String;
                    if (self.teacherCode == upper) { //do they teach 1st sem
                        //this will map out with the A/B DAY INFO
                        if (lower == 99) {//do they continue?
                            NSArray *strings = [classString componentsSeparatedByString:@", Sem2- "];
                            if ([strings count] == 2) {//different class subjects? (, means sem2)
                                sem1String = strings[0];
                                sem2String = strings[1];
                            } else {//same class type
                                sem1String = classString;
                                sem2String = classString;
                            }
                        } else {
                            NSUInteger splitIndex = [classString rangeOfString:@","].location;
                            NSRange extrasRange = NSMakeRange(splitIndex, [classString length] - splitIndex);
                            NSString *extractedString = [classString stringByReplacingCharactersInRange:extrasRange withString:@""];
                            sem1String = extractedString;
                        }
                    } else {
                        if (self.teacherCode == lower) {
                            if ([classString rangeOfString:@"- "].location != NSNotFound) {
                                NSUInteger splitIndex = [classString rangeOfString:@"- "].location + 2;//create a range and add 2 since we want what is after this
                                if (splitIndex > 2) {//since we add 2 to offset the deletion point
                                    NSRange classesTaughtRange = NSMakeRange(0, splitIndex);
                                    NSString *extractedString = [classString stringByReplacingCharactersInRange:classesTaughtRange withString:@""];
                                    sem2String = extractedString;
                                }
                            } else {
                                sem2String = classString;
                            }
                            
                        }
                    }
                    
                    if (sem1String) {
                        sem1Classes[i] = [NSString stringWithFormat:@"%@ - %@", sem1String, key];
                    }
                    if (sem2String) {
                        sem2Classes[i] = [NSString stringWithFormat:@"%@ - %@", sem2String, key];
                    }
                }
            }
        }
        
        [sem1Classes addObjectsFromArray:sem2Classes]; //put sem 2 and sem 1 classes in one dict to put into property
        //first object will be sem 1 a day, last will be sem 2 bday
        self.teacherInfo = [NSArray arrayWithArray:sem1Classes];
    } else {
        self.classesInfo = self.classesDictionary[[NSString stringWithFormat:@"%d", self.roomNumber]];
    }
}

- (void)dismiss
{
    [self.navigationController.presentingViewController dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - tableview delegate

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    if (self.teacherMode) {
        switch (section) {
            case 0:
                return @"Sem 1 A Day";
            case 1:
                return @"Sem 1 B Day";
            case 2:
                return @"Sem 2 A Day";
            case 3:
                return @"Sem 2 B Day";
            default:
                return nil;
        }
    } else {
        if (section == 0) {
            return @"A Day";
        } else {
            return @"B Day";
        }
    }
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    if (self.teacherMode) {
        return 4;
    } else {
        return 2;
    }
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 4;
}

- (NSString *)tableView:(UITableView *)tableView titleForFooterInSection:(NSInteger)section
{
    if (section == tableView.numberOfSections - 1) {
        return @"As of 2015-2016"; //change every year once info is updated!
    }
    
    return nil;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:@"cell" forIndexPath:indexPath];
    //if teacher mode then do this
    if (self.teacherMode) {
        //take the class subject string - might contain classes for other teachers
        cell.textLabel.adjustsFontSizeToFitWidth = YES;
        long index = indexPath.row + (indexPath.section * 4);
        id object = self.teacherInfo[index];
        if ([object isKindOfClass:[NSString class]]) {
            cell.textLabel.text = (NSString *)object;
        } else {
            cell.textLabel.text = @"No Class";//amke sure you alway set values for dequqeued cells since they can come woth old values
        }
        
    } else {
        if (self.classesInfo) {
            int i = (int) indexPath.section + (int) indexPath.row;
            if (indexPath.section == 1) {
                i += 3;
            }
            NSString *subjectString = self.classesInfo[i + 8];
            cell.textLabel.adjustsFontSizeToFitWidth = YES;
            cell.textLabel.text = subjectString;
            cell.detailTextLabel.textColor = [UIColor grayColor];
            NSString *teacherCode = self.classesInfo[i];
            int codeNumber = [teacherCode intValue];
            int firstHalf = codeNumber / 100; //int value so dividing will only return whole #
            int secondHalf = codeNumber % 100;
            
            NSString *sem_1_name;
            NSString *sem_2_name;
            
            if (firstHalf == 0) { //sem 1 CANNOT be 99!
                sem_1_name = @"None";
            } else {
                //the algorithm to retrieve teacher names is teachercode + (teachercode - 1)
                sem_1_name = self.teachersArray[firstHalf + (firstHalf - 1)];
            }
            
            if (secondHalf == 0 && firstHalf != 0) {
                sem_2_name = @"None"; //when no teacher taeches 2nd sem
            } else if (secondHalf != 99 && secondHalf != 0) { //99 means that the same teacher teaches the 2nd sem.
                sem_2_name = self.teachersArray[secondHalf + (secondHalf - 1)];
            } else {
                //do nothing since same teacher teaches
            }
            
            NSString *finalTeacherString;
            if (sem_1_name && sem_2_name) {
                finalTeacherString = [NSString stringWithFormat:@"%@, Sem 2-%@", sem_1_name, sem_2_name];
            } else {
                finalTeacherString = [NSString stringWithFormat:@"%@", sem_1_name]; //only if same teacher
            }
            
            cell.detailTextLabel.text = finalTeacherString;
        } else {
            cell.textLabel.text = @"No Scheduled Class";
        }
    }
    
    return cell;
}

@end
