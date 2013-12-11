//
//  GeoAlarmMasterCDTVC.m
//  Geographic Proximity Alarm
//
//  Created by Matthew Schurr on 11/9/13.
//  Copyright (c) 2013 Schurr Solutions. All rights reserved.
//

#import "GeoAlarmMasterCDTVC.h"
#import "CoreDatabase.h"
#import "Alarm+CD.h"
#import "UITableViewCellSwitch.h"
#import "MapRegionSelectionViewController.h"
#import "DeveloperAnnotation.h"
#import "GeoPoint+CD.h"
#import "AlarmEvent.h"

@interface GeoAlarmMasterCDTVC ()
@property (strong, nonatomic) NSManagedObjectContext *managedObjectContext;
@property (strong, nonatomic) UITextView *instructionsView;

@end

@implementation GeoAlarmMasterCDTVC

- (void) viewWillAppear: (BOOL) animated
{
    [super viewWillAppear: animated];
}

- (void) viewDidLoad
{
    [super viewDidLoad];
    [CoreDatabase databaseNamed: @"geoalarm" notifyTarget: self];
    self.navigationItem.leftBarButtonItem = self.editButtonItem;
    //self.tableView.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"tableviewbackground.png"]];
    //self.tableView.backgroundView = nil;
    self.tableView.backgroundColor = [UIColor whiteColor];
    
    self.instructionsView = [[UITextView alloc] initWithFrame: self.tableView.frame];
    self.instructionsView.text = self.defaultText;
    self.instructionsView.userInteractionEnabled = NO;
    [self.view addSubview: self.instructionsView];
}

- (void) databaseIsReady: (CoreDatabase *) database
{
    self.managedObjectContext = [database managedObjectContext];
    [[AlarmEvent standardAlarmEvent] alarmStateDidUpdate];
}

- (void) setManagedObjectContext: (NSManagedObjectContext *) managedObjectContext
{
    _managedObjectContext = managedObjectContext;
    
    if(!managedObjectContext) {
        self.fetchedResultsController = nil;
        return;
    }
    
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName: @"Alarm"];
    request.sortDescriptors = @[
                                [NSSortDescriptor sortDescriptorWithKey: @"alarmName"
                                                              ascending: YES
                                                               selector: @selector(compare:)]
                                ];
    request.fetchLimit = 100;
    request.predicate = self.predicate;
    request.fetchBatchSize = 20;
    self.fetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest: request
                                                                        managedObjectContext: managedObjectContext sectionNameKeyPath: nil
                                                                                   cacheName: nil];
}

- (CGFloat) tableView: (UITableView *) tableView heightForRowAtIndexPath: (NSIndexPath *) indexPath
{
    return 92.0;
}

- (UITableViewCell *) tableView: (UITableView *) tableView cellForRowAtIndexPath: (NSIndexPath *) indexPath
{
    [self.instructionsView removeFromSuperview];
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier: @"Cell" forIndexPath: indexPath];
    Alarm *alarm = [self.fetchedResultsController objectAtIndexPath: indexPath];
    
    cell.textLabel.text = alarm.alarmName;
    /*cell.backgroundColor = nil;
    UIImage *image = [UIImage imageNamed: @"tableViewCell.png"];
    UIImageView *imageView = [[UIImageView alloc] initWithImage: image];
    imageView.image = image;
    imageView.opaque = YES;
    cell.backgroundView = imageView;//*/
    
    UITableViewCellSwitch *toggleSwitch = [[UITableViewCellSwitch alloc] init];
    //toggleSwitch.indexPath = indexPath;
    toggleSwitch.alarm = alarm;
    [toggleSwitch setOn: [alarm.alarmEnabled boolValue] animated: NO];
    [toggleSwitch addTarget: self action: @selector(userDidToggleSwitchForItem:) forControlEvents: UIControlEventValueChanged];
    cell.accessoryView = toggleSwitch;
    return cell;
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    return YES;
}

- (IBAction) userDidFinishEditingItem: (UIStoryboardSegue *) segue
{
    MapRegionSelectionViewController *source = segue.sourceViewController;
    Alarm *alarm = source.alarm;
    
    // Update the alarm's title.
    alarm.alarmName = source.titleButton.title;
    
    // Update the alarm's geographic points.
    [alarm removeGeoPoints: alarm.geoPoints];
    
    for(id <MKAnnotation> annotation in source.mapView.annotations) {
        if([annotation isKindOfClass: [DeveloperAnnotation class]]) {
            DeveloperAnnotation *devAnnotation = (DeveloperAnnotation *) annotation;
            GeoPoint *geopoint = [GeoPoint createGeoPointForAlarm: alarm];
            geopoint.longitude = [NSNumber numberWithDouble: devAnnotation.coordinate.longitude];
            geopoint.latitude = [NSNumber numberWithDouble: devAnnotation.coordinate.latitude];
            geopoint.radius = [NSNumber numberWithDouble: devAnnotation.radius];
        }
    }
}

