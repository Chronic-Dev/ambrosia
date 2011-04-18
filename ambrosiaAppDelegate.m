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

@synthesize window, currentFirmware, ipswButton, pois0nButton, poisoning;

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

/*
 
 return [NSArray arrayWithObjects:@"AppleLogo", @"BatteryCharging", @"BatteryCharging0", @"BatteryCharging1", @"BatteryFull", @"BatteryLow", @"BatteryLow0", @"BatteryLow1", @"BatteryPlugin", @"DeviceTree", @"KernelCache", @"LLB", @"OS", @"RecoveryMode", @"RestoreDeviceTree", @"RestoreKernelCache", @"RestoreLogo", @"RestoreRamDisk", @"UpdateRamDisk", @"iBEC", @"iBSS", @"iBoot", nil];
 
 */



- (NSDictionary *)sendKbagArray:(NSArray *)kbagArray
{
	NSLog(@"processing kbag array...");
	NSString *logPath = [NSHomeDirectory() stringByAppendingPathComponent:@"Library/Logs/AMBROSIA_Keys.log"];
	[FM removeItemAtPath:logPath error:nil];
	FILE* file = freopen([logPath fileSystemRepresentation], "a", stdout);
	
	irecv_error_t error = 0;
	irecv_init();
	irecv_client_t client = NULL;
	if (irecv_open(&client) != IRECV_E_SUCCESS)
	{
		NSLog(@"fail!");
		return nil;
		
	}
	
	irecv_set_configuration(client, 1);
	
	irecv_set_interface(client, 0, 0);
	irecv_set_interface(client, 1, 1);
	error = irecv_receive(client);
	
	
	NSEnumerator *kbagEnum = [kbagArray objectEnumerator];
	id theObject = nil;
	while (theObject = [kbagEnum nextObject]) {
		
		NSString *newObject = [NSString stringWithFormat:@"go aes dec %@", theObject];
		error = irecv_send_command(client, [newObject UTF8String]);
	}
		
	error = irecv_receive(client);
	irecv_close(client);
	irecv_exit();
	fclose(file);
	
	NSString *keyLog = [NSString stringWithContentsOfFile:logPath encoding:NSASCIIStringEncoding error:nil];
	keyLog = [keyLog stringByReplacingOccurrencesOfString:@"\0" withString:@""];
	DebugLog(@"AMBROSIA_Keys.log: %@", keyLog);
	
	NSArray *rawkeyArray = [keyLog componentsSeparatedByString:@"\n"];
	
	DebugLog(@"line count: %i", [rawkeyArray count]);
	
	int currentIndex = 0;
	
	int lineCount = [rawkeyArray count];
	
	if (lineCount < 15)
	{
		NSLog(@"need to repois0n!!");
		return nil;
	}
	
	if (lineCount > 16)
	{
		
		currentIndex = lineCount - 16;
		DebugLog(@"initial run!! currentIndex: %i",currentIndex);
		
	}
	
	NSArray *keyArray = [currentFirmware keyArray];
	DebugLog(@"keyArray count: %i", [keyArray count]);
	
	NSMutableDictionary *keys = [[NSMutableDictionary alloc] init];
	
	NSEnumerator *theEnum = [keyArray objectEnumerator];
	id currentKey = nil;

	while (currentKey = [theEnum nextObject])
	{
		NSString *keyLine = [rawkeyArray objectAtIndex:currentIndex];
		NSArray *keyComponents = [keyLine componentsSeparatedByString:@" "];
		DebugLog(@"keyComponents count: %i", [keyComponents count]);
		if ([keyComponents count] == 4)
		{
			NSString *iv = [keyComponents objectAtIndex:1];
			
			NSString *k = [keyComponents objectAtIndex:3];
			
			k = [k stringByReplacingOccurrencesOfString:@"\n" withString:@""];
			
			k = [k cleanedString];
			
			DebugLog(@"klength: %i", [k length]);
			
			
			
			NSString *currentDict = [NSDictionary dictionaryWithObjectsAndKeys:iv, @"iv", k, @"k", nil];
			DebugLog(@"currentDict: %@", currentDict);
			if ([k length] > 0)
			{
				[keys setObject:currentDict forKey:currentKey];
			}
			
			
		} else {
			DebugLog(@"item not encrypted?: %@", currentKey);
		}
		currentIndex++;
		
	}
	
	
	return [keys autorelease];
	

}


- (IBAction)sendCommand:(id)sender
{
	

	NSString *logPath = [NSHomeDirectory() stringByAppendingPathComponent:@"Library/Logs/SP_Keys.log"];
	[FM removeItemAtPath:logPath error:nil];
	FILE* file = freopen([logPath fileSystemRepresentation], "a", stdout);

	irecv_error_t error = 0;
	irecv_init();
	irecv_client_t client = NULL;
	if (irecv_open(&client) != IRECV_E_SUCCESS)
	{
		NSLog(@"fail!");
		return;
		
	}
	
		
	irecv_set_configuration(client, 1);

	irecv_set_interface(client, 0, 0);
	irecv_set_interface(client, 1, 1);
	error = irecv_receive(client);
	
	
	NSEnumerator *kbagEnum = [[self kbagArray] objectEnumerator];
	id theObject = nil;
	while (theObject = [kbagEnum nextObject]) {
		
		NSString *newObject = [NSString stringWithFormat:@"go aes dec %@", theObject];
		error = irecv_send_command(client, [newObject UTF8String]);
	}
	
	
	
	
	
	error = irecv_receive(client);
	
	irecv_close(client);
	irecv_exit();
	
	fclose(file);
	
	
	NSString *me = [NSString stringWithContentsOfFile:logPath encoding:NSASCIIStringEncoding error:nil];
	me = [me stringByReplacingOccurrencesOfString:@"\0" withString:@""];
	NSLog(@"ME: %@", me);
	
	
	
	
	
	
}

