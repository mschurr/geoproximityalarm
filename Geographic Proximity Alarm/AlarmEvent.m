//
//  AlarmEvent.m
//  Geographic Proximity Alarm
//
//  Created by Matthew Schurr on 11/6/13.
//  Copyright (c) 2013 Schurr Solutions. All rights reserved.
//

#import "AlarmEvent.h"
#import "Alarm+CD.h"
#import "GeoPoint+CD.h"
#import "CoreDatabase.h"
#import <CoreLocation/CoreLocation.h>
#import <AudioToolbox/AudioToolbox.h>
#import <AVFoundation/AVFoundation.h>

@interface AlarmEvent () <CLLocationManagerDelegate, UIAlertViewDelegate>
@property (strong, nonatomic) CLLocationManager *locationManager;
@property (strong, nonatomic) NSArray *enabledAlarms;
@property (strong, nonatomic) NSMutableArray *activeAlarms;
@property (strong, nonatomic) AVAudioPlayer *audioPlayer;
@property (atomic) BOOL shouldVibrate;
@property (atomic) BOOL shouldPlayAlarmSound;
@end

@implementation AlarmEvent

+ (AlarmEvent *) standardAlarmEvent
{
    static AlarmEvent *alarmEvent = nil;
    
    if(!alarmEvent) {
        alarmEvent = [[AlarmEvent alloc] init];
    }
    
    return alarmEvent;
}

- (id) init
{
    self = [super init];
    
    if(self) {
        if(![CLLocationManager locationServicesEnabled]) {
            NSLog(@"This device is not supported (location services unavailable).");
            [self showAlertWithTitle: @"Notice" andMessage: @"You must enable location services to use this application."];
        }
        
        // iOS >= 7.0 ? Check UIApplication backgroundRefreshStatus
        
        // Allocation
        _locationManager = [[CLLocationManager alloc] init];
        _locationManager.delegate = self;
        _locationManager.desiredAccuracy = kCLLocationAccuracyBestForNavigation;
        _locationManager.activityType = CLActivityTypeOtherNavigation;
        _locationManager.pausesLocationUpdatesAutomatically = YES;
        _locationManager.distanceFilter = kCLDistanceFilterNone;
    }
    
    return self;
}

- (NSMutableArray *) activeAlarms
{
    if(!_activeAlarms)
        _activeAlarms = [[NSMutableArray alloc] init];
    return _activeAlarms;
}

- (void) fireEventForAlarm: (Alarm *) alarmObject
{
    
    NSLog(@"fireEventForAlarm");
    if([alarmObject.alarmIsReminder boolValue] == YES) {
        UIApplication *app = [UIApplication sharedApplication];
        UILocalNotification *notification = [[UILocalNotification alloc] init];
        notification.fireDate = [NSDate date];
        notification.timeZone = [NSTimeZone defaultTimeZone];
        notification.repeatInterval = 0;
        notification.hasAction = YES;
        notification.soundName = UILocalNotificationDefaultSoundName;
        notification.alertBody = [@"Reminder: " stringByAppendingString: alarmObject.alarmName];
        notification.alertAction = @"Continue";
        [app scheduleLocalNotification: notification];
        alarmObject.alarmEnabled = NO;
        [self alarmStateDidUpdate];
        
        // Vibrate
        dispatch_queue_t queue = dispatch_queue_create("vibrateReminder", NULL);
        dispatch_async(queue, ^{
            AudioServicesPlaySystemSound(kSystemSoundID_Vibrate);
            [NSThread sleepForTimeInterval: 0.3];
            AudioServicesPlaySystemSound(kSystemSoundID_Vibrate);
            [NSThread sleepForTimeInterval: 0.3];
        });
        return;
    }
    
    if(alarmObject) {
        // Check: the alarm is not already in the array.
        if([self.activeAlarms containsObject: alarmObject])
            return;
        
        // Add the alarm to the array.
        [self.activeAlarms addObject: alarmObject];
        
        // If an alarm was already sounding, we can just ignore this.
        if([self.activeAlarms count] > 1)
            return;
    }
    
    
    [self startAlarm];
    // ---------
    
    
    UIApplication *app = [UIApplication sharedApplication];
    /*if([[app scheduledLocalNotifications] count] > 0)
        [app cancelAllLocalNotifications]; // cancelLocalNotification:*/
    
    UILocalNotification *alarm = [[UILocalNotification alloc] init];
    if(alarm) {
        alarm.fireDate = [NSDate date];
        //alarm.fireDate = [NSDate dateWithTimeIntervalSinceNow: 5];
        //alarm.timeZone = [NSTimeZone defaultTimeZone];
        //alarm.repeatInterval = 0;
        alarm.hasAction = YES;
        alarm.soundName = UILocalNotificationDefaultSoundName;
        alarm.alertBody = [@"You entered region: " stringByAppendingString: alarmObject.alarmName];
        alarm.hasAction = YES;
        alarm.alertAction = @"Disable Alarm";
        //alarm.applicationIconBadgeNumber = 0;
        // userInfo - NSDictionary
        //[app presentLocalNotificationNow: alarm];
        [app scheduleLocalNotification: alarm];
    }
}

