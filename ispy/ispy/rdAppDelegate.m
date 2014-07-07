//
//  rdAppDelegate.m
//  ispy
//
//  Created by Darshan Katrumane on 5/26/14.
//  Copyright (c) 2014 Darshan Katrumane. All rights reserved.
//

#import "rdAppDelegate.h"
#import "rdViewController.h"
#import <Dropbox/Dropbox.h>
#import "RDHelper.h"
#import "AFNetworking.h"

@implementation rdAppDelegate
@synthesize navcontroller;

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    DBAccountManager *accountManager = [[DBAccountManager alloc] initWithAppKey:DROPBOX_KEY secret:DROPBOX_SECRET];
    [DBAccountManager setSharedManager:accountManager];
    
    NSDictionary *userDefaultsDefaults = [NSDictionary dictionaryWithObjectsAndKeys:
                                          [NSNumber numberWithBool:NO], @"screenLocked",
                                          nil];
    [[NSUserDefaults standardUserDefaults] registerDefaults:userDefaultsDefaults];
    
    // Override point for customization after application launch.
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    self.window.backgroundColor = [UIColor whiteColor];
    [self.window makeKeyAndVisible];
    
    rdViewController *maincontroller = [[rdViewController alloc] init];
    [maincontroller.view setFrame:CGRectMake(0, 0, self.window.frame.size.width, self.window.frame.size.height)];
    navcontroller = [[AHKNavigationController alloc] initWithRootViewController:maincontroller];
    [[[navcontroller navigationBar] topItem] setTitle:@"SafeCam"];
    NSShadow *shadow = [[NSShadow alloc] init];
    shadow.shadowColor = [UIColor colorWithRed:0.0 green:0.0 blue:0.0 alpha:0.8];
    shadow.shadowOffset = CGSizeMake(0, 1);
    [[UINavigationBar appearance] setTitleTextAttributes: [NSDictionary dictionaryWithObjectsAndKeys:
                                                           [UIColor colorWithRed:245.0/255.0 green:245.0/255.0 blue:245.0/255.0 alpha:1.0], NSForegroundColorAttributeName,
                                                           shadow, NSShadowAttributeName,
                                                           [UIFont fontWithName:@"AvenirNext-DemiBold" size:23.0], NSFontAttributeName, nil]];
    [[maincontroller navigationController] setNavigationBarHidden:YES];
    [self.window setRootViewController:navcontroller];
    return YES;
    
}

-(void) checkForUpdates {
    NSDate *prevDate = [[NSUserDefaults standardUserDefaults] objectForKey:@"versionCheckedOnDate"];
    if (!prevDate) {
        // This is the 1st run of the app
        prevDate = [NSDate date];
        [[NSUserDefaults standardUserDefaults] setObject:prevDate forKey:@"versionCheckedOnDate"];
    }else{
        prevDate = [[NSUserDefaults standardUserDefaults] objectForKey:@"versionCheckedOnDate"];
    }
    NSDate *currentDate = [NSDate date];
    NSCalendar *calendar = [NSCalendar currentCalendar];
    NSDateComponents *difference = [calendar components:NSDayCalendarUnit fromDate:prevDate toDate:currentDate options:0];
    NSInteger diffDays = [difference day];
    if(diffDays > 15) {
        // lets do a version check
        NSString *versionNumber = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleVersion"];
        NSURL *updateUrl = [NSURL URLWithString:@"http://kmdarshan.com/safecam.json"];
        NSMutableURLRequest *urlRequest = [NSMutableURLRequest requestWithURL:updateUrl
                                                    cachePolicy:NSURLCacheStorageNotAllowed
                                                timeoutInterval:20.0];
        [urlRequest setCachePolicy:NSURLRequestReloadIgnoringCacheData];
        AFHTTPRequestOperation *operation = [[AFHTTPRequestOperation alloc] initWithRequest:urlRequest];
        operation.responseSerializer = [AFJSONResponseSerializer serializer];
        [operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
            NSDictionary *json = (NSDictionary *)responseObject;
            if([json valueForKey:@"update"]){
                NSString *update = (NSString*)[json valueForKey:@"update"];
                if ([update isEqualToString:@"1"]) {
                    // we need to ask the user to update
                    if([json valueForKey:@"newVersion"]){
                        if (![[json valueForKey:@"newVersion"] isEqualToString:versionNumber]) {
                            UIAlertView *view = [[UIAlertView alloc] initWithTitle:@"Update" message:[json valueForKey:@"updateMessage"] delegate:self cancelButtonTitle:nil otherButtonTitles:nil, nil];
                            [view setTag:999999];
                            [view show];
                        }
                    }
                }
            }
        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            NSLog(@"failure to download the file during version check");
        }];
        [operation start];
    }
}

- (BOOL)application:(UIApplication *)app openURL:(NSURL *)url sourceApplication:(NSString *)source annotation:(id)annotation {
    DBAccount *account = [[DBAccountManager sharedManager] handleOpenURL:url];
    if (account) {
        // save to nsuserdefaults
        NSString *dbAccount = @"1";
        [[NSUserDefaults standardUserDefaults] setObject:dbAccount forKey:@"dropboxLinked"];
        [[NSUserDefaults standardUserDefaults] synchronize];
        return YES;
    }
    NSString *dbAccount = @"0";
    [[NSUserDefaults standardUserDefaults] setObject:dbAccount forKey:@"dropboxLinked"];
    [[NSUserDefaults standardUserDefaults] synchronize];
    return NO;
}

- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    
    [self checkForUpdates];
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

@end
