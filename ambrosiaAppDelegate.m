//
//  ambrosiaAppDelegate.m
//  ambrosia
//
//  Created by Kevin Bradley on 4/14/11.
//  Copyright 2011 Chronic-Dev Team. All rights reserved.
//

#import "ambrosiaAppDelegate.h"

@interface NSString (specialAdditions)


-(NSString *)cleanedString;


@end

@implementation NSString (specialAdditions) //this is why we need MSHookIvar to

-(NSString *)cleanedString
{
	NSString *current = self;
	NSCharacterSet *cleanliness = [NSCharacterSet characterSetWithCharactersInString:@"\0\t\n "];
	current = [[current stringByTrimmingCharactersInSet:cleanliness] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
	return current;
}


@end

@implementation ambrosiaAppDelegate 

@synthesize window, currentFirmware, ipswButton;

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
	// Insert code here to initialize your application 
}


	//@"7F8651BF1E81548A719A94BFF92C9A01980A3F3EDF0BED5D3F70D5BF266C92F37A3F0D817A434B04E693D94AB619B23F"
- (NSDictionary *)decryptedKbag:(NSString *)theKbag
{
		//NSArray *ivK = [ACommon runHelper:theKbag];

	NSArray *ivK = [ACommon runHelper:theKbag];

	
	if ([[ivK objectAtIndex:0] isEqualToString:@"TRY_AGAIN"])
	{
		ivK = [ACommon runHelper:theKbag];
	}
	
		//NSLog(@"ivK: %@", ivK);
	if ([ivK count] == 0)
		
		return nil;
	
		//NSLog(@"ivk: %@", ivK);
	NSString *k = [ivK objectAtIndex:3];
	NSString *iv = [ivK objectAtIndex:1];

	NSCharacterSet *theSet = [NSCharacterSet characterSetWithCharactersInString:@"\0\n "];
	k = [k stringByTrimmingCharactersInSet:theSet];
//	char test_buffer[64];
//	strcpy( test_buffer, [k UTF8String] );
//	char *myChar = trim(test_buffer);
//	NSString *myString = [NSString stringWithUTF8String:myChar];
	k = [k stringByReplacingOccurrencesOfString:@"\0" withString:@""];
	k = [k stringByReplacingOccurrencesOfString:@"  " withString:@""];
	k = [k stringByReplacingOccurrencesOfString:@"\n" withString:@""];
		//NSString *kTrim = [k substringWithRange:NSMakeRange(0, 96)];
	
	
	iv = [iv stringByReplacingOccurrencesOfString:@"\0" withString:@""];
	iv = [iv stringByReplacingOccurrencesOfString:@"  " withString:@""];
	
		//NSLog(@"iv: %@", iv);
	
	NSDictionary *ivKDict = [NSDictionary dictionaryWithObjectsAndKeys:iv, @"iv", k, @"k", nil];
		//	NSLog(@"ivkDict: %@", ivKDict);
		//NSString *dict = [[NSHomeDirectory() stringByAppendingPathComponent:theKbag] stringByAppendingPathExtension:@"plist"];
		//[ivKDict writeToFile:dict atomically:YES];
	return ivKDict;
	
}

- (IBAction)testRun:(id)sender
{
	[sender setEnabled:FALSE];
	NSOpenPanel *op = [NSOpenPanel openPanel];
	[op runModalForTypes:[NSArray arrayWithObject:@"ipsw"]];
	NSString *theFile = [op filename];
	
		//NSString *theFile = [NSHomeDirectory() stringByAppendingPathComponent:@"Downloads/iPhone3,1_4.3.2_8H7_Restore/kernelcache.release.k48"];
		//NSString *theFile = [NSHomeDirectory() stringByAppendingPathComponent:@"Desktop/AppleTV2,1_4.3_8F202_Restore.ipsw"];
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(unzipFinished:) name:@"unzipComplete" object:nil];
	currentFirmware = [[AFirmware alloc] initWithFile:theFile];
	

	
		
}

- (void)dealloc
{
	[currentFirmware release];
	[super dealloc];
}



