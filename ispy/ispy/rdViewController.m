//
//  rdViewController.m
//  ispy
//
//  Created by Darshan Katrumane on 5/26/14.
//  Copyright (c) 2014 Darshan Katrumane. All rights reserved.
//

#import "rdViewController.h"
#import "RDHelper.h"
#import "rdCameraViewController.h"
#import <Dropbox/Dropbox.h>
#import "UIAlertView+Additions.h"

// 1 cloud
// 2 local

// 1 photo
// 2 video

@interface rdViewController ()
{
    UIImageView *previewImage;
    UIImage *pimage;
    NSInteger selectedCamera, selectedStorage, selectedType;
    UIButton *startButton;
    UIButton *rightButton;
    UIView *blinds;
    UITextField *passcode;
}
@end

@implementation rdViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self initButtons];
    [self.view setBackgroundColor:[UIColor whiteColor]];
}

-(void)viewDidAppear:(BOOL)animated {
    [[RDHelper navigationController] setNavigationBarHidden:NO];
}

-(void) initButtons {
    NSShadow *shadow = [[NSShadow alloc] init];
    [shadow setShadowColor:[UIColor clearColor]];
//    [shadow setShadowOffset:CGSizeMake(1.0f, 1.0f)];
    
    [[UISegmentedControl appearance] setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:
                                                             [UIColor whiteColor],NSForegroundColorAttributeName,
                                                             shadow, NSShadowAttributeName,
                                                             [UIFont fontWithName:@"AvenirNext-Bold" size:16.0], NSFontAttributeName, nil] forState:UIControlStateSelected];

    [[UISegmentedControl appearance] setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:
                                                             [UIColor colorWithRed:0.0/255.0 green:127.0/255.0 blue:255.0/255.0 alpha:1.0],NSForegroundColorAttributeName,
                                                             shadow, NSShadowAttributeName,
                                                             [UIFont fontWithName:@"AvenirNext-Regular" size:16.0], NSFontAttributeName, nil] forState:UIControlStateNormal];
    [[UISegmentedControl appearance] setTintColor:[UIColor colorWithRed:0.0/255.0 green:119.0/255.0 blue:255.0/255.0 alpha:1.0]];

    [[UINavigationBar appearance] setBarTintColor:[UIColor redColor]];
    // select front camera
    selectedCamera = 1;
    selectedStorage = 2;
    selectedType = 1;
    
    previewImage = [[UIImageView alloc] initWithFrame:CGRectMake(20, 15, 100, 100)];
    [previewImage setCenter:CGPointMake(self.view.center.x, 100)];
    [[previewImage layer] setBorderColor:[UIColor blackColor].CGColor];
    [[previewImage layer] setBorderWidth:2.0f];
    // [self.view addSubview:previewImage];
    
    UIButton *selectPicture = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [selectPicture setFrame:CGRectMake(0, previewImage.frame.size.height + previewImage.frame.origin.y + 5, 300, 50)];
    [selectPicture setTitle:@"Select Background Picture" forState:UIControlStateNormal];
    [selectPicture setUserInteractionEnabled:YES];
    [selectPicture addTarget:self action:@selector(selectPictureFromLibrary) forControlEvents:UIControlEventTouchUpInside];
    // [self.view addSubview:selectPicture];
    [RDHelper setRoundedBorder:6.0f borderWidth:2.0f color:[UIColor blueColor] andButton:selectPicture];
    [selectPicture setCenter:CGPointMake(self.view.center.x, selectPicture.center.y)];

    NSArray *options = [[NSArray alloc] initWithObjects: @"Photo", @"Video", nil];
    UISegmentedControl *scontroloptions = [[UISegmentedControl alloc] initWithItems:options];
    [scontroloptions setSelectedSegmentIndex:0];
    [scontroloptions setFrame:CGRectMake(0, scontroloptions.frame.size.height + scontroloptions.frame.origin.y+ 5, 300, 50)];
    [self.view addSubview:scontroloptions];
    [scontroloptions setCenter:CGPointMake(self.view.center.x, self.view.center.y)];
    [scontroloptions addTarget:self action:@selector(pickOptions:) forControlEvents:UIControlEventValueChanged];
    
    NSArray *cameras = [[NSArray alloc] initWithObjects: @"Front Camera", @"Back Camera", nil];
    UISegmentedControl *scontrol = [[UISegmentedControl alloc] initWithItems:cameras];
    [scontrol setSelectedSegmentIndex:0];
    [scontrol setFrame:CGRectMake(0, scontroloptions.frame.size.height + scontroloptions.frame.origin.y+ 5, 300, 50)];
    [self.view addSubview:scontrol];
    [scontrol setCenter:CGPointMake(self.view.center.x, scontrol.center.y)];
    [scontrol addTarget:self action:@selector(pickCamera:) forControlEvents:UIControlEventValueChanged];
    
    NSArray *storages = [[NSArray alloc] initWithObjects: @"Dropbox", @"Local Storage", nil];
    UISegmentedControl *scontrolstorage = [[UISegmentedControl alloc] initWithItems:storages];
    [scontrolstorage setSelectedSegmentIndex:1];
    [scontrolstorage setFrame:CGRectMake(0, scontrol.frame.size.height + scontrol.frame.origin.y+ 5, 300, 50)];
    [self.view addSubview:scontrolstorage];
    [scontrolstorage setCenter:CGPointMake(self.view.center.x, scontrolstorage.center.y)];
    [scontrolstorage addTarget:self action:@selector(pickStorage:) forControlEvents:UIControlEventValueChanged];
    
    startButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [[startButton layer] setCornerRadius:5.0f];
    [startButton setTitle:@"start" forState:UIControlStateNormal];
    [startButton setUserInteractionEnabled:YES];
    [startButton addTarget:self action:@selector(clickStart) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:startButton];
    [startButton setFrame:CGRectMake(0, scontrolstorage.frame.size.height + scontrolstorage.frame.origin.y + 5, 300, 50)];
    [startButton setCenter:CGPointMake(self.view.center.x, startButton.center.y)];
    [[startButton titleLabel] setFont:[UIFont fontWithName:@"Menlo-Bold" size:20.0f]];
    [startButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    CGRect frameimg = CGRectMake(0, 0, 30, 30);
    [startButton setBackgroundColor:[UIColor redColor]];
    rightButton = [[UIButton alloc] initWithFrame:frameimg];
    [rightButton addTarget:self action:@selector(lockScreen) forControlEvents:UIControlEventTouchUpInside];

    UIBarButtonItem *lockButton = [[UIBarButtonItem alloc] initWithCustomView:rightButton];
    self.navigationItem.rightBarButtonItem=lockButton;
    
    blinds = [[UIView alloc] initWithFrame:CGRectMake(0, [[self.navigationController navigationBar] frame].size.height + [[self.navigationController navigationBar] frame].origin.y, self.view.frame.size.width, self.view.frame.size.height)];
    [blinds setBackgroundColor:[UIColor whiteColor]];
    [blinds setAlpha:0];
    UIImageView *iv = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"swan.jpg"]];
    [iv setFrame:blinds.frame];
    [blinds addSubview:iv];
    [self.view addSubview:blinds];
    
    passcode = [[UITextField alloc] initWithFrame:CGRectMake(0, 0, 100, 50)];
    [passcode setPlaceholder:@"PIN"];
    [passcode setDelegate:self];
    passcode.textAlignment = NSTextAlignmentCenter;
    [passcode setKeyboardType:UIKeyboardTypeNumberPad];
    [passcode setBorderStyle:UITextBorderStyleRoundedRect];
    [[passcode layer] setBorderColor:[UIColor colorWithRed:123.0/255.0 green:119.0/255.0 blue:114.0/255.0 alpha:1.0f].CGColor];
    [[passcode layer] setBorderWidth:1.0f];
    [[passcode layer] setCornerRadius:5.0f];
    [blinds addSubview:passcode];
    [passcode setCenter:blinds.center];
    
    [self setLockScreenButtonImages];
    
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    NSUInteger newLength = [textField.text length] + [string length] - range.length;
    return (newLength > 4) ? NO : YES;
}

