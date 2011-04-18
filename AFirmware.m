//
//  AFirmware.m
//  ambrosia
//
//  Created by Kevin Bradley on 4/14/11.
//  Copyright 2011 Chronic-Dev Team. All rights reserved.
//

#import "AFirmware.h"


@implementation AFirmware

@synthesize fwName, unzipLocation, filePath, vfDecryptKey, buildIdentity;

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
	
	return [NSArray arrayWithObjects:@"AppleLogo", @"BatteryCharging0", @"BatteryCharging1", @"BatteryFull", @"BatteryLow0", @"BatteryLow1", @"BatteryPlugin", @"DeviceTree", @"KernelCache", @"LLB", @"RecoveryMode", @"RestoreRamDisk", @"iBEC", @"iBSS", @"iBoot", nil];
}

-(NSArray *)manifestArray
{
	return [NSArray arrayWithObjects:[self AppleLogo], [self BatteryCharging0], [self BatteryCharging1], [self BatteryFull], [self BatteryLow0], [self BatteryLow1], [self BatteryPlugin], [self DeviceTree], [self KernelCache], [self LLB], [self RecoveryMode], [self RestoreRamDisk], [self iBEC], [self iBSS], [self iBoot], nil];
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
		NSLog(@"file exists at path: %@", [self plistPath]);
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