- (IBAction) userDidFinishAddingItem: (UIStoryboardSegue *) segue
{
    MapRegionSelectionViewController *source = segue.sourceViewController;
    
    // Create the new alarm.
    Alarm *alarm = [Alarm createAlarmWithIdentifier: source.titleButton.title inManagedObjectContent: self.managedObjectContext];
    alarm.alarmName = source.titleButton.title;
    alarm.alarmEnabled = [NSNumber numberWithBool: NO];
    NSLog(@"added alarm with mode %@", [NSNumber numberWithBool: source.isReminder]);
    alarm.alarmIsReminder = [NSNumber numberWithBool: source.isReminder];
    alarm.alarmText = @"";
    
    // Attach the geographic points.
    for(id <MKAnnotation> annotation in source.mapView.annotations) {
        if([annotation isKindOfClass: [DeveloperAnnotation class]]) {
            DeveloperAnnotation *devAnnotation = (DeveloperAnnotation *) annotation;
            GeoPoint *geopoint = [GeoPoint createGeoPointForAlarm: alarm];
            geopoint.longitude = [NSNumber numberWithDouble: devAnnotation.coordinate.longitude];
            geopoint.latitude = [NSNumber numberWithDouble: devAnnotation.coordinate.latitude];
            geopoint.radius = [NSNumber numberWithDouble: devAnnotation.radius];
        }
    }
    
    //NSLog(@"GeoAlarmMasterViewController->userDidFinishAddingItem");
}

- (IBAction) userDidCancelAddingItem: (UIStoryboardSegue *) segue
{
    // We don't need to do anything here.
}

- (IBAction) userDidToggleSwitchForItem: (UITableViewCellSwitch *) sender
{
    //NSIndexPath *indexPath = sender.indexPath;
    //Alarm *alarm = [self.fetchedResultsController objectAtIndexPath: indexPath];
    Alarm *alarm = sender.alarm;
    alarm.alarmEnabled = [NSNumber numberWithBool: sender.on];
    [[AlarmEvent standardAlarmEvent] alarmStateDidUpdate];
    //NSLog(@"GeoAlarmMasterViewController->userDidToggleSwitchForItem atIndexPath(%d.%d) to: %d", sender.indexPath.section, sender.indexPath.row, sender.on);
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(editingStyle == UITableViewCellEditingStyleDelete) {
        Alarm *alarm = [self.fetchedResultsController objectAtIndexPath: indexPath];
        if([alarm.alarmEnabled boolValue]) {
            [self showAlertWithTitle: @"Error" andMessage: @"You must disable this alarm in order to delete it."];
            return;
        }
        if([self tableView: tableView numberOfRowsInSection: indexPath.section] == 1) {
            [self.view addSubview: self.instructionsView];
        }
        [self.managedObjectContext deleteObject: alarm];
    }
}

- (void) showAlertWithTitle: (NSString *) title andMessage: (NSString *) message
{
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle: title message: message delegate: self cancelButtonTitle: @"Continue" otherButtonTitles: nil];
    [alert show];
}

- (BOOL) shouldPerformSegueWithIdentifier:(NSString *)identifier sender:(id)sender
{
    NSIndexPath *indexPath = [self.tableView indexPathForSelectedRow];
    Alarm *alarm = [self.fetchedResultsController objectAtIndexPath: indexPath];
    BOOL enabled = [alarm.alarmEnabled boolValue];
    if(enabled){
        [self showAlertWithTitle: @"Error" andMessage: @"You must disable this alarm in order to edit it."];
        return NO;
    }
    return YES;
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if([segue.identifier isEqualToString: @"editAlarm:"]) {
        NSIndexPath *indexPath = [self.tableView indexPathForSelectedRow];
        Alarm *alarm = [self.fetchedResultsController objectAtIndexPath: indexPath];
        MapRegionSelectionViewController *dest = (MapRegionSelectionViewController *) segue.destinationViewController;
        [dest editAlarm: alarm];
    }
    if([segue.identifier isEqualToString: @"editReminder:"]) {
        NSIndexPath *indexPath = [self.tableView indexPathForSelectedRow];
        Alarm *alarm = [self.fetchedResultsController objectAtIndexPath: indexPath];
        MapRegionSelectionViewController *dest = (MapRegionSelectionViewController *) segue.destinationViewController;
        [dest editReminder: alarm];
    }
    if([segue.identifier isEqualToString: @"addAlarm"]) {
        MapRegionSelectionViewController *dest = (MapRegionSelectionViewController *) segue.destinationViewController;
        [dest addAlarm];
    }
    if([segue.identifier isEqualToString: @"addReminder"]) {
        MapRegionSelectionViewController *dest = (MapRegionSelectionViewController *) segue.destinationViewController;
        [dest addReminder];
    }
}

@end