-(void) setLockScreenButtonImages {
    BOOL locked = [[NSUserDefaults standardUserDefaults] boolForKey:@"screenLocked"];
    UIImage* image;
    if (locked ) {
        image = [UIImage imageNamed:@"lock.png"];
        [blinds setAlpha:1.0f];
        [passcode setText:@""];
    }else{
        image = [UIImage imageNamed:@"unlock.png"];
        [blinds setAlpha:0];
    }
    [rightButton setBackgroundImage:image forState:UIControlStateNormal];
}

-(void) lockScreen {
    [self.view endEditing:YES];
    BOOL locked = [[NSUserDefaults standardUserDefaults] boolForKey:@"screenLocked"];
    UIImage* image;
    if (locked ) {

        // get the input from the user and check for passwords
        NSString *pass = [[NSUserDefaults standardUserDefaults] stringForKey:@"screenLockedPassword"];
        if ([pass isEqualToString:[passcode text]]) {
            [passcode setText:@""];
            [[NSUserDefaults standardUserDefaults] synchronize];
            [rightButton setBackgroundImage:image forState:UIControlStateNormal];
            [[NSUserDefaults standardUserDefaults] setBool:NO forKey:@"screenLocked"];
            image = [UIImage imageNamed:@"unlock.png"];
            [rightButton setBackgroundImage:image forState:UIControlStateNormal];
            [UIView animateWithDuration:0.5f animations:^{
                [blinds setAlpha:0];
            }];
        }else{
            UIAlertView *view = [[UIAlertView alloc] initWithTitle:@"" message:@"Passcodes don't match." delegate:self cancelButtonTitle:nil otherButtonTitles:@"OK", nil];
            [view setTag:999999];
            [view show];
        }
    }else{
        // unlocked
        // check if passcode has been set
        // if yes, lock the screen
        NSString *pass = [[NSUserDefaults standardUserDefaults] stringForKey:@"screenLockedPassword"];
        image = [UIImage imageNamed:@"lock.png"];
        if (pass != NULL) {
            [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"screenLocked"];
            [[NSUserDefaults standardUserDefaults] synchronize];
            [rightButton setBackgroundImage:image forState:UIControlStateNormal];
            [UIView animateWithDuration:0.5f animations:^{
                [blinds setAlpha:1.0f];
            }];

        }else {
            // passcode hasn't been
            // ask user if they want to set a passcode
            // if yes, go ahead and ask for passcode
            [UIAlertView presentWithTitle:@"Passcode"
                                  message:@"Do you want to set a passcode ?"
                                  buttons:@[ @"Yes", @"No" ]
                                     tags:1
                       shouldSetTextField:NO
                            buttonHandler:^(NSUInteger index, UIAlertView *alertview) {
                                
                                if (index == 0) {
                                    [UIAlertView presentWithTitle:@"Passcode"
                                                          message:@"Enter a 4 digit code."
                                                          buttons:@[ @"Cancel", @"Ok" ]
                                                             tags:2
                                               shouldSetTextField:YES
                                                    buttonHandler:^(NSUInteger index, UIAlertView *alertview) {
                                                        if (index == 1 && [alertview tag] == 2) {
                                                            // verify passcodes
                                                            if(   [[[alertview textFieldAtIndex:0] text] length] != 4
                                                               || [[[alertview textFieldAtIndex:1] text] length] != 4
                                                               || ![[[alertview textFieldAtIndex:0] text] isEqualToString: [[alertview textFieldAtIndex:1] text]])
                                                            {
                                                                    UIAlertView *view = [[UIAlertView alloc] initWithTitle:@"Errors" message:@"Passcode length is not equal to 4. \nPasscodes don't match. \nPlease try again." delegate:self cancelButtonTitle:nil otherButtonTitles:@"Ok", nil];
                                                                    [view setTag:999999];
                                                                    [view show];
                                                            }else {
                                                                // they match lets set the passcode
                                                                [[NSUserDefaults standardUserDefaults] setValue:[[alertview textFieldAtIndex:0] text] forKeyPath:@"screenLockedPassword"];
                                                                UIAlertView *view = [[UIAlertView alloc] initWithTitle:@"Passcode" message:[NSString stringWithFormat:@"Please do not forget your passcode. No one except you knows your passcode. There is no way to reset it. Your passcode is %@ ", [[alertview textFieldAtIndex:0] text]] delegate:self cancelButtonTitle:nil otherButtonTitles:@"Ok", nil];
                                                                [view setTag:9999999];
                                                                [view show];
                                                                
                                                                [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"screenLocked"];
                                                                [[NSUserDefaults standardUserDefaults] synchronize];
                                                                [rightButton setBackgroundImage:image forState:UIControlStateNormal];
                                                                [UIView animateWithDuration:0.5f animations:^{
                                                                    [blinds setAlpha:1.0f];
                                                                }];

                                                            }
                                                        }
                                                    }];

                                }
                            }];
            
        }
    }
    
}

