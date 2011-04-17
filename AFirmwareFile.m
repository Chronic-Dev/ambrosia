//
//  AFirmwareFile.m
//  ambrosia
//
//  Created by Kevin Bradley on 4/14/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "AFirmwareFile.h"


@implementation AFirmwareFile

@synthesize IV, key, keyBag, fileType, decryptionKey, file, encrypted;

- (id)initWithFile:(NSString *)theFile
{
	if(self = [super init]) {

		file = theFile;
		encrypted = [self grabKeybag];
	}
	
	return self;
}



-(BOOL)grabKeybag
{
	NSString *kbagProcess = [NSString stringWithFormat:@"\"%@\" \"%@\"", GRABKBAG, self.file];
		//	NSLog(@"grabKeybag: %@", kbagProcess);
	NSString *returnString = [ACommon singleLineReturnForProcess:kbagProcess];
	if (returnString != nil)
	{
		NSLog(@"%@ has keybag: %@", [file lastPathComponent], returnString);
		keyBag = returnString;
		return TRUE;
	}
	
	NSLog(@"%@ not encrypted!", file);
	return FALSE;
	
}


-(void)dealloc
{
	[IV release];
	[key release];
	[keyBag release];
	[decryptionKey release];
	IV = nil;
	key = nil;
	keyBag = nil;
	decryptionKey = nil;
	[super dealloc];
}

@end
