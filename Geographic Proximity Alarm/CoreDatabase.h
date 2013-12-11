//
//  CoreDatabase.h
//  Shutterbug
//
//  Created by Matthew Schurr on 10/19/13.
//  Copyright (c) 2013 Schurr Solutions. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@interface CoreDatabase : NSObject

+ (CoreDatabase *) databaseNamed: (NSString *) name;
+ (void) databaseNamed: (NSString *) name notifyTarget: (id) target; // calls databaseIsReady:(CoreDatabase*) on the target

- (id) initWithName: (NSString *) name;
- (NSManagedObjectContext *) managedObjectContext;
- (UIManagedDocument *) managedDocument;
- (void) close;
- (void) save;

@end


/*
 
 
 ----
 NSManagedObject *photo =
 [NSEntityDescription insertNewObjectForEntityForName:@“Photo”
 inManagedObjectContext:context];
 
 - (id)valueForKey:(NSString *)key;
 - (void)setValue:(id)value forKey:(NSString *)key;
 You can also use valueForKeyPath:/setValue:forKeyPath: and it will follow your relationships!
 
 Values will be NSNumber, NSDate, NSSet, NSOrderedSet, NSData
 
 --------
 + (Photo *)photoWithFlickrData:(NSDictionary *)flickrData
 inManagedObjectContext:(NSManagedObjectContext *)context
 {
 Photo *photo = ...; // see if a Photo for that Flickr data is already in the database if (!photo) {
 photo = [NSEntityDescription insertNewObjectForEntityForName:@“Photo”
 inManagedObjectContext:context];
 // initialize the photo from the Flickr data
 // perhaps even create other database objects (like the Photographer)
 }
 return photo;
 }
 - (void)prepareForDeletion;
 
 ------
 [aDocument.managedObjectContext deleteObject:photo];
 
 ------
 
 NSFetchRequest *req = [NSFetchRequest fetchRequestWithEntityName: @""]
 req.fetchBatchSize = 20;
 req.fetchLimit = 1000;
 req.sortDescriptors = @[NSSortDescriptor1, ...]
 req.predicate = NSPredicate
 
 [NSSortDescriptor sortDescriptorWithKey:@“title”
 ascending:YES
 selector:@selector(localizedCaseInsensitiveCompare:)];
 # also compare:
 
 [NSPredicate predicateWithFormat:@“thumbnailURL contains %@”, serverName];
 @“uniqueId = %@”, [flickrInfo objectForKey:@“id”] // unique a photo in the database @“name contains[c] %@”, (NSString *) // matches name case insensitively
 @“viewed > %@”, (NSDate *) // viewed is a Date attribute in the data mapping
 @“whoTook.name = %@”, (NSString *) // Photo search (by photographer’s name)
 @“any photos.title contains %@”, (NSString *) // Photographer search (not a Photo search) Many more options. Look at the class documentation for NSPredicate.
 
 NSDate *yesterday = [NSDate dateWithTimeIntervalSinceNow:-24*60*60];
 request.predicate = [NSPredicate predicateWithFormat:@“any photos.uploadDate > %@”, yesterday];
 
 NSCompoundPredicate @“(name = %@) OR (title = %@)”
 NSArray *array = [NSArray arrayWithObjects:predicate1, predicate2, nil];
 NSPredicate *predicate = [NSCompoundPredicate andPredicateWithSubpredicates:array];
 
 NSManagedObjectContext *context = aDocument.managedObjectContext;
 NSError *error;
 NSArray *photographers = [context executeFetchRequest:request error:&error
 // returns an NSArray of NSManageObjects (or their subclasses)
 
 // to be thread safe
 [contextperformBlock:^{ //orperformBlockAndWait:
 // do stuff with context
 }];
 
 
 NSManagedObject *managedObject =
 [self.fetchedResultsController objectAtIndexPath:indexPath];
 NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@“Photo”]; NSSortDescriptor *sortDescriptor = [NSSortDescriptor sortDescriptorWithKey:@“title” ...]; request.sortDescriptors = @[sortDescriptor];
 request.predicate = [NSPredicate predicateWithFormat:@“whoTook.name = %@”, photogName];
 NSFetchedResultsController *frc = [[NSFetchedResultsController alloc]
 initWithFetchRequest:(NSFetchRequest *)request
 managedObjectContext:(NSManagedObjectContext *)context
 sectionNameKeyPath:(NSString *)keyThatSaysWhichSectionEachManagedObjectIsIn cacheName:@“MyPhotoCache”];
 */
