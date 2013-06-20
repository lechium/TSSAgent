/*
 TSSHelper.m
 TSSAgent
 
 Written by Kevin Bradley
 
 
 */


#import <Foundation/Foundation.h>
#include <sys/types.h>
#include <unistd.h>
#import "TSSCommon.h"
#import "TSSManager.h"
#import "TSSWorker.h"

/**
 
 the main class foundation tool class, handles the arguments that are fed in to the command line and determines the proper flow of the tool
 
 */

void LogIt (NSString *format, ...)
{
    va_list args;
	
    va_start (args, format);
	
    NSString *string;
	
    string = [[NSString alloc] initWithFormat: format  arguments: args];
	
    va_end (args);
	
    printf ("%s", [string UTF8String]);
	
    [string release];
	
} // LogIt

int main (int argc, const char * argv[]) {
	NSAutoreleasePool * pool = [[NSAutoreleasePool alloc] init];
	//LogIt(@"argc: %i\n", argc);
	setuid(0);
    
    //im sure there is a better way to print out usage and have it fill the lines its supposed to / wrap properly, but oh well ;-P
    
	if (argc <= 1)
	{
		LogIt(@"\n");
		LogIt(@"AppleTV TSSAgent - a standalone solution for listing SHSH blobs, fetching SHSH blobs and submitting the blobs to saurik's SHSH server.\n\n");
		LogIt(@"Currently this is targeted for the AppleTV but it could definitely be expanded to work with other devices, not that it's necessary.\n\n");
		LogIt(@"-l \t\t\t lists all the SHSH blobs that are currently saved on sauriks server.\n");
		LogIt(@"-v osBuildVersion \t fetches the SHSH blobs for version specified from apples servers. ie -v 8F455.\n");
		LogIt(@"-c osBuildVersion \t fetches the SHSH blobs for version specified from sauriks's servers. ie -c 8F455.\n");
		LogIt(@"-p osBuildVersion \t fetch the SHSH blob for the version specified AND pushes to sauriks server.\n");
		LogIt(@"-1337 \t\t\t will fetch the versions that are still elgible to be signed and push them to sauriks server.\n\n");
		return -1;
        
	}
	
	NSString *value = nil;
	NSString *option = [NSString stringWithUTF8String:argv[1]];
	
	if (argc >= 3)
		value = [NSString stringWithUTF8String:argv[2]];
	
    if ([option isEqualToString:@"-l"]) //list
    {
        TSSManager *man = [[TSSManager alloc] initWithMode:kTSSCydiaBlobListingSolo];
        NSArray *blobs = [man _synchronousBlobCheck];
        if (blobs == nil)
        {
            LogIt(@"No Blobs Saved!");
        }
        NSString *string = [man stringFromDictionary:blobs];
        [man autorelease];
        LogIt(@"%@", string); //print the blob listing
        [pool release];
        return 0;
        
    } else if ([option isEqualToString:@"-v"]) //fetch version
    {
        if (value == nil)
        {
            LogIt(@"\nYou must specify a version number!\n\n");
            return -1;
        }
        
        TSSManager *man = [[TSSManager alloc] initWithMode:kTSSFetchBlobFromApple];
        NSString *theBlob = [man _synchronousReceiveVersion:value];
        [man autorelease];
        
        LogIt(@"%@", theBlob); //print the raw blob output
        
        [pool release];
        return 0;
        
    }  else if ([option isEqualToString:@"-c"]) //cydia fetch version
    {
        if (value == nil)
        {
            LogIt(@"\nYou must specify a version number!\n\n");
            return -1;
        }
        
        TSSManager *man = [[TSSManager alloc] initWithMode:kTSSFetchBlobFromApple];
        NSString *theBlob = [man _synchronousCydiaReceiveVersion:value];
        [man autorelease];
        
        LogIt(@"%@", theBlob);
        
        [pool release];
        return 0;
        
    } else if ([option isEqualToString:@"-p"]) { //push version
        
        if (value == nil)
        {
            LogIt(@"\nYou must specify a version number!\n\n");
            return -1;
        }
        
        TSSManager *man = [[TSSManager alloc] initWithMode:kTSSFetchBlobFromApple];
        NSString *theBlob = [man _synchronousReceiveVersion:value];
        LogIt(@"%@", theBlob);
        [man _synchronousPushBlob:theBlob];
        
        [man autorelease];
        [pool release];
        return 0;
        
    } else if ([option isEqualToString:@"-1337"]) //runs the whole process of fetching all available and pushing them all to sauriks server.
    {
        NSLog(@"Processing blobs...\n\n");
        TSSWorker *worker = [[TSSWorker alloc] init];
        [worker theWholeShebang];
        [worker autorelease];
        [pool release];
        return 0;
        
    } else if ([option isEqualToString:@"-debug"])
    {
        NSNumber *theValue = [NSNumber numberWithBool:[TSSCommon internetAvailable]];
        NSLog(@"internet available: %@", theValue);
    }
	
	[pool release];
    return 0;
}

