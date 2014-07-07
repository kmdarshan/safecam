//
//  UIAlertView+Additions.m
//  ispy
//
//  Created by kmd on 6/8/14.
//  Copyright (c) 2014 Darshan Katrumane. All rights reserved.
//

#import "UIAlertView+Additions.h"
#import <objc/runtime.h>

@implementation UIAlertView (Additions)

static const char *HANDLER_KEY = "com.redflower.alertview.handler";

+ (void)presentWithTitle:(NSString *)title
                 message:(NSString *)message
                 buttons:(NSArray *)buttons
                    tags:(NSInteger)tags
      shouldSetTextField:(BOOL)textField
           buttonHandler:(void (^)(NSUInteger, UIAlertView*))handler {
    
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:title
                                                    message:message
                                                   delegate:nil
                                          cancelButtonTitle:nil
                                          otherButtonTitles:nil];
    [alert setTag:tags];
    [alert setDelegate:alert];
    
    if(textField){
        [alert setAlertViewStyle:UIAlertViewStyleLoginAndPasswordInput];
        [[alert textFieldAtIndex:1] setSecureTextEntry:NO];
        [[alert textFieldAtIndex:0] setPlaceholder:@"Passcode"];
        [[alert textFieldAtIndex:1] setPlaceholder:@"Re-Enter Passcode"];
        [[alert textFieldAtIndex:0] setKeyboardType:UIKeyboardTypeNumberPad];
        [[alert textFieldAtIndex:1] setKeyboardType:UIKeyboardTypeNumberPad];
    }
    
    [buttons enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        [alert addButtonWithTitle:obj];
    }];
    
    if (handler)
        objc_setAssociatedObject(alert, HANDLER_KEY, handler, OBJC_ASSOCIATION_COPY_NONATOMIC);
    
    [alert show];
}

- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex {
    id handler = objc_getAssociatedObject(alertView, HANDLER_KEY);
    
    if (handler)
        ((void(^)())handler)(buttonIndex, alertView);
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    NSUInteger newLength = [textField.text length] + [string length] - range.length;
    return (newLength > 4) ? NO : YES;
}

@end