- (void)unzipFinished:(NSNotification *)a
{
		//NSLog(@"unzipFinished: %@", a);
		//NSLog(@"currentFirmware: %@", currentFirmware);
		//NSDictionary *restoreDict = [currentFirmware restoreDictionary];
		//NSLog(@"restoreDict; %@", restoreDict);
		//NSLog(@"system restore image; %@", [currentFirmware systemRestoreImage]);
		//NSLog(@"ramdisk ; %@", [currentFirmware RestoreRamDisk]);
		//NSLog(@"RestoreKernelCache: %@", [currentFirmware LLB]);
	NSLog(@"platform: %@", [currentFirmware platform]);
	AFirmwareFile *kernelTest = [[AFirmwareFile alloc] initWithFile:[currentFirmware RestoreRamDisk]];
	NSString *outputFile = [[currentFirmware RestoreRamDisk] stringByDeletingPathExtension];
	outputFile = [outputFile stringByAppendingString:@"_patched.dmg"];
	if ([kernelTest encrypted] == TRUE)
	{
		NSString *kbag = [kernelTest keyBag];
		
			//for now release the kernelTest file, in the future we are going to want to catalog these for reference on kbags and iv/k
		
			//[kernelTest release];
		
		NSDictionary *decryptedKbag = [self decryptedKbag:kbag];
		
		
		[ACommon decryptRamdisk:[currentFirmware RestoreRamDisk] toPath:outputFile withIV:[decryptedKbag valueForKey:@"iv"] key:[decryptedKbag valueForKey:@"k"]];
	} else {
			//NSLog(@"ivkDict: %@", decryptedKbag);

		NSLog(@"null decryptedKbag");
		[ACommon decryptRamdisk:[currentFirmware RestoreRamDisk] toPath:outputFile withIV:nil key:nil];
	}
	
	

	
	
	NSString *vfDecryptKey = [ACommon genpassFromRamdisk:outputFile platform:[currentFirmware platform] andFilesystem:[currentFirmware OS]];
	vfDecryptKey = [vfDecryptKey stringByReplacingOccurrencesOfString:@"\n" withString:@""];
	vfDecryptKey = [vfDecryptKey substringFromIndex:14];
		vfDecryptKey = [vfDecryptKey cleanedString];
		//vfDecryptKey = [vfDecryptKey stringByReplacingOccurrencesOfString:@"\0" withString:@""];
		//vfDecryptKey = [vfDecryptKey stringByReplacingOccurrencesOfString:@"\n" withString:@""];
		//vfDecryptKey = [vfDecryptKey stringByReplacingOccurrencesOfString:@" " withString:@""];
		NSLog(@"vfdecrypt key: %@", vfDecryptKey);
	if (vfDecryptKey != nil)
	{
		NSString *decrypted = [ACommon decryptFilesystem:[currentFirmware OS] withKey:vfDecryptKey];
		NSString *mountedVolume = [ACommon mountImage:decrypted];
		
		if (mountedVolume == nil)
		{
			NSLog(@"invalid vfdecrypt key, trying to generate from update ramdisk!");
			[FM removeItemAtPath:decrypted error:nil];
			NSString *updateRamdisk = [currentFirmware UpdateRamDisk];
			if (updateRamdisk != nil)
			{
				//must've been a bad vfdecrypt key, lets try the other ramdisk (hoping there is one)
				NSLog(@"huzzah! there is an update ramdisk! %@ lets hope we have better luck with it!!", updateRamdisk);
				AFirmwareFile *urd = [[AFirmwareFile alloc] initWithFile:updateRamdisk];
				NSString *outputFile2 = [[currentFirmware UpdateRamDisk] stringByDeletingPathExtension];
				outputFile2 = [outputFile2 stringByAppendingString:@"_patched.dmg"];
				if ([urd encrypted] == TRUE)
				{
					NSString *kbag2 = [urd keyBag];
					
						//for now release the kernelTest file, in the future we are going to want to catalog these for reference on kbags and iv/k
					
						//	[urd release];
					
					NSDictionary *decryptedKbag2 = [self decryptedKbag:kbag2];
					
					
					[ACommon decryptRamdisk:[currentFirmware UpdateRamDisk] toPath:outputFile2 withIV:[decryptedKbag2 valueForKey:@"iv"] key:[decryptedKbag2 valueForKey:@"k"]];
				} else {
						//NSLog(@"ivkDict: %@", decryptedKbag);
					
					NSLog(@"null decryptedKbag");
					[ACommon decryptRamdisk:[currentFirmware UpdateRamDisk] toPath:outputFile2 withIV:nil key:nil];
					
				}
				
				NSString *vfDecryptKey2 = [ACommon genpassFromRamdisk:outputFile2 platform:[currentFirmware platform] andFilesystem:[currentFirmware OS]];
				vfDecryptKey2 = [vfDecryptKey2 stringByReplacingOccurrencesOfString:@"\n" withString:@""];
				vfDecryptKey2 = [vfDecryptKey2 substringFromIndex:14];
				vfDecryptKey2 = [vfDecryptKey2 cleanedString];
				NSLog(@"vfdecrypt key take 2: %@", vfDecryptKey2);
				if (vfDecryptKey2 != nil)
				{
					NSString *decrypted2 = [ACommon decryptFilesystem:[currentFirmware OS] withKey:vfDecryptKey2];
					NSString *mountedVolume2 = [ACommon mountImage:decrypted2];
					NSLog(@"mounted?: %@", mountedVolume2);
				}
				
			}
				
		}
	}
	
	[[NSNotificationCenter defaultCenter] removeObserver:self];
	[ipswButton setEnabled:TRUE];
}

@end
