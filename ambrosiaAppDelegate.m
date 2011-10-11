//
//  ambrosiaAppDelegate.m
//  ambrosia
//
//  Created by Kevin Bradley on 4/14/11.
//  Copyright 2011 Chronic-Dev Team. All rights reserved.
//

#import "ambrosiaAppDelegate.h"


@implementation NSString (specialAdditions) //this is why we need MSHookIvar to

-(NSString *)cleanedString
{
	NSString *current = self;
	NSCharacterSet *cleanliness = [NSCharacterSet characterSetWithCharactersInString:@"\0\t\n "];
	current = [[current stringByTrimmingCharactersInSet:cleanliness] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
	return current;
}


-(NSString *)decryptedPath
{
	NSString *current = self;
	NSString *extension = [current pathExtension];
	return [[[current stringByDeletingPathExtension] stringByAppendingString:@"_abdec"] stringByAppendingPathExtension:extension];
}


@end

@implementation ambrosiaAppDelegate 


@synthesize window, currentFirmware, ipswButton, pois0nButton, poisoning, downloadBar, downloadProgressField, instructionImage, instructionField ;

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
	// Insert code here to initialize your application 
	
	[[NSDistributedNotificationCenter defaultCenter] addObserver:self selector:@selector(statusChanged:) name:@"statusChanged" object:nil];
	[[NSDistributedNotificationCenter defaultCenter] addObserver:self selector:@selector(updateCF:) name:@"updateCF" object:nil];
}


	//@"7F8651BF1E81548A719A94BFF92C9A01980A3F3EDF0BED5D3F70D5BF266C92F37A3F0D817A434B04E693D94AB619B23F"



- (void)setDownloadProgress:(double)theProgress
{
	
	if (theProgress == 0)
	{
		[downloadBar setIndeterminate:TRUE];
		[downloadBar setHidden:FALSE];
		[downloadBar setNeedsDisplay:YES];
		[downloadBar setUsesThreadedAnimation:YES];
		[downloadBar startAnimation:self];
		return;
	}
	[downloadBar setIndeterminate:FALSE];
	[downloadBar startAnimation:self];
	[downloadBar setHidden:FALSE];
	[downloadBar setNeedsDisplay:YES];
	[downloadBar setDoubleValue:theProgress];
}


- (void)setInstructionText:(NSString *)instructions
{
	[instructionField setStringValue:instructions];
	[instructionField setNeedsDisplay:YES];
}

- (void)setDownloadText:(NSString *)downloadString
{
	
		//NSLog(@"setDownlodText:%@", downloadString);
	[downloadProgressField setStringValue:downloadString];
	[downloadProgressField setNeedsDisplay:YES];
}


- (IBAction)testRun:(id)sender
{
		//[self sendCommand:self];
		//return;
	[sender setEnabled:FALSE];
	NSOpenPanel *op = [NSOpenPanel openPanel];
	[op runModalForTypes:[NSArray arrayWithObject:@"ipsw"]];
	NSString *theFile = [op filename];
	

	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(unzipFinished:) name:@"unzipComplete" object:nil];
	currentFirmware = [[AFirmware alloc] initWithFile:theFile];
	[self setDownloadText:@"Unzipping ipsw...."];
	[self showProgress];
	

	
		
}

- (void)dealloc
{
	[[NSDistributedNotificationCenter defaultCenter] removeObserver:self];
		//[[NSNotificationCenter defaultCenter] removeObserver:self];
	[currentFirmware release];
	[super dealloc];
}

/*
 
 return [NSArray arrayWithObjects:@"AppleLogo", @"BatteryCharging", @"BatteryCharging0", @"BatteryCharging1", @"BatteryFull", @"BatteryLow", @"BatteryLow0", @"BatteryLow1", @"BatteryPlugin", @"DeviceTree", @"KernelCache", @"LLB", @"OS", @"RecoveryMode", @"RestoreDeviceTree", @"RestoreKernelCache", @"RestoreLogo", @"RestoreRamDisk", @"UpdateRamDisk", @"iBEC", @"iBSS", @"iBoot", nil];
 
 */

- (void)statusChanged:(NSNotification *)n
{
	id userI = [n userInfo];
	[self setDownloadText:[userI valueForKey:@"Status"]];
	
}

