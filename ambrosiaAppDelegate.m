//
//  ambrosiaAppDelegate.m
//  ambrosia
//
//  Created by Kevin Bradley on 4/14/11.
//  Copyright 2011 Chronic-Dev Team. All rights reserved.
//

#import "ambrosiaAppDelegate.h"

#define WIKI_H3_XPATH					@"//h3"
#define WIKI_UL_PATH					@"//ul/li"
#define WIKI_VF_KEY_PATH				@"/html[1]/body[1]/div[3]/div[2]/ul[2]/li[1]"
#define WIKI_SUMMARY_XPATH				@"/html[1]/body[1]/div[3]/div[2]/ul[1]"
#define WIKI_DOWNLOAD_HREF				@"//li[starts-with(a/@href, 'http://appldnld.apple.com')]"
#define WIKI_RESULT_LINK_XPATH			@"a/@href"


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
	
//	ADevice testDevice = ADeviceMake(3, 10);
//	[AFirmware logDevice:testDevice];
	
}



- (BOOL)hasDownloadLink:(NSDictionary *)theDict
{
	if ([[theDict allKeys] containsObject:@"DownloadLink"])
		return (TRUE);
	
	return (FALSE);
}

- (NSDictionary *)dictionaryForWikiFirmware:(NSString *)theString

{
	//http://theiphonewiki.com/wiki/index.php?title=Mojave_8M89_(Apple_TV_2G)
	
	NSMutableDictionary *newDictCity = [[NSMutableDictionary alloc] init];
	
	NSURL *url = [NSURL URLWithString:theString];
	NSError * error = nil;
	NSArray * results = nil;
	NSArray * results2 = nil;
	id children = nil;
	NSXMLElement *downloadLink = nil;
	NSString *finalLink = nil;
	NSXMLDocument *document = [[NSXMLDocument alloc] initWithContentsOfURL:url options:NSXMLDocumentTidyHTML error:&error];
	NSXMLElement *root = [document rootElement];	
	//NSLog(@"root: %@", root);
	NSString *resultTitle=[[[root objectsForXQuery:@"//title" error:&error]objectAtIndex:0] stringValue];
	//NSLog(@"resultTitle: %@", resultTitle);
	results = [root objectsForXQuery:WIKI_H3_XPATH error:&error];
	results2 = [root objectsForXQuery:WIKI_UL_PATH error:&error];
	children = [[root nodesForXPath:WIKI_SUMMARY_XPATH error:&error] lastObject]; //this helps discern what index to start at in the arrays.
	downloadLink = [[root objectsForXQuery:WIKI_DOWNLOAD_HREF error:&error] lastObject];
	finalLink = [[[downloadLink objectsForXQuery:WIKI_RESULT_LINK_XPATH error:&error] lastObject] stringValue];
	
	if (finalLink != nil)
	{
		//NSLog(@"finalLink: %@", finalLink);
		[newDictCity setValue:finalLink forKey:@"DownloadLink"];
		NSString *ipswName = [finalLink lastPathComponent];
		[newDictCity setValue:ipswName forKey:@"FirmwareName"];
	}
	
	//NSLog(@"downloadlink: %@", finalLink);
	//NSLog(@"child count: %i", [children childCount]);
	//NSLog(@"children: %@", children);
	int i = [children childCount];
	
	NSXMLNode *currentR3 = nil;
	BOOL hasKey = FALSE;
	
	id object = nil;
	for (object in results)
	{
		hasKey = FALSE;
		NSString *dmgName = nil;
		//NSLog(@"%i", i);
		NSString *keyValue = [object stringValue]; //name of the main dict key
		NSXMLNode *currentR2 = [results2 objectAtIndex:i]; //this is the Key value that corresponds to keyValue
		NSString *currentFirstValue = [currentR2 stringValue];
		NSString *currentSecondValue = nil;
		
		//NSLog(@"%@", keyValue); 
		//NSLog(@"%@", currentFirstValue); //current iv or key value
		
		if ([self isDMG:keyValue]) //if we are @"Root Filesystem", @"Update Ramdisk", @"Restore Ramdisk"
		{
			//if it is a DMG, trim out () and separate by spaces, grabbing second object.
			NSString *cleanPath = [keyValue stringByTrimmingCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@" )"]];
			cleanPath = [cleanPath stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
			dmgName = [[cleanPath componentsSeparatedByString:@"("] lastObject];
			//NSLog(@"DMG path: %@", newPath);
		}
		
		
		if ([currentR2 nextSibling] != nil)
		{
			hasKey = TRUE;
			currentR3 = [results2 objectAtIndex:i+1];
			//NSLog(@"%@", [currentR3 stringValue]);
			currentSecondValue = [[currentR3 stringValue] stringByTrimmingCharactersInSet:[NSCharacterSet newlineCharacterSet]];
			i++;
		}
		
		//NSLog(@"results2: %@", results2);
		i++;
		
		
		/* 
		 
		 add item to dictionary
		 
		 we still need to separate the IV/KEY values out.
		 
		 */
		
		NSMutableDictionary *currentItem = [[NSMutableDictionary alloc] init];
		
		//separate currentFIrstValue into value and key
		
		NSArray *objectOneComponents = [currentFirstValue componentsSeparatedByString:@": "];
		NSArray *objectTwoComponents = [currentSecondValue componentsSeparatedByString:@": "];
		
		if ([objectOneComponents count] > 1)
			[currentItem setValue:[objectOneComponents objectAtIndex:1] forKey:[objectOneComponents objectAtIndex:0]];
		
		
		if ([objectTwoComponents count] > 1)
			[currentItem setValue:[objectTwoComponents objectAtIndex:1] forKey:[objectTwoComponents objectAtIndex:0]];
		
		if (dmgName != nil)
		{
			[currentItem setValue:dmgName forKey:@"path"];
			NSString *newValue = [self dmgNameFromFullName:keyValue];
			keyValue = newValue;
		}
		
		
		[newDictCity setValue:currentItem forKey:keyValue];
		
		[currentItem release];
		currentItem = nil;
		
		
		
	}
	
	
	//NSLog(@"final Dict: %@", newDictCity);
	
	return [newDictCity autorelease];
	
}

