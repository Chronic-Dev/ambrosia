
#import "ACommon.h"



@implementation ACommon

/*
 
 return [NSArray arrayWithObjects:@"AppleLogo", @"BatteryCharging", @"BatteryCharging0", @"BatteryCharging1", @"BatteryFull", @"BatteryLow", @"BatteryLow0", @"BatteryLow1", @"BatteryPlugin", @"DeviceTree", @"KernelCache", @"LLB", @"OS", @"RecoveryMode", @"RestoreDeviceTree", @"RestoreKernelCache", @"RestoreLogo", @"RestoreRamDisk", @"UpdateRamDisk", @"iBEC", @"iBSS", @"iBoot", nil];
 
 */



-(NSString *)grabKeybagForFile:(NSString *)theFile
{
	NSString *kbagProcess = [NSString stringWithFormat:@"\"%@\" \"%@\"", GRABKBAG, theFile];
		//	DebugLog(@"grabKeybag: %@", kbagProcess);
	NSString *returnString = [ACommon singleLineReturnForProcess:kbagProcess];
	if (returnString != nil)
	{
		DebugLog(@"%@ has keybag: %@", [theFile lastPathComponent], returnString);
		return returnString;
	}
	
	DebugLog(@"%@ not encrypted!", [theFile lastPathComponent]);
	return nil;
	
}

+ (id)sharedCommon
{
	static ACommon *shared = nil;
	if(shared == nil)
		shared = [[ACommon alloc] init];
	
	return shared;
}

+ (NSString *)dyldcacheFileFromVolume:(NSString *)theVolume
{
	NSString *dyldcacheFolder = [theVolume stringByAppendingPathComponent:@"System/Library/Caches/com.apple.dyld"];
	DebugLog(@"dyldcacheFolder: %@",dyldcacheFolder );
	NSArray *cacheFiles = [FM contentsOfDirectoryAtPath:dyldcacheFolder error:nil];
	DebugLog(@"cacheFiles: %@", cacheFiles);
	
	if ([cacheFiles count] > 1)
	{
		NSEnumerator *cacheEnum = [cacheFiles objectEnumerator];
		id theObject = nil;
		while (theObject = [cacheEnum nextObject]) {
			
			if ([theObject length] > 17) 
			{
				NSString *substrg = [theObject substringToIndex:17];
				DebugLog(@"substrg: %@", substrg);
				
				if ([substrg isEqualToString:@"dyld_shared_cache"])
				{
					return [dyldcacheFolder stringByAppendingPathComponent:theObject];
					
				}
			}
				//dyld_shared_cache_armv7
			
		}
	} else {
		
		return [dyldcacheFolder stringByAppendingPathComponent:[cacheFiles objectAtIndex:0]];
		
	}
	
	return nil;
}

+ (NSArray *)dyldcacheContentsFromVolume:(NSString *)theVolume
{
	NSString *dyldcacheFile = [self dyldcacheFileFromVolume:theVolume];
	return [ACommon returnForTask:DYLDCACHE withArguments:[NSArray arrayWithObjects:@"-l", dyldcacheFile, nil]];
}



+ (ACommon *)sharedInstance
{
    return [[self alloc] init];
}

+ (NSString *)applicationSupportFolder {
	
	NSFileManager *man = [NSFileManager defaultManager];
    NSArray *paths =
	NSSearchPathForDirectoriesInDomains(NSApplicationSupportDirectory,
										NSUserDomainMask, YES);
    NSString *basePath = ([paths count] > 0) ? [paths objectAtIndex:
												0] : NSTemporaryDirectory();
	basePath = [basePath stringByAppendingPathComponent:@"FWAmbrosia"];
    if (![man fileExistsAtPath:basePath])
		[man createDirectoryAtPath:basePath withIntermediateDirectories:YES attributes:nil error:nil];
	return basePath;
}

+ (NSString *)firmwarePath {
	
	NSFileManager *man = [NSFileManager defaultManager];
    NSString *basePath = [[ACommon applicationSupportFolder] stringByAppendingPathComponent:@"Firmware"];
    if (![man fileExistsAtPath:basePath])
		[man createDirectoryAtPath:basePath withIntermediateDirectories:YES attributes:nil error:nil];
	return basePath;
}