- (void)updateCF:(NSNotification *)n
{
	
	id userI = [n userInfo];
	NSLog(@"updateCF: %@",userI );
	[currentFirmware setMountVolume:[userI valueForKey:@"mountVolume"]];
	
	
}


- (NSDictionary *)sendKbagArray:(NSArray *)kbagArray
{
	NSLog(@"processing kbag array...");
	[self setDownloadText:(@"processing kbag array...")];
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
		//irecv_set_debug_level(20);
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
	int properIndex = 0;
	
	int lineCount = [rawkeyArray count];
	
	if (lineCount < 15)
	{
		NSLog(@"need to repois0n!!");
		[self setDownloadText:@"i can haz fail: need to repois0n!!"];
		return nil;
	}
	
	if (lineCount > 18)
	{
		
		currentIndex = lineCount - 17;
		DebugLog(@"initial run!! currentIndex: %i",currentIndex);
		
	}
	
	NSArray *keyArray = [currentFirmware keyArray];
	DebugLog(@"keyArray count: %i", [keyArray count]);
	
	NSMutableDictionary *keys = [[NSMutableDictionary alloc] init];
	
	NSEnumerator *theEnum = [keyArray objectEnumerator];
	id currentKey = nil;
	NSMutableArray *stragglers = [[NSMutableArray alloc] init];
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
			
			if ([k length] != 64)
			{
				[stragglers addObject:[NSDictionary dictionaryWithObjectsAndKeys:currentKey, @"key", [NSString stringWithFormat:@"%i", properIndex], @"index", [kbagArray objectAtIndex:properIndex], @"kbag", nil]];
				
			}
				//else {
//				
//				[keys setObject:[NSNull	null] forKey:currentKey];
//			}
			
			
		} else {
			DebugLog(@"item not encrypted?: %@", currentKey);
		}
		currentIndex++;
		properIndex++;
		
	}
	
		DebugLog(@"Stragglers: %@", stragglers);
	
	NSEnumerator *stragglerEnum = [stragglers objectEnumerator];
	id straggler = nil;
	while (straggler = [stragglerEnum nextObject]) {
	
		DebugLog(@"handling straggler: %@", straggler);
		NSString *currentKey = [straggler valueForKey:@"key"];
		NSString *kbag = [straggler valueForKey:@"kbag"];
		NSDictionary *keyDict = [ACommon decryptedKbag:kbag];
		DebugLog(@"new keydict: %@", keyDict);
		if (keyDict != nil)
		{
			[keys removeObjectForKey:currentKey];
			[keys setObject:keyDict forKey:currentKey];
			
		}
		
		
	}
	
	[stragglers release];
	stragglers = nil;
	return [keys autorelease];
	

}

- (NSArray *)kbagArray
{
	return [NSArray arrayWithObject:@"D6A180E9305953FCBC7A470B02170EB4C738A58FA29B54C9F1FA20DDDAC7BAF68D5CB5DAD6828D681323DBEFD309F237"];
	return nil; //deprecated, this was here from when i was testing how to interact with the iRecovery shell
}

- (IBAction)sendCommand:(id)sender //deprecated, this was here from when i was testing how to interact with the iRecovery shell, may find some other implementation in future here.
{
	

	NSString *logPath = [NSHomeDirectory() stringByAppendingPathComponent:@"Library/Logs/AMBROSIA_Keys.log"];
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
	
	NSString *output = [NSString stringWithContentsOfFile:logPath encoding:NSASCIIStringEncoding error:nil];
	output = [output stringByReplacingOccurrencesOfString:@"\0" withString:@""];
		NSLog(@"output: %@", output);
	
	
}



- (void)killiTunes
{
	
}



- (void)showProgress
{
	[pois0nButton setEnabled:FALSE];
	[ipswButton setEnabled:FALSE];
		//	self.processing = TRUE;
	[downloadBar startAnimation:self];
	[downloadBar setHidden:FALSE];
	[downloadBar setNeedsDisplay:TRUE];
	[self setDownloadProgress:0];
		
}

