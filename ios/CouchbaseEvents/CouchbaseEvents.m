//
//  CouchbaseEvents.m
//  CouchbaseEvents
//
//  Created by James Nocentini on 14/09/2015.
//  Copyright (c) 2015 Couchbase. All rights reserved.
//

#import "CouchbaseEvents.h"
#import "CBObjects.h"
#import <CouchbaseLite/CouchbaseLite.h>

@implementation CouchbaseEvents

- (BOOL)helloCBL {
    
    NSString* docID = [self createDocument:CBObjects.sharedInstance.database];
    [self updateDocument:CBObjects.sharedInstance.database documentId:docID];
    [self addAttachment:CBObjects.sharedInstance.database documentId:docID];
//    [self deleteDocument:CBObjects.sharedInstance.database documentId:docID];
    
    [[CBObjects sharedInstance] startReplications];
    
    [self createOrderedByDateView];
    
    [self outputOrderedByDate];
    
    CBLLiveQuery* liveQuery = [[[self getView] createQuery] asLiveQuery];
    [liveQuery addObserver: self forKeyPath:@"rows" options:0 context: NULL];
    [liveQuery start];
 
    return NO;
}

- (void)observeValueForKeyPath: (NSString *)keyPath ofObject: (id)object change: (NSDictionary *)change context: (void *)context {
    NSLog(@"Observe event received");
}

// creates the Document
- (NSString *)createDocument: (CBLDatabase *)database {
    // 1. Create an object that contains data for the new document
    NSDictionary *eventDetails = @{
                                   @"name": @"Big Party",
                                   @"location": @"My House"
                                   };
    // 2. Create an empty document
    CBLDocument *doc = [database createDocument];
    // 3. Save the ID of the new document
    NSString *docID = doc.documentID;
    // 4. Write the document to the database
    NSError *error;
    CBLRevision *newRevision = [doc putProperties: eventDetails error:&error];
    if (newRevision) {
        NSLog(@"Document created and written to database, ID = %@", docID);
    }
    return docID;
}

- (BOOL) updateDocument:(CBLDatabase *) database documentId:(NSString *) documentId {
    // 1. Retrieve the document from the database
    CBLDocument *getDocument = [database documentWithID: documentId];
    // 2. Make a mutable copy of the properties from the document we just retrieved
    NSMutableDictionary *docContent = [getDocument.properties mutableCopy];
    // 3. Modify the document properties
    docContent[@"description"] = @"Anyone is invited!";
    docContent[@"address"] = @"123 Elm St.";
    docContent[@"date"] = @"2014";
    // 4. Save the Document revision to the database
    NSError *error;
    CBLSavedRevision *newRev = [getDocument putProperties:docContent error:&error];
    if (!newRev) {
        NSLog(@"Cannot update document. Error message: %@", error.localizedDescription);
    }
    // 5. Display the new revision of the document
    NSLog(@"The new revision of the document contains: %@", newRev.properties);
    return YES;
}

- (BOOL) addAttachment: (CBLDatabase *) database documentId: (NSString *) documentId {
    NSError *error;
    // 1
    CBLDocument *getDocument = [database documentWithID: documentId];
    // 2
    const unsigned char bytes[] = {0, 0, 0, 0, 0};
    NSData *zerosData = [NSData dataWithBytes: bytes length: sizeof(bytes)];
    // 3
    CBLUnsavedRevision *unsavedRev = [getDocument.currentRevision createRevision];
    [unsavedRev setAttachmentNamed: @"zeros.bin"
                   withContentType: @"application/octet-stream" content: zerosData];
    // 4
    CBLSavedRevision *newRev = [unsavedRev save: &error];
    NSLog(@"The new revision of the document contains: %@", newRev.properties);
    return YES;
}

- (BOOL) deleteDocument:(CBLDatabase*) database documentId:(NSString*) documentId {
    CBLDocument* document = [database documentWithID:documentId];
    NSError* error;
    [document deleteDocument:&error];
    if (!error) {
        NSLog(@"Deleted document, deletion status is %d", [document isDeleted]);
        return YES;
    }
    return NO;
}

- (CBLView *)getView {
    CBLDatabase* database = [CBObjects sharedInstance].database;
    return [database viewNamed:@"byDate"];
}

- (void) createOrderedByDateView {
    CBLView* orderedByDateView = [self getView];
    [orderedByDateView setMapBlock: MAPBLOCK({
        emit(doc[@"date"], nil);
    }) version: @"1" /* Version of the mapper */ ];
    NSLog(@"Ordered By Date View created.");
}

-(void) outputOrderedByDate {
    CBLQuery *orderedByDateQuery = [[self getView] createQuery];
    orderedByDateQuery.descending = YES;
    orderedByDateQuery.startKey = @"2015";
    orderedByDateQuery.endKey = @"2014";
    orderedByDateQuery.limit = 20;
    NSError *error;
    CBLQueryEnumerator *result = [orderedByDateQuery run: &error];
    if (!error) {
        for (CBLQueryRow * row in result) {
            NSLog(@"Found party: %@", [row.document.properties valueForKey:@"description"]);
        }
    } else {
        NSLog(@"Error querying view %@", error.localizedDescription);
    }
}

@end
