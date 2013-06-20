//
//  TSSCommon.h
//  TSSAgent
//
//  Created by Kevin Bradley on 1/23/12.
//  Copyright 2012 nito, LLC. All rights reserved.
//

/**
 
 this class is a small mishmash of convenience classes that are commonly used throughout the rest of the project
 
 */

@interface TSSCommon : NSObject {

}

///users popen to run a process and then returns its output in a single string.
+ (NSString *)stringReturnForProcess:(NSString *)call;
///returns the os version, used to do version comparison checks for things such as fixing UIDevices (returns the product version ie 5.0)
+ (NSString *)osVersion;
///are we passed the 5.0 threshold
+ (BOOL)fiveOHPlus;
///osbuild version ie 8F455
+ (NSString *)osBuild;
///fix ui device exception issue on AppleTV in 5.0+
+ (void)fixUIDevices;
///our own method using reachability for internet connectivity, should be used instead of BRIPConfig check for device agnosticism.
+ (BOOL)internetAvailable;
@end
