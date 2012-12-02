//
//  AFirmware.m
//  ambrosia
//
//  Created by Kevin Bradley on 4/14/11.
//  Copyright 2011 Chronic-Dev Team. All rights reserved.
//

#import "AFirmware.h"
#import "patchClass.h"


@implementation AFirmware

@synthesize fwName, unzipLocation, filePath, vfDecryptKey, buildIdentity, mountVolume, needsDecryption;


#define IPAD11			@"K48ap"
#define APPLETV21		@"K66ap"
#define IPAD21			@"K93ap"
#define IPAD22			@"K94ap"
#define IPAD23			@"K95ap"
#define IPOD31			@"N18ap"
#define IPOD41			@"N81ap"
#define IPHONE12		@"N82ap"
#define IPHONE21		@"N88ap"
#define IPHONE31		@"N90ap"
#define IPHONE33		@"N92ap"
#define IPHONE41		@"N94ap"


- (NSString *)deviceTypeFromModel:(NSString *)modelType
{
	NSString *device = nil;
	
	if ([modelType isEqualToString:IPAD11])
		device = @"iPad1,1";
	if ([modelType isEqualToString:APPLETV21])
		device = @"AppleTV2,1";
	if ([modelType isEqualToString:IPAD21])
		device = @"iPad2,1";
	if ([modelType isEqualToString:IPAD22])
		device = @"iPad2,2";
	if ([modelType isEqualToString:IPAD23])
		device = @"iPad2,3";
	if ([modelType isEqualToString:IPOD31])
		device = @"iPod3,1";
	if ([modelType isEqualToString:IPOD41])
		device = @"iPod4,1";
	if ([modelType isEqualToString:IPHONE12])
		device = @"iPhone1,2";
	if ([modelType isEqualToString:IPHONE21])
		device = @"iPhone2,1";
	if ([modelType isEqualToString:IPHONE31])
		device = @"iPhone3,1";
	if ([modelType isEqualToString:IPHONE33])
		device = @"iPhone3,3";
	if ([modelType isEqualToString:IPHONE41])
		device = @"iPhone4,1";
	
	
	return device;
	
}



- (NSString *)modelType
{
	//iPhone4,1_5.0_9A334_Restore.ipsw
	
	NSArray *ipswArray = [[self.filePath lastPathComponent] componentsSeparatedByString:@"_"];
	NSString *theDevice = [ipswArray objectAtIndex:0];
	//NSLog(@"theDevice:%@", theDevice);
	if ([theDevice isEqualToString:@"iPad1,1"])
		return IPAD11;
	if ([theDevice isEqualToString:@"AppleTV2,1"])
		return APPLETV21;
	if ([theDevice isEqualToString:@"iPad2,1"])
		return IPAD21;
	if ([theDevice isEqualToString:@"iPad2,2"])
		return IPAD22;
	if ([theDevice isEqualToString:@"iPad2,3"])
		return IPAD23;
	if ([theDevice isEqualToString:@"iPod3,1"])
		return IPOD31;
	if ([theDevice isEqualToString:@"iPod4,1"])
		return IPOD41;
	if ([theDevice isEqualToString:@"iPhone1,2"])
		return IPHONE12;
	if ([theDevice isEqualToString:@"iPhone2,1"])
		return IPHONE21;
	if ([theDevice isEqualToString:@"iPhone3,1"])
		return IPHONE31;
	if ([theDevice isEqualToString:@"iPhone3,3"])
		return IPHONE33;
	if ([theDevice isEqualToString:@"iPhone4,1"])
		return IPHONE41;
	
	return nil;
}

- (NSString *)archivedFirmwareDict
{
	NSArray *ipswArray = [[self.filePath lastPathComponent] componentsSeparatedByString:@"_"];
	NSString *theBuild = [ipswArray objectAtIndex:2]; //ie 9A334
	NSString *modelType = [self modelType];
	//	NSLog(@"modelType: %@", modelType);
	
	return [[NSBundle mainBundle] pathForResource:modelType ofType:@"plist" inDirectory:@"fw"];
	
}

- (NSDictionary *)firmwareDict
{

	NSArray *ipswArray = [[self.filePath lastPathComponent] componentsSeparatedByString:@"_"];
	NSString *theBuild = [ipswArray objectAtIndex:2]; //ie 9A334
	NSString *modelType = [self modelType];
	NSString *dictName = [[NSBundle mainBundle] pathForResource:modelType ofType:@"plist" inDirectory:@"fw"];
	
	if (dictName == nil)
	{
		NSLog(@"no dict yet! need to decrypt it ourselves!");
		return nil;	
	}
		
	NSDictionary *fwDict = [NSDictionary dictionaryWithContentsOfFile:dictName];
	
	return [fwDict valueForKey:theBuild];
}



+ (void)logDevice:(ADevice)inputDevice
{
	NSString *deviceString = [NSString stringWithFormat:@"Device(%i,%i)", inputDevice.platform, inputDevice.subplatform];
	NSLog(@"%@", deviceString);
}

- (NSString *)patchNameFromFile:(NSString *)original
{
	NSString *newNameBase  = [[[original componentsSeparatedByString:@"/"] lastObject] stringByDeletingPathExtension];
	NSMutableString *patchFile = [[NSMutableString alloc] initWithString:newNameBase];
	[patchFile replaceOccurrencesOfString:@"_abdec" withString:@"" options:NSLiteralSearch range:NSMakeRange(0, [patchFile length])];
	[patchFile appendString:@".patch"];
	return [patchFile autorelease];
}

- (NSString *)simpleDeviceType
{
	NSString *firstLetter = [[self fwName] substringToIndex:1];
	if ([firstLetter isEqualToString:@"i"]) //ipad or iphone oops forgot ipod dummy!! ;-P
	{
		NSString *clippedPath = [[self fwName] substringToIndex:5];
		if ([clippedPath isEqualToString:@"iPhone"])
		{
			return clippedPath;
			
		} else {
			
			return [[self fwName] substringToIndex:3]; //since iPod/iPad are both 4 letters this should return either one.
		}
		
	}
	
	return @"AppleTV";
	
		//iPhone 5
		//iPad 5
		//AppleTV 7 
}

