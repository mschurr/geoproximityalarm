//
//  MapRegionSelectionViewController.m
//  Geographic Proximity Alarm
//
//  Created by Matthew Schurr on 11/4/13.
//  Copyright (c) 2013 Schurr Solutions. All rights reserved.
//

#import "MapRegionSelectionViewController.h"
#import "NetworkActivityManager.h"
#import "DeveloperAnnotation.h"
#import "Alarm+CD.h"
#import "GeoPoint+CD.h"
#import "CoreDatabase.h"

@interface MapRegionSelectionViewController () <UIAlertViewDelegate>

@property (nonatomic) BOOL centered;
@end

@implementation MapRegionSelectionViewController

- (NSUInteger) userNotationsCount
{
    NSUInteger count = 0;
    
    for(id <MKAnnotation> ann in self.mapView.annotations)
    {
        if([ann isKindOfClass: [DeveloperAnnotation class]])
        {
            count += 1;
        }
    }
    
    return count;
}

- (void) addAlarm
{
    NSLog(@"entered in alarm mode");
    self.isReminder = NO;
}

- (void) addReminder
{
    NSLog(@"entered in reminder mode");
    self.isReminder = YES;
}

- (void) editAlarm: (Alarm *) alarm
{
    _alarm = alarm;
    if(self.view.window)
        [self updateEditingData];
}

- (void) editReminder:(Alarm *)alarm
{
    // TODO
    NSLog(@"reminder edit todo");
    [self editAlarm: alarm];
}

- (void) alertView: (UIAlertView *) alertView clickedButtonAtIndex: (NSInteger) buttonIndex
{
    if(buttonIndex == 1) {
        NSString *title = [[alertView textFieldAtIndex: 0] text];
        if([title length] > 0)
            self.titleButton.title = title;
    }
}

- (void) updateEditingData
{
    if(!self.alarm)
        return;
    
    // Copy title.
    self.titleButton.title = self.alarm.alarmName;
    
    // Copy regions.
    for(GeoPoint *point in self.alarm.geoPoints) {
        DeveloperAnnotation *ann = [[DeveloperAnnotation alloc] init];
        CLLocationCoordinate2D coordinate = CLLocationCoordinate2DMake([point.latitude doubleValue], [point.longitude doubleValue]);
        ann.title = @"Alarm Region";
        ann.subtitle = nil;
        ann.coordinate = coordinate;
        ann.radius = [point.radius doubleValue];
        [self.mapView addAnnotation: ann];
        
        MKCircle *radiusOverlay = [MKCircle circleWithCenterCoordinate: coordinate radius: [point.radius doubleValue]];
        ann.circleOverlay = radiusOverlay;
        [self.mapView addOverlay: radiusOverlay];
    }
    
    self.centered = NO;
    [self centerMapOnFocus];
}

- (IBAction) userDidTouchTitleEdit: (UIBarButtonItem *) sender
{
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Alarm Title"
                                                    message:@"Enter a new title for this alarm."
                                                   delegate:self
                                          cancelButtonTitle:@"Cancel"
                                          otherButtonTitles:@"Apply", nil];
    alert.alertViewStyle = UIAlertViewStylePlainTextInput;
    //[alert textFieldAtIndex: 0].text = self.titleButton.title;
    [alert show];
}

- (IBAction) userDidTouchSaveForEditing: (UIBarButtonItem *) sender
{
    // Return to presenter.
    [self performSegueWithIdentifier: @"userDidFinishEditingItem:" sender: self];
}

- (IBAction) userDidTouchSave: (UIBarButtonItem *) sender
{
    // Perform some validation.
    
    // Title not in use
    NSManagedObjectContext *context = [[CoreDatabase databaseNamed: @"geoalarm"] managedObjectContext];
    if([Alarm alarmExistsWithIdentifier: self.titleButton.title
                 inManagedObjectContext: context])
    {
        if(self.alarm == nil || (self.alarm != nil && ![self.alarm.alarmName isEqualToString: self.titleButton.title])) {
            [self showValidationFailedAlertWithMessage: @"That title is already in use."];
            return;
        }
        
    }
    
    // Title Length <= 15
    if([self.titleButton.title length] > 15)
    {
        [self showValidationFailedAlertWithMessage: @"Titles must be no longer than 15 characters."];
        return;
    }
    
    // Title Length > 3
    if([self.titleButton.title length] < 3)
    {
        [self showValidationFailedAlertWithMessage: @"Titles must be at least 3 characters."];
        return;
    }
    
    // Pin Count <= 10
    if([self userNotationsCount] > 10) {
        [self showValidationFailedAlertWithMessage: @"You can define at most 10 regions."];
        return;
    }
    
    // Pin Count > 0
    if([self userNotationsCount] == 0) {
        [self showValidationFailedAlertWithMessage: @"You must define at least one region."];
        return;
    }
    
    if(self.alarm) {
        [self userDidTouchSaveForEditing: sender];
        return;
    }
    
    // Return iff validation passes.
    [self performSegueWithIdentifier: @"userDidFinishAddingItem:" sender: self];
}

