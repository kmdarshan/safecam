//
//  rdBrowser.h
//  ispy
//
//  Created by kmd on 6/1/14.
//  Copyright (c) 2014 Darshan Katrumane. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MBProgressHUD.h"
#import <AVFoundation/AVFoundation.h>
@interface rdBrowser : UIView <UIWebViewDelegate, UISearchBarDelegate>
- initWithFrame:(CGRect) frame andType:(NSInteger) typeSession andCamera:(NSInteger) camera;
-(void) showCaptureSession:(AVCaptureSession*) captureSession;
@end