- (NSString *)deviceType
{
	NSString *firstLetter = [[self fwName] substringToIndex:1];
	if ([firstLetter isEqualToString:@"i"]) //ipad or iphone oops forgot ipod dummy!! ;-P
	{
		NSString *clippedPath = [[self fwName] substringToIndex:5];
		if ([clippedPath isEqualToString:@"iPhone"])
		{
			return [[self fwName] substringToIndex:11]; //should return 3,1 or whatever
			
		} else {
			
			return [[self fwName] substringToIndex:7]; //since iPod/iPad are both 4 letters this should return either one.
		}
		
	}
	
	return @"AppleTV2,1";
	
		//iPhone3,1 5
		//iPad1,1 7
		//AppleTV 7 
}

- (int)deviceInt
{
	if ([[self simpleDeviceType] isEqualToString:@"iPhone"])
	{
		return kiPhoneDevice;
		
	} else if ([[self simpleDeviceType] isEqualToString:@"iPad"]){
		
		return kiPadDevice;
		
	} else if ([[self simpleDeviceType] isEqualToString:@"AppleTV"]) {
		
		return kAppleTVDevice;
		
	} else if ([[self simpleDeviceType] isEqualToString:@"iPod"]) {
		
		return kiPodDevice;
		
	}
	
	return kUnknownDevice;
}


- (NSDictionary *)firmwarePatches
{
	/*
	 
	 FirmwarePatches =     {
	 "Restore Ramdisk" =         {
	 File = "038-1328-062.dmg";
	 IV = 7bf76ec1fdf382d70ea9581e223943f6;
	 Key = f91256406327befe3c5c495abcef342fad14a28227a120e04139e1220814a31a;
	 TypeFlag = 8;
	 };
	 iBSS =         {
	 File = "Firmware/dfu/iBSS.k66ap.RELEASE.dfu";
	 IV = 17742baec33113889e5cbfcaa12fb4f0;
	 Key = 998bd521b5b54641fbeb3f73d9959bae126db0bc7e90b7ede7440d3951016010;
	 Patch = "iBSS.k66ap.RELEASE.patch";
	 TypeFlag = 8;
	 };
	 };
	 
	 */
	
	NSString *rrdiv = [[self ramdiskKey] valueForKey:@"iv"];
	NSString *rrdK = [[self ramdiskKey] valueForKey:@"k"];
	NSString *rrdPath = [[self RestoreRamDisk] lastPathComponent];
	
	NSString *ibssK = [[[self keyRepository] valueForKey:@"iBSS"] valueForKey:@"k"];
	NSString *ibssiv = [[[self keyRepository] valueForKey:@"iBSS"] valueForKey:@"iv"];
	NSString *ibssPath = [[[[self manifest] valueForKey:@"iBSS"] valueForKey:@"Info"] valueForKey:@"Path"];
	NSString *ibssPatch = [self patchNameFromFile:ibssPath];
	
	NSString *ibecK = [[[self keyRepository] valueForKey:@"iBEC"] valueForKey:@"k"];
	NSString *ibeciv = [[[self keyRepository] valueForKey:@"iBEC"] valueForKey:@"iv"];
	NSString *ibecPath = [[[[self manifest] valueForKey:@"iBEC"] valueForKey:@"Info"] valueForKey:@"Path"];
	NSString *ibecPatch = [self patchNameFromFile:ibecPath];
	
	NSString *kcacheK = [[[self keyRepository] valueForKey:@"KernelCache"] valueForKey:@"k"];
	NSString *kcacheiv = [[[self keyRepository] valueForKey:@"KernelCache"] valueForKey:@"iv"]; 
	NSString *kcachePath = [[[[self manifest] valueForKey:@"KernelCache"] valueForKey:@"Info"] valueForKey:@"Path"];
	NSString *kcachePatch = [self patchNameFromFile:kcachePath];
	
	NSDictionary *restoreRamDisk = [NSDictionary dictionaryWithObjectsAndKeys:rrdPath, @"File", rrdiv, @"IV", rrdK, @"Key", @"8", @"TypeFlag",nil];
	NSDictionary *ibssDict = [NSDictionary dictionaryWithObjectsAndKeys:ibssPath, @"File", ibssiv, @"IV", ibssK, @"Key", @"8", @"TypeFlag", ibssPatch, @"Patch", nil];
	NSDictionary *ibecDict = [NSDictionary dictionaryWithObjectsAndKeys:ibecPath, @"File", ibeciv, @"IV", ibecK, @"Key", @"8", @"TypeFlag", ibecPatch, @"Patch",nil];
	NSDictionary *kcacheDict = [NSDictionary dictionaryWithObjectsAndKeys:kcachePath, @"File", kcacheiv, @"IV", kcacheK, @"Key", @"8", @"TypeFlag", kcachePatch, @"Patch",nil];
	return [NSDictionary dictionaryWithObjectsAndKeys:restoreRamDisk, @"Restore Ramdisk", ibssDict, @"iBSS", ibecDict, @"iBEC",kcacheDict, @"kernelcache", nil];
	
}//FIXME: missing patch path!!!!!

- (NSString *)extractAppleTVFromVolume:(NSString *)theVolume
{
	NSString *appletvFile = [theVolume stringByAppendingPathComponent:@"Applications/AppleTV.app/AppleTV"];
	NSString *outputATV = [[self unzipLocation] stringByAppendingPathComponent:@"AppleTV"];
	NSString *patchedATV = [[self unzipLocation] stringByAppendingPathComponent:@"AppleTV.patched"];
	[[NSFileManager defaultManager] copyItemAtPath:appletvFile toPath:outputATV error:nil];
	[[NSFileManager defaultManager] copyItemAtPath:appletvFile toPath:patchedATV error:nil];
	return patchedATV;
		/*
		 
		NSMutableDictionary *envDict = [[NSMutableDictionary alloc] init];
		[envDict setObject: @"/Developer/Platforms/iPhoneOS.platform/Developer/usr/bin/codesign_allocate" forKey: @"CODESIGN_ALLOCATE"];
		[mpTask setEnvironment:envDict];
		[envDict release];
		 
		 */
}

