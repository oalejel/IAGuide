//
//  OlympicsViewController.m
//  IAGuide
//
//  Created by Omar Alejel on 12/7/14.
//  Copyright (c) 2014 Omar Alejel. All rights reserved.
// This view controller is responsible for showing data on the ia olympics only for olympics day

#import "OlympicsViewController.h"
#import "WebViewController.h"

@interface OlympicsViewController ()

@property (nonatomic) BOOL viewAppearedBefore;
@property (weak, nonatomic) IBOutlet UITextView *infoTextView;
@property (weak, nonatomic) IBOutlet UIView *freshmenBar;
@property (weak, nonatomic) IBOutlet UIView *juniorBar;
@property (weak, nonatomic) IBOutlet UIView *seniorBar;
@property (weak, nonatomic) IBOutlet UIView *sophomoreBar;
@property (weak, nonatomic) IBOutlet UIButton *showFeedButton;

@property (nonatomic) NSDictionary *scoreDictionary;
@property (nonatomic) NSDictionary *freshmanDictionary;
@property (nonatomic) NSDictionary *sophomoreDictionary;
@property (nonatomic) NSDictionary *juniorDictionary;
@property (nonatomic) NSDictionary *seniorDictionary;

@property (nonatomic) IBOutlet UIView *contentView;
@property (nonatomic) IBOutlet UIScrollView *scrollView;

@property (nonatomic) NSString *statusString;
@property (weak, nonatomic) IBOutlet UIView *scoresContainer;

@end

@implementation OlympicsViewController

- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.tabBarItem.title = @"Olympics";
        self.tabBarItem.image = [UIImage imageNamed:@"trophy"];
    }
    
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    UIImage *pressedImage = [UIImage imageNamed:@"pressed.png"];
    [self.showFeedButton setBackgroundImage:pressedImage forState:UIControlStateHighlighted];
    
    self.scoresContainer.layer.cornerRadius = 4;
    
    CGFloat contentHeight = self.contentView.frame.size.height;
    self.contentView.frame = CGRectMake(0, 0, self.view.frame.size.width, contentHeight);
    self.contentView.backgroundColor = [UIColor clearColor];
    
    self.scrollView.contentSize = self.contentView.frame.size;
    [self.scrollView addSubview:self.contentView];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    if (!self.viewAppearedBefore) {
        
        [self setBackgroundGradient];
//        [self drawScoresGraph];
        
        //do on a separate thread so things dont lag...
        dispatch_queue_t q = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
        dispatch_async(q, ^{
            [self getData];
            [self setBargraphs];
        });
    }
}

- (void)viewDidLayoutSubviews {
    [self drawScoresGraph];
}

- (void)drawScoresGraph {
    UIBezierPath *xAxisPath = [[UIBezierPath alloc] init];
    UIBezierPath *yAxisPath = [[UIBezierPath alloc] init];
    
    CGFloat xMin = 15;
    CGFloat xMax = self.scoresContainer.frame.size.width - xMin;
    CGFloat yMin = 15;
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
}

//-(void)viewDidAppear:(BOOL)animated {
//    [super viewDidAppear:animated];
//    if (!self.viewAppearedBefore) {
//        self.viewAppearedBefore = true;
//    }
//    
//}

- (void)getData {
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
    
    CGFloat maxWidth = self.view.frame.size.width - (2 * self.freshmenBar.frame.origin.x);
    
    CGFloat frWidth = frPercent * maxWidth;
    CGFloat soWidth = soPercent * maxWidth;
    CGFloat juWidth = juPercent * maxWidth;
    CGFloat seWidth = sePercent * maxWidth;
    
    [self animateGraphsForHeights:frWidth height2:soWidth height3:juWidth height4:seWidth];
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
#pragma MARK - IBACTIONS

- (void)animateGraphsForHeights:(CGFloat)h1 height2:(CGFloat)h2 height3:(CGFloat)h3 height4:(CGFloat)h4 {
    [UIView animateWithDuration:2.0 animations:^{
        CGRect SeRect = self.seniorBar.frame;
        SeRect.size.height = h4;
        NSLog(@"width: %f", SeRect.size.width);
        self.seniorBar.frame = SeRect;
        
        CGRect SoRect = self.sophomoreBar.frame;
        SoRect.size.height = h2;
        self.sophomoreBar.frame = SoRect;
        
        CGRect JuRect = self.juniorBar.frame;
        JuRect.size.height = h2;
        self.juniorBar.frame = JuRect;
        
        CGRect FeRect = self.freshmenBar.frame;
        FeRect.size.height = h2;
        self.freshmenBar.frame = FeRect;
    }];
}

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

@end
