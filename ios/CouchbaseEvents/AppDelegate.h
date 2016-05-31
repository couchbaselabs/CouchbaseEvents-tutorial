//
//  AppDelegate.h
//  CouchbaseEvents
//
//  Created by James Nocentini on 14/09/2015.
//  Copyright (c) 2015 Couchbase. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CouchbaseEvents.h"

@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;
@property CouchbaseEvents* cbevents;

@end