- (NSString *)constantsFile
{
	NSString *fileName = [[[self trimmedName] stringByAppendingString:@"_constants"] stringByAppendingPathExtension:@"h"];
	return [[ACommon absintheFiles] stringByAppendingPathComponent:fileName];
}

- (NSString *)extractASR
{
	NSString *ramdiskPath = [[self RestoreRamDisk] stringByDeletingPathExtension];
	ramdiskPath = [ramdiskPath stringByAppendingString:@"_patched.dmg"];
	NSString *mountedPath = [ACommon mountImage:ramdiskPath];
	if(mountedPath != nil)
	{
		NSString *asrPath = [mountedPath stringByAppendingPathComponent:@"usr/sbin/asr"];
		NSString *outputAsr = [[self unzipLocation] stringByAppendingPathComponent:@"asr"];
		[[NSFileManager defaultManager] copyItemAtPath:asrPath toPath:outputAsr error:nil];
		return outputAsr;
	}
	return nil;
}

- (ADevice)device
{
	NSString *currentDevice = [self deviceType];
	NSLog(@"currentDevice: %@", currentDevice);
	
	if ([currentDevice isEqualToString:@"iPhone2,1"])
		return ADeviceMake(1, 5);
	else if ([currentDevice isEqualToString:@"iPhone3,1"])
		return ADeviceMake(1, 6);
	else if ([currentDevice isEqualToString:@"iPod4,1"])
		return ADeviceMake(2, 9);
	else if ([currentDevice isEqualToString:@"iPod3,1"])
		return ADeviceMake(2, 8);
	else if ([currentDevice isEqualToString:@"iPad1,1"])
		return ADeviceMake(3, 3);
	else if ([currentDevice isEqualToString:@"AppleTV2,1"])
		return ADeviceMake(3, 10);
	else
		return ADeviceMake(0, 0);
	
	return ADeviceMake(0, 0);

}

- (NSDictionary *)defaultFilesystemPatches
{

	NSDictionary *fstabDict = [NSDictionary 
							   dictionaryWithObjectsAndKeys:@"Patch", @"Action", @"etc/fstab", 
							   @"File", @"Filesystem Write Access", @"Name", @"fstab.patch", @"Patch", nil];
	
	

	return [NSDictionary dictionaryWithObject:[NSArray arrayWithObject:fstabDict] forKey:@"Filesystem Jailbreak"];
}

- (NSString *)trimmedName
{
	NSMutableString *theString = [[NSMutableString alloc] initWithString:[self fwName]];
	[theString replaceOccurrencesOfString:@"_Restore" withString:@"" options:NSLiteralSearch range:NSMakeRange(0, [theString length])];
	return [theString autorelease];
}

- (NSDictionary *)ramdiskPatches
{
	
	return [NSDictionary dictionaryWithObject:[NSDictionary 
											   dictionaryWithObjectsAndKeys:@"usr/sbin/asr", @"File", @"asr.patch", 
											   @"Patch", nil] forKey:@"asr"];
}

