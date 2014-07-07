//
//  rdBrowser.m
//  ispy
//
//  Created by kmd on 6/1/14.
//  Copyright (c) 2014 Darshan Katrumane. All rights reserved.
//

#import "rdBrowser.h"
#import "rdCameraViewController.h"

@interface rdBrowser() {
    UISearchBar *sbar;
    UIView *cameraIcon;
    NSInteger session;
    NSInteger camera;
    MBProgressHUD *progress;
    UIWebView *webview ;
}

@end
@implementation rdBrowser

- (id)initWithFrame:(CGRect)frame andType:(NSInteger) typeSession andCamera:(NSInteger) thscamera;
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        sbar = [[UISearchBar alloc] initWithFrame:CGRectMake(0, [UIApplication sharedApplication].statusBarFrame.size.height-20, self.frame.size.width, 40)];
        [sbar setDelegate:self];
        [self addSubview:sbar];
        
        session = typeSession;
        camera = thscamera;
        
        webview = [[UIWebView alloc] initWithFrame:CGRectMake(0, sbar.frame.size.height+sbar.frame.origin.y, self.frame.size.width, self.frame.size.height - sbar.frame.size.height-20)];
        NSString *fullURL = @"http://www.google.com";
        NSURL *url = [NSURL URLWithString:fullURL];
        NSURLRequest *requestObj = [NSURLRequest requestWithURL:url];
        [webview loadRequest:requestObj];
        [self addSubview:webview];
        [webview setDelegate:self];
        
        progress = [MBProgressHUD showHUDAddedTo:self animated:YES];
        progress.mode = MBProgressHUDModeIndeterminate;
        progress.labelText = @"Loading";
        
        cameraIcon = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 50, 50)];
        [cameraIcon setCenter:CGPointMake(self.frame.size.width - cameraIcon.frame.size.width - 20, self.center.y)];
        [cameraIcon setBackgroundColor:[UIColor yellowColor]];
        [[cameraIcon layer] setBorderColor:[UIColor blackColor].CGColor];
        [[cameraIcon layer] setCornerRadius:20.0f];
        [[cameraIcon layer] setBorderWidth:5.0f];
        [cameraIcon setUserInteractionEnabled:YES];
//        [self addSubview:cameraIcon];
        
//        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTap:)];
//        [cameraIcon addGestureRecognizer:tap];
//        UIPanGestureRecognizer *pan = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handlePan:)];
//        [cameraIcon addGestureRecognizer:pan];
        
    }
    return self;
}
-(void)webViewDidStartLoad:(UIWebView *)webView {
    [progress show:YES];
}

-(void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error {
    [progress hide:YES];
}

-(void)webViewDidFinishLoad:(UIWebView *)webView {
    [progress hide:YES];
}

-(void) handleTap:(UITapGestureRecognizer*) recognizer {
    if ([[cameraIcon layer] borderColor] == [UIColor redColor].CGColor){
        [[cameraIcon layer] setBorderColor:[UIColor blackColor].CGColor];
    }else{
        [[cameraIcon layer] setBorderColor:[UIColor redColor].CGColor];
    }
    NSLog(@"sending clickPicture notification");
    NSDictionary *dict = [[NSDictionary alloc] initWithObjectsAndKeys:[NSNumber numberWithInteger:camera], @"camera", [NSNumber numberWithInteger:session], @"session", nil];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"clickPicture" object:dict];
}

-(void) handlePan:(UIPanGestureRecognizer*) recognizer {
    CGPoint translation = [recognizer translationInView:self];
    recognizer.view.center = CGPointMake(recognizer.view.center.x + translation.x, recognizer.view.center.y + translation.y);
    [recognizer setTranslation:CGPointMake(0, 0) inView:self];
}

-(void) handlePinch:(UIPinchGestureRecognizer*) recognizer {
    recognizer.view.transform = CGAffineTransformScale(recognizer.view.transform, recognizer.scale, recognizer.scale);
    recognizer.scale = 1;
}

-(void)searchBarTextDidBeginEditing:(UISearchBar *)searchBar {
    [searchBar setText:@"http://www."];
    [searchBar setShowsCancelButton:YES animated:YES];
}

-(void)searchBarCancelButtonClicked:(UISearchBar *)searchBar {
    [self endEditing:YES];
}

-(void)searchBarSearchButtonClicked:(UISearchBar *)searchBar {
    NSString *fullURL = [searchBar text];
    NSURL *url = [NSURL URLWithString:fullURL];
    NSURLRequest *requestObj = [NSURLRequest requestWithURL:url];
    [webview loadRequest:requestObj];
    [self endEditing:YES];
}

-(void) showCaptureSession:(AVCaptureSession*) captureSession {
    AVCaptureVideoPreviewLayer *previewLayer = [[AVCaptureVideoPreviewLayer alloc]initWithSession:captureSession];
    [previewLayer setVideoGravity:AVLayerVideoGravityResizeAspectFill];
    
    UIView *camView = [[UIView alloc] initWithFrame:CGRectMake(10, 10, 100, 100)];
    [self addSubview:camView];
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTap:)];
    [camView addGestureRecognizer:tap];
    UIPanGestureRecognizer *pan = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handlePan:)];
    [camView addGestureRecognizer:pan];

    CALayer *rootLayer = [camView layer];
    [rootLayer setMasksToBounds:YES];
    CGRect frame = [camView frame];
    [previewLayer setFrame:frame];
    [rootLayer insertSublayer:previewLayer atIndex:0];
}

@end
