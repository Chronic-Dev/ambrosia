
#import "ACommon.h"



@implementation ACommon

+ (id)sharedCommon
{
	static ACommon *shared = nil;
	if(shared == nil)
		shared = [[ACommon alloc] init];
	
	return shared;
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
		//NSLog(@"hdiutil %@", [[irTask arguments] componentsJoinedByString:@" "]);
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
		
		NSLog(@"%@", the_error);
		
		[the_error release];
		
	}
		//NSLog(@"plist: %@", plist);
	
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
				//NSLog(@"Mount Point: %@", mountPath);
			
			
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
		NSLog(@"%@", command);
	return [ACommon singleLineReturnForProcess:command];
	
}

+ (NSString *)decryptFilesystem:(NSString *)fileSystem withKey:(NSString *)fileSystemKey
{
	NSTask *vfTask = [[NSTask alloc] init];
	[vfTask setLaunchPath:VFDECRYPT];
	NSString *decrypted = [[[fileSystem stringByDeletingPathExtension] stringByAppendingString:@"_decrypt"] stringByAppendingPathExtension:@"dmg"];
	[vfTask setArguments:[NSArray arrayWithObjects:@"-i", fileSystem, @"-k", fileSystemKey, @"-o", decrypted, nil]];
		NSLog(@"%@ %@\n", VFDECRYPT, [[vfTask arguments] componentsJoinedByString:@" "]);
		//[vfTask setStandardError:NULLOUT];
		//[vfTask setStandardOutput:NULLOUT];
	[vfTask launch];
	[vfTask waitUntilExit];
	
	int returnStatus = [vfTask terminationStatus];
	NSLog(@"decryptFilesystem: %i", returnStatus);
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
			//NSLog(@"temp length: %i", [temp length]);
		
		if ([temp length] > 800)
		{
			[swh closeFile];
			[pwnHelper release];
			
			pwnHelper = nil;
			return [NSArray arrayWithObject:@"TRY_AGAIN"];
		}
		
			//NSLog(@"temp: %@", [temp componentsSeparatedByString:@" "]);
			//[lineArray addObject:[temp stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]]];
			//NSArray *arrayOne = [temp componentsSeparatedByString:@"\n"];
			//NSLog(@"arrayOneCount: %i", [arrayOne count]);
			//NSArray *arrayTwo = [[arrayOne objectAtIndex:0] componentsSeparatedByString:@" "];
		[lineArray addObjectsFromArray:[[temp stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]] componentsSeparatedByString:@" "]];
		[temp release];
    }
	
	
	
		//	NSLog(@"lineARray: %@", lineArray);
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
	
		//NSLog(@"uzp2: %@", uzp2);
	NSTask *unzipTask = [[NSTask alloc] init];
	
	
	[unzipTask setLaunchPath:uzp];
	[unzipTask setArguments:[NSArray arrayWithObjects:@"-o", theFile, @"-d", newPath, @"-x", @"*MACOSX*", nil]];
	[unzipTask setStandardOutput:nullOut];
	[unzipTask setStandardError:nullOut];
	[unzipTask launch];
	[unzipTask waitUntilExit];
	int theTerm = [unzipTask terminationStatus];
		//NSLog(@"helperTask terminated with status: %i",theTerm);
	if (theTerm != 0)
	{
			//NSLog(@"failure unzip %@ to %@", theFile, newPath);
		return (FALSE);
		
	} else if (theTerm == 0){
			//NSLog(@"success unzip %@ to %@", theFile, newPath);
		
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
		//NSLog(@"decryptArgs; %@", decryptArgs);
	NSLog(@"xpwntool %@\n", [decryptArgs componentsJoinedByString:@" "]);
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

- (void)threadedUnzipFile:(NSDictionary *)theDict
{
	NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
	NSString *theFile = [theDict valueForKey:@"theFile"];
	NSString *newPath = [theDict valueForKey:@"newPath"];
	
	NSString *uzp = @"/usr/bin/unzip";
	
		//NSFileManager *man = [NSFileManager defaultManager];
	
	NSFileHandle *nullOut = [NSFileHandle fileHandleWithNullDevice];
	
		//NSLog(@"uzp2: %@", uzp2);
	NSTask *unzipTask = [[NSTask alloc] init];
	
	
	[unzipTask setLaunchPath:uzp];
	[unzipTask setArguments:[NSArray arrayWithObjects:@"-o", theFile, @"-d", newPath, @"-x", @"*MACOSX*", nil]];
	[unzipTask setStandardOutput:nullOut];
	[unzipTask setStandardError:nullOut];
	[unzipTask launch];
	[unzipTask waitUntilExit];
	NSLog(@"unzip finished!");
	
	[[NSNotificationCenter defaultCenter] postNotificationName:@"unzipComplete" object:nil userInfo:theDict];
	[pool release];
}


@end