- (NSString *)convertForBundle
{
	NSFileManager *man = [NSFileManager defaultManager];
	
	NSString *fstabPath = [[NSBundle bundleForClass:[AFirmware class]] pathForResource:@"fstab" ofType:@"patch"];
	
	NSMutableDictionary *bundleInfo = [[NSMutableDictionary alloc] init];
	[bundleInfo setObject:[NSNumber numberWithBool:FALSE] forKey:@"DeleteBuildManifest"];
	[bundleInfo setObject:@"" forKey:@"DownloadUrl"];
	[bundleInfo setObject:[[self fwName] stringByAppendingPathExtension:@"ipsw"] forKey:@"Filename"];
	[bundleInfo setObject:[self defaultFilesystemPatches] forKey:@"FilesystemPatches"];
	[bundleInfo setObject:[self firmwarePatches] forKey:@"FirmwarePatches"];
	[bundleInfo setObject:[self trimmedName] forKey:@"Name"];
	[bundleInfo setObject:[[self OS] lastPathComponent] forKey:@"RootFilesystem"];
	[bundleInfo setObject:@"ramdisk" forKey:@"RestoreRamdiskMountVolume"];
	
	NSString *rfsmv = [[self mountVolume] lastPathComponent];
	
	if (rfsmv =! nil)
		[bundleInfo setObject:[[self mountVolume] lastPathComponent] forKey:@"RootFilesystemMountVolume"];
	
	[bundleInfo setObject:[self vfDecryptKey] forKey:@"RootFilesystemKey"];
	[bundleInfo setObject:@"1024" forKey:@"RootFilesystemSize"];
	[bundleInfo setObject:[NSArray arrayWithObject:@"org.saurik.cydia"] forKey:@"PreInstalledPackages"];
	[bundleInfo setObject:[ACommon SHA1FromFile:self.filePath] forKey:@"SHA1"];
	[bundleInfo setObject:[self ramdiskPatches] forKey:@"RamdiskPatches"];
	ADevice currentDevice = [self device];
	
	NSString *platform = [NSString stringWithFormat:@"%i", currentDevice.platform];
	NSString *subplatform = [NSString stringWithFormat:@"%i", currentDevice.subplatform];
	
	[bundleInfo setObject:platform forKey:@"platform"];
	[bundleInfo setObject:subplatform forKey:@"subplatform"];
	
	NSString *bundleFolder = [[[self unzipLocation] stringByAppendingPathComponent:[self trimmedName]] stringByAppendingPathExtension:@"bundle"];
	NSString *infoPath = [bundleFolder stringByAppendingPathComponent:@"Info.plist"];
	[man createDirectoryAtPath:bundleFolder withIntermediateDirectories:TRUE attributes:nil error:nil];
	
	[bundleInfo writeToFile:infoPath atomically:TRUE];
	
	[bundleInfo release];
	bundleInfo = nil;

	NSLog(@"extracting asr...");
	
	[ACommon changeStatus:@"Extracting asr..."];

	NSString *asrPath = [self extractASR];
	
	/*
	
	NSLog(@"creating patches....");
	
	[ACommon changeStatus:@"Creating patches..."];
	
	NSString *deciBSS = [[self iBSS] decryptedPath];
	NSString *decCache = [[self KernelCache] decryptedPath];
	NSString *deciBEC = [[self iBEC] decryptedPath];
	
	[ACommon changeStatus:@"Patching iBEC..."];
	
	NSLog(@"Patching iBEC...");
	
	NSString *ibecPatch = [patchClass patchDFUFile:deciBEC];
	
	[ACommon changeStatus:@"Patching iBSS..."];
	
	NSLog(@"Patching iBSS...");
	
	NSString *ibssPatch = [patchClass patchDFUFile:deciBSS];
	
	[ACommon changeStatus:@"Patching kernelcache..."];
	
	NSLog(@"Patching kernelcache...");
	
	NSString *kernelPatch = [patchClass patchKernelFile:decCache];
	
	if (asrPath != nil)
	{
		[ACommon changeStatus:@"Patching asr..."];
		
		NSLog(@"Patching asr...");
		
		NSString *asrPatch = [patchClass patchASRFile:asrPath];
		NSString *bundleAsr = [bundleFolder stringByAppendingPathComponent:[asrPatch lastPathComponent]];
		[man moveItemAtPath:asrPatch toPath:bundleAsr error:nil];
	}
	
	
	NSString *bundleiBEC = [bundleFolder stringByAppendingPathComponent:[ibecPatch lastPathComponent]];
	NSString *bundleiBSS = [bundleFolder stringByAppendingPathComponent:[ibssPatch lastPathComponent]];
	NSString *bundleKernel = [bundleFolder stringByAppendingPathComponent:[kernelPatch lastPathComponent]];
	
	[man moveItemAtPath:ibecPatch toPath:bundleiBEC error:nil];
	[man moveItemAtPath:ibssPatch toPath:bundleiBSS error:nil];
	[man moveItemAtPath:kernelPatch toPath:bundleKernel error:nil];
	*/
	
	NSString *finalFstab = [bundleFolder stringByAppendingPathComponent:@"fstab.patch"];
	
	[man copyItemAtPath:fstabPath toPath:finalFstab error:nil];
	
	
	/*
	 
	 Still need to do AppleTV patch, for now we'll always do it for testing purposes
	 
	 */
	
	
	//commenting out for now, i dont think it even works anymore
	
	/*
	
	if ([self deviceInt] == kAppleTVDevice)
	{
		
		[ACommon changeStatus:@"Patching AppleTV.app..."];
		
		NSLog(@"Patching AppleTV.app...");
		
		NSString *outputAtvDict = [[self unzipLocation] stringByAppendingPathComponent:@"AppleTV.plist"];
		
		NSString *atvFile = [self extractAppleTVFromVolume:self.mountVolume];
		[ACommon writeCodesignDictionaryFromFile:atvFile toFile:outputAtvDict];
		NSMutableDictionary *codesignDict = [[NSMutableDictionary alloc] initWithContentsOfFile:outputAtvDict];
		[codesignDict removeObjectForKey:@"seatbelt-profiles"];
		[codesignDict writeToFile:outputAtvDict atomically:YES];
		[codesignDict release];
		codesignDict = nil;
		
		[ACommon writeCodesign:outputAtvDict toFile:atvFile];
		
		NSString *vanillaATV = [atvFile stringByDeletingPathExtension];
		
		NSString *atvPatch = [patchClass createBSDiffFromOriginal:vanillaATV newFile:atvFile];
		NSString *finalATVPatch = [bundleFolder stringByAppendingPathComponent:@"AppleTV.patch"];
		
		if ([man fileExistsAtPath:atvPatch])
		{
			NSLog(@"atv patch exists!. copying!");
			[man copyItemAtPath:atvPatch toPath:finalATVPatch error:nil];
			
			
		}
		
	}
	
	*/
	
	return infoPath;
		//FIXME: need Platform and SubPlatform
	
	
}


- (BOOL)hasFWDict
{
	if ([self firmwareDict] != nil)
		return (TRUE);
	
	return (FALSE);
}


- (id)initWithFile:(NSString *)theFile
{
	if(self = [super init]) {
		
		filePath = theFile;
		fwName = [[theFile lastPathComponent] stringByDeletingPathExtension];
		[fwName retain];
		unzipLocation = [[ACommon firmwarePath]  stringByAppendingPathComponent:fwName];
		if ([FM fileExistsAtPath:unzipLocation])
		{
				//[[[NSApplication sharedApplication] delegate] unzipFinished:nil];
				//[[NSNotificationCenter defaultCenter] postNotificationName:@"unzipComplete" object:nil userInfo:nil];
				//return self;
		}
		[FM createDirectoryAtPath:unzipLocation withIntermediateDirectories:YES attributes:nil error:nil];
		
		self.needsDecryption = ![self hasFWDict];
		
		[[ACommon sharedCommon] unzipFile:filePath toPath:unzipLocation];
		

	}
	
	return self;
}

- (NSString *)plistPath
{
	NSString *starter = [self unzipLocation];
	starter = [starter stringByAppendingPathComponent:fwName];
	starter = [starter stringByAppendingPathExtension:@"plist"];
	return starter;
}

- (NSString *)wikiPath
{
	NSString *starter = [self unzipLocation];
	starter = [starter stringByAppendingPathComponent:fwName];
	starter = [starter stringByAppendingPathExtension:@"txt"];
	return starter;
}

- (NSString *)privateFrameworksPath;
{
	NSString *pf = [[self unzipLocation] stringByAppendingPathComponent:@"PrivateFrameworks"];
	if(![FM fileExistsAtPath:pf])
	{
			//[FM createDirectoryAtPath:pf attributes:nil];
		[FM createDirectoryAtPath:pf withIntermediateDirectories:TRUE attributes:nil error:nil];
	}
	
	return pf;
}

- (NSString *)frameworksPath;
{
	NSString *pf = [[self unzipLocation] stringByAppendingPathComponent:@"Frameworks"];
	if(![FM fileExistsAtPath:pf])
	{
		[FM createDirectoryAtPath:pf withIntermediateDirectories:TRUE attributes:nil error:nil];
	}
	
	return pf;
}

