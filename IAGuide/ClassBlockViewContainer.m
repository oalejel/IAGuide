//
//  ClassBlockViewContainer.m
//  IAGuide
//
//  Created by Omar Alejel on 1/2/15.
//  Copyright (c) 2015 Omar Alejel. All rights reserved.
//

#import "ClassBlockViewContainer.h"
#import "TodayManager.h"
#import "ClassBlockView.h"

@interface ClassBlockViewContainer () <UIScrollViewDelegate>

@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;
@property (weak, nonatomic) IBOutlet UIPageControl *pageControl; //the thing with the dots that shows which page ur on
@property (nonatomic) NSArray *classBlockViews;

@end

@implementation ClassBlockViewContainer

- (instancetype)init
{
    NSArray *viewArray = [[NSBundle mainBundle] loadNibNamed:@"ClassBlockViewContainer" owner:self options:0];
    self = (ClassBlockViewContainer *)[viewArray firstObject];
    
    [self configureScrollView];//this just sets some special attributes in the view's subviews
    
    [[TodayManager sharedClassManager] setDelegate:self];
    int l_1_LabelIndex = [[TodayManager sharedClassManager] findCurrentClassForFirstLunch:YES];
    int l_2_LabelIndex = [[TodayManager sharedClassManager] findCurrentClassForFirstLunch:NO];
    
    [self highlightClassLabelAtIndex:l_1_LabelIndex forViewIndex:0];
    [self highlightClassLabelAtIndex:l_2_LabelIndex forViewIndex:1];
    
    return self;
}

- (void)highlightClassLabelAtIndex:(int)index forViewIndex:(int)classBlockViewIndex
{
    //all drawing mst be done on the main thread
    dispatch_async(dispatch_get_main_queue(), ^{
        if (self.classBlockViews.count - 1 >= classBlockViewIndex) {
            ClassBlockView *view = self.classBlockViews[classBlockViewIndex];
            
            int labelIndex = index;
            
            int i = 0;
            UILabel *labelToChange = nil;
            for (UIView *maybeLabel in view.subviews) {
                if ([maybeLabel isKindOfClass:[UILabel class]]) {
                    if (maybeLabel.tag == 0 || maybeLabel.tag > 6) {
                        //do nothing, we dont want to make the title (tag=0) green
                    } else if (maybeLabel.tag == labelIndex) {
                        labelToChange = (UILabel *)maybeLabel;
                        break;
                    }
                }
                
                i++;
            }
            
            if (labelToChange) {
                //change previous label back from green to black
                UILabel *previousLabel = (UILabel *)[view viewWithTag:i - 1];
                if ([previousLabel isKindOfClass:[UILabel class]]) {
                    previousLabel.textColor = [UIColor blackColor];
                    [previousLabel setFont:labelToChange.font];
                }
                
                labelToChange.textColor = [UIColor greenColor];
                NSString *boldName = [labelToChange.font.fontName stringByReplacingOccurrencesOfString:@"-Regular" withString:@"-Bold"];
                labelToChange.font = [UIFont fontWithName:boldName size:labelToChange.font.pointSize];
            }
        }
    });
}

