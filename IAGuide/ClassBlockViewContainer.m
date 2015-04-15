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
                NSString *boldFontName = [labelToChange.font.fontName stringByReplacingOccurrencesOfString:@"-Regular" withString:@"-Bold"];
                labelToChange.font = [UIFont fontWithName:boldFontName size:labelToChange.font.pointSize];
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
    
    ClassBlockView *view1;
    ClassBlockView *view2;
    
    
    NSMutableArray *lunch_1_Titles = [@[@"First Lunch Schedule", @"Block 1", @"Passing", @"Block 2", @"Lunch", @"Block 3", @"Block 4", @" 7:45|10:55", @" 9:15|11:30", @"9:25|1:05"] mutableCopy];
    
    //if half day, just make one
    if ([[TodayManager sharedClassManager] halfDay]) {
        NSMutableArray *halfDayTitles = [lunch_1_Titles mutableCopy];
        
        halfDayTitles[0] = @"Half Day Schedule";
        halfDayTitles[4] = @" ";//since there is no lunch on half days
        halfDayTitles[7] = @"7:45|    ";
        halfDayTitles[8] = @"8:45|9:55";
        halfDayTitles[9] = @" 8:50|11:00";
        view1 = [[ClassBlockView alloc] initWithTitles:halfDayTitles];
        self.classBlockViews = @[view1];
        [self.scrollView addSubview:view1];
    } else {
        view1 = [[ClassBlockView alloc] initWithTitles:lunch_1_Titles];
        //make titles for view2 based on view1 titles
        NSMutableArray *lunch_2_Titles = [lunch_1_Titles mutableCopy];
        lunch_2_Titles[0] = @"Second Lunch Schedule";
        NSString *reinsertString = lunch_1_Titles[5];
        [lunch_2_Titles removeObjectAtIndex:5];
        [lunch_2_Titles insertObject:reinsertString atIndex:4];
        
        if ([[TodayManager sharedClassManager] lateStart]) {
            lunch_1_Titles[7] = @" 9:30|11:45";
            lunch_1_Titles[8] = @"10:35|12:20";
            lunch_1_Titles[9] = @"10:40|1:30 ";
            
            lunch_2_Titles[7] = @" 9:30|11:50";
            lunch_2_Titles[8] = @"10:35|12:55";
            lunch_2_Titles[9] = @"10:40|1:30 ";
        } else {
            //configure time labels for 2nd lunch
            lunch_2_Titles[7] = @" 7:45|11:00";
            lunch_2_Titles[8] = @" 9:15|12:30";
            lunch_2_Titles[9] = @"9:25|1:05";
        }

        view2 = [[ClassBlockView alloc] initWithTitles:lunch_2_Titles];
        //the frame must have an origin x value that moves it to the right of the other view
        view2.frame = CGRectMake(scrollerSize.width, 0, scrollerSize.width, scrollerSize.height);
        
        self.classBlockViews = @[view1, view2];
        [self.scrollView addSubview:view1];
        [self.scrollView addSubview:view2];
    }
}

//you can use one ibaction for two buttons as long as the buttons have special tags setup in the xib
- (IBAction)pageButtonClicked:(id)sender {
    if ([(UIButton *)sender tag] == 2) {
        [self.pageControl setCurrentPage:0];//0 is first page
        [self.scrollView setContentOffset:CGPointZero animated:YES];
    } else {
        [self.pageControl setCurrentPage:1];
        [self.scrollView setContentOffset:CGPointMake(self.scrollView.frame.size.width, 0) animated:YES];
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
