//
//  CoreDatabase.m
//  Shutterbug
//
//  Created by Matthew Schurr on 10/19/13.
//  Copyright (c) 2013 Schurr Solutions. All rights reserved.
//

#import "CoreDatabase.h"

@interface CoreDatabase ()

@property (strong, nonatomic) UIManagedDocument *document;
@property (strong, nonatomic) NSManagedObjectContext *context;
@property (strong, nonatomic) NSURL *path;

@end

@implementation CoreDatabase

+ (CoreDatabase *) databaseNamed: (NSString *)name
{
    static NSMutableDictionary *databases;
    
    if(!databases) {
        databases = [[NSMutableDictionary alloc] init];
    }
    
    if([databases objectForKey: name]) {
        return [databases objectForKey: name];
    }
    
    CoreDatabase *db = [[CoreDatabase alloc] initWithName: name];
    [databases setObject: db forKey: name];
    
    return db;
}

+ (void) databaseNamed: (NSString *) name notifyTarget: (id) target
{
    CoreDatabase *database = [[self class] databaseNamed: name];
    
    dispatch_queue_t queue = dispatch_queue_create("notifyDatabaseContext", NULL);
    dispatch_async(queue, ^{
        while(![database managedObjectContext]) {
        }
        dispatch_async(dispatch_get_main_queue(), ^{
            [target databaseIsReady: database];
        });
    });
}

- (id) init
{
    return nil;
}

- (void) databaseIsReady: (CoreDatabase *) database
{
    //
}

- (id) initWithName: (NSString *) name;
{
    self = [super init];
    
    if(self) {
        NSFileManager *fm = [[NSFileManager alloc] init];
        NSURL *url = [[fm URLsForDirectory: NSDocumentDirectory inDomains: NSUserDomainMask] lastObject];
        self.path = [url URLByAppendingPathComponent: [name stringByAppendingString:@".db"]];
        self.document = [[UIManagedDocument alloc] initWithFileURL: self.path];
        
        if(![fm fileExistsAtPath: [self.path path]]) {
             //NSLog(@"making db");
            // Create the database
            [self.document saveToURL: self.path forSaveOperation: UIDocumentSaveForCreating completionHandler: ^(BOOL success){
                if(success) {
                    self.context = self.document.managedObjectContext;
                }
            }];
        }
        else if (self.document.documentState == UIDocumentStateClosed) {
             //NSLog(@"opening db");
            // Open the database
            [self.document openWithCompletionHandler:^(BOOL success){
                if(success) {
                    self.context = self.document.managedObjectContext;
                }
            }];
        }
        else {
             //NSLog(@"db exists");
            // Retrieve the existing context
            self.context = self.document.managedObjectContext;
        }
    }
    
    return self;
}

- (UIManagedDocument *) managedDocument
{
    return self.document;
}

- (NSManagedObjectContext *) managedObjectContext
{
    return self.context;
}

- (void) close
{
    [self.document closeWithCompletionHandler:^(BOOL success) {
        }];
}

- (void) save
{
    [self.document saveToURL: self.document.fileURL
            forSaveOperation: UIDocumentSaveForOverwriting
           completionHandler: ^(BOOL success) {
           }];
}

@end
