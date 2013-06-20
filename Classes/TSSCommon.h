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
///returns the os version
+ (NSString *)osVersion;
+ (BOOL)fiveOHPlus;
+ (NSString *)osBuild;
+ (void)fixUIDevices;
+ (BOOL)internetAvailable;
@end
