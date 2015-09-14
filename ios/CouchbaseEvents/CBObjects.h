//
//  CBObjects.h
//  CouchbaseEvents
//
//  Created by James Nocentini on 14/09/2015.
//  Copyright (c) 2015 Couchbase. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CouchbaseLite/CouchbaseLite.h>

@interface CBObjects : NSObject

+ (CBObjects*)sharedInstance;

@property (nonatomic, strong) CBLDatabase *database;
@property (nonatomic, strong) CBLManager *manager;

- (void) startReplications;

@end
