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


- (void)theWholeShebang;
- (NSArray *)filteredList:(NSArray *)signedFW;
- (NSArray *)buildsFromList:(NSArray *)theList;

@end
