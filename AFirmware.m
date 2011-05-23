//
//  AFirmware.m
//  ambrosia
//
//  Created by Kevin Bradley on 4/14/11.
//  Copyright 2011 Chronic-Dev Team. All rights reserved.
//

#import "AFirmware.h"


@implementation AFirmware

@synthesize fwName, unzipLocation, filePath, vfDecryptKey, buildIdentity, mountVolume;

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
		[FM createDirectoryAtPath:pf attributes:nil];
	}
	
	return pf;
}

- (NSString *)frameworksPath;
{
	NSString *pf = [[self unzipLocation] stringByAppendingPathComponent:@"Frameworks"];
	if(![FM fileExistsAtPath:pf])
	{
		[FM createDirectoryAtPath:pf attributes:nil];
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
		[wikiString appendString:@"== Decryption Keys ==\n"];
		
		[wikiString appendString:[NSString stringWithFormat:@"=== Root Filesystem (%@) ===\n",[[self OS] lastPathComponent]]];
		
		[wikiString appendString:[NSString stringWithFormat:@"*'''[[VFDecrypt]] Key''': %@\n\n",[self vfDecryptKey]]];
		
		[wikiString appendString:[NSString stringWithFormat:@"=== [[Restore Ramdisk]] (%@) ===\n",[[self RestoreRamDisk] lastPathComponent]]];
	
		 [wikiString appendString:[NSString stringWithFormat:@"* '''IV''': %@\n",[[[self keyRepository] valueForKey:@"RestoreRamDisk"] valueForKey:@"iv"]]];
		 
		 [wikiString appendString:[NSString stringWithFormat:@"* '''Key''': %@\n\n",[[[self keyRepository] valueForKey:@"RestoreRamDisk"] valueForKey:@"k"]]];
		
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
	
	return [NSArray arrayWithObjects:@"AppleLogo", @"BatteryCharging0", @"BatteryCharging1", @"BatteryFull", @"BatteryLow0", @"BatteryLow1", @"GlyphPlugin", @"GlyphCharging", @"DeviceTree", @"KernelCache", @"LLB", @"RecoveryMode", @"RestoreRamDisk", @"iBEC", @"iBSS", @"iBoot", nil];
}

-(NSArray *)manifestArray
{
	return [NSArray arrayWithObjects:[self AppleLogo], [self BatteryCharging0], [self BatteryCharging1], [self BatteryFull], [self BatteryLow0], [self BatteryLow1], [self BatteryPlugin], [self GlyphCharging], [self DeviceTree], [self KernelCache], [self LLB], [self RecoveryMode], [self RestoreRamDisk], [self iBEC], [self iBSS], [self iBoot], nil];
}

-(NSArray *)kbagArray
{
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