+ (NSDictionary *)decryptedKbag:(NSString *)theKbag
{
		//NSArray *ivK = [ACommon runHelper:theKbag];
	
	NSArray *ivK = [ACommon runHelper:theKbag];
	if ([ivK count] == 0)
	{
		NSLog(@"game over man!!! so... start over man!!!");
		return nil;
	}
	
	if ([[ivK objectAtIndex:0] isEqualToString:@"TRY_AGAIN"])
	{
		ivK = [ACommon runHelper:theKbag];
	}
	
	DebugLog(@"ivK: %@", ivK);
	if ([ivK count] == 0)
		
		return nil;
	
		//DebugLog(@"ivk: %@", ivK);
	NSString *k = [ivK objectAtIndex:3];
	NSString *iv = [ivK objectAtIndex:1];
	
	NSCharacterSet *theSet = [NSCharacterSet characterSetWithCharactersInString:@"\0\n "];
	k = [k stringByTrimmingCharactersInSet:theSet];
	
	k = [k stringByReplacingOccurrencesOfString:@"\0" withString:@""];
	k = [k stringByReplacingOccurrencesOfString:@"  " withString:@""];
	k = [k stringByReplacingOccurrencesOfString:@"\n" withString:@""];
		//NSString *kTrim = [k substringWithRange:NSMakeRange(0, 96)];
	
	
	iv = [iv stringByReplacingOccurrencesOfString:@"\0" withString:@""];
	iv = [iv stringByReplacingOccurrencesOfString:@"  " withString:@""];
	
		//DebugLog(@"iv: %@", iv);
	
	NSDictionary *ivKDict = [NSDictionary dictionaryWithObjectsAndKeys:iv, @"iv", k, @"k", nil];
	DebugLog(@"ivkDict: %@", ivKDict);
	if ([k isEqualToString:@"fail!"])
		return nil;
		//NSString *dict = [[NSHomeDirectory() stringByAppendingPathComponent:theKbag] stringByAppendingPathExtension:@"plist"];
		//[ivKDict writeToFile:dict atomically:YES];
	return ivKDict;
	
}


+ (NSString *)mountImage:(NSString *)irString
{
	NSTask *irTask = [[NSTask alloc] init];
	NSPipe *hdip = [[NSPipe alloc] init];
    NSFileHandle *hdih = [hdip fileHandleForReading];
	
	NSMutableArray *irArgs = [[NSMutableArray alloc] init];
	
	[irArgs addObject:@"attach"];
	[irArgs addObject:@"-plist"];
	
	[irArgs addObject:irString];
	
	[irArgs addObject:@"-owners"];
	[irArgs addObject:@"on"];
	
	[irTask setLaunchPath:@"/usr/bin/hdiutil"];
	
	[irTask setArguments:irArgs];
	
	[irArgs release];
	
	[irTask setStandardError:hdip];
	[irTask setStandardOutput:hdip];
		//DebugLog(@"hdiutil %@", [[irTask arguments] componentsJoinedByString:@" "]);
	[irTask launch];
	[irTask waitUntilExit];
	
	NSData *outData;
	outData = [hdih readDataToEndOfFile];
	NSString *the_error;
	NSPropertyListFormat format;
	id plist;
	plist = [NSPropertyListSerialization propertyListFromData:outData
											 mutabilityOption:NSPropertyListImmutable 
													   format:&format
											 errorDescription:&the_error];
	
	if(!plist)
		
	{
		
		DebugLog(@"%@", the_error);
		
		[the_error release];
		
	}
		//DebugLog(@"plist: %@", plist);
	
	NSArray *plistArray = [plist objectForKey:@"system-entities"];
	
		//int theItem = ([plistArray count] - 1);
	
	int i;
	
	NSString *mountPath = nil;
	
	for (i = 0; i < [plistArray count]; i++)
	{
		NSDictionary *mountDict = [plistArray objectAtIndex:i];
		
		mountPath = [mountDict objectForKey:@"mount-point"];
		if (mountPath != nil)
		{
				//DebugLog(@"Mount Point: %@", mountPath);
			
			
			int rValue = [irTask terminationStatus];
			
			if (rValue == 0)
			{	[irTask release];
				irTask = nil;
				return mountPath;
			}
		}
	}
	
	[irTask release];
	irTask = nil;	
	return nil;
}

