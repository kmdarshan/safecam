//
//  rdCameraViewController.m
//  ispy
//
//  Created by Darshan Katrumane on 5/26/14.
//  Copyright (c) 2014 Darshan Katrumane. All rights reserved.
//

#import "rdCameraViewController.h"
#import "RDHelper.h"
#import "rdBrowser.h"
#import <Dropbox/Dropbox.h>

// 1 = photo
// 2 = video

@interface rdCameraViewController ()
{
    AVCaptureSession *captureSession;
    AVCaptureStillImageOutput *stillImageOutput;
    UIImageView *previewImage;
    NSInteger type;
    AVCaptureMovieFileOutput *movieOutput;
    BOOL bRecording;
    NSInteger selectedCamera, selectedStorage;
    rdBrowser *browser;
}
@end

@implementation rdCameraViewController

-(id) initWithImage:(UIImage*) image andType:(NSInteger) typeSession andCamera:(NSInteger) camera andStorage:(NSInteger) storage {
    if((self = [super init]))
    {
        selectedCamera = camera;
        selectedStorage = storage;
        bRecording = false;
        type = typeSession;
        
        // lets show the browser to the user
        browser = [[rdBrowser alloc] initWithFrame:self.view.frame andType:(NSInteger) typeSession andCamera:(NSInteger) camera];
        [self.view addSubview:browser];
        
        // add a remote notification
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(clickPicture:)
                                                     name:@"clickPicture" object:nil];
        self.edgesForExtendedLayout = UIRectEdgeNone;
        
    }
    return self;
}

-(void)viewDidAppear:(BOOL)animated {
    [self startCamera];
}

-(void)viewWillAppear:(BOOL)animated {
    [[RDHelper navigationController] setNavigationBarHidden:NO];
}

- (AVCaptureDevice *) frontFacingCameraIfAvailable
{
    NSArray *videoDevices = [AVCaptureDevice devicesWithMediaType:AVMediaTypeVideo];
    AVCaptureDevice *captureDevice = nil;
    for (AVCaptureDevice *device in videoDevices)
    {
        if (device.position == AVCaptureDevicePositionFront)
        {
            captureDevice = device;
            break;
        }
    }
    
    if ( ! captureDevice)
    {
        captureDevice = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
    }
    
    return captureDevice;
}

-(void) startCamera {
    
    captureSession = [[AVCaptureSession alloc]init];
    [captureSession setSessionPreset:AVCaptureSessionPresetMedium];
    
    AVCaptureDevice *inputDevice = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
    if(selectedCamera == CAMERA_FRONT) {
        inputDevice = [self frontFacingCameraIfAvailable];
    }
    NSError *error;
    AVCaptureDeviceInput *deviceInput = [AVCaptureDeviceInput deviceInputWithDevice:inputDevice error:&error];
    
    if ([captureSession canAddInput:deviceInput]) {
        [captureSession addInput:deviceInput];
    }
    
    [captureSession startRunning];
    
    [browser showCaptureSession:captureSession];
    //    AVCaptureVideoPreviewLayer *previewLayer = [[AVCaptureVideoPreviewLayer alloc]initWithSession:captureSession];
    //    [previewLayer setVideoGravity:AVLayerVideoGravityResizeAspectFill];
    //    CALayer *rootLayer = [[self view] layer];
    //    [rootLayer setMasksToBounds:YES];
    //    CGRect frame = self.view.frame;
    //    [previewLayer setFrame:frame];
    //    [rootLayer insertSublayer:previewLayer atIndex:0];
    
    if(type == TYPE_CAMERA) {
        stillImageOutput = [[AVCaptureStillImageOutput alloc]init];
        if ([captureSession canAddOutput:stillImageOutput])
            [captureSession addOutput:stillImageOutput];
        
        NSDictionary *outputSettings = [[NSDictionary alloc] initWithObjectsAndKeys:AVVideoCodecJPEG, AVVideoCodecKey, nil];
        [stillImageOutput setOutputSettings:outputSettings];
        
        UITapGestureRecognizer *trecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(clickPicture:)];
        [previewImage setUserInteractionEnabled:YES];
        [previewImage addGestureRecognizer:trecognizer];
        [previewImage setFrame:self.view.frame];
    }
    
    if(type == TYPE_VIDEO) {
        CMTime maxDuration = CMTimeMake(60, 1);
        movieOutput = [[AVCaptureMovieFileOutput alloc] init];
        movieOutput.maxRecordedDuration = maxDuration;
        movieOutput.minFreeDiskSpaceLimit = 1000;
        if ([captureSession canAddOutput:movieOutput]) {
            [captureSession addOutput:movieOutput];
        }
        else {
            NSLog(@"failed to add output");
        }
    }
}

