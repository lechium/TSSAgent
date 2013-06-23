//
//  TSSManager.mm
//  TSSAgent
//
//  Created by Kevin Bradley on 1/16/12.
//  Copyright 2012 nito, LLC. All rights reserved.
//

//#import "MSettingsController.h"

#import "TSSManager.h"
#import "IOKit/IOKitLib.h"
#import <CoreFoundation/CoreFoundation.h>
#import <Foundation/Foundation.h>
#include <stdio.h>
#include <stdlib.h>
#include <stddef.h>
#include <sys/types.h>
#import "TSSCommon.h"
#import "JSONKit.h"
#import "TSSCategories.h"

//not sure why foundation isnt picking this up, keep the compiler from complaining



@interface NSHost : NSObject {
    
}

+ (id)currentHost;

@end

/*
 
 all of this asynchronous stuff isn't really needed anymore, im just too lazy to prune it out. *SHOCK*
 
 
 */

@interface TSSManager ()


@end


static NSString *ChipID_ = nil;

static NSString *HexToDec(NSString *hexValue)
{
	if (hexValue == nil)
		return nil;
	
	unsigned long long dec;
	NSScanner *scan = [NSScanner scannerWithString:hexValue];
	if ([scan scanHexLongLong:&dec])
	{
		
		return [NSString stringWithFormat:@"%llu", dec];
		//NSLog(@"chipID binary: %@", finalValue);
	}
	
	return nil;
}

/*
 
 CYDIOGetValue is a carbon copy of CYIOGetValue from Cydia by Jay Freeman
 CYDHex is a carbon copy of CYDHex from Cydia by Jay Freeman
 */

static NSObject *CYDIOGetValue(const char *path, NSString *property) {
	
    io_registry_entry_t entry(IORegistryEntryFromPath(kIOMasterPortDefault, path));
    if (entry == MACH_PORT_NULL)
        return nil;
	
    CFTypeRef value(IORegistryEntryCreateCFProperty(entry, (CFStringRef) property, kCFAllocatorDefault, 0));
    IOObjectRelease(entry);
	
    if (value == NULL)
        return nil;
    return [(id) value autorelease];
}

static NSString *CYDHex(NSData *data, bool reverse) {
    if (data == nil)
        return nil;
	
    size_t length([data length]);
    uint8_t bytes[length];
    [data getBytes:bytes];
	
    char string[length * 2 + 1];
    for (size_t i(0); i != length; ++i)
        sprintf(string + i * 2, "%.2x", bytes[reverse ? length - i - 1 : i]);
	
    return [NSString stringWithUTF8String:string];
}

@implementation TSSManager

void TSSLog (NSString *format, ...)
{
    va_list args;
	
    va_start (args, format);
	
    NSString *string;
	
    string = [[NSString alloc] initWithFormat: format  arguments: args];
	
    va_end (args);
	
    printf ("%s", [string UTF8String]);
	
    [string release];
	
} // LogIt

@synthesize baseUrlString, ecid, mode, theDevice;


//obsolete

+ (NSString *)versionFromBuild:(NSString *)buildNumber
{
	if ([buildNumber isEqualToString:@"8F455"])
		return @"4.3";
	if ([buildNumber isEqualToString:@"9A334v"])
		return @"4.4";
	if ([buildNumber isEqualToString:@"9A335a"])
		return @"4.4.1";
	if ([buildNumber isEqualToString:@"9A336a"])
		return @"4.4.2";
	if ([buildNumber isEqualToString:@"9A405l"])
		return @"4.4.3";
	if ([buildNumber isEqualToString:@"9A406a"])
		return @"4.4.4";
	if ([buildNumber isEqualToString:@"9B5127c"])
		return @"5.0b1";
	if ([buildNumber isEqualToString:@"9B5141a"])
		return @"5.0b2";
    
    return nil;
}

- (void)logDevice:(TSSDeviceID)inputDevice
{
	NSLog(@"TSSDeviceID(boardID: %i, chipID: %i)", inputDevice.boardID, inputDevice.chipID);
}

