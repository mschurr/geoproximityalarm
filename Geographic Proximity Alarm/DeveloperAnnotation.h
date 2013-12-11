//
//  DeveloperAnnotation.h
//  Geographic Proximity Alarm
//
//  Created by Matthew Schurr on 11/4/13.
//  Copyright (c) 2013 Schurr Solutions. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MapKit/MapKit.h>
	
@interface DeveloperAnnotation : NSObject <MKAnnotation>
@property (nonatomic) CLLocationCoordinate2D coordinate;
@property (nonatomic, copy) NSString *title;
@property (nonatomic, copy) NSString *subtitle;
@property (nonatomic) CLLocationDistance radius;
@property (strong, nonatomic) id <MKOverlay> circleOverlay;
@end
