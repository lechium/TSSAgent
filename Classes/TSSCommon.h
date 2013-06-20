//
//  TSSCommon.h
//  TSSAgent
//
//  Created by Kevin Bradley on 1/23/12.
//  Copyright 2012 nito, LLC. All rights reserved.
//

@interface TSSCommon : NSObject {

}

///users popen to run a process and then returns its output in a single string.
+ (NSString *)stringReturnForProcess:(NSString *)call;
///returns the os version, used to do version comparison checks for things such as fixing UIDevices
+ (NSString *)osVersion;
///are we passed the 5.0 threshold
+ (BOOL)fiveOHPlus;
///osbuild version
+ (NSString *)osBuild;
///fix ui device exception issue on AppleTV in 5.0+
+ (void)fixUIDevices;
///our own method using reachability for internet connectivity, should be used instead of BRIPConfig check for device agnosticism.
+ (BOOL)internetAvailable;
@end