- (void)configureScrollView
{
    CGSize scrollerSize = self.scrollView.frame.size;
    
    self.scrollView.contentSize = CGSizeMake(scrollerSize.width * 2, scrollerSize.height);
    self.scrollView.pagingEnabled = YES;
    self.scrollView.showsHorizontalScrollIndicator = NO;
    self.scrollView.showsVerticalScrollIndicator = NO;
    self.scrollView.scrollsToTop = NO;
    self.scrollView.delegate = self;
    
    self.pageControl.numberOfPages = 2;//2 pages
    self.pageControl.currentPage = 0;
    [(UIButton *)[self viewWithTag:2] setEnabled:NO];//can only move right in beginning
    
    NSString *titleString_1 = @"Lunch 1 Schedule";
    
    NSString *timeString1_1 = @"7:45";
    NSString *timeString2_1 = @"9:15";
    NSString *timeString3_1 = @"9:25";
    NSString *timeString4_1 = @"10:55";
    NSString *timeString5_1 = @"11:30";
    NSString *timeString6_1 = @"1:05";
    
    NSString *titleString_2 = @"Lunch 2 Schedule";// since xib has "First Lunch Schedule"
    
    NSString *timeString1_2 = @"7:45";
    NSString *timeString2_2 = @"9:15";
    NSString *timeString3_2 = @"9:25";
    NSString *timeString4_2 = @"11:00";
    NSString *timeString5_2 = @"12:30";
    NSString *timeString6_2 = @"1:05";
    
    NSString *blockString1_1 = @"Block 1";
    NSString *blockString2_1 = @"Passing";
    NSString *blockString3_1 = @"Block 2";
    NSString *blockString4_1 = @"Lunch 1";
    NSString *blockString5_1 = @"Block 3";
    NSString *blockString6_1 = @"Block 4";
    
    NSString *blockString1_2 = @"Block 1";
    NSString *blockString2_2 = @"Passing";
    NSString *blockString3_2 = @"Block 2";
    NSString *blockString4_2 = @"Block 3";
    NSString *blockString5_2 = @"Lunch 2";
    NSString *blockString6_2 = @"Block 4";
    
    if ([[TodayManager sharedClassManager] halfDay]) {
        titleString_1 = @"Half Day";
        //only need one sched view
        timeString1_1 = @"7:45";
        timeString2_1 = @"8:45";
        timeString3_1 = @"8:50";
        timeString4_1 = @"(none)";
        timeString5_1 = @"9:55";
        timeString6_1 = @"11:00";
    } else if ([[TodayManager sharedClassManager]lateStart]) {
        //make titles for view2 based on view1 titles
        titleString_1 = @"Late Start Lunch 1";
        titleString_2 = @"Late Start Lunch 2";
        
        timeString1_1 = @"9:30";
        timeString2_1 = @"10:35";
        timeString3_1 = @"10:40";
        timeString4_1 = @"11:45";
        timeString5_1 = @"12:20";
        timeString6_1 = @"1:30";
        
        timeString1_2 = @"9:30";
        timeString2_2 = @"10:35";
        timeString3_2 = @"11:45";
        timeString4_2 = @"11:50";
        timeString5_2 = @"12:55";
        timeString6_2 = @"1:30";
    }
    
    ClassBlockView *view1 = [[ClassBlockView alloc] init];
    ClassBlockView *view2 = [[ClassBlockView alloc] init];
    
    //the frame must have an origin x value that moves it to the right of the other view
    view2.frame = CGRectMake(scrollerSize.width, 0, scrollerSize.width, scrollerSize.height);
    
    UIBezierPath *linePath = [[UIBezierPath alloc] init];
    [linePath moveToPoint:CGPointMake(view1.frame.size.width / 2, 35)];
    [linePath addLineToPoint:CGPointMake(view1.frame.size.width / 2, view1.frame.size.height - 6)];
    
    CAShapeLayer *shapeLayer = [CAShapeLayer layer];
    shapeLayer.path = linePath.CGPath;
    shapeLayer.lineWidth = 1;
    shapeLayer.strokeColor = [[UIColor darkGrayColor] CGColor];
    
    [view1.layer addSublayer:shapeLayer];
    
    CAShapeLayer *otherLayer = [CAShapeLayer layer];
    otherLayer.path = linePath.CGPath;
    otherLayer.lineWidth = 1;
    otherLayer.strokeColor = [[UIColor darkGrayColor] CGColor];
    
    [view2.layer addSublayer:otherLayer];
    
    view1.titleLabel.text = titleString_1;
    
    view1.blockLabel1.text = blockString1_1;
    view1.blockLabel2.text = blockString2_1;
    view1.blockLabel3.text = blockString3_1;
    view1.blockLabel4.text = blockString4_1;
    view1.blockLabel5.text = blockString5_1;
    view1.blockLabel6.text = blockString6_1;
    
    view1.timeLabel1.text = timeString1_1;
    view1.timeLabel2.text = timeString2_1;
    view1.timeLabel3.text = timeString3_1;
    view1.timeLabel4.text = timeString4_1;
    view1.timeLabel5.text = timeString5_1;
    view1.timeLabel6.text = timeString6_1;
    
    if ([[TodayManager sharedClassManager] halfDay]) {
        self.classBlockViews = @[view1];//both lunches have the same scheds in half day
        [self.scrollView addSubview:view1];
    } else {
        view2.titleLabel.text = titleString_2;
        
        view2.timeLabel1.text = timeString1_2;
        view2.timeLabel2.text = timeString2_2;
        view2.timeLabel3.text = timeString3_2;
        view2.timeLabel4.text = timeString4_2;
        view2.timeLabel5.text = timeString5_2;
        view2.timeLabel6.text = timeString6_2;
        
        view2.blockLabel1.text = blockString1_2;
        view2.blockLabel2.text = blockString2_2;
        view2.blockLabel3.text = blockString3_2;
        view2.blockLabel4.text = blockString4_2;
        view2.blockLabel5.text = blockString5_2;
        view2.blockLabel6.text = blockString6_2;
        
        self.classBlockViews = @[view1, view2];
        [self.scrollView addSubview:view1];
        [self.scrollView addSubview:view2];
    }
}

//you can use one ibaction for two buttons as long as the buttons have special tags setup in the xib
- (IBAction)pageButtonClicked:(id)sender {
    if ([(UIButton *)sender tag] == 2) {
        [self.scrollView setContentOffset:CGPointZero animated:YES];
    } else {
        [self.scrollView setContentOffset:CGPointMake(self.scrollView.frame.size.width,0) animated:YES];
    }
}

#pragma mark - ScrollView delegate
- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    CGFloat pageWidth = CGRectGetWidth(self.scrollView.frame);
    int currentPageIndex = floor((self.scrollView.contentOffset.x - pageWidth / 2) / pageWidth) + 1;
    self.pageControl.currentPage = currentPageIndex;
    
    if (currentPageIndex == 0) {
        //there are 2 buttons, the moveright has a tag of 2, the moveleft has a tag pf 3
        [(UIButton *)[self viewWithTag:3] setEnabled:YES];//set moveright button to enabled
        [(UIButton *)[self viewWithTag:2] setEnabled:NO];
    } else {
        [(UIButton *)[self viewWithTag:3] setEnabled:NO];//set moveleft button to disabled
        [(UIButton *)[self viewWithTag:2] setEnabled:YES];
    }
}


@end