- (NSArray *)notInlineKeys
{
	return [NSArray arrayWithObjects:@"BatteryCharging0", @"BatteryCharging1", @"BatteryFull", @"BatteryLow0", @"BatteryLow1",@"DeviceTree", nil];
}

- (NSString *)convertForWiki
{

	if ([self isDecrypted] == TRUE)
	{
		NSMutableString *wikiString = [[NSMutableString alloc] init];
		
		NSString *rrdiv = [[[self keyRepository] valueForKey:@"RestoreRamDisk"] valueForKey:@"iv"];
		NSString *rrdk = [[[self keyRepository] valueForKey:@"RestoreRamDisk"] valueForKey:@"k"];
		BOOL encryptedRD = FALSE;
		if (([rrdk length] > 5) && ([rrdiv length] > 5))
			encryptedRD = TRUE;
	
		
		[wikiString appendString:@"== Decryption Keys ==\n"];
		
		[wikiString appendString:[NSString stringWithFormat:@"=== Root Filesystem (%@) ===\n",[[self OS] lastPathComponent]]];
		
		[wikiString appendString:[NSString stringWithFormat:@"*'''[[VFDecrypt]] Key''': %@\n\n",[self vfDecryptKey]]];
		
		[wikiString appendString:[NSString stringWithFormat:@"=== [[Restore Ramdisk]] (%@) ===\n",[[self RestoreRamDisk] lastPathComponent]]];
		
		if (encryptedRD)
		{
			[wikiString appendString:[NSString stringWithFormat:@"* '''IV''': %@\n",rrdiv]];
			
			[wikiString appendString:[NSString stringWithFormat:@"* '''Key''': %@\n\n",rrdk]];
		} else {
			
			[wikiString appendString:@"\tNot Encrypted\n\n"];
		}
	
		 
		
		NSEnumerator *theEnum = [[self keyArray] objectEnumerator];
		
		id theObject = nil;
		
		while (theObject = [theEnum nextObject])
		{
			if (![theObject isEqualToString:@"RestoreRamDisk"])
			{
				if (![[self notInlineKeys] containsObject:theObject])
				{
					[wikiString appendString:[NSString stringWithFormat:@"=== [[%@]] ===\n",theObject]];
					
				} else {
					[wikiString appendString:[NSString stringWithFormat:@"=== %@ ===\n",theObject]];
				}
				
				
				[wikiString appendString:[NSString stringWithFormat:@"* '''IV''': %@\n",[[[self keyRepository] valueForKey:theObject] valueForKey:@"iv"]]];
				
				[wikiString appendString:[NSString stringWithFormat:@"* '''Key''': %@\n\n",[[[self keyRepository] valueForKey:theObject] valueForKey:@"k"]]];
			}
			
		
		}
		
		return [wikiString autorelease];
		
	}
	
		  
		
	/*
	 
	 === AppleLogo ===
	 * '''IV''': 5a7cb0980b4cf56d9699d7ef756c4f9c
	 * '''Key''': ca3665583d6e30c0e4d9ddc3f0808aa33a9515922435cc6669868d66e78ba635
	 
	 === BatteryCharging0 ===
	 * '''IV''': 20744e995ce6ca7f93df896bb72198bd
	 * '''Key''': ea08ba056f0b4a8726becd6d8550fd59b6e047055e1535e4fcac7d07fa7b4cb5
	 
	 === BatteryCharging1 ===
	 * '''IV''': f9504808a1f6673b51ecc05e0535d6fe
	 * '''Key''': 410e530fba7f0555247a5f6e14904251b95306439b7b4a3e0721f403aa1d3aad
	 
	 === BatteryFull ===
	 * '''IV''': 822ca5ae33c83d5048fd4b1f13d063f6
	 * '''Key''': bd8fc5816dee922606b6ac6465f88cc7534b9a4450f8baa15f3fc9cff42d849c
	 
	 === BatteryLow0 ===
	 * '''IV''': d77c640914de89faa60522907109bdef
	 * '''Key''': 93d7c555c79390a46949e28f286daa8e72149ffe60282570b9305f7affc42e95
	 
	 === BatteryLow1 ===
	 * '''IV''': 5cf61c60b5d9ff940a6089053363278a
	 * '''Key''': 4dc63f8ed03cf5adc93af7d02cf88aa606b6ccf47c98620cbab2c103136da470
	 
	 === DeviceTree ===
	 * '''IV''': e442f41e28c951e30b89b15d8a701909
	 * '''Key''': e37b592286ea527b88f10ff29df52cbefd12b99a89ec92ec6a2fbe1a1e5af0ff
	 
	 === GlyphCharging ===
	 * '''IV''': 404af73f2eba410b00cdd2f4644cc3e8
	 * '''Key''': 5ec0dcc45b200989cb35c8159cd62d0c41bf3bbdc6a9b35820d24079d5783cba
	 
	 === GlyphPlugin ===
	 * '''IV''': 83edb6499e782720c590ab938e0913a9
	 * '''Key''': a9047a2f17601643626e4c5c036158317d6b555ad09227e0a44baad84623f951
	 
	 === [[iBEC]] ===
	 * '''IV''': 08d25f37324660147ff4dd9544d6fa4c
	 * '''Key''': df6265c5606d22c9ba870df89447a797cecb25ff101c38befb3c0f9f9ef63970
	 
	 === [[iBoot (Bootloader)|iBoot]] ===
	 * '''IV''': 115ed2213d19975088ac0c49d3b58d44
	 * '''Key''': f5dae9051e20b2889f1673e4ffbd269b862136e559432ae8a2580e0d47de3766
	 
	 === [[iBSS]] ===
	 * '''IV''': 17742baec33113889e5cbfcaa12fb4f0
	 * '''Key''': 998bd521b5b54641fbeb3f73d9959bae126db0bc7e90b7ede7440d3951016010
	 
	 === [[Kernelcache]] ===
	 * '''IV''': 9d3878deca198ede4541317af2e330d3
	 * '''Key''': c659e7be427e067366c3c1ea03d6071f3372aaf8ad90d3aa82c6c05a55757e02
	 
	 === [[LLB]] ===
	 * '''IV''': 1ea341d5d29460148ddbe9e7241c80aa
	 * '''Key''': be839ab0d009324febf45545d48907906b83af0b6d75a1843794e71ab82f93e2
	 
	 === RecoveryMode ===
	 * '''IV''': b21896777e7511de9f6ed7622e3b44fe
	 * '''Key''': edd55099d0deb9d3b5bc8229d1b3d5f597e92eb28b28e9126e01c268c23e0531
	 
	 */
	
	return nil;
}


