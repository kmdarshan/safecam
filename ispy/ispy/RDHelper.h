//
//  RDHelper.h
//  mywear
//
//  Created by Darshan Katrumane on 9/30/13.
//  Copyright (c) 2013 RD. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "rdAppDelegate.h"

#define AMZN_ID @""
#define AMZN_KEY @""
#define AMZN_BUCKET @""
#define DROPBOX_KEY @""
#define DROPBOX_SECRET @""

#define STORAGE_DROPBOX     1
#define STORAGE_LOCAL       2

#define TYPE_CAMERA         1
#define TYPE_VIDEO          2

#define CAMERA_FRONT        1
#define CAMERA_BACK         2

@interface RDHelper : NSObject
+(rdAppDelegate*)sharedDelegate;
+(CGFloat) screenWidth;
+(CGFloat) screenHeight;
+(UINavigationController*) navigationController;
+(CGSize) correctSize;
+(UIImage*) makeImage:(UIView*) view;
+ (void)setRoundedBorder:(float) radius borderWidth:(float)borderWidth color:(UIColor*)color andButton:(UIButton*) button;
+(NSString*) generateRandom:(NSInteger) count;
@end