+ (NSString *)genpassFromRamdisk:(NSString *)ramdisk platform:(NSString *)thePlatform andFilesystem:(NSString *)theFilesystem
{
	NSString *command = [NSString stringWithFormat:@"\"%@\" %@ \"%@\" \"%@\"\n", GENPASS, thePlatform, ramdisk, theFilesystem];
		DebugLog(@"%@", command);
	return [ACommon singleLineReturnForProcess:command];
	
}

+ (NSString *)decryptFilesystem:(NSString *)fileSystem withKey:(NSString *)fileSystemKey
{
	NSTask *vfTask = [[NSTask alloc] init];
	[vfTask setLaunchPath:VFDECRYPT];
	NSString *decrypted = [[[fileSystem stringByDeletingPathExtension] stringByAppendingString:@"_decrypt"] stringByAppendingPathExtension:@"dmg"];
	[vfTask setArguments:[NSArray arrayWithObjects:@"-i", fileSystem, @"-k", fileSystemKey, @"-o", decrypted, nil]];
		DebugLog(@"%@ %@\n", VFDECRYPT, [[vfTask arguments] componentsJoinedByString:@" "]);
		[vfTask setStandardError:NULLOUT];
		[vfTask setStandardOutput:NULLOUT];
	[vfTask launch];
	[vfTask waitUntilExit];
	
	int returnStatus = [vfTask terminationStatus];
	DebugLog(@"decryptFilesystem: %i", returnStatus);
	[vfTask release];
	vfTask = nil;
		//return returnStatus;
	return decrypted;
}

