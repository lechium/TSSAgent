//
//  TSSWorker.m
//  TSSAgent
//
//  Created by Kevin Bradley on 1/22/12.
//  Copyright 2012 nito, LLC. All rights reserved.
//

#import "TSSWorker.h"
#import "TSSCommon.h"

@implementation TSSWorker


void MyLogIt (NSString *format, ...)
{
    va_list args;
	
    va_start (args, format);
	
    NSString *string;
	
    string = [[NSString alloc] initWithFormat: format  arguments: args];
	
    va_end (args);
	
    printf ("%s", [string UTF8String]);
	
    [string release];
	
} // LogIt

- (void)theWholeShebang
{
	/*
	 
	 1. grab available blob listing from cydia
	 2. get signing list from wherever
	 3. cycle through filtered array grabbing blob from apple then sending to cydia
     
	 */
    
	
	if ([TSSCommon internetAvailable] == FALSE)
	{
		NSLog(@"internet is not available!, bail");
		return;
	}
	
	TSSManager *man = [[TSSManager alloc] initWithMode:kTSSFetchBlobFromApple];
	
	MyLogIt(@"synchronous blob check...\n\n");
	
	NSArray *blobs = [man _synchronousBlobCheck];
	
	if (blobs == nil);
    //MyLogIt(@"no blobs saved!!!\n");
	
	MyLogIt(@"filtering list...\n\n");
	NSArray *filteredList = [self filteredList:blobs];
	
	MyLogIt(@"processing versions...\n\n");
	
	for (id fw in filteredList)
	{
		MyLogIt(@"fetching version: %@...\n\n", fw);
		
		NSString *theBlob = [man _synchronousReceiveVersion:fw];
        
        NSDictionary *theBlobDict = [man dictionaryFromString:theBlob];
        
        int keyCount = [[theBlobDict allKeys] count];
        
        if (keyCount >= 21)
		{
            MyLogIt(@"pushing version: %@...\n\n", fw);
            
            NSString *returns = [man _synchronousPushBlob:theBlob];
            
            MyLogIt(@"%@\n\n", returns);
        }
    }
	
	[man release];
	
	MyLogIt(@"Done!!\n\n");
	
}

- (NSArray *)filteredList:(NSArray *)signedFW
{
	NSMutableArray *fetchList = [[NSMutableArray alloc] init];
	NSArray *avail = [TSSManager signableVersions]; //the versions we still report that can be signed from apple, from a plist we maintain
	NSArray *trimmedList = [self buildsFromList:signedFW]; //this cuts the array down to single string objects of JUST the "build" key
	
	//	NSLog(@"trimmedList: %@", trimmedList);
	
	for (id currentFW in avail)
	{
		//see if the trimmed list contains our current build, if it does, dont add, otherwise, add.
		
		if (![trimmedList containsObject:currentFW])
		{
			[fetchList addObject:currentFW];
		}
		
	}
	
	return [fetchList autorelease];
}


/*
 
 
 board = 16;
 build = 8C150;
 chip = 35120;
 firmware = "4.2";
 model = "AppleTV2,1";
 
 
 */

- (NSArray *)buildsFromList:(NSArray *)theList
{
	//LOG_SELF
	NSMutableArray *newArray = [[NSMutableArray alloc] init];
	
	for (id theItem in theList)
	{
		NSString *build = [theItem valueForKey:@"build"];
		[newArray addObject:build];
	}
	
	return [newArray autorelease];
}


- (void)dealloc
{
    
	[super dealloc];
}



@end
