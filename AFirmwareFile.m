//
//  AFirmwareFile.m
//  ambrosia
//
//  Created by Kevin Bradley on 4/14/11.
//  Copyright 2011 Chronic-Dev Team. All rights reserved.
//

#import "AFirmwareFile.h"


@implementation AFirmwareFile

@synthesize keyBag, file, encrypted;

- (id)initWithFile:(NSString *)theFile
{
	if(self = [super init]) {

		DebugLog(@"initWithFile: %@", theFile);
		file = theFile;

		encrypted = [self grabKeybag];
		//if (encrypted == TRUE)
//		{
//			NSDictionary *kbagDict = [ACommon decryptedKbag:keyBag];
//			IV = [kbagDict valueForKey:@"iv"];
//			key = [kbagDict valueForKey:@"k"];
//		}
	}
	
	return self;
}



-(BOOL)grabKeybag
{
	NSString *kbagProcess = [NSString stringWithFormat:@"\"%@\" \"%@\"", GRABKBAG, self.file];
		//	DebugLog(@"grabKeybag: %@", kbagProcess);
	NSString *returnString = [ACommon singleLineReturnForProcess:kbagProcess];
	if (returnString != nil)
	{
		DebugLog(@"%@ has keybag: %@", [file lastPathComponent], returnString);
		keyBag = returnString;
		return TRUE;
	}
	
	DebugLog(@"%@ not encrypted!", file);
	return FALSE;
	
}


-(void)dealloc
{
		//[file release];
		//[keyBag release];

	[super dealloc];
}

@end
