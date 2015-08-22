//
//  OlympicsViewController.m
//  IAGuide
//
//  Created by Omar Alejel on 12/7/14.
//  Copyright (c) 2014 Omar Alejel. All rights reserved.
// This view controller is responsible for showing data on the ia olympics on olympics day

#import "OlympicsViewController.h"
#import "WebViewController.h"

const int x_offset = 15;
const int y_offset = 20;

@interface OlympicsViewController ()

@property (nonatomic) BOOL viewAppearedBefore;
@property (weak, nonatomic) IBOutlet UITextView *infoTextView;
@property (weak, nonatomic) IBOutlet UIView *freshmenBar;
@property (weak, nonatomic) IBOutlet UIView *juniorBar;
@property (weak, nonatomic) IBOutlet UIView *seniorBar;
@property (weak, nonatomic) IBOutlet UIView *sophomoreBar;
@property (weak, nonatomic) IBOutlet UIButton *showFeedButton;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *refreshingIndicator;

@property (nonatomic) NSString *statusString;

@property (nonatomic) NSDictionary *scoreDictionary;
@property (nonatomic) NSDictionary *freshmanDictionary;
@property (nonatomic) NSDictionary *sophomoreDictionary;
@property (nonatomic) NSDictionary *juniorDictionary;
@property (nonatomic) NSDictionary *seniorDictionary;

@property (nonatomic) IBOutlet UIView *contentView;
@property (nonatomic) IBOutlet UIScrollView *scrollView;

@property (weak, nonatomic) IBOutlet UIView *scoresContainer;
@property (weak, nonatomic) IBOutlet UIView *refreshBarView;

@property (nonatomic) UILabel *freshLabel;
@property (nonatomic) UILabel *sophLabel;
@property (nonatomic) UILabel *junLabel;
@property (nonatomic) UILabel *senLabel;
@property (nonatomic) UILabel *frTitle;
@property (nonatomic) UILabel *soTitle;
@property (nonatomic) UILabel *juTitle;
@property (nonatomic) UILabel *seTitle;

@property (nonatomic) BOOL refreshBarDown;

@end

@implementation OlympicsViewController

- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.tabBarItem.title = @"Olympics";
        self.tabBarItem.image = [UIImage imageNamed:@"trophy"];
        NSTimer *refreshTimer = [NSTimer timerWithTimeInterval:70 target:self selector:@selector(refreshData) userInfo:nil repeats:true];
        [[NSRunLoop mainRunLoop] addTimer:refreshTimer forMode:NSDefaultRunLoopMode];
    }
    
    return self;
}

- (void)refreshData {
    //do on a separate thread so things dont lag...
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.refreshingIndicator startAnimating];
    });
    dispatch_queue_t q = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    dispatch_async(q, ^{
        [self getData];
        if (self.scoreDictionary) {
            [self setScoreLabels];
            [self updateOlympicsStatus];
            [self setBargraphs];
            if (self.refreshBarDown) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    [self liftRefreshBar];
                });
            }
        } else {
            if (!self.refreshBarDown) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    [self dropRefreshBar];
                });
            }
        }
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.refreshingIndicator stopAnimating];
        });
    });
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    UIImage *pressedImage = [UIImage imageNamed:@"pressed.png"];
    [self.showFeedButton setBackgroundImage:pressedImage forState:UIControlStateHighlighted];
    
    self.scoresContainer.layer.cornerRadius = 4;
    
    self.scoresContainer.layer.shadowColor = [[UIColor blackColor] CGColor];
    self.scoresContainer.layer.shadowRadius = 3;
    self.scoresContainer.layer.shadowOpacity = 0.4;
    self.scoresContainer.layer.shadowOffset = CGSizeMake(0, 1.2);
    
    self.refreshBarView.layer.cornerRadius = 4;
    
    self.freshLabel = [self configureScoreLabel];
    self.sophLabel = [self configureScoreLabel];
    self.junLabel = [self configureScoreLabel];
    self.senLabel = [self configureScoreLabel];
    
    self.frTitle  = [self configureScoreLabel];
    self.frTitle.text = @"Fr";
    self.soTitle = [self configureScoreLabel];
    self.soTitle.text = @"So";
    self.juTitle = [self configureScoreLabel];
    self.juTitle.text = @"Ju";
    self.seTitle = [self configureScoreLabel];
    self.seTitle.text = @"Se";
    
    [self.scoresContainer addSubview:self.freshLabel];
    [self.scoresContainer addSubview:self.sophLabel];
    [self.scoresContainer addSubview:self.junLabel];
    [self.scoresContainer addSubview:self.senLabel];
    [self.scoresContainer addSubview:self.frTitle];
    [self.scoresContainer addSubview:self.soTitle];
    [self.scoresContainer addSubview:self.juTitle];
    [self.scoresContainer addSubview:self.seTitle];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    if (!self.viewAppearedBefore) {
        CGFloat contentHeight = self.contentView.frame.size.height;
        self.contentView.frame = CGRectMake(0, 0, self.view.frame.size.width, contentHeight);
        self.contentView.backgroundColor = [UIColor clearColor];
        
        self.scrollView.contentSize = self.contentView.frame.size;
        [self.scrollView addSubview:self.contentView];
        
        [self setBackgroundGradient];
    }
}

