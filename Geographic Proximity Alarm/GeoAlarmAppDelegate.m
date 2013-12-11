//
//  GeoAlarmAppDelegate.m
//  Geographic Proximity Alarm
//
//  Created by Matthew Schurr on 10/16/13.
//  Copyright (c) 2013 Schurr Solutions. All rights reserved.
//

#import "GeoAlarmAppDelegate.h"
#import "AlarmEvent.h"
#import "CoreDatabase.h"
#import <AVFoundation/AVFoundation.h>

@interface GeoAlarmAppDelegate()
@end

@implementation GeoAlarmAppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    NSError *error;
    [[AVAudioSession sharedInstance] setCategory: AVAudioSessionCategoryPlayback
                                     withOptions: AVAudioSessionCategoryOptionMixWithOthers|AVAudioSessionCategoryOptionDefaultToSpeaker error:&error];
    [[AVAudioSession sharedInstance] setMode: AVAudioSessionModeDefault error: &error];
    [[AVAudioSession sharedInstance] overrideOutputAudioPort: AVAudioSessionPortOverrideSpeaker error: &error];
    [[AVAudioSession sharedInstance] setActive: YES error: &error];
    
    // Override point for customization after application launch.
    //[[AlarmEvent standardAlarmEvent] performSelector: @selector(fireEventForAlarm:) withObject: nil afterDelay: 5.0];
    
    //UIApplicationLaunchOptionsLocationKey - configure loc manager, use .location, and recall start... to continue receiving events.
    //UIApplicationLaunchOptionsLocalNotificationKey
    
    NSLog(@"app load");
    return YES;
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
    [[CoreDatabase databaseNamed: @"geoalarm"] save];
    NSLog(@"app background");
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    NSLog(@"app foreground");
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    [[CoreDatabase databaseNamed: @"geoalarm"] save];
    NSLog(@"app terminate");
}

/**
 * This method is called when receiving a local notifiction when the application is foremost and visible
 *  OR when the user enters the application by tapping a notification.
 */
- (void) application: (UIApplication *) application didReceiveLocalNotification: (UILocalNotification *) notification
{
    NSLog(@"local notif received");
    
    // We need to display it.
    [[AlarmEvent standardAlarmEvent] showAlertForNotification: notification];
}


@end