- (void)hideProgress
{
	[pois0nButton setEnabled:TRUE];
	[ipswButton setEnabled:TRUE];
		//self.processing = FALSE;
	[downloadBar stopAnimation:self];
	[downloadBar setHidden:YES];
	[downloadBar setNeedsDisplay:YES];

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
//	irecv_error_t error = 0;
//	irecv_init();
//	irecv_client_t client = NULL;
//	if (irecv_open(&client) != IRECV_E_SUCCESS)
//	{
//		NSLog(@"fail!");
//		return;
//		
//	}
//	
//	error = irecv_send_command(client, "setenv boot-args 2");
//	debug("%s\n", irecv_strerror(error));
//	
//	error = irecv_send_command(client, "saveenv");
//	debug("%s\n", irecv_strerror(error));
//	irecv_close(client);
//	irecv_exit();
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
		if (keysDict != nil)
		{
			[keysDict writeToFile:firmwarePlist atomically:YES];
		}
		NSDictionary *decDict = [ACommon decryptFilesystemFromFirmware:currentFirmware];
		
		NSString *vfDecryptKey = [decDict valueForKey:@"vfdecrypt"];
		NSString *mountVolume = [decDict valueForKey:@"mountVolume"];
		
		NSLog(@"mountVolume: %@", mountVolume);
		
		[keysDict setValue:vfDecryptKey forKey:@"vfdecrypt"];
		if (keysDict != nil)
		{
			[self setDownloadText:@"Creating fw plist..."];
			
			[keysDict setValue:[currentFirmware unzipLocation] forKey:@"unzipLocation"];
			[keysDict setValue:[NSNumber numberWithInt:[currentFirmware buildIdentity]] forKey:@"buildIdentity"];

			
			if (mountVolume != nil)
			{
				[keysDict setValue:kbagArray forKey:@"kbagArray"];
				[keysDict setValue:mountVolume forKey:@"mountVolume"];
				[currentFirmware setMountVolume:mountVolume];
				NSArray *staticCacheList = [ACommon dyldcacheContentsFromVolume:mountVolume];
				NSMutableArray *cacheList = [[NSMutableArray alloc] initWithArray:staticCacheList];
				[keysDict setValue:staticCacheList forKey:@"dyldcache"];
				DebugLog(@"cacheList: %@", cacheList);
				DebugLog(@"cacheListCount: %i", [cacheList count]);
				NSPredicate *pfPredicate = [NSPredicate predicateWithFormat:@"SELF BEGINSWITH[cd] '/System/Library/PrivateFrameworks'"];//
				[cacheList filterUsingPredicate:pfPredicate];
				DebugLog(@"Private Frameworks: %@", cacheList);
				DebugLog(@"Private Frameworks count: %i", [cacheList count]);
				
				[self setDownloadText:@"Dumping PrivateFrameworks Headers..."];
				[self processPFHeaders:cacheList fromCache:[ACommon dyldcacheFileFromVolume:mountVolume]];
				[cacheList removeAllObjects];
				[cacheList addObjectsFromArray:staticCacheList];
				
				NSPredicate *fPredicate = [NSPredicate predicateWithFormat:@"SELF BEGINSWITH[cd] '/System/Library/Frameworks'"];//
				[cacheList filterUsingPredicate:fPredicate];
				DebugLog(@"Frameworks: %@", cacheList);
				DebugLog(@"Frameworks count: %i", [cacheList count]);
				[self setDownloadText:@"Dumping Frameworks Headers..."];
				[self processFHeaders:cacheList fromCache:[ACommon dyldcacheFileFromVolume:mountVolume]];
				
					
				
				
			}
			
			
			[keysDict writeToFile:firmwarePlist atomically:YES];
			[[NSWorkspace sharedWorkspace] openFile:firmwarePlist];
			[self setDownloadText:@"Creating wiki text..."];
			NSString *convertForWiki = [currentFirmware convertForWiki];
				//NSLog(@"convertForWiki: %@", convertForWiki);			
			NSString *wikiPath = [currentFirmware wikiPath];
			[convertForWiki writeToFile:wikiPath atomically:YES encoding:NSUTF8StringEncoding error:nil];
			[[NSWorkspace sharedWorkspace] openFile:wikiPath];
			
			
			
		}
		
		
		
		/*
		 
		 ohhh yeh this needs some work, BUT it /SHOULD/ work!
		 
		 */
		
		[self setDownloadText:@"Decryping iBSS..."];
		
		[ACommon decryptRamdisk:[currentFirmware iBSS] toPath:[[currentFirmware iBSS] decryptedPath] withIV:[[[currentFirmware keyRepository] valueForKey:@"iBSS"] valueForKey:@"iv"] key:[[[currentFirmware keyRepository] valueForKey:@"iBSS"] valueForKey:@"k"]];
		
		[self setDownloadText:@"Decryping iBoot..."];
		
		[ACommon decryptRamdisk:[currentFirmware iBoot] toPath:[[currentFirmware iBoot] decryptedPath] withIV:[[[currentFirmware keyRepository] valueForKey:@"iBoot"] valueForKey:@"iv"] key:[[[currentFirmware keyRepository] valueForKey:@"iBoot"] valueForKey:@"k"]];
		
		[self setDownloadText:@"Decryping KernelCache..."];
		
		
		[ACommon decryptRamdisk:[currentFirmware KernelCache] toPath:[[currentFirmware KernelCache] decryptedPath] withIV:[[[currentFirmware keyRepository] valueForKey:@"KernelCache"] valueForKey:@"iv"] key:[[[currentFirmware keyRepository] valueForKey:@"KernelCache"] valueForKey:@"k"]];
		
		[self setDownloadText:@"Decryping LLB..."];
		
		[ACommon decryptRamdisk:[currentFirmware LLB] toPath:[[currentFirmware LLB] decryptedPath] withIV:[[[currentFirmware keyRepository] valueForKey:@"LLB"] valueForKey:@"iv"] key:[[[currentFirmware keyRepository] valueForKey:@"LLB"] valueForKey:@"k"]];
		
		[self setDownloadText:@"Decryping iBEC..."];
		
		[ACommon decryptRamdisk:[currentFirmware iBEC] toPath:[[currentFirmware iBEC] decryptedPath] withIV:[[[currentFirmware keyRepository] valueForKey:@"iBEC"] valueForKey:@"iv"] key:[[[currentFirmware keyRepository] valueForKey:@"iBEC"] valueForKey:@"k"]];
		
		[self setDownloadText:@"Creating PT/SP Bundle..."];
		
		NSString *infoBundle = [currentFirmware convertForBundle];
		[[NSWorkspace sharedWorkspace] openFile:infoBundle];
		
		
	}
	
	[self setDownloadText:@"Finished!!"];
	
		//iBSS, iBoot, kernelcache
	
	[currentFirmware release];
	
	[self hideProgress];
		
	[self startOverMan];
}

