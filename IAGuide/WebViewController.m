//
//  WebViewController.m
//  IAGuide
//
//  Created by Omar Alejel on 4/5/15.
//  Copyright (c) 2015 Omar Alejel. All rights reserved.
//

#import "WebViewController.h"

@interface WebViewController () <UIWebViewDelegate>

@end

@implementation WebViewController

- (instancetype)initWithURL:(NSURL *)url {
    self = [super init];
    if (self) {
        UIBarButtonItem *doneItem = [[UIBarButtonItem alloc] initWithTitle:@"Done" style:UIBarButtonItemStyleDone target:self action:@selector(dismiss)];
        self.navigationItem.rightBarButtonItem = doneItem;
        self.navigationItem.title = @"Live Olympics Feed";
        UIWebView *webView = [[UIWebView alloc] init];
        webView.scalesPageToFit = TRUE;
        self.url = url;
        self.view = webView;
        webView.delegate = self;
    }
    
    return self;
}

-(void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear: animated];
    NSURLRequest *request = [[NSURLRequest alloc] initWithURL:self.url];
    [(UIWebView *)self.view loadRequest:request];
}

- (void)dismiss {
    [self.navigationController.presentingViewController dismissViewControllerAnimated:TRUE completion:nil];
}

- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error {
    NSLog(@"no connection");
    UIImage *noConnectImage = [UIImage imageNamed:@"noconnection.png"];
    UIImageView *imageView = [[UIImageView alloc] initWithImage:noConnectImage];
    CGFloat W = imageView.frame.size.width / 2;
    CGFloat H = imageView.frame.size.height / 2;
    imageView.frame = CGRectMake(0, 0, W, H);
     
    imageView.center = self.view.center;
    
    [self.view addSubview:imageView];
}

@end
