//
//  AFirmware.m
//  ambrosia
//
//  Created by Kevin Bradley on 4/14/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "AFirmware.h"


@implementation AFirmware

@synthesize fwName, unzipLocation, filePath, vfDecryptKey;

- (id)initWithFile:(NSString *)theFile
{
	if(self = [super init]) {
		
		filePath = theFile;
		fwName = [[theFile lastPathComponent] stringByDeletingPathExtension];
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



- (void)dealloc
{
	[fwName release];
	[unzipLocation release];
	[filePath release];
	[vfDecryptKey release];
	[super dealloc];
}


- (NSString *)AppleLogo
{
	return [[self unzipLocation] stringByAppendingPathComponent:[[[[self manifest] valueForKey:@"AppleLogo"] valueForKey:@"Info"] valueForKey:@"Path"]];
}

- (NSString *)BatteryCharging
{
	return [[self unzipLocation] stringByAppendingPathComponent:[[[[self manifest] valueForKey:@"BatteryCharging"] valueForKey:@"Info"] valueForKey:@"Path"]];
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

- (NSString *)BatteryLow
{
	return [[self unzipLocation] stringByAppendingPathComponent:[[[[self manifest] valueForKey:@"BatteryLow"] valueForKey:@"Info"] valueForKey:@"Path"]];
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
	NSDictionary *one = [[[buildIdentities objectAtIndex:0] valueForKey:@"Info"] valueForKey:@"VariantContents"];
	return one;
	
}

- (NSDictionary *)VariantContentsTwo
{
	NSArray *buildIdentities = [[self buildManifest] objectForKey:@"BuildIdentities"];
	NSDictionary *one = [[[buildIdentities objectAtIndex:1] valueForKey:@"Info"] valueForKey:@"VariantContents"];
	return one;
	
}


- (NSDictionary *)manifest
{
	NSArray *buildIdentities = [[self buildManifest] objectForKey:@"BuildIdentities"];
	NSDictionary *one = [buildIdentities objectAtIndex:0];
	return [one valueForKey:@"Manifest"];
	
}

- (NSDictionary *)manifestTwo
{
	NSArray *buildIdentities = [[self buildManifest] objectForKey:@"BuildIdentities"];
	NSDictionary *one = [buildIdentities objectAtIndex:1];
	return [one valueForKey:@"Manifest"];
	
}

@end