- (void)processPFHeaders:(NSArray *)cacheArray fromCache:(NSString *)dyldcacheFile

{
	NSEnumerator *frameworkEnum = [cacheArray objectEnumerator];
	id currentFramework = nil;
	while (currentFramework = [frameworkEnum nextObject]) {
		if (![[currentFramework pathExtension] isEqualToString:@"dylib"])
		{
			NSString *newName = [[[currentFirmware privateFrameworksPath] stringByAppendingPathComponent:[currentFramework lastPathComponent]] stringByAppendingPathExtension:@"framework/Headers/"];
			[FM createDirectoryAtPath:newName withIntermediateDirectories:YES attributes:nil error:nil];
			NSArray *taskArguments = [NSArray arrayWithObjects:@"-pabkkzARH", @"-o", newName, @"-d", dyldcacheFile, currentFramework, nil];
			[ACommon returnForTask:CDC withArguments:taskArguments];
		}
		
	}
}

- (void)processFHeaders:(NSArray *)cacheArray fromCache:(NSString *)dyldcacheFile

{
	NSEnumerator *frameworkEnum = [cacheArray objectEnumerator];
	id currentFramework = nil;
	while (currentFramework = [frameworkEnum nextObject]) {
		if (![[currentFramework pathExtension] isEqualToString:@"dylib"])
		{
			NSString *newName = [[[currentFirmware frameworksPath] stringByAppendingPathComponent:[currentFramework lastPathComponent]] stringByAppendingPathExtension:@"framework/Headers/"];
			[FM createDirectoryAtPath:newName withIntermediateDirectories:YES attributes:nil error:nil];
			NSArray *taskArguments = [NSArray arrayWithObjects:@"-pabkkzARH", @"-o", newName, @"-d", dyldcacheFile, currentFramework, nil];
			[ACommon returnForTask:CDC withArguments:taskArguments];
		}
	}
}

- (void)startOverMan
{
	[[NSNotificationCenter defaultCenter] removeObserver:self];
	[ipswButton setEnabled:TRUE];
}

@end