-(void)captureOutput:(AVCaptureFileOutput *)captureOutput didFinishRecordingToOutputFileAtURL:(NSURL *)outputFileURL fromConnections:(NSArray *)connections error:(NSError *)error {
    bRecording = FALSE;
    BOOL recordedSuccessfully = YES;
    if ([error code] != noErr) {
        // A problem occurred: Find out if the recording was successful.
        id value = [[error userInfo] objectForKey:AVErrorRecordingSuccessfullyFinishedKey];
        if (value) {
            recordedSuccessfully = [value boolValue];
        }
    }
    ALAssetsLibrary* library = [[ALAssetsLibrary alloc] init];
    if (selectedStorage == STORAGE_DROPBOX) {
        [self uploadDataToDropbox:[NSData dataWithContentsOfURL:outputFileURL] andExt:@".mov"];
    }else{
        [library writeVideoAtPathToSavedPhotosAlbum:outputFileURL completionBlock:^(NSURL *assetURL, NSError *error) {
            NSLog(@"Video file is written %@ ", outputFileURL);
        }];
    }
}

//-(void) uploadImageToCloud:(NSData*) data {
//    AmazonS3Client *s3 = [[AmazonS3Client alloc] initWithAccessKey:AMZN_ID withSecretKey:AMZN_KEY];
//    S3PutObjectRequest *por = [[S3PutObjectRequest alloc] initWithKey:@"testpic" inBucket:AMZN_BUCKET];
//    por.contentType = @"image/jpeg";
//    por.data = data;
//    [s3 putObject:por];
//}

-(void) uploadDataToDropbox:(NSData*) data andExt:(NSString*) ext{
    DBAccount *account = [[DBAccountManager sharedManager] linkedAccount];
    if (account) {
        DBFilesystem *filesystem = [DBFilesystem sharedFilesystem];
        if (!filesystem) {
            filesystem = [[DBFilesystem alloc] initWithAccount:account];
            [DBFilesystem setSharedFilesystem:filesystem];
        }
        NSString *randomString = [RDHelper generateRandom:5];
        DBPath *newPath = [[DBPath root] childPath:[NSString stringWithFormat:@"%@.%@", randomString, ext]];
        DBFile *file = [[DBFilesystem sharedFilesystem] createFile:newPath error:nil];
        [file writeData:data error:nil];
    }
}

-(void) clickPicture :(NSNotification*) notification  {
    NSDictionary *dict = [notification object];
    NSString *strsession = [dict objectForKey:@"session"];
    NSString *strcamera = [dict objectForKey:@"camera"];
    type = [strsession intValue];
    selectedCamera = [strcamera intValue];
    
    if(type == TYPE_CAMERA) {
        AVCaptureConnection *connections = nil;
        if([stillImageOutput.connections count] > 0){
            for (AVCaptureConnection *connection in stillImageOutput.connections) {
                for (AVCaptureInputPort *port in [connection inputPorts]) {
                    if ([[port mediaType]isEqual:AVMediaTypeVideo]) {
                        connections = connection;
                        break;
                    }
                }
                if (connections) {
                    break;
                }
            }
            
            if (connections != NULL) {
                [stillImageOutput captureStillImageAsynchronouslyFromConnection:connections completionHandler:^(CMSampleBufferRef imageDataSampleBuffer, NSError *error) {
                    if (imageDataSampleBuffer !=NULL) {
                        NSData *imageData = [AVCaptureStillImageOutput jpegStillImageNSDataRepresentation:imageDataSampleBuffer];
                        if (selectedStorage == STORAGE_DROPBOX) {
                            [self uploadDataToDropbox:imageData andExt:@".jpeg"];
                        }else if(selectedStorage == STORAGE_LOCAL) {
                            UIImage *image = [UIImage imageWithData:imageData];
                            ALAssetsLibrary *library = [[ALAssetsLibrary alloc] init];
                            [library writeImageToSavedPhotosAlbum:[image CGImage]
                                                      orientation:(ALAssetOrientation)[image imageOrientation]
                                                  completionBlock:^(NSURL *assetURL, NSError *error){
                                                      if (error) {
                                                          NSLog(@"Writing images to file %@ ", assetURL);
                                                      }
                                                  }];
                        }
                    }
                }];
            }else{
                NSLog(@"Not able to write to files");
            }
        }else{
            NSLog(@"stillImageOutput connections is less than zero");
        }
    }
    
    if(type == TYPE_VIDEO) {
        if(!bRecording) {
            NSString *outputPath = [[NSString alloc] initWithFormat:@"%@%@", NSTemporaryDirectory(), @"output.mov"];
            NSURL *outputURL = [[NSURL alloc] initFileURLWithPath:outputPath];
            NSFileManager *fileManager = [NSFileManager defaultManager];
            if ([fileManager fileExistsAtPath:outputPath]) {
                NSError *error;
                if ([fileManager removeItemAtPath:outputPath error:&error] == NO) {
                    NSLog(@"error getting a file url");
                }
            }
            if (movieOutput != Nil) {
                bRecording = TRUE;
                if(movieOutput != NULL) {
                    [movieOutput startRecordingToOutputFileURL:outputURL recordingDelegate:self];
                }else{
                    NSLog(@"movie ouput is empty, cant record");
                }
            }else{
                NSLog(@"no file exists at url %@ / Movie output is null", outputURL);
            }
        }else{
            NSLog(@"stopped recording");
            bRecording = FALSE;
            [movieOutput stopRecording];
        }
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
