//
//  OutlineOverlayRenderer.m
//  IAGuide
//
//  Created by Omar Alejel on 10/10/14.
//  Copyright (c) 2014 Omar Alejel. All rights reserved.
//

#import "OutlineOverlayRenderer.h"

@implementation OutlineOverlayRenderer

- (void)drawMapRect:(MKMapRect)mapRect zoomScale:(MKZoomScale)zoomScale inContext:(CGContextRef)context
{
    MKMapRect overlayRect = [self.overlay boundingMapRect];
    
    CGRect aRect = [self rectForMapRect:overlayRect];
    
    CGContextAddRect(context, aRect);
    
    UIImage *image = [UIImage imageNamed:@"mapoutline"];
    CGImageRef ref = image.CGImage;
    
    //flip coordinate system and adjust angle
    CGContextTranslateCTM(context, aRect.size.width - 5, 0);
    CGContextScaleCTM(context, -1, 1);
    CGContextRotateCTM(context, 1 * (M_PI/180));
    
    CGContextDrawImage(context, aRect, ref);
}

@end
