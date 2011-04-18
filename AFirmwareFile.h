//
//  AFirmwareFile.h
//  ambrosia
//
//  Created by Kevin Bradley on 4/14/11.
//  Copyright 2011 Chronic-Dev Team. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "ACommon.h"


@interface AFirmwareFile : NSObject {

	NSString *file;
	NSString *keyBag;
	BOOL encrypted;
}

@property (nonatomic, retain) NSString *file;
@property (nonatomic, retain) NSString *keyBag;
@property (readwrite, assign) BOOL encrypted;

- (id)initWithFile:(NSString *)theFile;
-(BOOL)grabKeybag;


@end
