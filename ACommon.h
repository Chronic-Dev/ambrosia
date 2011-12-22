

@interface ACommon : NSObject

{
	
}
+ (NSString *)absintheFiles;
+ (NSString *)IOLogOffsetFromKernel:(NSString *)kernel;
+ (NSArray *)extractSystemLibsFromVolume:(NSString *)theVolume toPath:(NSString *)outputPath;
+ (NSArray *)returnForTask:(NSString *)taskBinary withArguments:(NSArray *)taskArguments fromPath:(NSString *)runFolder;
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
+ (NSDictionary *)decryptFilesystemFromFirmware:(id)currentFirmware;
+ (void)changeStatus:(NSString *)theStatus;
+ (NSArray *)returnForTask:(NSString *)taskBinary withArguments:(NSArray *)taskArguments;
+ (NSString *)SHA1FromFile:(NSString *)inputFile;
+ (NSArray *)dyldcacheContentsFromVolume:(NSString *)theVolume;
+ (NSString *)dyldcacheFileFromVolume:(NSString *)theVolume;
+ (NSString *)stringReturnForTask:(NSString *)taskBinary withArguments:(NSArray *)taskArguments;
+ (NSString *)stringReturnForTask:(NSString *)taskBinary withArguments:(NSArray *)taskArguments fromLocation:(NSString *)outputPath;
@end