- (void) showValidationFailedAlertWithMessage: (NSString *) message
{
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle: @"Error" message: message delegate: self cancelButtonTitle: @"Continue" otherButtonTitles: nil];
    [alert show];
}

- (void) showAlertWithTitle: (NSString *) title andMessage: (NSString *) message
{
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle: title message: message delegate: nil cancelButtonTitle: @"Continue" otherButtonTitles: nil];
    [alert show];
}

- (IBAction)userDidTouchCancel: (UIBarButtonItem *) sender
{
}

- (void) viewDidLoad
{
    [super viewDidLoad];
    self.mapView.delegate = self;
    self.mapView.mapType = MKMapTypeHybrid;
    self.mapView.showsUserLocation = YES;
    self.mapView.zoomEnabled = YES;
    self.mapView.scrollEnabled = YES;
    self.centered = NO;
    [self updateEditingData];
    
    if(self.alarm == nil)
        [self showAlertWithTitle: @"Instructions" andMessage: @"To place geographic regions, press and hold at a location on the map. The size of the region is determined by your zoom level. Tap existing regions to delete them."];
}

- (void) viewWillAppear: (BOOL) animated
{
    [super viewWillAppear: animated];
    [self.navigationController setNavigationBarHidden:YES animated:animated];
    //[self centerMapOnFocus];
}

- (void) viewWillDisappear: (BOOL) animated
{
    [super viewWillDisappear: animated];
    [self.navigationController setNavigationBarHidden:NO animated:animated];
}

- (void) centerMapOnFocus
{
    if(self.centered == NO && [self.mapView.annotations count] >= 1)
    {
        // Try to make all annotations visible.
        CGRect boundingRect;
        BOOL started = NO;
        
        for(id <MKAnnotation> annotation in self.mapView.annotations) {
            if([annotation isKindOfClass: [MKUserLocation class]])
                continue;
            
            CGRect annotationRect = CGRectMake(annotation.coordinate.latitude, annotation.coordinate.longitude, 0, 0);
            if(!started) {
                started = YES;
                boundingRect = annotationRect;
            }
            else {
                boundingRect = CGRectUnion(boundingRect, annotationRect);
            }
        }
        
        if (started) {
            boundingRect = CGRectInset(boundingRect, -0.2, -0.2);
            if ((boundingRect.size.width < 20) && (boundingRect.size.height < 20)) {
                MKCoordinateRegion region;
                region.center.latitude = boundingRect.origin.x + boundingRect.size.width / 2;
                region.center.longitude = boundingRect.origin.y + boundingRect.size.height / 2;
                region.span.latitudeDelta = boundingRect.size.width;
                region.span.longitudeDelta = boundingRect.size.height;
                [self.mapView setRegion:region animated:YES];
                self.centered = YES;
                //NSLog(@"set region %f %f %f %f", region.span.latitudeDelta, region.span.longitudeDelta, region.center.longitude, region.center.latitude);
            }
        }
    }
}

- (void) mapView: (MKMapView *) mapView didUpdateUserLocation: (MKUserLocation *) userLocation
{
    if((self.centered == NO && [self.mapView.annotations count] <= 1)) {
        MKCoordinateRegion region;
        double miles = 2.0;
        double scalingFactor = ABS( (cos(2 * M_PI * self.mapView.userLocation.coordinate.latitude / 360.0) ));
        
        region.center = self.mapView.userLocation.coordinate;
        region.span.latitudeDelta = (miles / 69.0);
        region.span.longitudeDelta = miles/(scalingFactor * 69.0);
        
        [self.mapView setRegion: region animated: YES];
        //NSLog(@"set region %f %f %f %f", region.span.latitudeDelta, region.span.longitudeDelta, region.center.longitude, region.center.latitude);
        self.centered = YES;
    }
}

