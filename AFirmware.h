//
//  AFirmware.h
//  ambrosia
//
//  Created by Kevin Bradley on 4/14/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "AFirmwareFile.h"

@interface AFirmware : NSObject {

	NSString *filePath;
	NSString *fwName;
	NSString *unzipLocation;
	NSString *vfDecryptKey;

}

@property (nonatomic, retain) NSString *filePath;
@property (nonatomic, retain) NSString *fwName;
@property (nonatomic, retain) NSString *unzipLocation;
@property (nonatomic, retain) NSString *vfDecryptKey;

- (NSDictionary *)manifest;
- (NSDictionary *)buildManifest;
- (NSDictionary *)restoreDictionary;

- (NSString *)platform;

- (NSString *)ProductBuildVersion;
- (NSString *)ProductType;
- (NSString *)ProductVersion;

- (NSString *)AppleLogo;
- (NSString *)BatteryCharging;
- (NSString *)BatteryCharging0;
- (NSString *)BatteryCharging1;
- (NSString *)BatteryFull;
- (NSString *)BatteryLow;
- (NSString *)BatteryLow0;
- (NSString *)BatteryLow1;
- (NSString *)BatteryPlugin;
- (NSString *)DeviceTree;
- (NSString *)KernelCache;
- (NSString *)LLB;
- (NSString *)OS;
- (NSString *)RecoveryMode;
- (NSString *)RestoreDeviceTree;
- (NSString *)RestoreKernelCache;
- (NSString *)RestoreLogo;
- (NSString *)RestoreRamDisk;
- (NSString *)UpdateRamDisk;
- (NSString *)iBEC;
- (NSString *)iBSS;
- (NSString *)iBoot;

- (NSDictionary *)VariantContents;
- (NSDictionary *)VariantContentsTwo;
- (NSDictionary *)manifestTwo;

@end

/*

 2011-04-14 20:00:28.830 ambrosia[20581:4807] restoreDict; {
 DeviceClass = iPhone;
 DeviceMap =     (
 {
 BDID = 0;
 BoardConfig = n90ap;
 CPID = 35120;
 Platform = s5l8930x;
 SCEP = 1;
 }
 );
 FirmwareDirectory = Firmware;
 KernelCachesByPlatform =     {
 };
 KernelCachesByTarget =     {
 k48 =         {
 Release = "kernelcache.release.k48";
 };
 n81 =         {
 Release = "kernelcache.release.n81";
 };
 n90 =         {
 Release = "kernelcache.release.n90";
 };
 };
 ProductBuildVersion = 8H7;
 ProductType = "iPhone3,1";
 ProductVersion = "4.3.2";
 RamDisksByPlatform =     {
 s5l8930x =         {
 Update = "038-1031-007.dmg";
 User = "038-1035-007.dmg";
 };
 };
 RestoreKernelCaches =     {
 Development = "kernelcache.development.s5l8930x";
 Release = "kernelcache.release.s5l8930x";
 };
 RestoreRamDisks =     {
 Update = "038-1031-007.dmg";
 User = "038-1035-007.dmg";
 };
 SupportedProductTypeIDs =     {
 DFU =         (
 35120
 );
 Recovery =         (
 35120
 );
 };
 SupportedProductTypes =     (
 "iPhone3,1"
 );
 SystemRestoreImages =     {
 User = "038-1025-007.dmg";
 };
 }

*/