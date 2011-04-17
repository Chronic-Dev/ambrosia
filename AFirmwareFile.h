//
//  AFirmwareFile.h
//  ambrosia
//
//  Created by Kevin Bradley on 4/14/11.
//  Copyright 2011 Chronic-Dev Team. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "ACommon.h"

enum {
	
	kAFlashFWType,
	kADFUFWType,
	kAFileSystemType,
	kARamdiskType,
	kAKernelType,
	kPlistType,
	kUndefinedType,
	
};


@interface AFirmwareFile : NSObject {

	NSString *file;
	NSString *keyBag;
	NSString *IV;
	NSString *key;
	NSString *decryptionKey; //doesn't always apply
	BOOL encrypted;
	int fileType;
}

@property (nonatomic, retain) NSString *file;
@property (nonatomic, retain) NSString *key;
@property (nonatomic, retain) NSString *IV;
@property (nonatomic, retain) NSString *keyBag;
@property (nonatomic, retain) NSString *decryptionKey;
@property (readwrite, assign) BOOL encrypted;
@property (readwrite, assign) int fileType;

- (id)initWithFile:(NSString *)theFile;
-(BOOL)grabKeybag;


@end
