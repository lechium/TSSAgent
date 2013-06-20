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


}

@property (readwrite, assign) TSSDeviceID theDevice; ///keep track of the device
@property (readwrite, assign) int mode; ///current mode we are running in, probably not needed anymore
@property (nonatomic, assign) NSString *baseUrlString;
@property (nonatomic, assign) NSString *ecid;

///the response string typically has information delimited by ampersands and at the end there is the raw plist data, this returns just the raw blob data
+ (NSString *)rawBlobFromResponse:(NSString *)inputString;
///the current device we are running on, in an easy to use struct for constructing our plist responses
+ (TSSDeviceID)currentDevice;
///the versions apple is currently signing
+ (NSArray *)signableVersions;
///the array of blobs the user has on file, parsed from the initial JSON string, should be obsolete now by using JSONKit
+ (NSArray *)blobArrayFromString:(NSString *)theString;
///current user IP address
+ (NSString *)ipAddress; 

///debug method to log out the current device easily
- (void)logDevice:(TSSDeviceID)inputDevice; 

///convenience function to create a proper NSDictionary from its raw string representation, also probably belongs in TSSCommon
- (id)dictionaryFromString:(NSString *)theString;
///convenience function that may be better suited to be in TSSCommon, converts a proper NSDictionary to raw string representant
- (NSString *)stringFromDictionary:(id)theDict;

///synchronously recieve a blob from cydia
- (NSString *)_synchronousCydiaReceiveVersion:(NSString *)theVersion;
///synchronously push a blob to cydia
- (NSString *)_synchronousPushBlob:(NSString *)theBlob;
///synchronously receieve a blob from apple
- (NSString *)_synchronousReceiveVersion:(NSString *)theVersion;
///synchronously check for a blob listing
- (NSArray *)_synchronousBlobCheck;

///the post request to fetch the list of blobs that are already saved on sauriks server
- (NSMutableURLRequest *)requestForList;
///post request to push a blob
- (NSMutableURLRequest *)requestForBlob:(NSString *)theBlob;
///post request to fetch a blob
- (NSMutableURLRequest *)postRequestFromVersion:(NSString *)theVersion;
///used in postRequestFromVersion, grab the build manifest that is associated with this particular version from our plist online
- (NSDictionary *)tssDictFromVersion:(NSString *)versionNumber;
///the init method that is always used to instantiate this class.
- (id)initWithMode:(int)theMode;


@end