+(NSString *)singleLineReturnForProcess:(NSString *)call
{
    if (call==nil) 
        return 0;
    char line[200];
    
    FILE* fp = popen([call UTF8String], "r");
	NSString *s = nil;
    if (fp)
    {
        while (fgets(line, sizeof line, fp))
        {
            s = [NSString stringWithCString:line encoding:NSUTF8StringEncoding];
        }
    }
    pclose(fp);
    return [s stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
}

+ (NSArray *)returnForTask:(NSString *)taskBinary withArguments:(NSArray *)taskArguments
{
	DebugLog(@"%@ %@", taskBinary, [taskArguments componentsJoinedByString:@" "]);
	NSTask *task = [[NSTask alloc] init];
	NSPipe *pipe = [[NSPipe alloc] init];
	NSFileHandle *handle = [pipe fileHandleForReading];
	
	[task setLaunchPath:taskBinary];
	[task setArguments:taskArguments];
	[task setStandardOutput:pipe];
	[task setStandardError:pipe];
	
	[task launch];
	
	NSData *outData = nil;
    NSString *temp = nil;
    NSMutableArray *lineArray = [[NSMutableArray alloc] init];
	
	
    while((outData = [handle readDataToEndOfFile]) && [outData length])
    {
			// temp = [[[NSString alloc] initWithData:outData encoding:NSASCIIStringEncoding] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
		temp = [[NSString alloc] initWithData:outData encoding:NSASCIIStringEncoding];
		DebugLog(@"temp length: %i", [temp length]);
			//[lineArray addObject:temp];
		[lineArray addObjectsFromArray:[temp componentsSeparatedByString:@"\n"]];
		[temp release];
    }
	
	
	
	DebugLog(@"lineArray: %@", lineArray);
	[handle closeFile];
	[task release];
	
	task = nil;
	
	return [lineArray autorelease];
	
}

+ (NSArray *)runHelper:(NSString *)theKbag
{
	
	
	NSString *helpPath = DBHELPER;
	
	NSTask *pwnHelper = [[NSTask alloc] init];
	
	[pwnHelper setLaunchPath:helpPath];
	NSPipe *swp = [[NSPipe alloc] init];
	NSFileHandle *swh = [swp fileHandleForReading];
	[pwnHelper setArguments:[NSArray arrayWithObjects:@"nil", theKbag, nil]];
	[pwnHelper setStandardOutput:swp];
	[pwnHelper setStandardError:swp];
	
	[pwnHelper launch];
	
	
	NSData *outData = nil;
    
	
		//Variables needed for reading output
	NSString *temp = nil;
    NSMutableArray *lineArray = [[NSMutableArray alloc] init];
	
	
    while((outData = [swh readDataToEndOfFile]) && [outData length])
    {
        temp = [[[NSString alloc] initWithData:outData encoding:NSASCIIStringEncoding] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
			//DebugLog(@"temp length: %i", [temp length]);
		
		if ([temp length] > 800)
		{
			[swh closeFile];
			[pwnHelper release];
			
			pwnHelper = nil;
			return [NSArray arrayWithObject:@"TRY_AGAIN"];
		}
		
			//DebugLog(@"temp: %@", [temp componentsSeparatedByString:@" "]);
			//[lineArray addObject:[temp stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]]];
			//NSArray *arrayOne = [temp componentsSeparatedByString:@"\n"];
			//DebugLog(@"arrayOneCount: %i", [arrayOne count]);
			//NSArray *arrayTwo = [[arrayOne objectAtIndex:0] componentsSeparatedByString:@" "];
		[lineArray addObjectsFromArray:[[temp stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]] componentsSeparatedByString:@" "]];
		[temp release];
    }
	
	
	
			DebugLog(@"lineArray: %@", lineArray);
	[swh closeFile];
	[pwnHelper release];
	
	pwnHelper = nil;
	
	return [lineArray autorelease];
	
}

+(NSArray *)returnForProcess:(NSString *)call
{
    if (call==nil) 
        return 0;
    char line[200];
    
    FILE* fp = popen([call UTF8String], "r");
    NSMutableArray *lines = [[NSMutableArray alloc]init];
    if (fp)
    {
        while (fgets(line, sizeof line, fp))
        {
            NSString *s = [NSString stringWithCString:line encoding:NSUTF8StringEncoding];
            [lines addObject:s];
        }
    }
    pclose(fp);
    return [lines autorelease];
}

+ (BOOL)unzipFile:(NSString *)theFile toPath:(NSString *)newPath
{
	
	NSString *uzp = @"/usr/bin/unzip";
	
		//NSFileManager *man = [NSFileManager defaultManager];
	
	NSFileHandle *nullOut = [NSFileHandle fileHandleWithNullDevice];
	
		//DebugLog(@"uzp2: %@", uzp2);
	NSTask *unzipTask = [[NSTask alloc] init];
	
	
	[unzipTask setLaunchPath:uzp];
	[unzipTask setArguments:[NSArray arrayWithObjects:@"-o", theFile, @"-d", newPath, @"-x", @"*MACOSX*", nil]];
	[unzipTask setStandardOutput:nullOut];
	[unzipTask setStandardError:nullOut];
	[unzipTask launch];
	[unzipTask waitUntilExit];
	int theTerm = [unzipTask terminationStatus];
		//DebugLog(@"helperTask terminated with status: %i",theTerm);
	if (theTerm != 0)
	{
			//DebugLog(@"failure unzip %@ to %@", theFile, newPath);
		return (FALSE);
		
	} else if (theTerm == 0){
			//DebugLog(@"success unzip %@ to %@", theFile, newPath);
		
		return (TRUE);
	}
	
	return (FALSE);
}

+ (int)decryptRamdisk:(NSString *)theRamdisk toPath:(NSString *)outputDisk withIV:(NSString *)iv key:(NSString *)key

{
	NSTask *decryptTask = [[NSTask alloc] init];
	[decryptTask setLaunchPath:XPWNTOOL];
	NSMutableArray *decryptArgs = [[NSMutableArray alloc ]init];
	[decryptArgs addObject:theRamdisk];
	[decryptArgs addObject:outputDisk];
	if (iv != nil)
	{
		if (key != nil)
		{
			[decryptArgs addObject:@"-iv"];
			[decryptArgs addObject:iv];
			[decryptArgs addObject:@"-k"];
			[decryptArgs addObject:key];
			
		}
		
		
	}
		//DebugLog(@"decryptArgs; %@", decryptArgs);
	DebugLog(@"xpwntool %@\n", [decryptArgs componentsJoinedByString:@" "]);
	[decryptTask setArguments:decryptArgs];
	[decryptArgs release];
		//[decryptTask setArguments:[NSArray arrayWithObjects:theRamdisk, outputDisk, @"-iv", iv, @"-k", key, nil]];
	[decryptTask setStandardError:NULLOUT];
	[decryptTask setStandardOutput:NULLOUT];
	[decryptTask launch];
	[decryptTask waitUntilExit];
	
	int returnStatus = [decryptTask terminationStatus];
	[decryptTask release];
	decryptTask = nil;
	
	return returnStatus;
}

- (void)unzipFile:(NSString *)theFile toPath:(NSString *)newPath
{
	NSMutableDictionary *unzipDict = [[NSMutableDictionary alloc] init];
	[unzipDict setObject:theFile forKey:@"theFile"];
	[unzipDict setObject:newPath forKey:@"newPath"];
	[NSThread detachNewThreadSelector:@selector(threadedUnzipFile:) toTarget:self withObject:[unzipDict autorelease]];

}

+ (void)changeStatus:(NSString *)theStatus
{
	NSDictionary * userInfo = [NSDictionary dictionaryWithObjectsAndKeys: theStatus, @"Status", nil];
	[[NSDistributedNotificationCenter defaultCenter] postNotificationName:@"statusChanged" object:nil userInfo:userInfo deliverImmediately:YES];
	
}


+ (void)updateMountVolume:(NSString *)updateMV
{
	NSDictionary * userInfo = [NSDictionary dictionaryWithObjectsAndKeys: updateMV, @"mountVolume", nil];
	[[NSDistributedNotificationCenter defaultCenter] postNotificationName:@"updateCF" object:nil userInfo:userInfo deliverImmediately:YES];
}



- (void)threadedUnzipFile:(NSDictionary *)theDict
{
	NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
	NSString *theFile = [theDict valueForKey:@"theFile"];
	NSString *newPath = [theDict valueForKey:@"newPath"];
	
	NSString *uzp = @"/usr/bin/unzip";
	
		//NSFileManager *man = [NSFileManager defaultManager];
	
	NSFileHandle *nullOut = [NSFileHandle fileHandleWithNullDevice];
	
		//DebugLog(@"uzp2: %@", uzp2);
	NSTask *unzipTask = [[NSTask alloc] init];
	
	
	[unzipTask setLaunchPath:uzp];
	[unzipTask setArguments:[NSArray arrayWithObjects:@"-o", theFile, @"-d", newPath, @"-x", @"*MACOSX*", nil]];
	[unzipTask setStandardOutput:nullOut];
	[unzipTask setStandardError:nullOut];
	[unzipTask launch];
	[unzipTask waitUntilExit];
	NSLog(@"unzip finished!");
	[ACommon changeStatus:@"Unzip finished!"];
	
	NSLog(@"passing dict: %@", theDict);
	[[NSNotificationCenter defaultCenter] postNotificationName:@"unzipComplete" object:nil userInfo:theDict];
	[pool release];
}

+ (NSDictionary *)decryptFilesystemFromFirmware:(id)currentFirmware
{
	
	NSString *outputFile = [[currentFirmware RestoreRamDisk] stringByDeletingPathExtension];
	outputFile = [outputFile stringByAppendingString:@"_patched.dmg"];
	NSDictionary *rdKeys = [currentFirmware ramdiskKey];
	if (rdKeys != nil)
	{
	
		
		NSLog(@"decrypting: %@\n", [currentFirmware RestoreRamDisk]);

		[ACommon changeStatus:[NSString stringWithFormat:@"decrypting: %@\n", [[currentFirmware RestoreRamDisk]lastPathComponent]]];
		
		
		[ACommon decryptRamdisk:[currentFirmware RestoreRamDisk] toPath:outputFile withIV:[rdKeys valueForKey:@"iv"] key:[rdKeys valueForKey:@"k"]];
	} else {
			//DebugLog(@"ivkDict: %@", decryptedKbag);
		
		DebugLog(@"no kbag! no encryption on ramdisk.\n");
		[ACommon decryptRamdisk:[currentFirmware RestoreRamDisk] toPath:outputFile withIV:nil key:nil];
	}
	
	[ACommon changeStatus:@"generating vfdecrypt key..."];
	
	NSLog(@"generating vfdecrypt key...\n");
	
	NSString *vfDecryptKey = [ACommon genpassFromRamdisk:outputFile platform:[currentFirmware platform] andFilesystem:[currentFirmware OS]];
	vfDecryptKey = [vfDecryptKey stringByReplacingOccurrencesOfString:@"\n" withString:@""];
	vfDecryptKey = [vfDecryptKey substringFromIndex:14];
	vfDecryptKey = [vfDecryptKey cleanedString];
	
	NSLog(@"vfdecrypt key: %@\n", vfDecryptKey);
	
	
	if (vfDecryptKey != nil)
	{
		[ACommon changeStatus:[NSString stringWithFormat:@"decrypting filesystem: %@\n", [[currentFirmware OS] lastPathComponent]]];
		NSLog(@"decrypting filesystem: %@\n", [currentFirmware OS]);
		NSString *decrypted = [ACommon decryptFilesystem:[currentFirmware OS] withKey:vfDecryptKey];
		NSString *mountedVolume = [ACommon mountImage:decrypted];
		NSLog(@"mounted?: %@", mountedVolume);
		if (mountedVolume == nil)
		{
			[ACommon changeStatus:@"invalid vfdecrypt key, trying to generate from update ramdisk!"];
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
					
					[ACommon changeStatus:@"ramdisk is encrypted... finding kbag"];
					
					NSLog(@"ramdisk is encrypted... finding kbag");
					
					NSString *kbag2 = [urd keyBag];
					
					NSLog(@"decrypting keybag....");
					[ACommon changeStatus:@"decrypting keybag...."];
					
					NSDictionary *decryptedKbag2 = [ACommon decryptedKbag:kbag2];
					
					if (decryptedKbag2 == nil)
					{
						[ACommon changeStatus:@"bail!!!, gotz to repois0n!"];
						NSLog(@"bail!!!, gotz to repois0n!");
						return nil;
					}
					[ACommon changeStatus:[NSString stringWithFormat:@"decrypting: %@", [currentFirmware UpdateRamDisk]]];
					NSLog(@"decrypting: %@", [currentFirmware UpdateRamDisk]);
					
					[ACommon decryptRamdisk:[currentFirmware UpdateRamDisk] toPath:outputFile2 withIV:[decryptedKbag2 valueForKey:@"iv"] key:[decryptedKbag2 valueForKey:@"k"]];
				} else {
						//DebugLog(@"ivkDict: %@", decryptedKbag);
					
					DebugLog(@"no kbag! no encryption on ramdisk.");
					[ACommon decryptRamdisk:[currentFirmware UpdateRamDisk] toPath:outputFile2 withIV:nil key:nil];
					
				}
				
				[ACommon changeStatus:@"generating vfdecrypt key (take two)..."];
				NSLog(@"generating vfdecrypt key (take two)...");
				
				NSString *vfDecryptKey2 = [ACommon genpassFromRamdisk:outputFile2 platform:[currentFirmware platform] andFilesystem:[currentFirmware OS]];
				vfDecryptKey2 = [vfDecryptKey2 stringByReplacingOccurrencesOfString:@"\n" withString:@""];
				vfDecryptKey2 = [vfDecryptKey2 substringFromIndex:14];
				vfDecryptKey2 = [vfDecryptKey2 cleanedString];
				
				[ACommon changeStatus:[NSString stringWithFormat:@"vfdecrypt key take 2: %@", vfDecryptKey2]];
				DebugLog(@"vfdecrypt key take 2: %@", vfDecryptKey2);
				if (vfDecryptKey2 != nil)
				{
					NSString *decrypted2 = [ACommon decryptFilesystem:[currentFirmware OS] withKey:vfDecryptKey2];
					NSString *mountedVolume2 = [ACommon mountImage:decrypted2];
					NSLog(@"mounted?: %@", mountedVolume2);
					if (mountedVolume2 != nil)
					{
						DebugLog(@"valid vfdecrypt found!: %@", vfDecryptKey);
						[ACommon changeStatus:[NSString stringWithFormat:@"valid vfdecrypt found!: %@", vfDecryptKey]];
							//[ACommon updateMountVolume:mountedVolume2];
							//return vfDecryptKey2;
						return [NSDictionary dictionaryWithObjectsAndKeys:vfDecryptKey2, @"vfdecrypt", mountedVolume2, @"mountVolume", nil];
					}
				}
				
			}
			
		} else {
			
			DebugLog(@"valid vfdecrypt found!: %@", vfDecryptKey);
				//[ACommon updateMountVolume:mountedVolume];
			return [NSDictionary dictionaryWithObjectsAndKeys:vfDecryptKey, @"vfdecrypt", mountedVolume, @"mountVolume", nil];
				//return vfDecryptKey;
		}
	}
	return nil;
}
@end
