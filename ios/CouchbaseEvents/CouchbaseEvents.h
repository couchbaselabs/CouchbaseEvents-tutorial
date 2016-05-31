//
//  CouchbaseEvents.h
//  CouchbaseEvents
//
//  Created by James Nocentini on 14/09/2015.
//  Copyright (c) 2015 Couchbase. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CouchbaseLite/CouchbaseLite.h>

@interface CouchbaseEvents : NSObject

- (BOOL) helloCBL;
@property CBLLiveQuery* liveQuery;
@end
