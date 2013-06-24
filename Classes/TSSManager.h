//
//  TSSManager.h
//  TSSAgent
//
//  Created by Kevin Bradley on 1/16/12.
//  Copyright 2012 nito, LLC. All rights reserved.
//

/**
 
 This class manages all the web requests to fetch, push and process blobs from sauriks servier, apples server and the server where we maintain 
 the different buildManifest information and the firmware versions apple is currently signing.
 
 */

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


///struct modeled after CGRects for creation and comparison of different device models

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
@property (nonatomic, assign) NSString *baseUrlString; ///the baseurl string that is modified as needed for post/get requests
@property (nonatomic, assign) NSString *ecid; ///the current devices ecid, is kind of redudant vs static _chipID so will probably get pruned in the future.

///the response string typically has information delimited by ampersands and at the end there is the raw plist data, this returns just the raw blob data
+ (NSString *)rawBlobFromResponse:(NSString *)inputString;
///the current device we are running on, in an easy to use struct for constructing our plist responses
+ (TSSDeviceID)currentDevice;
///the versions apple is currently signing
+ (NSArray *)signableVersions;
///current user IP address
+ (NSString *)ipAddress; 

///debug method to log out the current device easily
- (void)logDevice:(TSSDeviceID)inputDevice; 

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

+ (NSArray *)buildManifestList;


@end


