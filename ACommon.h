

@interface ACommon : NSObject

{
	
}

+ (id)sharedCommon;
+ (NSDictionary *)decryptedKbag:(NSString *)theKbag;
+ (NSString *)mountImage:(NSString *)irString;
+ (NSString *)genpassFromRamdisk:(NSString *)ramdisk platform:(NSString *)thePlatform andFilesystem:(NSString *)theFilesystem;
+ (NSString *)decryptFilesystem:(NSString *)fileSystem withKey:(NSString *)fileSystemKey;
+ (NSArray *)runHelper:(NSString *)theKbag;
+ (int)decryptRamdisk:(NSString *)theRamdisk toPath:(NSString *)outputDisk withIV:(NSString *)iv key:(NSString *)key;
+(NSString *)singleLineReturnForProcess:(NSString *)call;
+(NSArray *)returnForProcess:(NSString *)call;
+ (BOOL)unzipFile:(NSString *)theFile toPath:(NSString *)newPath;
+ (NSString *)applicationSupportFolder;
+ (NSString *)firmwarePath;
+ (NSString *)decryptFilesystemFromFirmware:(id)currentFirmware;
+ (void)statusChanged:(NSNotification *)n;
@end


