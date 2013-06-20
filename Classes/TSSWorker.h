//
//  TSSWorker.h
//  TSSAgent
//
//  Created by Kevin Bradley on 1/22/12.
//  Copyright 2012 nito, LLC. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "TSSManager.h"

@interface TSSWorker : NSObject {
	
}

///fetches all the firmware versions that are currently signing, grabs the requisite blobs from apple stitches in build manifest, submits to sauriks server
- (void)theWholeShebang;
///filters the list into versions we havent saved the blobs for yet, if we've already saved them, no reason to do it again
- (NSArray *)filteredList:(NSArray *)signedFW;
///takes the list and breaks it down an array of strings that JUST has the build number ie 8F455
- (NSArray *)buildsFromList:(NSArray *)theList;

@end
