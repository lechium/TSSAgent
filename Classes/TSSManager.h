//
//  TSSManager.h
//  TSSAgent
//
//  Created by Kevin Bradley on 1/16/12.
//  Copyright 2012 nito, LLC. All rights reserved.
//

#import <Foundation/Foundation.h>

	//#define BLOB_PLIST_URL @"http://nitosoft.com/ATV2/install/k66ap.plist"
#define BLOB_PLIST_URL @"http://files.firecore.com/FW/k66ap.plist"

enum {
	
	kTSSFetchBlobFromApple,
	kTSSFetchBlobFromCydia,
	kTSSSendBlobToCydia,
	kTSSCydiaBlobListing,
	kTSSCydiaBlobListingSolo,
};


#define TSSNullDevice DeviceIDMake(0, 0);

struct TSSDeviceID {
	int boardID;
	int chipID;
};
typedef struct TSSDeviceID TSSDeviceID;

static inline TSSDeviceID DeviceIDMake(int bid, int cid);

static inline TSSDeviceID DeviceIDMake(int bid, int cid)
{
	TSSDeviceID theDevice;
	theDevice.boardID = bid; theDevice.chipID = cid;
	return theDevice;
}

static inline bool DeviceIDEqualToDevice(TSSDeviceID device1, TSSDeviceID device2);

static inline bool DeviceIDEqualToDevice(TSSDeviceID device1, TSSDeviceID device2)
{
	return device1.boardID == device2.boardID && device1.chipID == device2.chipID;
}



@interface TSSManager : NSObject {

	NSString *					baseUrlString;
	NSString *					ecid;
	int							mode;
	TSSDeviceID					theDevice;
}

@property (readwrite, assign) TSSDeviceID theDevice;
@property (readwrite, assign) int mode;
@property (nonatomic, assign) NSString *baseUrlString;
@property (nonatomic, assign) NSString *ecid;

+ (NSString *)rawBlobFromResponse:(NSString *)inputString; ///the response string typically has information delimited by ampersands and at the end there is the raw plist data, this returns just the raw blob data
+ (TSSDeviceID)currentDevice; ///the current device we are running on, in an easy to use struct for constructing plist responses
+ (NSArray *)signableVersions; ///the versions apple is currently signing
+ (NSArray *)blobArrayFromString:(NSString *)theString; ///the array of blobs the user has on file, parsed from the initial JSON string
+ (NSString *)ipAddress; ///current user IP address

- (void)logDevice:(TSSDeviceID)inputDevice; ///debug method to log out the current device easily

- (NSString *)stringFromDictionary:(id)theDict; ///convenience function that may be better suited to be in TSSCommon

- (NSString *)_synchronousCydiaReceiveVersion:(NSString *)theVersion; ///synchronously receieve a blob from cydia
- (NSString *)_synchronousPushBlob:(NSString *)theBlob;
- (NSString *)_synchronousReceiveVersion:(NSString *)theVersion;
- (NSArray *)_synchronousBlobCheck;

- (NSMutableURLRequest *)requestForList;
- (NSMutableURLRequest *)requestForBlob:(NSString *)theBlob;
- (NSMutableURLRequest *)postRequestFromVersion:(NSString *)theVersion;
- (NSDictionary *)tssDictFromVersion:(NSString *)versionNumber;
- (id)initWithMode:(int)theMode;


@end


