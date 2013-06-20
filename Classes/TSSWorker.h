//
//  TSSWorker.h
//  TSSAgent
//
//  Created by Kevin Bradley on 1/22/12.
//  Copyright 2012 nito, LLC. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "TSSManager.h"

/**
 
 this classes sole purpose is to fetch information from the TSSManager class and stitch it together in one full fledged process, its pretty minimalistic, most of it 
 resides in 'theWholeShebang' where it will fetch the blob listing the user has saved on cydias servers, the fw versions apple is still signing, filter the list down 
 to versions that ARE signing but NOT saved yet, fetches them, does some error checking, then saves them to sauriks server.
 
 */

@interface TSSWorker : NSObject {
	
}

///fetches all the firmware versions that are currently signing, grabs the requisite blobs from apple stitches in build manifest, submits to sauriks server
- (void)theWholeShebang;
///filters the list into versions we havent saved the blobs for yet, if we've already saved them, no reason to do it again
- (NSArray *)filteredList:(NSArray *)signedFW;
///takes the list and breaks it down an array of strings that JUST has the build number ie 8F455
- (NSArray *)buildsFromList:(NSArray *)theList;

@end