+ (TSSDeviceID)currentDevice
{
	NSString *rawDevice = [TSSCommon stringReturnForProcess:@"/usr/sbin/sysctl -n hw.machine"];
	NSString *theDevice = [rawDevice stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
	
	//NSLog(@"theDevice: -%@-", theDevice);
	
	if ([theDevice isEqualToString:@"AppleTV2,1"])
		return DeviceIDMake(16, 35120);
	
	if ([theDevice isEqualToString:@"iPad1,1"])
		return DeviceIDMake(2, 35120);
    
	if ([theDevice isEqualToString:@"iPad2,1"])
		return DeviceIDMake(4, 35136);
    
	if ([theDevice isEqualToString:@"iPad2,2"])
		return DeviceIDMake(6, 35136);
	
	if ([theDevice isEqualToString:@"iPad2,3"])
		return DeviceIDMake(2, 35136);
	
	if ([theDevice isEqualToString:@"iPad2,1"])
		return DeviceIDMake(4, 35136);
	
	if ([theDevice isEqualToString:@"iPhone1,1"])
		return DeviceIDMake(0, 35072);
	
	if ([theDevice isEqualToString:@"iPhone1,2"])
		return DeviceIDMake(4, 35072);
	
	if ([theDevice isEqualToString:@"iPhone2,1"])
		return DeviceIDMake(0, 35104);
	
	if ([theDevice isEqualToString:@"iPhone3,1"])
		return DeviceIDMake(0, 35120);
	
	if ([theDevice isEqualToString:@"iPhone3,3"])
		return DeviceIDMake(6, 35120);
	
	if ([theDevice isEqualToString:@"iPod1,1"])
		return DeviceIDMake(2, 35072);
	
	if ([theDevice isEqualToString:@"iPod2,1"])
		return DeviceIDMake(0, 34592);
    
	if ([theDevice isEqualToString:@"iPod3,1"])
		return DeviceIDMake(2, 35106);
	
	if ([theDevice isEqualToString:@"iPod4,1"])
		return DeviceIDMake(8, 35120);
	
	return TSSNullDevice;
	
	/*
	 
     
	 "appletv2,1": (35120, 16, 'AppleTV2,1'),
	 
	 "ipad1,1": (35120, 2, 'iPad1,1'),
	 "ipad2,1": (35136, 4, 'iPad2,1'),
	 "ipad2,2": (35136, 6, 'iPad2,2'),
	 "ipad2,3": (35136, 2, 'iPad2,3'),
	 
	 "iphone1,1": (35072, 0, 'iPhone1,1'),
	 "iphone1,2": (35072, 4, 'iPhone1,2'),
	 "iphone2,1": (35104, 0, 'iPhone2,1'),
	 "iphone3,1": (35120, 0, 'iPhone3,1'),
	 "iphone3,3": (35120, 6, 'iPhone3,3'),
	 
	 "ipod1,1": (35072, 2, 'iPod1,1'),
	 "ipod2,1": (34592, 0, 'iPod2,1'),
	 "ipod3,1": (35106, 2, 'iPod3,1'),
	 "ipod4,1": (35120, 8, 'iPod3,1'),
	 
	 */
}

+ (NSString *)rawBlobFromResponse:(NSString *)inputString
{
    
	NSArray *componentArray = [inputString componentsSeparatedByString:@"&"];
	int count = [componentArray count];
		//NSLog(@"count: %i array: %@", count, componentArray);
    if (count >= 3)
	{
		NSString *plist = [[componentArray objectAtIndex:2] substringFromIndex:15];
		
			//make sure the plist has 21+ keys
		
		NSArray *allKeys = [[plist dictionaryFromString] allKeys];
		if ([allKeys count] >= 21)
		{	
			return plist;
	
		} else { // we are short on keys, probably just an APTicket
			

			TSSLog(@"\n ERROR: TSSAgent SHSH blob retrieval failed. The firmware file was incomplete.\n\n");
			return nil;
		}
	
		
			
		} else {
		
		/*
		 
		 (
		 "STATUS=94",
		 "MESSAGE=This device isn't eligible for the requested build."
		 )
		 
		 */

		if (count == 2)
		{
			int status = [[[[componentArray objectAtIndex:0] componentsSeparatedByString:@"="] lastObject] intValue];
			NSString *message = [[[componentArray objectAtIndex:1] componentsSeparatedByString:@"="] lastObject];
			TSSLog(@"\n ERROR: TSSAgent SHSH blob retrieval failed with status '%i' and message '%@'\n\n", status, message);
		}
		
	    return nil;
	}
	
	
}

//obsolete, just leaving in here for some notes on output formatting

+ (NSString *)blobPathFromString:(NSString *)inputString andEcid:(NSString *)theEcid andBuild:(NSString *)theBuildVersion
{
	//LOG_SELF
    //STATUS=0&MESSAGE=SUCCESS&REQUEST_STRING=<?xml
	
	NSString *version = [TSSManager versionFromBuild:theBuildVersion];
	//NSLog(@"version: %@", version);
	NSArray *componentArray = [inputString componentsSeparatedByString:@"&"];
    //	NSLog(@"componentArray: %@", componentArray);
	int count = [componentArray count];
    //STATUS=0
    //MESSAGE=SUCCESS
    //REQUEST_STRING=<?xml
    
    //int status = [[[[componentArray objectAtIndex:0] componentsSeparatedByString:@"="] lastObject] intValue];
    //NSString *message = [[[componentArray objectAtIndex:1] componentsSeparatedByString:@"="] lastObject];
	if (count >= 3)
	{
		NSString *plist = [[componentArray objectAtIndex:2] substringFromIndex:15];
        //NSLog(@"plist: %@", plist);
		
		NSString *outputName = [NSString stringWithFormat:@"/private/var/tmp/%@-appletv2,1-%@", theEcid, version];
		//NSLog(@"outputName: %@", outputName);
        //NSString *finalName = [outputName stringByAppendingPathExtension:@"shsh"];
        //NSString *tmp = @"/private/var/tmp/thefile";
		[plist writeToFile:outputName atomically:YES encoding:NSUTF8StringEncoding error:nil];
        //NSDictionary *blob = [NSDictionary dictionaryWithContentsOfFile:outputName];
        //[[NSFileManager defaultManager] removeItemAtPath:tmp error:nil];
        //gzip 780309390798-appletv2,1-4.4 -S.shsh
        //[self gzipBlob:outputName];
		
		return outputName;
	} else {
		
		NSLog(@"probably failed: %@ count: %i", componentArray, count);
		
		return nil;
	}
	
	
}


+ (NSString *)ipAddress { return [[[NSHost currentHost] addresses] objectAtIndex:1]; }

/*
 
 the request we send to get the list of SHSH blobs for the current device
 
 NOTE: this is all requisite on saurik updating the BuildManifest info on his servers to reflect new versions.
 */


- (NSMutableURLRequest *)requestForList
{
    
	NSMutableURLRequest *request = [[[NSMutableURLRequest alloc] init] autorelease];
	[request setURL:[NSURL URLWithString:baseUrlString]];
	[request setHTTPMethod:@"POST"];
	[request setValue:@"text/xml" forHTTPHeaderField:@"Content-Type"];
	[request setValue:@"X-User-Agent" forHTTPHeaderField:@"User-Agent"];
	[request setValue:nil forHTTPHeaderField:@"X-User-Agent"];
	
	return request;
}

/*
 
 we call this request when we are trying to send the blob TO cydia after fetching it FROM apple
 
 */

- (NSMutableURLRequest *)requestForBlob:(NSString *)post
{
	NSData *postData = [post dataUsingEncoding:NSUTF8StringEncoding allowLossyConversion:YES];
    NSString *postLength = [NSString stringWithFormat:@"%d", [postData length]];
	NSMutableURLRequest *request = [[[NSMutableURLRequest alloc] init] autorelease];
	[request setURL:[NSURL URLWithString:baseUrlString]];
	[request setHTTPMethod:@"POST"];
	[request setValue:postLength forHTTPHeaderField:@"Content-Length"];
	[request setValue:@"text/xml" forHTTPHeaderField:@"Content-Type"];
	[request setValue:@"X-User-Agent" forHTTPHeaderField:@"User-Agent"]; //should probably change this to a custom user agent
	[request setValue:nil forHTTPHeaderField:@"X-User-Agent"];
	[request setHTTPBody:postData];
	return request;
}


/*
 
 the url request to fetch a particular version from apple for the SHSH blob
 
 */

- (NSMutableURLRequest *)postRequestFromVersion:(NSString *)theVersion
{
	NSDictionary *theDict = [self tssDictFromVersion:theVersion]; //create a dict based on buildmanifest, we want to read this dictionary from a server in the future.
	self.ecid = [theDict valueForKey:@"ApECID"];
    [ecid retain]; //crashes for some reason if we dont retain here
    
	NSString *post = [theDict stringFromDictionary]; //convert the nsdictionary into a string we can submit
	
	NSData *postData = [post dataUsingEncoding:NSASCIIStringEncoding allowLossyConversion:YES]; //convert string to NSData that can be used as the HTTPBody of the POST
	
	NSString *postLength = [NSString stringWithFormat:@"%d", [postData length]];
	
	NSMutableURLRequest *request = [[[NSMutableURLRequest alloc] init] autorelease];
	[request setURL:[NSURL URLWithString:baseUrlString]];
	[request setHTTPMethod:@"POST"];
	[request setValue:postLength forHTTPHeaderField:@"Content-Length"];
	[request setValue:@"text/xml" forHTTPHeaderField:@"Content-Type"];
	[request setValue:@"InetURL/1.0" forHTTPHeaderField:@"User-Agent"];
	[request setHTTPBody:postData];
	return request;
}

+ (NSArray *)signableVersions
{
	NSDictionary *k66 = [NSDictionary dictionaryWithContentsOfURL:[NSURL URLWithString:BLOB_PLIST_URL]];
	return [k66 valueForKey:@"openVersions"];
}

/*
 
 grabs the proper build manifest info from a plist that is hosted online
 
 we combine this build manifest into an example dictionary (plist) to make a tss request from apples servers.
 
 
 */

- (NSDictionary *)tssDictFromVersion:(NSString *)versionNumber //ie 9A406a
{
	TSSDeviceID cd = self.theDevice; //ascertain the current device
	NSDictionary *k66 = [NSDictionary dictionaryWithContentsOfURL:[NSURL URLWithString:BLOB_PLIST_URL]]; //fetch our dictionary of buildManifests
    NSDictionary *versionDict = [k66 valueForKey:versionNumber]; //grab our specific versionDict, we should probably bail here if that doesnt exist.
	NSMutableDictionary *theDict = [[NSMutableDictionary alloc] initWithDictionary:versionDict]; //create a mutable version, mutableCopy would probably be sufficient here
	
	[theDict setObject:[NSNumber numberWithBool:YES] forKey:@"@APTicket"];
	[theDict setObject:[TSSManager ipAddress] forKey:@"@HostIpAddress"];
	[theDict setObject:@"mac" forKey:@"@HostPlatformInfo"];
	[theDict setObject:[NSNumber numberWithInt:cd.boardID] forKey:@"ApBoardID"];
	[theDict setObject:[NSNumber numberWithInt:cd.chipID] forKey:@"ApChipID"];
	[theDict setObject:@"libauthinstall-107" forKey:@"@VersionInfo"];
	[theDict setObject:ChipID_ forKey:@"ApECID"];
	[theDict setObject:[NSNumber numberWithBool:YES] forKey:@"ApProductionMode"];
	[theDict setObject:[NSNumber numberWithInt:1] forKey:@"ApSecurityDomain"];
	
	return [theDict autorelease];
	
}

/*
 
 should have a switch statement here to start the requisite processes, not just for the blob listing one, even if the delegate is set after its should still pick up the end functions properly.
 
 
 */

- (id)initWithMode:(int)theMode
{
	if ((self = [super init]) != nil);
	{
		
        ChipID_ = HexToDec([CYDHex((NSData *) CYDIOGetValue("IODeviceTree:/chosen", @"unique-chip-id"), true) uppercaseString]);
		theDevice = [TSSManager currentDevice];
        self.mode = theMode;
        
		return (self);
	}
	return nil;
}


/*
 
 see what blobs are available for this particular device
 
 */

- (NSArray *)_synchronousBlobCheck
{
	
    //just check if interwebz are available first, if they aren't, bail
	
	if ([TSSCommon internetAvailable] == FALSE)
	{
		
		NSLog(@"no internet available, should we bail?!");
        //	return nil
	}
    
	// First get and check the URL.
    
	baseUrlString = [NSString stringWithFormat:@"http://cydia.saurik.com/tss@home/api/check/%@", ChipID_];
    
    // Open a connection for the URL.
    
    NSMutableURLRequest *request = [self requestForList];
    
    NSURLResponse *theResponse = nil;
    NSData *returnData = [NSURLConnection sendSynchronousRequest:request returningResponse:&theResponse error:nil];
    NSString *datString = [[NSString alloc] initWithData:returnData  encoding:NSUTF8StringEncoding];
    if ([datString length] <= 2)
    {
        [datString release];
        return nil;
    }
    
    NSArray *blobArray = [datString objectFromJSONString];
    [datString release];
    return blobArray;
}

/*
 
 push the newly constructed blob to sauriks servers for safekeeping.
 
 */

- (NSString *)_synchronousPushBlob:(NSString *)theBlob
{
	if ([TSSCommon internetAvailable] == FALSE)
	{
		
		NSLog(@"no internet available, should we bail?!");
        //	return nil;
	}
    NSMutableURLRequest *      request;
	TSSDeviceID cd = self.theDevice;
	baseUrlString = [NSString stringWithFormat:@"http://cydia.saurik.com/tss@home/api/store/%i/%i/%@", cd.chipID, cd.boardID, ChipID_];
    
    // Open a connection for the URL.
    request = [self requestForBlob:theBlob];
    
    NSHTTPURLResponse * theResponse = nil;
    
    [NSURLConnection sendSynchronousRequest:request returningResponse:&theResponse error:nil];
    
    NSString *returnString = [NSString stringWithFormat:@"Request returned with response: \"%@\" with status code: %i",[NSHTTPURLResponse localizedStringForStatusCode:theResponse.statusCode], theResponse.statusCode ];
    
    return returnString;
    
}

/*
 
 fetch the specified blob version from cydias servers
 
 */

- (NSString *)_synchronousCydiaReceiveVersion:(NSString *)theVersion
{
	if ([TSSCommon internetAvailable] == FALSE)
	{
		
		NSLog(@"no internet available, bail!");
		return nil;
		
	}
    
    baseUrlString = @"http://cydia.saurik.com/TSS/controller?action=2";
    
    // Open a connection for the URL.
    
    NSMutableURLRequest *request = [self postRequestFromVersion:theVersion];
    NSURLResponse *theResponse = nil;
    NSData *returnData = [NSURLConnection sendSynchronousRequest:request returningResponse:&theResponse error:nil];
    NSString *datString = [[NSString alloc] initWithData:returnData  encoding:NSUTF8StringEncoding];
    NSString *outString = [TSSManager rawBlobFromResponse:datString];
    [datString release];
    
    return outString;
}

/*
 
 synchronously recieve a blob version from apples servers
 
 */

- (NSString *)_synchronousReceiveVersion:(NSString *)theVersion
{
    
	baseUrlString = @"http://gs.apple.com/TSS/controller?action=2";
	
    // Open a connection for the URL.
    NSMutableURLRequest *request = [self postRequestFromVersion:theVersion];
    NSURLResponse *theResponse = nil;
    NSData *returnData = [NSURLConnection sendSynchronousRequest:request returningResponse:&theResponse error:nil];
    NSString *datString = [[NSString alloc] initWithData:returnData  encoding:NSUTF8StringEncoding];
    NSString *outString = [TSSManager rawBlobFromResponse:datString];
    [datString release];
    return outString;
    
}

//http://cydia.saurik.com/tss@home/api/check/%llu <--ecid


- (void)dealloc {
	
    [super dealloc];
}



@end