- (void)viewDidLayoutSubviews {
    if (!self.viewAppearedBefore) {
        [self.scoresContainer setNeedsLayout];
        [self.scoresContainer layoutIfNeeded];
        
        [self drawScoresGraph];//only time to do this is here
    }
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    if (!self.viewAppearedBefore) {
        //move the refresh bar up once it loads
        CGRect temp = self.refreshBarView.frame;
        temp.origin.y -= 50;
        self.refreshBarView.frame = temp;
        self.refreshBarDown = false;
        [self refreshData];
        self.viewAppearedBefore = true;
    }
}

- (UILabel *)configureScoreLabel {
    UILabel *scoreLabel = [[UILabel alloc] init];
    scoreLabel.font = [UIFont fontWithName:@"Digital-7 Mono" size:18];
    scoreLabel.textColor = [UIColor blackColor];
    scoreLabel.text = @"000";
    scoreLabel.textAlignment = NSTextAlignmentCenter;
    [scoreLabel sizeToFit];
    
    return scoreLabel;
}

- (void)drawScoresGraph {
    UIBezierPath *xAxisPath = [[UIBezierPath alloc] init];
    UIBezierPath *yAxisPath = [[UIBezierPath alloc] init];
    CGFloat xMin = x_offset;
    CGFloat xMax = self.scoresContainer.frame.size.width - xMin;
    CGFloat yMin = y_offset;
    CGFloat yMax = self.scoresContainer.frame.size.height - yMin;
    
    [xAxisPath moveToPoint:CGPointMake(xMin, yMax)];
    [xAxisPath addLineToPoint:CGPointMake(xMax, yMax)];
    [yAxisPath moveToPoint:CGPointMake(xMin, yMin)];
    [yAxisPath addLineToPoint:CGPointMake(xMin, yMax)];
    
    CAShapeLayer *xAxislayer = [CAShapeLayer layer];
    CAShapeLayer *yAxisLayer = [CAShapeLayer layer];
    
    xAxislayer.path = xAxisPath.CGPath;
    yAxisLayer.path = yAxisPath.CGPath;
    
    xAxislayer.lineWidth = 1;
    yAxisLayer.lineWidth = 1;
    xAxislayer.strokeColor = [[UIColor grayColor] CGColor];
    yAxisLayer.strokeColor = [[UIColor grayColor] CGColor];
    
    [self.scoresContainer.layer addSublayer:xAxislayer];
    [self.scoresContainer.layer addSublayer:yAxisLayer];
    
    CGFloat barWidth = (xMax - xMin) / 8;
    self.freshmenBar.frame = CGRectMake(xMin + barWidth * 0.5, yMax - 5, barWidth, 5);
    self.sophomoreBar.frame = CGRectMake(xMin + barWidth * 2.5, yMax - 5, barWidth, 5);
    self.juniorBar.frame = CGRectMake(xMin + barWidth * 4.5, yMax - 5, barWidth, 5);
    self.seniorBar.frame = CGRectMake(xMin + barWidth * 6.5, yMax - 5, barWidth, 5);
    
    CGFloat labelY = 12;
    CGFloat freX = self.freshmenBar.center.x;
    CGFloat sopX = self.sophomoreBar.center.x;
    CGFloat junX = self.juniorBar.center.x;
    CGFloat senX = self.seniorBar.center.x;
    self.freshLabel.center = CGPointMake(freX, labelY);
    self.sophLabel.center = CGPointMake(sopX, labelY);
    self.junLabel.center = CGPointMake(junX, labelY);
    self.senLabel.center = CGPointMake(senX, labelY);
    
    CGFloat titleY = self.scoresContainer.frame.size.height - 8;
    self.frTitle.center = CGPointMake(freX, titleY);
    self.soTitle.center = CGPointMake(sopX, titleY);
    self.juTitle.center = CGPointMake(junX, titleY);
    self.seTitle.center = CGPointMake(senX, titleY);
}

- (IBAction)refreshPressed:(id)sender {
    [self liftRefreshBar];
    [self refreshData];
}

