//
//  RDHelper.m
//  mywear
//
//  Created by Darshan Katrumane on 9/30/13.
//  Copyright (c) 2013 RD. All rights reserved.
//

#import "RDHelper.h"

@implementation RDHelper
+(rdAppDelegate *)sharedDelegate {
    return (rdAppDelegate*)[[UIApplication sharedApplication] delegate];
}
+(CGRect) screenSize {
    CGRect screenRect = [[UIScreen mainScreen] bounds];
    return screenRect;
}
+(CGFloat) screenWidth {
    CGRect screenRect = [[UIScreen mainScreen] bounds];
    CGFloat screenWidth = screenRect.size.width;
    return screenWidth;
}
+(CGFloat) screenHeight {
    CGRect screenRect = [[UIScreen mainScreen] bounds];
    CGFloat screenHeight = screenRect.size.height;
    return screenHeight;
}
+(UINavigationController*) navigationController {
    return [(rdAppDelegate*)[[UIApplication sharedApplication] delegate] navcontroller];
}
+(CGSize) correctSize {
    return CGSizeMake([self screenWidth] - 50, [self screenWidth] - 50);
}
+(UIImage*) makeImage:(UIView*) view {
    UIGraphicsBeginImageContext(view.bounds.size);
    [view.layer renderInContext:UIGraphicsGetCurrentContext()];
    UIImage *viewImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return viewImage;
}
+ (void)setRoundedBorder:(float) radius borderWidth:(float)borderWidth color:(UIColor*)color andButton:(UIButton*) button
{
    CALayer * l = [button layer];
    [l setMasksToBounds:YES];
    [l setCornerRadius:radius];
    // You can even add a border
    [l setBorderWidth:borderWidth];
    [l setBorderColor:[color CGColor]];
}

+(NSString*) generateRandom:(NSInteger) count {
    char data[count];
    for (int x=0;x<count;data[x++] = (char)('A' + (arc4random_uniform(26))));
    return [[NSString alloc] initWithBytes:data length:count encoding:NSUTF8StringEncoding];
}
@end
