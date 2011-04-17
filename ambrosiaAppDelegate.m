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
		//DebugLog(@"unzipFinished: %@", a);
		//DebugLog(@"currentFirmware: %@", currentFirmware);
		//NSDictionary *restoreDict = [currentFirmware restoreDictionary];
		//DebugLog(@"restoreDict; %@", restoreDict);
		//DebugLog(@"system restore image; %@", [currentFirmware systemRestoreImage]);
		//DebugLog(@"ramdisk ; %@", [currentFirmware RestoreRamDisk]);
		//DebugLog(@"RestoreKernelCache: %@", [currentFirmware LLB]);
	DebugLog(@"platform: %@", [currentFirmware platform]);
	AFirmwareFile *restoreRD = [[AFirmwareFile alloc] initWithFile:[currentFirmware RestoreRamDisk]];
	NSString *outputFile = [[currentFirmware RestoreRamDisk] stringByDeletingPathExtension];
	outputFile = [outputFile stringByAppendingString:@"_patched.dmg"];
	if ([restoreRD encrypted] == TRUE)
	{
		NSLog(@"ramdisk is encrypted... finding kbag\n");
		
		NSString *kbag = [restoreRD keyBag];
		
		NSLog(@"decrypting keybag....\n");
		
		NSDictionary *decryptedKbag = [ACommon decryptedKbag:kbag];
		
		NSLog(@"decrypting: %@\n", [currentFirmware RestoreRamDisk]);
		
		
		
		[ACommon decryptRamdisk:[currentFirmware RestoreRamDisk] toPath:outputFile withIV:[decryptedKbag valueForKey:@"iv"] key:[decryptedKbag valueForKey:@"k"]];
	} else {
			//DebugLog(@"ivkDict: %@", decryptedKbag);

		DebugLog(@"no kbag! no encryption on ramdisk.\n");
		[ACommon decryptRamdisk:[currentFirmware RestoreRamDisk] toPath:outputFile withIV:nil key:nil];
	}
	
	

	NSLog(@"generating vfdecrypt key...\n");
	
	NSString *vfDecryptKey = [ACommon genpassFromRamdisk:outputFile platform:[currentFirmware platform] andFilesystem:[currentFirmware OS]];
	vfDecryptKey = [vfDecryptKey stringByReplacingOccurrencesOfString:@"\n" withString:@""];
	vfDecryptKey = [vfDecryptKey substringFromIndex:14];
		vfDecryptKey = [vfDecryptKey cleanedString];

		NSLog(@"vfdecrypt key: %@\n", vfDecryptKey);
	if (vfDecryptKey != nil)
	{
		NSLog(@"decrypting filesystem: %@\n", [currentFirmware OS]);
		NSString *decrypted = [ACommon decryptFilesystem:[currentFirmware OS] withKey:vfDecryptKey];
		NSString *mountedVolume = [ACommon mountImage:decrypted];
		NSLog(@"mounted?: %@", mountedVolume);
		if (mountedVolume == nil)
		{
			NSLog(@"invalid vfdecrypt key, trying to generate from update ramdisk!");
			[FM removeItemAtPath:decrypted error:nil];
			NSString *updateRamdisk = [currentFirmware UpdateRamDisk];
			if (updateRamdisk != nil)
			{
				//must've been a bad vfdecrypt key, lets try the other ramdisk (hoping there is one)
				DebugLog(@"huzzah! there is an update ramdisk! %@ lets hope we have better luck with it!!", updateRamdisk);
				AFirmwareFile *urd = [[AFirmwareFile alloc] initWithFile:updateRamdisk];
				NSString *outputFile2 = [[currentFirmware UpdateRamDisk] stringByDeletingPathExtension];
				outputFile2 = [outputFile2 stringByAppendingString:@"_patched.dmg"];
				if ([urd encrypted] == TRUE)
				{
					
					NSLog(@"ramdisk is encrypted... finding kbag");
				
					NSString *kbag2 = [urd keyBag];
					
					NSLog(@"decrypting keybag....");
		
					
					NSDictionary *decryptedKbag2 = [ACommon decryptedKbag:kbag2];
					
					NSLog(@"decrypting: %@", [currentFirmware UpdateRamDisk]);
					
					[ACommon decryptRamdisk:[currentFirmware UpdateRamDisk] toPath:outputFile2 withIV:[decryptedKbag2 valueForKey:@"iv"] key:[decryptedKbag2 valueForKey:@"k"]];
				} else {
						//DebugLog(@"ivkDict: %@", decryptedKbag);
					
					DebugLog(@"no kbag! no encryption on ramdisk.");
					[ACommon decryptRamdisk:[currentFirmware UpdateRamDisk] toPath:outputFile2 withIV:nil key:nil];
					
				}
				
				NSLog(@"generating vfdecrypt key (take two)...");
				
				NSString *vfDecryptKey2 = [ACommon genpassFromRamdisk:outputFile2 platform:[currentFirmware platform] andFilesystem:[currentFirmware OS]];
				vfDecryptKey2 = [vfDecryptKey2 stringByReplacingOccurrencesOfString:@"\n" withString:@""];
				vfDecryptKey2 = [vfDecryptKey2 substringFromIndex:14];
				vfDecryptKey2 = [vfDecryptKey2 cleanedString];
				DebugLog(@"vfdecrypt key take 2: %@", vfDecryptKey2);
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