- (void) mapViewWillStartLoadingMap: (MKMapView *) mapView
{
    [[NetworkActivityManager standardNetworkActivityManager] registerNetworkActivity];
}

- (void) mapViewDidFinishLoadingMap: (MKMapView *) mapView
{
    [[NetworkActivityManager standardNetworkActivityManager] unregisterNetworkActivity];
}

- (void) mapViewDidFailLoadingMap: (MKMapView *) mapView withError: (NSError *)error
{
    [[NetworkActivityManager standardNetworkActivityManager] unregisterNetworkActivity];
}
- (IBAction) userDidLongPressMap: (UILongPressGestureRecognizer *) sender
{
    /*CGPoint loc = [sender locationInView:sender.view];
    UIView* subview = [sender.view hitTest:loc withEvent:nil];
    
    if([subview isKindOfClass: [MKAnnotationView class]])
        return;*/
    
    if(sender.state != UIGestureRecognizerStateEnded)
        return;
    	    
    CGPoint touchPoint = [sender locationInView: self.mapView];
    CLLocationCoordinate2D location = [self.mapView convertPoint: touchPoint toCoordinateFromView: self.mapView];
    CLLocationDistance radius = self.mapView.region.span.latitudeDelta * 11100; // 1 degree latitude = ~111km
    
    DeveloperAnnotation *ann = [[DeveloperAnnotation alloc] init];
    ann.title = @"Alarm Region";
    ann.subtitle = nil;
    ann.coordinate = location;
    ann.radius = radius;
    [self.mapView addAnnotation: ann];
    
    MKCircle *radiusOverlay = [MKCircle circleWithCenterCoordinate: location radius: radius];
    ann.circleOverlay = radiusOverlay;
    [self.mapView addOverlay: radiusOverlay];
}

- (MKOverlayView *) mapView: (MKMapView *) map viewForOverlay: (id <MKOverlay>) overlay
{
    MKCircleView *circleView = [[MKCircleView alloc] initWithOverlay:overlay];
    circleView.strokeColor = [UIColor redColor];
    circleView.fillColor = [[UIColor redColor] colorWithAlphaComponent:0.4];
    circleView.lineWidth = 1.0;
    return circleView;
}

- (void) mapView:(MKMapView *)mapView didAddAnnotationViews:(NSArray *)views
{
    for (MKAnnotationView *view in views) {
        if([view.annotation isKindOfClass: [MKUserLocation class]]) {
            view.canShowCallout = NO;
            view.enabled = NO;
        }
    }
}

- (MKAnnotationView *) mapView: (MKMapView *) mapView viewForAnnotation: (id <MKAnnotation>) annotation
{
    // Special Case: MKUserLocation
    if([annotation isKindOfClass: [MKUserLocation class]]) {
        return nil; // Returning nil tells the mapView to use MKUserLocationView.
    }
    
    // Special Case: Point
    MKAnnotationView *view = [mapView dequeueReusableAnnotationViewWithIdentifier:@"Point"];
    if(!view) {
        
        view = [[MKPinAnnotationView alloc] initWithAnnotation: annotation reuseIdentifier: @"Point"];
    }
    
    view.canShowCallout = YES;
    view.annotation = annotation;
    //UIButton *button = [UIButton buttonWithType: UIButtonTypeDetailDisclosure];
    
    // --
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    [button setTitle:@"" forState:UIControlStateNormal];
    button.titleLabel.font = [UIFont systemFontOfSize: 14.0];
    [button setTitleColor: [UIColor redColor] forState: UIControlStateNormal];
    UIImage *image = [UIImage imageNamed: @"iconDelete-normal.png"];
    [button setImage: image forState: UIControlStateNormal];
    [button sizeToFit];
    // --
    
    view.rightCalloutAccessoryView = button;
    return view;
}

- (void) mapView: (MKMapView *) mapView annotationView: (MKAnnotationView *) view calloutAccessoryControlTapped: (UIControl *) control
{
    // Remove the overlay first (before view.annotation gets nilled).
    if([view.annotation isKindOfClass: [DeveloperAnnotation class]]) {
        DeveloperAnnotation *ann = (DeveloperAnnotation *)view.annotation;
        [mapView removeOverlay: ann.circleOverlay];
    }
    
    // Remove the annotation.
    [mapView removeAnnotation: view.annotation];
}

- (void) dealloc
{
    self.mapView.delegate = nil;
}

@end