-(void) pickOptions:(id) sender {
    UISegmentedControl *segmentedControl = (UISegmentedControl *)sender;
    selectedType = [segmentedControl selectedSegmentIndex] + 1;
}

-(void) pickStorage: (id) sender {
    UISegmentedControl *segmentedControl = (UISegmentedControl *)sender;
    selectedStorage = [segmentedControl selectedSegmentIndex] + 1;
}

-(void) pickCamera:(id)sender {
    UISegmentedControl *segmentedControl = (UISegmentedControl *)sender;
    selectedCamera = [segmentedControl selectedSegmentIndex] + 1;
}

-(void) clickStart {
    
    if (selectedStorage == STORAGE_DROPBOX) {
        // its cloud, check if its linked
        NSString *dbAccount = [[NSUserDefaults standardUserDefaults] stringForKey:@"dropboxLinked"];
        if (dbAccount == NULL ) {
            [[DBAccountManager sharedManager] linkFromController:self];
        }else if([dbAccount isEqualToString:@"1"]) {
            DBAccount *account = [[DBAccountManager sharedManager] linkedAccount];
            if (!account) {
                // try again
                [[DBAccountManager sharedManager] linkFromController:self];
            }
        }else if([dbAccount isEqualToString:@"0"]) {
            // try again
            [[DBAccountManager sharedManager] linkFromController:self];
        }
    }
    switch (selectedType) {
        case 1:
            [self startCamera];
            break;
        case 2:
            [self startVideo];
            break;
        default:
            break;
    }
}

