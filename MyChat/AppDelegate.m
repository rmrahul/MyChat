//
//  AppDelegate.m
//  MyChat
//
//  Created by Rahul Mane on 07/12/15.
//  Copyright © 2015 Rahul Mane. All rights reserved.
//

#import "AppDelegate.h"
#import "PubNub.h"
#import "DBManager.h"


#define subscriberKey @"sub-c-94e25b9a-9c9b-11e5-b829-02ee2ddab7fe"
#define publishKey @"pub-c-13d46ec4-ca95-4dce-9d0d-0884bf0eaca5"
#define appScerate @"sec-c-MWZhYTU2OGMtMTRmNi00ODUxLWFmNWUtNWRlNjI2NDcxMDlk"

@interface AppDelegate ()

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.

    PNConfiguration *configuration = [PNConfiguration configurationWithPublishKey:publishKey subscribeKey:subscriberKey];
    
    
    [PubNub clientWithConfiguration:configuration];
   
    
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}


#pragma mark - PN Delegates

/**
 * Called on delegate when some client runtime error occurred
 * (mostly because of configuration/connection when connected)
 */
- (void)pubnubClient:(PubNub *)client error:(PNError *)error{
    NSLog(@"Error : %@",error.localizedDescription);
}

/**
 * Called on delegate when client is about to initiate connection
 * to the origin
 */
- (void)pubnubClient:(PubNub *)client willConnectToOrigin:(NSString *)origin{
        NSLog(@"Will connect to : %@",origin);
}

/**
 * Called on delegate when client successfully connected to the
 * origin and performed initial calls (time token requests to make
 * connection keep-alive)
 */
- (void)pubnubClient:(PubNub *)client didConnectToOrigin:(NSString *)origin{
            NSLog(@"Did connect to : %@",origin);
}

////////////////////////////////////////////////////////////////
// Checks if client has receivedmessage, and stores if he has //
////////////////////////////////////////////////////////////////

- (void)pubnubClient:(PubNub *)client didReceiveMessage:(PNMessage *)message {
    NSLog(@"Message  to : %@",[message.message allKeys]);

    NSDateFormatter *formatter=[[NSDateFormatter alloc]init];
    [formatter setDateFormat:@"yyyy/MM/dd hh:mm:ss aa"];
    
    PNDate *date=message.receiveDate;
    

    MessageModel *model=[[MessageModel alloc]init];
    model.msg = [message.message valueForKey:@"message"];
    model.msgFrom = [message.message valueForKey:@"from"];
    model.msgDate = [formatter stringFromDate:date.date];
    model.isSent = NO;
    
    
    if([model.msgFrom isEqualToString:[UIDevice currentDevice].name]){
        return;
    }
    
    [[DBManager getSharedInstance]saveMessage:model];
    
    
    [[NSNotificationCenter defaultCenter]postNotificationName:@"chatMessageRecived" object:nil];
    
}


@end
