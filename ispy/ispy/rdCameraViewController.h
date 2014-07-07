//
//  rdCameraViewController.h
//  ispy
//
//  Created by Darshan Katrumane on 5/26/14.
//  Copyright (c) 2014 Darshan Katrumane. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AssetsLibrary/AssetsLibrary.h>
#import <AVFoundation/AVFoundation.h>

@interface rdCameraViewController : UIViewController <AVCaptureFileOutputRecordingDelegate>
-(id) initWithImage:(UIImage*) image andType:(NSInteger) type andCamera:(NSInteger) camera andStorage:(NSInteger) storage;
@end