- (void)dropRefreshBar {
    if (!self.refreshBarDown) {
        [UIView animateWithDuration:0.9 animations:^{
            CGRect temp =  self.refreshBarView.frame;
            temp.origin.y += 50;
            self.refreshBarView.frame = temp;
            self.refreshBarDown = true;
        }];
    }
}

- (void)liftRefreshBar {
    if (self.refreshBarDown) {
        [UIView animateWithDuration:0.9 animations:^{
            CGRect temp = self.refreshBarView.frame;
            temp.origin.y -= 50;
            self.refreshBarView.frame = temp;
            self.refreshBarDown = false;
        }];
    }
}

- (void)getData {
    //there is an issue wiht the website. must access main website first...
//    NSURL *bootURL = [NSURL URLWithString:@"http://www.iaolympics.com"];
//    NSData *bootData = [NSData dataWithContentsOfURL:bootURL];
//    bootData = nil;
//    bootURL = nil;
    
    NSArray *urlStrings = @[@"http://www.iaolympics.com/api/scores", @"http://www.iaolympics.com/api/freshman",
                            @"http://www.iaolympics.com/api/sophomore", @"http://www.iaolympics.com/api/junior",
                            @"http://www.iaolympics.com/api/senior", @"http://www.iaolympics.com/api/status"];
    NSMutableArray *urls = [[NSMutableArray alloc] initWithCapacity:5];
    for (NSString *str in urlStrings) {
        NSURL *url = [NSURL URLWithString:str];
        [urls addObject:url];
    }
    
    NSMutableArray *dictStorage = [[NSMutableArray alloc] initWithCapacity:6];
    int index = 0;
    for (NSURL *url in urls) {
        
//        NSURLRequest *urlRequest = [NSURLRequest requestWithURL:url];
//        NSURLResponse *response = nil;
//        NSError *error = nil;
//        NSData *webData = [NSURLConnection sendSynchronousRequest:urlRequest
//                                              returningResponse:&response
//                                                          error:&error];
        NSData *webData = [NSData dataWithContentsOfURL:url];

        if (!webData) {
            return;//data retrieval failed
        }
        if (index != 5) {
            NSDictionary *dataDictionary = [NSJSONSerialization JSONObjectWithData:webData options:0 error:nil];
            [dictStorage addObject:dataDictionary];
        } else {
            NSString *dataString = [[NSString alloc] initWithData:webData encoding:NSUTF8StringEncoding];
            [dictStorage addObject:dataString];
        }
        
        index++;
    }
    self.scoreDictionary = dictStorage[0];
    self.freshmanDictionary = dictStorage[1];
    self.sophomoreDictionary = dictStorage[2];
    self.juniorDictionary = dictStorage[3];
    self.seniorDictionary = dictStorage[4];
    self.statusString = dictStorage[5];
    
    NSLog(@"%@", self.scoreDictionary);
}

- (void)setBargraphs {
    if (!self.scoreDictionary) {
        return;
    }
    float fr = [(NSString *)self.scoreDictionary[@"freshman"] floatValue];
    float so = [(NSString *)self.scoreDictionary[@"sophomore"] floatValue];
    float ju = [(NSString *)self.scoreDictionary[@"junior"] floatValue];
    float se = [(NSString *)self.scoreDictionary[@"senior"] floatValue];
    float largest = MAX(MAX(fr, so), MAX(ju, se));
   
    float frPercent = fr / largest;
    float soPercent = so / largest;
    float juPercent = ju / largest;
    float sePercent = se / largest;
    
    CGFloat maxHeight = self.scoresContainer.frame.size.height - y_offset * 4.5;//30 is the # used as the y offset
    
    CGFloat frHeight = frPercent * maxHeight;
    CGFloat soHeight = soPercent * maxHeight;
    CGFloat juHeight = juPercent * maxHeight;
    CGFloat seHeight = sePercent * maxHeight;
    
    [self animateGraphsForHeights:frHeight height2:soHeight height3:juHeight height4:seHeight];
}

- (void)setScoreLabels {
    dispatch_async(dispatch_get_main_queue(), ^{
        self.freshLabel.text = [(NSNumber *)self.scoreDictionary[@"freshman"] stringValue];
        self.sophLabel.text = [(NSNumber *)self.scoreDictionary[@"sophomore"] stringValue];
        self.junLabel.text = [(NSNumber *)self.scoreDictionary[@"junior"] stringValue];
        self.senLabel.text = [(NSNumber *)self.scoreDictionary[@"senior"] stringValue];
    });
}

- (void)updateOlympicsStatus {
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.infoTextView setText:self.statusString];
    });
}

