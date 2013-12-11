//
//  FileCacheManager.m
//  Shutterbug
//
//  Created by Matthew Schurr on 10/13/13.
//  Copyright (c) 2013 Schurr Solutions. All rights reserved.
//

#import "FileCacheManager.h"
#import "NetworkActivityManager.h"
#import <CommonCrypto/CommonDigest.h>

@interface FileCacheManager()

@end

@implementation FileCacheManager

#define CACHE_MAX_BYTES 15728640 // 15 MB
#define CACHE_EXPIRE_TIME 600 // 5 minutes

+ (NSData *) waitForDataForURL: (NSURL *) url
{
    // Create a new file manager...
    NSFileManager *fileManager = [[NSFileManager alloc] init];
    
    // Grab the application cache directory path...
    NSArray *filePaths = [fileManager URLsForDirectory: NSCachesDirectory inDomains: NSUserDomainMask];
    NSURL *filePath = [filePaths lastObject];
    
    // Convert the URL to an MD5 hash...
    NSString *urlString = [url absoluteString];
    NSString *urlStringHash = [self hashMD5: urlString];
    
    // Convert the MD5 hash to a cache file path...
    NSURL *cacheFile = [filePath URLByAppendingPathComponent: urlStringHash];
    cacheFile = [cacheFile URLByAppendingPathExtension: @"dat"];
        
    // Check if the URL is cached (and within expire time). If it is, we can just return the data from the file.
    if([fileManager fileExistsAtPath: [cacheFile path]]) {
        NSDictionary *attributes = [fileManager attributesOfItemAtPath: [cacheFile path] error: NULL];
        NSDate *lastModified = [attributes fileModificationDate];
        NSDate *expirationTime = [NSDate dateWithTimeIntervalSinceNow: -CACHE_EXPIRE_TIME];
        
        //NSLog(@"LM=%@\n EXP=%@\n NOW=%@\n\n", lastModified, expirationTime, [NSDate date]);
        
        if([lastModified compare: expirationTime] == NSOrderedDescending) {
            NSData *data = [NSData dataWithContentsOfURL: cacheFile];
            
            if(data)
                return data;
        }
    }
    
    // Otherwise, we need to retrieve the data from the URL (use network activity indicator).
    [[NetworkActivityManager standardNetworkActivityManager] registerNetworkActivity];
    NSData *data = [[NSData alloc] initWithContentsOfURL: url];
    [[NetworkActivityManager standardNetworkActivityManager] unregisterNetworkActivity];
    
    // Retrieve the size of the data.
    NSUInteger bytes = [data length];
    
    // If the data exceeds the cache's maximum size, we can't cache it. Just return it.
    if(bytes > CACHE_MAX_BYTES)
        return data;
    
    // Calculate the current space utilized by the cache.
    NSUInteger cacheBytes = 0;
    NSArray *cacheFiles = [fileManager contentsOfDirectoryAtPath: [filePath path] error: NULL];
    
    for(NSString *file in cacheFiles) {
        NSString *filePathFull = [[filePath path] stringByAppendingPathComponent: file];
        NSDictionary *attributes = [fileManager attributesOfItemAtPath: filePathFull error: NULL];
        cacheBytes += [attributes fileSize];
    }
    
    // Remove files from the cache in LRU order until there is sufficient space for the data.
    if(cacheBytes + bytes > CACHE_MAX_BYTES) {
        // Create a sorted array of files in last modified order.
        NSArray *sortedArray = [cacheFiles sortedArrayUsingComparator:^NSComparisonResult(id a, id b) {
            NSString *pathOfA = [[filePath path] stringByAppendingPathComponent: (NSString *) a];
            NSString *pathOfB = [[filePath path] stringByAppendingPathComponent: (NSString *) b];
            NSDictionary *attributesOfA = [fileManager attributesOfItemAtPath: pathOfA error: NULL];
            NSDictionary *attributesOfB = [fileManager attributesOfItemAtPath: pathOfB error: NULL];
            NSDate *lastModifiedOfA = [attributesOfA fileModificationDate];
            NSDate *lastModifiedOfB = [attributesOfB fileModificationDate];
            return [lastModifiedOfA compare: lastModifiedOfB];
        }];
        
        NSMutableArray *sortedFiles = [sortedArray mutableCopy];
        
        // Remove files in LRU order until there is space.
        while(cacheBytes + bytes > CACHE_MAX_BYTES) {
            NSString *filePathToRemove = [[filePath path] stringByAppendingPathComponent: [sortedFiles objectAtIndex: 0]];
            [sortedFiles removeObjectAtIndex: 0];
            NSDictionary *attributes = [fileManager attributesOfItemAtPath: filePathToRemove error: NULL];
            cacheBytes -= [attributes fileSize];
            [fileManager removeItemAtPath: filePathToRemove error: NULL];
            //NSLog(@"purging cache files %@", filePathToRemove);
        }
    }
        
    // Store the data in the cache.
    //NSLog(@"writing to file %@", [cacheFile path]);
    [data writeToURL: cacheFile atomically: YES];
    
    // Return the data.
    return data;
}

// Taken from http://stackoverflow.com/questions/2018550/how-do-i-create-an-md5-hash-of-a-string-in-cocoa
+ (NSString *) hashMD5: (NSString *)input
{
    const char *cstr = [input UTF8String];
    unsigned char result[16];
    CC_MD5(cstr, strlen(cstr), result);
    
    return [NSString stringWithFormat:
            @"%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X",
            result[0], result[1], result[2], result[3],
            result[4], result[5], result[6], result[7],
            result[8], result[9], result[10], result[11],
            result[12], result[13], result[14], result[15]
            ];
}

@end