/*
 
 DeviceTree.k66ap.img3
 LLB.k66ap.RELEASE.img3
 applelogo-1280x720.s5l8930x.img3
 batterycharging0.s5l8930x.img3
 batterycharging1.s5l8930x.img3
 batteryfull.s5l8930x.img3
 batterylow0.s5l8930x.img3
 batterylow1.s5l8930x.img3
 glyphcharging.s5l8930x.img3
 glyphplugin.s5l8930x.img3
 iBoot.k66ap.RELEASE.img3
 recoverymode-1280x720.s5l8930x.img3
 
 */

- (void)dealloc
{
	[fwName release];
	[unzipLocation release];
	[filePath release];
	[vfDecryptKey release];
	[super dealloc];
}

- (NSArray *)keyArray
{
	
	return [NSArray arrayWithObjects:@"AppleLogo", @"BatteryCharging0", @"BatteryCharging1", @"BatteryFull", @"BatteryLow0", @"BatteryLow1", @"GlyphPlugin", @"GlyphCharging", @"KernelCache", @"DeviceTree", @"LLB", @"RecoveryMode", @"RestoreRamDisk", @"iBEC", @"iBSS", @"iBoot", nil];
}

/*
 
 -iv 5a7cb0980b4cf56d9699d7ef756c4f9c -k ca3665583d6e30c0e4d9ddc3f0808aa33a9515922435cc6669868d66e78ba635 AppleLogo
-iv 20744e995ce6ca7f93df896bb72198bd -k ea08ba056f0b4a8726becd6d8550fd59b6e047055e1535e4fcac7d07fa7b4cb5  BatteryCharging0
-iv f9504808a1f6673b51ecc05e0535d6fe -k 410e530fba7f0555247a5f6e14904251b95306439b7b4a3e0721f403aa1d3aad  BatteryCharging1
-iv 822ca5ae33c83d5048fd4b1f3d063f6 -k bd8fc5816dee922606b6ac6465f88cc7534b9a4450f8baa15f3fc9cff42d849c   BatteryFull
-iv d77c640914de89faa60522907109bdef -k 93d7c555c79390a46949e28f286daa8e72149ffe60282570b9305f7affc42e95  BatteryLow0
-iv 5cf61c60b5d9ff940a6089053363278a -k 4dc63f8ed03cf5adc93af7d02cf88aa606b6ccf47c98620cbab2c103136da470  BatteryLow1
-iv 83edb6499e782720c590ab938e0913a9 -k a9047a2f1760164366e4c5c036158317d6b555ad09227e0a44baad84623f951   BatteryPlugin
-iv 404af73f2eba410b00cdd2f4644cc3e8 -k 5ec0dcc45b200989cb35c8159cd62d0c41bf3bbdc6a9b35820d24079d5783cba  GlpyhCharging
-iv e442f41e28c951e30b89b15d8a701909 -k e37b592286ea527b88f10ff29df52cbefd12b99a89ec92ec6a2fbe1a1e5af0ff  DeviceTree
-iv 64970e424ea6cece20dca812d0cdaf07 -k c6f159b441e660e5f192ae54d9084b1176145707bb3474e03f83ad9a28188e4   KernelCache
-iv 1ea341d5d29460148ddbe9e7241c80aa -k be839ab0d009324febf45545d48907906b83af0b6d75a1843794e71ab82f93e2  LLB
-iv b21896777e7511de9f6ed7622e3b44fe -k edd55099d0deb9d3b5bc8229d1b3d5f597e92eb28b28e9126e01c268c23e0531  RecoveryMode
-iv 7bf76ec1fdf382d70ea9581e223943f6 -k f91256406327befe3c5c495abcef342fad14a28227a120e04139e1220814a31a  RestoreRamDisk
-iv 08d25f37324660147ff4dd9544d6fa4c -k df6265c5606d22c9ba870df89447a797cecb25ff101c38befb3c0f9f9ef63970  iBEC
-iv 17742baec33113889e5cbfcaa12fb4f0 -k 998bd521b5b54641fbeb3f73d9959bae126db0bc7e90b7ede7440d3951016010  iBSS
-iv 115ed2213d19975088ac0c49d3b58d44 -k f5dae9051e20b2889f1673e4ffbd269b862136e559432ae8a2580e0d47de3766  iBoot

*/

-(NSArray *)manifestArray
{
	return [NSArray arrayWithObjects:[self AppleLogo], [self BatteryCharging0], [self BatteryCharging1], [self BatteryFull], [self BatteryLow0], [self BatteryLow1], [self BatteryPlugin], [self GlyphCharging], [self KernelCache], [self DeviceTree],  [self LLB], [self RecoveryMode], [self RestoreRamDisk], [self iBEC], [self iBSS], [self iBoot], nil];
}

-(NSArray *)kbagArray
{
	if ([self isDecrypted] == TRUE)
	{
			///	NSLog(@"isDecrypted!!");
		NSDictionary *keyRepository = [self keyRepository];
			//NSLog(@"keyRepository: %@", keyRepository);
		return [keyRepository valueForKey:@"kbagArray"];
	}
		//NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
	NSMutableArray *myKbagArray = [[NSMutableArray alloc] init];
	NSEnumerator *manifestEnum = [[self manifestArray] objectEnumerator];
	id object = nil;
	while (object = [manifestEnum nextObject])
	{
		AFirmwareFile *current = [[AFirmwareFile alloc] initWithFile:object];
		NSString *kbag = [current keyBag];
		DebugLog(@"kbag: %@", kbag);
		if (kbag == nil)
			kbag = @"NO_KBAG";
			
		[myKbagArray addObject:kbag];
		[current release];
	}
		//[pool release];
	return [myKbagArray autorelease];
}

