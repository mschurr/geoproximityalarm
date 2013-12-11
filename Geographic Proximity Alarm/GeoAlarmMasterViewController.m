//
//  GeoAlarmMasterViewController.m
//  Geographic Proximity Alarm
//
//  Created by Matthew Schurr on 10/16/13.
//  Copyright (c) 2013 Schurr Solutions. All rights reserved.
//

#import "GeoAlarmMasterViewController.h"
#import "GeoAlarmDetailViewController.h"
#import "MapRegionSelectionViewController.h"
#import "UITableViewCellSwitch.h"
#import "Alarm+CD.h"
#import "GeoPoint+CD.h"
#import "DeveloperAnnotation.h"

@interface GeoAlarmMasterViewController () {
    NSMutableArray *_objects;
}
@end

@implementation GeoAlarmMasterViewController

- (void) databaseIsReady: (CoreDatabase *) database
{
    //NSLog(@"received context %@", [database managedObjectContext]);
    self.managedObjectContext = [database managedObjectContext];
}

- (void) viewWillAppear: (BOOL) animated
{
    [super viewWillAppear: animated];
}

- (void) setManagedObjectContext: (NSManagedObjectContext *) managedObjectContext
{
    _managedObjectContext = managedObjectContext;
    [self reload];
}

- (void) reload
{
    
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    if(!self.managedObjectContext) {
        [CoreDatabase databaseNamed: @"geoalarm" notifyTarget: self];
    }
    
	// Do any additional setup after loading the view, typically from a nib.
    self.navigationItem.leftBarButtonItem = self.editButtonItem;

    /*UIBarButtonItem *addButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(insertNewObject:)];
    self.navigationItem.rightBarButtonItem = addButton;*/
    
    // -- TEMPORARY
    if (!_objects) {
        _objects = [[NSMutableArray alloc] init];
    }
    [_objects insertObject:[NSDate date] atIndex:0];
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:0 inSection:0];
    [self.tableView insertRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
    [_objects insertObject:[NSDate date] atIndex:0];
    indexPath = [NSIndexPath indexPathForRow:0 inSection:0];
    [self.tableView insertRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
}

- (void)insertNewObject:(id)sender
{
    //MapRegionSelectionViewController *addViewController = [[MapRegionSelectionViewController alloc]];
    //[self presentViewController: addViewController animated: YES completion: nil];
    /*if (!_objects) {
        _objects = [[NSMutableArray alloc] init];
    }
    [_objects insertObject:[NSDate date] atIndex:0];
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:0 inSection:0];
    [self.tableView insertRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];*/
}

- (IBAction) userDidFinishAddingItem: (UIStoryboardSegue *) segue
{
    MapRegionSelectionViewController *source = segue.sourceViewController;
    
    // Create the new alarm.
    Alarm *alarm = [Alarm createAlarmWithIdentifier: source.titleButton.title inManagedObjectContent: self.managedObjectContext];
    alarm.alarmName = source.titleButton.title;
    alarm.alarmEnabled = [NSNumber numberWithBool: NO];
    
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

#pragma mark - Table View

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return _objects.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell" forIndexPath:indexPath];

    NSDate *object = _objects[indexPath.row];
    cell.textLabel.text = [object description];
    
    UITableViewCellSwitch *toggleSwitch = [[UITableViewCellSwitch alloc] init];
    toggleSwitch.indexPath = indexPath;
    [toggleSwitch setOn: NO animated: NO];
    [toggleSwitch addTarget: self action: @selector(userDidToggleSwitchForItem:) forControlEvents: UIControlEventValueChanged];
    
    cell.accessoryView = toggleSwitch;
    
    return cell;
}

- (IBAction) userDidToggleSwitchForItem: (UITableViewCellSwitch *) sender
{
    
    NSLog(@"GeoAlarmMasterViewController->userDidToggleSwitchForItem atIndexPath(%d.%d)", sender.indexPath.section, sender.indexPath.row);
}

- (CGFloat) tableView: (UITableView *) tableView heightForRowAtIndexPath: (NSIndexPath *) indexPath
{
    return 100.0;
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return YES;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        [_objects removeObjectAtIndex:indexPath.row];
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view.
    }
}

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
{
}
*/

// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the item to be re-orderable.
    return NO;
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([[segue identifier] isEqualToString:@"showDetail"]) {
        NSIndexPath *indexPath = [self.tableView indexPathForSelectedRow];
        NSDate *object = _objects[indexPath.row];
        [[segue destinationViewController] setDetailItem:object];
    }
}

@end