// Called when user toggles an alarm from UI. In future, can listen for NSManagedObject Notifications.
- (void) alarmStateDidUpdate
{
    NSManagedObjectContext *context = [[CoreDatabase databaseNamed: @"geoalarm"] managedObjectContext];
    NSArray *alarms = [Alarm activeAlarmsInManagedObjectContext: context];
    self.enabledAlarms = alarms;
    
    // If there are no active alarms, we can save cycles.
    if(!alarms || [alarms count] == 0) {
        [self stopAlarm];
        [self stopListening];
        [[AVAudioSession sharedInstance] setActive: NO error: nil];
        NSLog(@"No active alarms.. killing background processes.");
        return;
    }
    
    for(Alarm *alarm in self.activeAlarms)
    {
        if(![alarms containsObject: alarm])
        {
            [self.activeAlarms removeObject: alarm];
        }
    }
    
    if([self.activeAlarms count] == 0)
    {
        [self stopAlarm];
    }
    
    // Otherwise, start listening.
    [self startListening];
    [[AVAudioSession sharedInstance] setActive: YES error: nil];
    
    // Display a notification to the user if their volume is too low.
    if([[AVAudioSession sharedInstance] outputVolume] < 0.5) {
        [self showAlertWithTitle: @"Notice" andMessage: @"You must turn up your volume or you will not hear the alarm!"];
    }
}

- (void) showAlertWithTitle: (NSString *) title andMessage: (NSString *) message
{
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle: title message: message delegate: nil cancelButtonTitle: @"Continue" otherButtonTitles: nil];
    [alert show];
}

- (void) showAlertForNotification: (UILocalNotification *) notification
{
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle: @"Geo Proximity Alarm"
                                                        message: notification.alertBody
                                                       delegate: self
                                              cancelButtonTitle: notification.alertAction
                                              otherButtonTitles: nil];
    // Show the alert (if possible).
    [alertView show];
}

- (void) startVibrating
{
    self.shouldVibrate = YES;
    
    dispatch_queue_t queue = dispatch_queue_create("vibrate", NULL);
    dispatch_async(queue, ^{
        while(true) {
            if(self.shouldVibrate == NO)
                break;
            
            AudioServicesPlaySystemSound(kSystemSoundID_Vibrate);
            
            [NSThread sleepForTimeInterval: 1.0];
        }
    });
}

/*-(void)createAndPlaySoundID: (NSString*)name
{
    NSLog(@"sound play");
    SystemSoundID soundID;
    CFURLRef soundPath = CFBundleCopyResourceURL(CFBundleGetMainBundle(), CFSTR("Charge"), CFSTR("caf"), NULL);
    AudioServicesCreateSystemSoundID(soundPath, &soundID);
    AudioServicesPlaySystemSound(soundID);
    AudioServicesDisposeSystemSoundID(soundID);
}

- (void) startSounding
{
    self.shouldPlayAlarmSound = YES;
    
    dispatch_queue_t queue = dispatch_queue_create("alarmsound", NULL);
    dispatch_async(queue, ^{
        while(true) {
            if(self.shouldVibrate == NO)
                break;
            
            [self createAndPlaySoundID:@"Charge.caf"];
            
            [NSThread sleepForTimeInterval: 1.0];
        }
    });
}*/

- (void) startAlarm
{
    [self startVibrating];
    
    
     NSString *soundFilePath = [NSString stringWithFormat:@"%@/Charge.caf", [[NSBundle mainBundle] resourcePath]];
     NSURL *soundFileURL = [[NSURL alloc] initFileURLWithPath: soundFilePath];
     
     NSError *error;
    AVAudioPlayer *player = [[AVAudioPlayer alloc] initWithContentsOfURL: soundFileURL error: &error];
    
    if(error) {
        NSLog(@"Error: %@", error);
    }
    [player setVolume: 1.0];
    [player prepareToPlay];
    player.numberOfLoops = -1;
    [player play];
    
    self.audioPlayer = player;
}