- (NSString *)dmgNameFromFullName:(NSString *)theName
{
	NSString *cleanPath = [theName stringByTrimmingCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@")"]];
	NSString *clean2 = [[cleanPath componentsSeparatedByString:@"("] objectAtIndex:0];
	int length = ([clean2 length]-1);
	return [clean2 substringToIndex:length];
}

- (BOOL)isDMG:(NSString *)theString
{
	NSString *newName = [self dmgNameFromFullName:theString];
	//NSLog(@"newName: -%@-", newName);
	NSArray *dmgNames = [NSArray arrayWithObjects:@"Root Filesystem", @"Update Ramdisk", @"Restore Ramdisk", nil];
	if ([dmgNames containsObject:newName])
	{
		
		return (TRUE);
		
	}
	
	
	return (FALSE);
}


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
	
//	NSDictionary *theShit = [self firmwareDictFromIPSW:theFile];
	
//	NSLog(@"%@", theShit);
	
	
	[self setDownloadText:@"Unzipping ipsw...."];
	[self showProgress];
	
	
	
	
}

- (IBAction)oldtestRun:(id)sender
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
				if (![currentKey isEqualToString:@"RestoreRamDisk"])
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
		id keysDict = nil;
		if ([currentFirmware needsDecryption])
		{
			keysDict = [self sendKbagArray:kbagArray];
			DebugLog(@"keysDict: %@", keysDict);
		} else {
			
			NSLog(@"shouldnt need decryption, lets use the firmwaredict instead!");
			keysDict = [currentFirmware firmwareDict];
		}
		
		
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
				NSDictionary *mountDict = [NSDictionary dictionaryWithObject:mountVolume forKey:@"mountVolume"];
				[[NSNotificationCenter defaultCenter] postNotificationName:@"updateCF" object:nil userInfo:mountDict];
				
				[currentFirmware setMountVolume:mountVolume];
				[currentFirmware setMountVolume:mountVolume];
				NSLog(@"cf mv: %@", [currentFirmware mountVolume]);
				NSArray *staticCacheList = [ACommon dyldcacheContentsFromVolume:mountVolume];
				NSMutableArray *cacheList = [[NSMutableArray alloc] initWithArray:staticCacheList];
				[keysDict setValue:staticCacheList forKey:@"dyldcache"];
				DebugLog(@"cacheList: %@", cacheList);
				DebugLog(@"cacheListCount: %i", [cacheList count]);
				NSPredicate *pfPredicate = [NSPredicate predicateWithFormat:@"SELF BEGINSWITH[cd] '/System/Library/PrivateFrameworks'"];//
				[cacheList filterUsingPredicate:pfPredicate];
				DebugLog(@"Private Frameworks: %@", cacheList);
				DebugLog(@"Private Frameworks count: %i", [cacheList count]);
				
				NSLog(@"extracting dyldcache...");
				
				NSString *dyldfile = [ACommon dyldcacheFileFromVolume:mountVolume];
				
				NSString *copiedFile = [[currentFirmware unzipLocation] stringByAppendingPathComponent:@"dyld_shared_cache_armv7"];
				
				[FM copyItemAtPath:dyldfile toPath:copiedFile error:nil];
				
				//dyld_shared_cache_armv7
				
				NSLog(@"extracting system libs...");
				
				[ACommon extractSystemLibsFromVolume:mountVolume toPath:[currentFirmware unzipLocation]];
				
				NSArray *kernelSymbols = [self dumpKernelSymbolsFromFirmwareFolder:[currentFirmware unzipLocation]];
				
				NSLog(@"kernelSymbols: %@", kernelSymbols);
				
				[keysDict setValue:kernelSymbols forKey:@"KernelSymbolOffsets"];
				
				
				NSArray *cSymbols = [self dumpCSymbolsFromFirmwareFolder:[currentFirmware unzipLocation]];
				
				NSLog(@"cSymbols: %@", cSymbols);
				
				[keysDict setValue:cSymbols forKey:@"CSymbolOffsets"];
				
				
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
		//	[[NSWorkspace sharedWorkspace] openFile:firmwarePlist];
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
		//[[NSWorkspace sharedWorkspace] openFile:infoBundle];
		
		
	}
	
	[self setDownloadText:@"Finished!!"];
	
	[self cleanup];
		//iBSS, iBoot, kernelcache
	
	[currentFirmware release];
	
	[self hideProgress];
		
	[self startOverMan];
}