- (void)setDownloadText:(NSString *)downloadText
{
	NSLog(@"%@", downloadText);
}

- (void)setInstructionText:(NSString *)downloadText
{
	NSLog(@"%@", downloadText);
	
}

- (void)hideProgress
{
	[pois0nButton setEnabled:TRUE];
	[ipswButton setEnabled:TRUE];
}

- (void)killiTunes
{
	
}

- (void)showProgress
{
	[pois0nButton setEnabled:FALSE];
	[ipswButton setEnabled:FALSE];
	
}

- (void)setDownloadProgress:(double)theProgress
{
	
}

void print_progress(double progress, void* data) {
	int i = 0;
	if(progress < 0) {
		return;
	}
	
	if(progress > 100) {
		progress = 100;
	}
	[data setDownloadProgress:progress];
	printf("\r[");
	for(i = 0; i < 50; i++) {
		if(i < progress / 2) {
			printf("=");
		} else {
			printf(" ");
		}
	}
	
	printf("] %3.1f%%", progress);
	if(progress == 100) {
		printf("\n");
	}
}



- (int)inject
{
	NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
	
	[self killiTunes];
	self.poisoning = TRUE;
	[self showProgress];
	
	int result = 0;
	
	irecv_error_t ir_error = IRECV_E_SUCCESS;
	
	pois0n_init();
	pois0n_set_callback(&print_progress, self);
	
	
	[self setDownloadText:NSLocalizedString(@"Waiting for device to enter DFU mode...", @"Waiting for device to enter DFU mode...")];
	[self setInstructionText:NSLocalizedString(@"Connect USB then press and hold MENU and PLAY/PAUSE for 7 seconds.", @"Connect USB then press and hold MENU and PLAY/PAUSE for 7 seconds.")];
		//[instructionImage setImage:[self imageForMode:kSPATVRestoreImage]];

	
	while(pois0n_is_ready()) {
		sleep(1);
	}
	irecv_event_subscribe(client, IRECV_RECEIVED, &print_progress, NULL);
	
	[self setDownloadText:NSLocalizedString(@"Found device in DFU mode", @"Found device in DFU mode")];
	[self setInstructionText:@""];
	
	result = pois0n_is_compatible();
	if (result < 0) {
		[self setDownloadText:NSLocalizedString(@"Your device is not compatible with this exploit!", @"Your device is not compatible with this exploit!")];
		return result;
	}
	[self setDownloadText:NSLocalizedString(@"Injecting Pois0n", @"Injecting Pois0n")];
	result = pois0n_inject();
	if (result < 0) {
		[self setDownloadText:NSLocalizedString(@"Exploit injection failed!", @"Exploit injection failed!")];
		[self hideProgress];
		pois0n_exit();
		self.poisoning = FALSE;
		[pool release];
		return result;
	}
	[self setDownloadText:@"pois0n successfully administered"];
		//NSString *command = [commandTextField stringValue];
		//irecv_send_command(client, [command UTF8String]);
	[self hideProgress];
		//[cancelButton setTitle:@"Done"];
		//[instructionImage setImage:[self imageForMode:kSPSuccessImage]];
	pois0n_exit();
	self.poisoning = FALSE;
	[pool release];
	return 0;
}

- (IBAction)poison:(id)sender
{

	[NSThread detachNewThreadSelector:@selector(inject) toTarget:self withObject:nil];
}

- (void)unzipFinished:(NSNotification *)a
{
	DebugLog(@"unzipFinished: %@", a);

	[currentFirmware setBuildIdentity];
	
	DebugLog(@"platform: %@", [currentFirmware platform]);
	
	
	NSArray *kbagArray = [currentFirmware kbagArray];
	
	DebugLog(@"KbagArray: %@", kbagArray);
	
	if ([kbagArray count] > 1)
	{
		id keysDict = [self sendKbagArray:kbagArray];
		DebugLog(@"keysDict: %@", keysDict);
		
		NSString *firmwarePlist = [currentFirmware plistPath];
		NSLog(@"%@", firmwarePlist);
		
		NSString *vfDecryptKey = [ACommon decryptFilesystemFromFirmware:currentFirmware];
		[keysDict setValue:vfDecryptKey forKey:@"vfdecrypt"];
		if (keysDict != nil)
		{
			[keysDict writeToFile:firmwarePlist atomically:YES];
			[[NSWorkspace sharedWorkspace] openFile:firmwarePlist];
			NSString *convertForWiki = [currentFirmware convertForWiki];
				//NSLog(@"convertForWiki: %@", convertForWiki);			
			NSString *wikiPath = [currentFirmware wikiPath];
			[convertForWiki writeToFile:wikiPath atomically:YES];
			[[NSWorkspace sharedWorkspace] openFile:wikiPath];
		}
		
	}
	[currentFirmware release];
	
	/*
	NSString *outputFile = [[currentFirmware RestoreRamDisk] stringByDeletingPathExtension];
	outputFile = [outputFile stringByAppendingString:@"_patched.dmg"];
	if ([restoreRD encrypted] == TRUE)
	{
		NSLog(@"ramdisk is encrypted... finding kbag\n");
		
		NSString *kbag = [restoreRD keyBag];
		
		NSLog(@"decrypting keybag....\n");
		
		NSDictionary *decryptedKbag = [ACommon decryptedKbag:kbag];
		
		if (decryptedKbag == nil)
		{
			NSLog(@"FAIL!!!");
			[self startOverMan];
			return;
		}
		
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
	 */
	
	[self startOverMan];
}

- (void)startOverMan
{
	[[NSNotificationCenter defaultCenter] removeObserver:self];
	[ipswButton setEnabled:TRUE];
}

@end