- (void) preserveBackgroundAudio
{
    NSLog(@"preserveAudio");
    NSString *soundFilePath = [NSString stringWithFormat:@"%@/silence.caf", [[NSBundle mainBundle] resourcePath]];
    NSURL *soundFileURL = [[NSURL alloc] initFileURLWithPath: soundFilePath];
    NSError *error;
    AVAudioPlayer *player = [[AVAudioPlayer alloc] initWithContentsOfURL: soundFileURL error: &error];
    [player setVolume: 1.0];
    [player prepareToPlay];
    player.numberOfLoops = -1;
    [player play];
    self.audioPlayer = player;
}

- (void) stopAlarm
{
    self.shouldVibrate = NO;
    self.shouldPlayAlarmSound = NO;
    [self.audioPlayer stop];
    self.audioPlayer = nil;
    if([self.enabledAlarms count] > 0)
        [self preserveBackgroundAudio];
}

- (void) alertView: (UIAlertView *) alertView didDismissWithButtonIndex: (NSInteger) buttonIndex
{
    if(self.activeAlarms == nil || [self.activeAlarms count] == 0)
        return;
    
    // First, stop the alarm.
    [self stopAlarm];
    
    // Second, make any active alarms inactive.
    for(Alarm *alarm in self.activeAlarms) {
        alarm.alarmEnabled = NO;
    }
    
    // Let the class know alarms have changed activity state.
    [self alarmStateDidUpdate];
    
    // Reset the array.
    self.activeAlarms = nil;
    
    NSLog(@"userDidStopAlarm");
}

- (void) locationManagerDidPauseLocationUpdates: (CLLocationManager *) manager
{
    NSLog(@"Location updates are paused.");
}

- (void) locationManagerDidResumeLocationUpdates: (CLLocationManager *) manager
{
    NSLog(@"Location updates have resumed.");
    
}

- (void) locationManager: (CLLocationManager *) manager didFailWithError: (NSError *) error
{
    if(error.code == kCLErrorDenied) {
        [self showAlertWithTitle: @"Notice" andMessage: @"You must enable location services to use this application."];
    }
    if(error.code == kCLErrorLocationUnknown) {
        [self showAlertWithTitle: @"Notice" andMessage: @"Your location can not be determined. This application may not function properly."];
    }
    //
    NSLog(@"The location manager failured to update %@.", error);
}

- (void) locationManager: (CLLocationManager *) manager didUpdateLocations: (NSArray *) locations
{
    NSLog(@"Location update received.");
    
    // Get the last location.
    CLLocation *location = [locations lastObject];
    
    // Let's check for alarm events. For every alarm...
    for(Alarm *alarm in self.enabledAlarms)
    {
        // For every point...
        NSSet *points = alarm.geoPoints;
        for(GeoPoint *point in points)
        {
            // Check to see if the user's location falls within the radius of the point. If it does, start an alarm event.
            CLLocationDegrees latitude = [point.latitude doubleValue];
            CLLocationDegrees longitude = [point.longitude doubleValue];
            CLLocationDistance radius = [point.radius doubleValue];
            CLLocation *pointLocation = [[CLLocation alloc] initWithLatitude: latitude longitude: longitude];
            //NSLog(@"%f %f", [location distanceFromLocation: pointLocation], radius);
            if([location distanceFromLocation: pointLocation] <= radius) {
                NSLog(@"Alarm Should Fire For Alarm With Identifier: %@", alarm.alarmName);
                [self fireEventForAlarm: alarm];
            }
        }
    }
}

- (void) startListening
{
    [self.locationManager startUpdatingLocation];
    //[self.locationManager startMonitoringSignificantLocationChanges];
}

- (void) stopListening
{
    [self.locationManager stopUpdatingLocation];
    //[self.locationManager stopMonitoringSignificantLocationChanges];
}

/*- (IBAction) userDidStopAlarm
{
    
}

- (void) showAlert
{
    
}

- (void) sendNotification
{
    
}

- (void) startVibrating
{
    
}

- (void) stopVibrating
{
    
}

- (void) startSound
{
    
}

- (void) stopSound
{
    
}*/

@end