- (NSArray *)libsystemCSymbols
{
	return [NSArray arrayWithObjects:@"_exit", @"_fopen", @"_fread", @"_fclose", @"_syslog", nil];
}

- (NSArray *)libsystemKernelSymbols
{
	return [NSArray arrayWithObjects:@"_mmap", @"_open", @"_mkdir", @"_ioctl", @"_close", @"_mount", @"_unmount" , @"_syscall", @"_zfree", 
			@"_sysent", @"_IOLog", nil];
}

- (NSArray *)dumpKernelSymbolsFromFirmwareFolder:(NSString *)outputFolder
{
	NSArray *kSymbols = [self libsystemKernelSymbols];
	NSMutableArray *mutArray = [[NSMutableArray alloc] init];
	id object = nil;
	for (object in kSymbols)
	{
		NSArray *arguments = [NSArray arrayWithObjects:@"dyld_shared_cache_armv7", @"libsystem_kernel.dylib", object, nil];
		NSString *returnString = [ACommon stringReturnForTask:DYLDROP withArguments:arguments fromLocation:outputFolder];
		if (returnString != nil)
			[mutArray addObject:returnString];
		else 
			NSLog(@"object symbol failed; %@", object);
		//dyldrop dyld_shared_cache_armv7 libsystem_kernel.dylib _open 2> /dev/null
		
	}
	return [mutArray autorelease];

}

- (NSArray *)dumpCSymbolsFromFirmwareFolder:(NSString *)outputFolder
{
	NSArray *cSymbols = [self libsystemCSymbols];
	NSMutableArray *mutArray = [[NSMutableArray alloc] init];
	id object = nil;
	for (object in cSymbols)
	{
		NSArray *arguments = [NSArray arrayWithObjects:@"dyld_shared_cache_armv7", @"libsystem_c.dylib", object, nil];
		NSString *returnString = [ACommon stringReturnForTask:DYLDROP withArguments:arguments fromLocation:outputFolder];
		if (returnString != nil)
			[mutArray addObject:returnString];
		else 
			NSLog(@"object symbol failed; %@", object);
		//dyldrop dyld_shared_cache_armv7 libsystem_kernel.dylib _open 2> /dev/null
														
	}
	return [mutArray autorelease];
	

	/*
	 
	 _exit, _fopen, _fread, and _fclose are all in libsystem_c.dylib
	 
	 
	 / Dyldcache Offsets
	 
	 _syslog
	 _mmap
	 _open
	 _mkdir
	 _ioctl
	 _close
	 _exit
	 _mount
	 _unmount
	 _fopen
	 _fclose
	 _fread
	 _syscall
	 
	 / Kernel Offsets
	 _zfree
	 _sysent
	 _IOLog
	 
	 */
}

- (void)cleanup
{
	if ([FM fileExistsAtPath:@"/Volumes/ramdisk"])
		[ACommon detachImage:@"/Volumes/ramdisk"];
	
	if ([FM fileExistsAtPath:[currentFirmware mountVolume]])
		[ACommon detachImage:[currentFirmware mountVolume]];
	
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