- (NSString *)AppleLogo
{
	return [[self unzipLocation] stringByAppendingPathComponent:[[[[self manifest] valueForKey:@"AppleLogo"] valueForKey:@"Info"] valueForKey:@"Path"]];
}


- (NSString *)BatteryCharging0
{
	return [[self unzipLocation] stringByAppendingPathComponent:[[[[self manifest] valueForKey:@"BatteryCharging0"] valueForKey:@"Info"] valueForKey:@"Path"]];
}

- (NSString *)BatteryCharging1
{
	return [[self unzipLocation] stringByAppendingPathComponent:[[[[self manifest] valueForKey:@"BatteryCharging1"] valueForKey:@"Info"] valueForKey:@"Path"]];
}

- (NSString *)BatteryFull
{
	return [[self unzipLocation] stringByAppendingPathComponent:[[[[self manifest] valueForKey:@"BatteryFull"] valueForKey:@"Info"] valueForKey:@"Path"]];
}

- (NSString *)BatteryLow0
{
	return [[self unzipLocation] stringByAppendingPathComponent:[[[[self manifest] valueForKey:@"BatteryLow0"] valueForKey:@"Info"] valueForKey:@"Path"]];
}

- (NSString *)BatteryLow1
{
	return [[self unzipLocation] stringByAppendingPathComponent:[[[[self manifest] valueForKey:@"BatteryLow1"] valueForKey:@"Info"] valueForKey:@"Path"]];
}

- (NSString *)GlyphPlugin
{
	return [[self unzipLocation] stringByAppendingPathComponent:[[[[self manifest] valueForKey:@"BatteryPlugin"] valueForKey:@"Info"] valueForKey:@"Path"]];
}

- (NSString *)GlyphCharging
{
	return [[self unzipLocation] stringByAppendingPathComponent:[[[[self manifest] valueForKey:@"BatteryCharging"] valueForKey:@"Info"] valueForKey:@"Path"]];
}


- (NSString *)BatteryPlugin
{
	return [[self unzipLocation] stringByAppendingPathComponent:[[[[self manifest] valueForKey:@"BatteryPlugin"] valueForKey:@"Info"] valueForKey:@"Path"]];
}

- (NSString *)DeviceTree
{
	return [[self unzipLocation] stringByAppendingPathComponent:[[[[self manifest] valueForKey:@"DeviceTree"] valueForKey:@"Info"] valueForKey:@"Path"]];
}

- (NSString *)KernelCache
{
	return [[self unzipLocation] stringByAppendingPathComponent:[[[[self manifest] valueForKey:@"KernelCache"] valueForKey:@"Info"] valueForKey:@"Path"]];
}

- (NSString *)LLB
{
	return [[self unzipLocation] stringByAppendingPathComponent:[[[[self manifest] valueForKey:@"LLB"] valueForKey:@"Info"] valueForKey:@"Path"]];
}

- (NSString *)OS
{
	return [[self unzipLocation] stringByAppendingPathComponent:[[[[self manifest] valueForKey:@"OS"] valueForKey:@"Info"] valueForKey:@"Path"]];
}

- (NSString *)RecoveryMode
{
	return [[self unzipLocation] stringByAppendingPathComponent:[[[[self manifest] valueForKey:@"RecoveryMode"] valueForKey:@"Info"] valueForKey:@"Path"]];
}

- (NSString *)RestoreDeviceTree
{
	return [[self unzipLocation] stringByAppendingPathComponent:[[[[self manifest] valueForKey:@"RestoreDeviceTree"] valueForKey:@"Info"] valueForKey:@"Path"]];
}

- (NSString *)RestoreKernelCache
{
	return [[self unzipLocation] stringByAppendingPathComponent:[[[[self manifest] valueForKey:@"RestoreKernelCache"] valueForKey:@"Info"] valueForKey:@"Path"]];
}

- (NSString *)RestoreLogo
{
	return [[self unzipLocation] stringByAppendingPathComponent:[[[[self manifest] valueForKey:@"RestoreLogo"] valueForKey:@"Info"] valueForKey:@"Path"]];
}

- (NSString *)RestoreRamDisk
{
	return [[self unzipLocation] stringByAppendingPathComponent:[[[[self manifest] valueForKey:@"RestoreRamDisk"] valueForKey:@"Info"] valueForKey:@"Path"]];
}

- (NSString *)UpdateRamDisk
{	
	NSString *RRD = [[self VariantContentsTwo] valueForKey:@"RestoreRamDisk"];
	if ([RRD isEqualToString:@"UpdateRamDisk"])
	{
		return [[self unzipLocation] stringByAppendingPathComponent:[[[[self manifestTwo] valueForKey:@"RestoreRamDisk"] valueForKey:@"Info"] valueForKey:@"Path"]];
	}
	return nil;
	
}

- (NSString *)iBEC
{
	return [[self unzipLocation] stringByAppendingPathComponent:[[[[self manifest] valueForKey:@"iBEC"] valueForKey:@"Info"] valueForKey:@"Path"]];
}

- (NSString *)iBSS
{
	return [[self unzipLocation] stringByAppendingPathComponent:[[[[self manifest] valueForKey:@"iBSS"] valueForKey:@"Info"] valueForKey:@"Path"]];
}

- (NSString *)iBoot
{
	return [[self unzipLocation] stringByAppendingPathComponent:[[[[self manifest] valueForKey:@"iBoot"] valueForKey:@"Info"] valueForKey:@"Path"]];
}



- (NSString *)ProductBuildVersion
{
	return [[self restoreDictionary] valueForKey:@"ProductBuildVersion"];
}

- (NSString *)ProductType
{
	return [[self restoreDictionary] valueForKey:@"ProductType"];
}

- (NSString *)ProductVersion;
{
	return [[self restoreDictionary] valueForKey:@"ProductVersion"];
}


