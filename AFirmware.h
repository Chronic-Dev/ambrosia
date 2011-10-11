//
//  AFirmware.h
//  ambrosia
//
//  Created by Kevin Bradley on 4/14/11.
//  Copyright 2011 Chronic-Dev Team. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "AFirmwareFile.h"

@interface AFirmware : NSObject {

	NSString *filePath;
	NSString *fwName;
	NSString *unzipLocation;
	NSString *vfDecryptKey;
	int buildIdentity;
	NSString *mountVolume;

}

@property (nonatomic, retain) NSString *filePath;
@property (nonatomic, retain) NSString *fwName;
@property (nonatomic, retain) NSString *unzipLocation;
@property (nonatomic, retain) NSString *vfDecryptKey;
@property (readwrite, assign) int buildIdentity;
@property (nonatomic, retain) NSString *mountVolume;

- (NSDictionary *)manifest;
- (NSDictionary *)buildManifest;
- (NSDictionary *)restoreDictionary;

- (NSString *)platform;
- (NSString *)BoardConfig;

- (NSString *)ProductBuildVersion;
- (NSString *)ProductType;
- (NSString *)ProductVersion;
- (NSString *)GlyphCharging;
- (NSString *)AppleLogo;
- (NSString *)BatteryCharging0;
- (NSString *)BatteryCharging1;
- (NSString *)BatteryFull;
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

- (NSArray *)keyArray;
- (void)setBuildIdentity;
-(NSArray *)manifestArray;
-(NSArray *)kbagArray;

-(NSString *)plistPath;
-(NSDictionary *)ramdiskKey;

-(NSDictionary *)keyRepository; //final dictionary with iv's and k's

-(BOOL)isDecrypted;

-(NSString *)vfDecryptKey;
- (NSString *)convertForWiki;
- (NSString *)wikiPath;
- (NSString *)privateFrameworksPath;
- (NSString *)frameworksPath;
- (NSString *)convertForBundle;
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