- (void)animateGraphsForHeights:(CGFloat)h1 height2:(CGFloat)h2 height3:(CGFloat)h3 height4:(CGFloat)h4 {
    dispatch_async(dispatch_get_main_queue(), ^{
        [UIView animateWithDuration:2.0 animations:^{
            CGFloat scoreContainerHeight = self.scoresContainer.frame.size.height;
            CGRect SeRect = self.seniorBar.frame;
            SeRect.size.height = h4 + y_offset;
            SeRect.origin.y = scoreContainerHeight - y_offset - SeRect.size.height;
            NSLog(@"width: %f", SeRect.size.width);
            self.seniorBar.frame = SeRect;
            
            CGRect SoRect = self.sophomoreBar.frame;
            SoRect.size.height = h2 + y_offset;
            SoRect.origin.y = scoreContainerHeight - y_offset - SoRect.size.height;
            self.sophomoreBar.frame = SoRect;
            
            CGRect JuRect = self.juniorBar.frame;
            JuRect.size.height = h3 + y_offset;
            JuRect.origin.y = scoreContainerHeight - y_offset - JuRect.size.height;
            self.juniorBar.frame = JuRect;
            
            CGRect FeRect = self.freshmenBar.frame;
            FeRect.size.height = h1 + y_offset;
            FeRect.origin.y = scoreContainerHeight - y_offset - FeRect.size.height;
            self.freshmenBar.frame = FeRect;
        }];
    });
}

#pragma MARK - View Setup

- (void)setBackgroundGradient {
    //create a gradient for the background
    CAGradientLayer *gradientLayer = [CAGradientLayer layer];
    gradientLayer.frame = self.view.frame;
    
    UIColor *firstColor = [UIColor colorWithRed:105.0/255 green:220.0/255 blue:255.0/255 alpha:1.0];
    UIColor *secondColor = [UIColor colorWithRed:0.0 green:0.17 blue:0.9 alpha:1.0];
    gradientLayer.colors = [NSArray arrayWithObjects:(id)firstColor.CGColor, (id)secondColor.CGColor, nil];
    
    [self.view.layer insertSublayer:gradientLayer atIndex:0];
}

#pragma MARK - IBACTIONS

- (IBAction)showFeedWebView:(id)sender {
    NSURL *url = [[NSURL alloc] initWithString:@"http://www.ustream.tv/embed/19967600?wmode=direct&showtitle=false"];
    WebViewController *wvc = [[WebViewController alloc] initWithURL:url];
    UINavigationController *nvc = [[UINavigationController alloc] initWithRootViewController:wvc];
    nvc.navigationBar.barTintColor = [UIColor colorWithRed:0.2 green:0.4 blue:0.9 alpha:1.0];
    nvc.navigationBar.tintColor = [UIColor whiteColor];
    NSDictionary *attrib = @{ NSForegroundColorAttributeName : [UIColor whiteColor] };
    nvc.navigationBar.titleTextAttributes = attrib;
    
    [self presentViewController:nvc animated:true completion:nil];
}

/*
 
 - (void)startRequests {
 // Create the request.
 NSArray *urlStrings = @[@"http://www.iaolympics.com/api/scores", @"http://www.iaolympics.com/api/freshman",
 @"http://www.iaolympics.com/api/sophomore", @"http://www.iaolympics.com/api/junior",
 @"http://www.iaolympics.com/api/senior", @"http://www.iaolympics.com/api/status"];
 NSMutableArray *urls = [[NSMutableArray alloc] initWithCapacity:5];
 for (NSString *str in urlStrings) {
 NSURL *url = [NSURL URLWithString:str];
 [urls addObject:url];
 }
 
 NSMutableArray *dictStorage = [[NSMutableArray alloc] initWithCapacity:6];
 int index = 0;
 for (NSURL *url in urls) {
 
 NSData *webData = [[NSData alloc] initWithContentsOfURL:url];
 
 if (!webData) {
 return;//data retrieval failed
 }
 if (index != 5) {
 NSDictionary *dataDictionary = [NSJSONSerialization JSONObjectWithData:webData options:0 error:nil];
 [dictStorage addObject:dataDictionary];
 } else {
 NSString *dataString = [[NSString alloc] initWithData:webData encoding:NSUTF8StringEncoding];
 [dictStorage addObject:dataString];
 }
 
 index++;
 }
 self.scoreDictionary = dictStorage[0];
 self.freshmanDictionary = dictStorage[1];
 self.sophomoreDictionary = dictStorage[2];
 self.juniorDictionary = dictStorage[3];
 self.seniorDictionary = dictStorage[4];
 self.statusString = dictStorage[5];
 
 NSLog(@"%@", self.scoreDictionary);
 }
 
 */

@end