- (NSString *)platform
{
	return [[[[self restoreDictionary] valueForKey:@"DeviceMap"] objectAtIndex:0] valueForKey:@"Platform"];
}

- (NSString *)BoardConfig
{
	return [[[[self restoreDictionary] valueForKey:@"DeviceMap"] objectAtIndex:0] valueForKey:@"BoardConfig"];
}

- (NSString *)userRestoreRamdisk
{
	return [[[self restoreDictionary] valueForKey:@"RestoreRamDisks"] valueForKey:@"User"];
		//RestoreRamDisks
}

- (NSString *)systemRestoreImage
{
	return [[[self restoreDictionary] valueForKey:@"SystemRestoreImages"] valueForKey:@"User"];
}

- (NSDictionary *)restoreDictionary
{
	NSString *restore = [unzipLocation stringByAppendingPathComponent:@"Restore.plist"];
	if ([FM fileExistsAtPath:restore])
	{
		return [NSDictionary dictionaryWithContentsOfFile:restore];
		
	}
	return nil;
}

- (NSDictionary *)buildManifest
{
	NSString *buildM = [unzipLocation stringByAppendingPathComponent:@"BuildManifest.plist"];
	if ([FM fileExistsAtPath:buildM])
	{
		return [NSDictionary dictionaryWithContentsOfFile:buildM];
		
	}
	return nil;
}

- (NSDictionary *)VariantContents
{
	NSArray *buildIdentities = [[self buildManifest] objectForKey:@"BuildIdentities"];
	NSDictionary *one = [[[buildIdentities objectAtIndex:buildIdentity] valueForKey:@"Info"] valueForKey:@"VariantContents"];
	return one;
	
}

- (NSDictionary *)VariantContentsTwo
{
	NSArray *buildIdentities = [[self buildManifest] objectForKey:@"BuildIdentities"];
	NSDictionary *one = [[[buildIdentities objectAtIndex:buildIdentity+1] valueForKey:@"Info"] valueForKey:@"VariantContents"];
	return one;
	
}

- (NSData *)UniqueBuildID
{
	NSArray *buildIdentities = [[self buildManifest] objectForKey:@"BuildIdentities"];
	return [[buildIdentities objectAtIndex:buildIdentity] valueForKey:@"UniqueBuildID"];
}

- (NSDictionary *)blobReadyManifest
{
		//ProductBuildVersion
	NSString *pbv = [self ProductBuildVersion]; //the final key for the dictionary
	NSMutableDictionary *manifestD = [[NSMutableDictionary alloc] initWithDictionary:[self manifest]];
	[manifestD removeObjectForKey:@"OS"];
	
	
	NSEnumerator *keyEnum = [manifestD keyEnumerator];
	id currentKey = nil;
	
	while (currentKey = [keyEnum nextObject])
	{
			//NSLog(@"currentObject: %@", currentObject);
		id currentObject = [manifestD objectForKey:currentKey];
		
		if ([currentObject respondsToSelector:@selector(allKeys)])
		{
			NSArray *keys = [currentObject allKeys];
			if ([keys containsObject:@"Info"])
			{
				[currentObject removeObjectForKey:@"Info"];
				
			}
			
			if ([keys containsObject:@"BuildString"])
			{
				[currentObject removeObjectForKey:@"BuildString"];
				
			}
		}
		
	}
	
	[manifestD setObject:[self UniqueBuildID] forKey:@"UniqueBuildID"];
	return [NSDictionary dictionaryWithObject:[manifestD autorelease] forKey:pbv];
}

- (NSDictionary *)manifest
{
	NSArray *buildIdentities = [[self buildManifest] objectForKey:@"BuildIdentities"];
	NSDictionary *one = [buildIdentities objectAtIndex:buildIdentity];
	return [one valueForKey:@"Manifest"];
	
}

- (NSDictionary *)manifestTwo
{
	NSArray *buildIdentities = [[self buildManifest] objectForKey:@"BuildIdentities"];
	NSDictionary *one = [buildIdentities objectAtIndex:buildIdentity+1];
	return [one valueForKey:@"Manifest"];
	
}

- (void)setBuildIdentity
{
	NSArray *buildIdentities = [[self buildManifest] objectForKey:@"BuildIdentities"];
	NSString *bc = [self BoardConfig];
		//NSLog(@"boardConfig: %@", bc);
	
	NSEnumerator *buildIdentityEnum = [buildIdentities objectEnumerator];
	id currentObject = nil;
	int currentIndex = 0;
	while (currentObject = [buildIdentityEnum nextObject])
	{
		NSString *one = [[currentObject valueForKey:@"Info"] valueForKey:@"DeviceClass"];
			//NSLog(@"one: %@", one);
		if ([one isEqualToString:bc])
		{
				//NSLog(@"found im: %i", currentIndex);
			buildIdentity = currentIndex;
			return;
		}
		currentIndex++;
		
	}
}

-(NSDictionary *)keyRepository
{
	if ([FM fileExistsAtPath:[self plistPath]])
		
	{
			//NSLog(@"file exists at path: %@", [self plistPath]);
		return [NSDictionary dictionaryWithContentsOfFile:[self plistPath]];
		
	}
	
	return nil;
}

- (BOOL)isDecrypted
{
	if ([FM fileExistsAtPath:[self plistPath]])
		return TRUE;
	
	return FALSE;
}

-(NSString *)vfDecryptKey
{
	if ([self isDecrypted] == TRUE)
	{
			///	NSLog(@"isDecrypted!!");
		NSDictionary *keyRepository = [self keyRepository];
			//NSLog(@"keyRepository: %@", keyRepository);
		return [keyRepository valueForKey:@"vfdecrypt"];
	}
	return nil;
}

-(NSDictionary *)ramdiskKey
{
	if ([self isDecrypted] == TRUE)
	{
			///	NSLog(@"isDecrypted!!");
		NSDictionary *keyRepository = [self keyRepository];
			//NSLog(@"keyRepository: %@", keyRepository);
		return [keyRepository valueForKey:@"RestoreRamDisk"];
	}
	return nil;
}

@end