-(void) startVideo {
    rdCameraViewController *controller = [[rdCameraViewController alloc] initWithImage:pimage andType:2 andCamera:selectedCamera andStorage:selectedStorage];
    [[RDHelper navigationController] pushViewController:controller animated:YES];
    self.navigationItem.backBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@""
                                      style:UIBarButtonItemStyleBordered
                                     target:nil
                                     action:nil];
}

-(void) startCamera {
//    UIAlertView *alertview = [[UIAlertView alloc] initWithTitle:@"Look here !!!" message:@"Put the phone in vibrate mode, if you don't want the click sound. Turn off the FLASH." delegate:self cancelButtonTitle:@"Understood" otherButtonTitles:nil, nil];
//    [alertview show];
    rdCameraViewController *controller = [[rdCameraViewController alloc] initWithImage:pimage andType:1 andCamera:selectedCamera andStorage:selectedStorage];
    [[RDHelper navigationController] pushViewController:controller animated:YES];
    self.navigationItem.backBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@""
                                     style:UIBarButtonItemStyleBordered
                                    target:nil
                                    action:nil];
    
}

-(void) selectPictureFromLibrary {
    UIImagePickerController *imagePickController=[[UIImagePickerController alloc]init];
    imagePickController.sourceType=UIImagePickerControllerSourceTypePhotoLibrary;
    imagePickController.delegate=self;
    imagePickController.allowsEditing=TRUE;
    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypePhotoLibrary]){
        [self presentViewController:imagePickController animated:YES completion:nil];
    }
}

-(void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    pimage=[info objectForKey:UIImagePickerControllerEditedImage];
    [self dismissViewControllerAnimated:YES completion:nil];
    [previewImage setImage:pimage];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
