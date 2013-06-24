//
//  TSSCommon.m
//  TSSAgent
//
//  Created by Kevin Bradley on 1/23/12.
//  Copyright 2012 nito, LLC. All rights reserved.
//

@interface ATVVersionInfo : NSObject {
}

+ (int)compareEFIVersion:(id)version withEFIVersion:(id)efiversion;	// 0x301c5fa1
+ (int)compareIRVersion:(id)version withIRVersion:(id)irversion;	// 0x301c6019
+ (int)compareOSVersion:(id)version andBuild:(id)build withOSVersion:(id)osversion andBuild:(id)build4;	// 0x301c5e01
+ (int)compareSIVersion:(id)version withSIVersion:(id)siversion;	// 0x301c6161
+ (id)currentEFIVersion;	// 0x301c5f25
+ (id)currentIRVersion;	// 0x301c5fe5
+ (id)currentOSBuildVersion;	// 0x301c5dd9
+ (id)currentOSVersion;	// 0x301c5db1
+ (id)currentSIBootVersion;	// 0x301c6131
+ (id)currentSIMainVersion;	// 0x301c6125
+ (BOOL)isSIFirmwareValid;	// 0x301c615d

@end


#import "TSSCommon.h"
#import "Reachability.h"

@implementation TSSCommon



/*
 
 may not be using this at all, probably should be to make this project properly device agnostic
 
 */

+ (BOOL)internetAvailable
{
	NetworkStatus netStatus = [[Reachability reachabilityForInternetConnection] currentReachabilityStatus];
	switch (netStatus) {
			
		case NotReachable:
			//NSLog(@"NotReachable");
			return NO;
			break;
			
		case ReachableViaWiFi:
			//NSLog(@"ReachableViaWiFi");
			return YES;
			break;
			
			
		case ReachableViaWWAN:
			//NSLog(@"ReachableViaWWAN");
			return YES;
			break;
	}
	return NO;
}

/*
 
 for some reason in 5.0+ [UIDevice currentDevice] returns an exception the first time called, but works thereafter, this fixes that.
 
 */

+ (void)fixUIDevices
{
	id cd = nil;
	Class uid = NSClassFromString(@"UIDevice");
	if ([TSSCommon fiveOHPlus])
	{
		
		@try {
			cd = [uid currentDevice];
		}
		
		@catch ( NSException *e ) {
			//NSLog(@"exception: %@", e);
		}
		
		@finally {
			//NSLog(@"will it work the second try?");
			
			cd = [uid currentDevice];
			//NSLog(@"current device fixed: %@", cd);
			
		}
	}
	
}

+ (NSString *)osBuild
{
	return [[TSSCommon stringReturnForProcess:@"/usr/bin/sw_vers -buildVersion"] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
}

	//@class ATVVersionInfo;

+ (NSString *)osBuildATV ///obsolete
{
	Class cls = NSClassFromString(@"ATVVersionInfo"); //FIXME: obviously this cant be okay since we need it to be device agnostic maybe someday
	if (cls != nil)
	{
		return [cls currentOSBuildVersion];
	}
	return nil;	
}

+ (NSString *)stringReturnForProcess:(NSString *)call
{
    if (call==nil) 
        return 0;
    char line[200];
    
    FILE* fp = popen([call UTF8String], "r");
    NSMutableString *lines = [[NSMutableString alloc]init];
    if (fp)
    {
        while (fgets(line, sizeof line, fp))
        {
            NSString *s = [NSString stringWithCString:line encoding:NSUTF8StringEncoding];
			[lines appendString:s];
        }
    }
    pclose(fp);
    return [lines autorelease];
}


+ (BOOL)fiveOHPlus
{
	NSString *versionNumber = [TSSCommon osVersion];
	NSString *baseline = @"5.0";
	NSComparisonResult theResult = [versionNumber compare:baseline options:NSNumericSearch];
    
	if ( theResult == NSOrderedDescending ) { return YES; }
    else if ( theResult == NSOrderedAscending ) { return NO; }
    else if ( theResult == NSOrderedSame ) { return YES; }
	
    return NO;
}

+ (NSString *)osVersion
{
	return [[TSSCommon stringReturnForProcess:@"/usr/bin/sw_vers -productVersion"] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
}

+ (NSString *)osVersionATV  ///obsolete
{

	Class cls = NSClassFromString(@"ATVVersionInfo");
	if (cls != nil)
	{
		return [cls currentOSVersion];
	}
	return nil;	
}



@end
