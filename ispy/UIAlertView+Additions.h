//
//  UIAlertView+Additions.h
//  ispy
//
//  Created by kmd on 6/8/14.
//  Copyright (c) 2014 Darshan Katrumane. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIAlertView (Additions)

+ (void)presentWithTitle:(NSString *)title
                 message:(NSString *)message
                 buttons:(NSArray *)buttons
                    tags:(NSInteger)tags
      shouldSetTextField:(BOOL)textField
           buttonHandler:(void(^)(NSUInteger index, UIAlertView* alertview))handler;

@end
