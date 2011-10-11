//
//  patchClass.m
//  countHelper
//
//  Created by Kevin Bradley on 8/9/11.
//  Copyright 2011 nito, LLC. All rights reserved.
//

#import "patchClass.h"


@implementation patchClass

+ (NSMutableData *)patchFile:(NSString *)inputFile bytes:(const void *)oldBytes withBytes:(const void *)newBytes length:(int)dataLength previousData:(NSMutableData *)previousData
{
	NSMutableData *myData = nil;
	if (previousData != nil)
		myData = previousData;
	else
		myData = [[NSMutableData alloc] initWithContentsOfMappedFile:inputFile];
		//NSString *newFile = [inputFile stringByAppendingPathExtension:@"patched"];
	NSData *dataToFind = [NSData dataWithBytes:oldBytes length:dataLength];
	NSData *patchData =  [NSData dataWithBytes:newBytes length:dataLength];
	NSRange searchRange = NSMakeRange(0, myData.length);
	NSRange dataRange = [myData rangeOfData:dataToFind options:0 range:searchRange];
	[myData replaceBytesInRange: dataRange withBytes: [patchData bytes]];
	return [myData autorelease];
		//[myData writeToFile:newFile atomically:YES];
}
/*
 
 RawPatch(ASRfile, "0x1340E", "F5 E7") 'jump : originally 4D F2 on b5/b6 (maybe earlier too)
 RawPatch(ASRfile, "0x2BEF6", "F6 93 B6 C7 4F 33 E1 BA E2 9D BC 30 1B 81 DE D2 0D 65 10 76") 'sig fix
 
 b5 sigfix is originally FD 4A DF B2 C6 B1 9A 72 1C BB 80 E0 D9 7E 8B C4 32 61 21 9A 
 b6 sigfix is originally FD 4A DF B2 C6 B1 9A 72 1C BB 80 E0 D9 7E 8B C4 32 61 21 9A 
 
 iPod 5 GM is originally  FD 4A DF B2 C6 B1 9A 72 1C BB 80 E0 D9 7E 8B C4 32 61 21 9A
 
 */

+ (NSString *)patchKernelFile:(NSString *)inputFile
{
	NSMutableData *myData = [[NSMutableData alloc] initWithContentsOfMappedFile:inputFile];
	NSString *newFile = [inputFile stringByAppendingPathExtension:@"patched"];
	
		//FindNPatch(KernelFile, "A2 6A 1B 68 00 2B 04 BF", "A2 6A 01 23 00 2B 04 BF")
	
	NSData *dataToFind = [NSData dataWithBytes:"\xA2\x6A\x1B\x68\x00\x2B\x04\xBF" length:8];
	NSData *patchData =  [NSData dataWithBytes:"\xA2\x6A\x01\x23\x00\x2B\x04\xBF" length:8];
	NSRange searchRange = NSMakeRange(0, myData.length);
	NSRange dataRange = [myData rangeOfData:dataToFind options:0 range:searchRange];
	
	if (dataRange.location == NSNotFound)
	{
		NSLog(@"first kernel patch failed, %@ not found", dataToFind);
	}
	
	[myData replaceBytesInRange: dataRange withBytes: [patchData bytes]];

		//	NSLog(@"first patch location: %lld", dataRange.location);
	
	if ([[[inputFile lastPathComponent] pathExtension] isEqualToString:@"k66"]) //dont need for appletv
	{
		NSLog(@"appletv skip vm_map_enter");
		
	} else {
			//iPod GM 5: 06 00 06 28 04 BF 19 98
		
			//FindNPatch(KernelFile, "06 00 06 28 04 BF 22 98", "06 00 FF") //vm_map_enter - may be unnessesary
		
		dataToFind = [NSData dataWithBytes:"\x06\x00\x06\x28\x04\xBF\x19\x98" length:8];
		patchData =  [NSData dataWithBytes:"\x06\x00\xFF\x28\x04\xBF\x19\x98" length:8];
		dataRange = [myData rangeOfData:dataToFind options:0 range:searchRange];
		
		[myData replaceBytesInRange: dataRange withBytes: [patchData bytes]];
		
		if (dataRange.location == NSNotFound)
		{
			NSLog(@"second kernel patch failed, %@ not found, vm_map_enter", dataToFind);
		}
	}
	
		//FindNPatch(KernelFile, "B0 F1 FF 3F DC BF 43 48 5C F7 0A FD", "00 00 00 00 00 00 00 00 00 00 00 00") '' //B0 F1 FF 3F DC BF 43 48 5C F7 E8 FC  instead?? @ offset 000B8C9C
	
		//b4			   B0 F1 FF 3F DC BF 43 48 5C F7 E8 FC 
		//changed again b5 B0 F1 FF 3F DC BF 43 48 5F F7 12 FB
		//changed again b6 B0 F1 FF 3F DC BF 43 48 5E F7 0E FB
	
		//ipod 5.0 GM B0 F1 FF 3F DC BF 43 48 5E F7 0E FB
		
	
		//dataToFind = [NSData dataWithBytes:"\xB0\xF1\xFF\x3F\xDC\xBF\x43\x48\x5C\xF7\xE8\xFC" length:12]; //b4	
		//dataToFind = [NSData dataWithBytes:"\xB0\xF1\xFF\x3F\xDC\xBF\x43\x48\x5F\xF7\x12\xFB" length:12]; //b5
		//dataToFind = [NSData dataWithBytes:"\xB0\xF1\xFF\x3F\xDC\xBF\x43\x48\x5E\xF7\x0E\xFB" length:12]; //b6
		
		dataToFind = [NSData dataWithBytes:"\xB0\xF1\xFF\x3F\xDC\xBF\x43\x48" length:8];
		patchData =  [NSData dataWithBytes:"\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00" length:12];
		dataRange = [myData rangeOfData:dataToFind options:0 range:searchRange];
		//dataRange2 = [myData rangeOfData:[NSData dataWithBytes:"\xB0\xF1\xFF\x3F\xDC\xBF\x43\x48" length:8] options:0 range:searchRange];
		//adjust data range to actually be 12 rather than 8
		dataRange.length = 12;
		[myData replaceBytesInRange: dataRange withBytes: [patchData bytes]];
	
		//NSLog(@"third kernel patch location: %lld length: %lld", dataRange.location, dataRange.length);
		//	NSLog(@"third kernel patch location2: %lld length: %lld", dataRange2.location, dataRange2.length);
	
	if (dataRange.location == NSNotFound)
	{
		NSLog(@"third kernel patch failed, %@ not found", dataToFind);
	}
	
	
		//FindNPatch(KernelFile, "00 21 B0 45 F0 DB 08 46 BD E8 00 05", "00 21 B0 45 F0 DB 01 20")
	
	dataToFind = [NSData dataWithBytes:"\x00\x21\xB0\x45\xF0\xDB\x08\x46\xBD\xE8\x00\x05" length:12];
	patchData =  [NSData dataWithBytes:"\x00\x21\xB0\x45\xF0\xDB\x01\x20\xBD\xE8\x00\x05" length:12];
	dataRange = [myData rangeOfData:dataToFind options:0 range:searchRange];
	[myData replaceBytesInRange: dataRange withBytes: [patchData bytes]];
	
	if (dataRange.location == NSNotFound)
	{
		NSLog(@"fourth kernel patch failed, %@ not found", dataToFind);
	}
	
		//FindNPatch(KernelFile, "00 78 10 F0 04 0F 04 D0", "00 78 01 23 01 23")
	
	dataToFind = [NSData dataWithBytes:"\x00\x78\x10\xF0\x04\x0F\x04\xD0" length:8];
	patchData =  [NSData dataWithBytes:"\x00\x78\x01\x23\x04\x0F\x04\xD0" length:8];
	dataRange = [myData rangeOfData:dataToFind options:0 range:searchRange];
	[myData replaceBytesInRange: dataRange withBytes: [patchData bytes]];
	
	if (dataRange.location == NSNotFound)
	{
		NSLog(@"fifth kernel patch failed, %@ not found", dataToFind);
	}
	
		//FindNPatch(KernelFile, "FF 31 A7 F1 18 04 08 46 A5 46 BD E8 00 0D F0 BD", "FF 31 A7 F1 18 04 00 20")
	
	dataToFind = [NSData dataWithBytes:"\xFF\x31\xA7\xF1\x18\x04\x08\x46\xA5\x46\xBD\xE8\x00\x0D\xF0\xBD" length:16];
	patchData =  [NSData dataWithBytes:"\xFF\x31\xA7\xF1\x18\x04\x00\x20\xA5\x46\xBD\xE8\x00\x0D\xF0\xBD" length:16];
	dataRange = [myData rangeOfData:dataToFind options:0 range:searchRange];
	[myData replaceBytesInRange: dataRange withBytes: [patchData bytes]];
	
	if (dataRange.location == NSNotFound)
	{
		NSLog(@"sixth kernel patch failed, %@ not found", dataToFind);
	}
	
	[myData writeToFile:newFile atomically:YES];
	
		//create patch
	
	return [patchClass createBSDiffFromOriginal:inputFile newFile:newFile];
	
}

+ (NSString *)patchDFUFile:(NSString *)inputFile
{
	NSMutableData *myData = [[NSMutableData alloc] initWithContentsOfMappedFile:inputFile];
	NSString *newFile = [inputFile stringByAppendingPathExtension:@"patched"];
	
		//PROD 03 93 FF F7 2F FE 00 28
	
	NSData *dataToFind = [NSData dataWithBytes:"\x03\x93\xFF\xF7\x2F\xFE\x00\x28" length:8];
	NSData *patchData =  [NSData dataWithBytes:"\x03\x93\x00\x20\x00\x20\x00\x28" length:8];
	NSRange searchRange = NSMakeRange(0, myData.length);
	NSRange dataRange = [myData rangeOfData:dataToFind options:0 range:searchRange];
	[myData replaceBytesInRange: dataRange withBytes: [patchData bytes]];

	if (dataRange.location == NSNotFound)
	{
		NSLog(@"PROD patch failed, %@ not found", patchData);
	}
	
		//SDOM 03 93 FF F7 42 FE 00 28
	
	dataToFind = [NSData dataWithBytes:"\x03\x93\xFF\xF7\x42\xFE\x00\x28" length:8];
	patchData =  [NSData dataWithBytes:"\x03\x93\x00\x20\x00\x20\x00\x28" length:8];
	dataRange = [myData rangeOfData:dataToFind options:0 range:searchRange];
	[myData replaceBytesInRange: dataRange withBytes: [patchData bytes]];
	
	if (dataRange.location == NSNotFound)
	{
		NSLog(@"SDOM patch failed, %@ not found", patchData);
	}
	
	
	
		//CHIP 03 93 FF F7 10 FE 00 28
	
	dataToFind = [NSData dataWithBytes:"\x03\x93\xFF\xF7\x10\xFE\x00\x28" length:8];
	patchData =  [NSData dataWithBytes:"\x03\x93\x00\x20\x00\x20\x00\x28" length:8];
	dataRange = [myData rangeOfData:dataToFind options:0 range:searchRange];
	[myData replaceBytesInRange: dataRange withBytes: [patchData bytes]];
	
	
	if (dataRange.location == NSNotFound)
	{
		NSLog(@"CHIP patch failed, %@ not found", patchData);
	}
	
	
	
		//TYPE 03 93 FF F7 FE FD 00 28
	
	dataToFind = [NSData dataWithBytes:"\x03\x93\xFF\xF7\xFE\xFD\x00\x28" length:8];
	patchData =  [NSData dataWithBytes:"\x03\x93\x00\x20\x00\x20\x00\x28" length:8];
	dataRange = [myData rangeOfData:dataToFind options:0 range:searchRange];
	[myData replaceBytesInRange: dataRange withBytes: [patchData bytes]];
	
	
	if (dataRange.location == NSNotFound)
	{
		NSLog(@"TYPE patch failed, %@ not found", patchData);
	}
	
		//SEPO 03 95 FF F7 E8 FD 00 28
	
	dataToFind = [NSData dataWithBytes:"\x03\x95\xFF\xF7\xE8\xFD\x00\x28" length:8];
	patchData =  [NSData dataWithBytes:"\x03\x95\x00\x20\x00\x20\x00\x28" length:8];
	dataRange = [myData rangeOfData:dataToFind options:0 range:searchRange];
	[myData replaceBytesInRange: dataRange withBytes: [patchData bytes]];
	
	if (dataRange.location == NSNotFound)
	{
		NSLog(@"SEPO patch failed, %@ not found", patchData);
	}
	
	
		//CEPO 03 95 FF F7 D6 FD 00 28
	
	dataToFind = [NSData dataWithBytes:"\x03\x95\xFF\xF7\xD6\xFD\x00\x28" length:8];
	patchData =  [NSData dataWithBytes:"\x03\x95\x00\x20\x00\x20\x00\x28" length:8];
	dataRange = [myData rangeOfData:dataToFind options:0 range:searchRange];
	[myData replaceBytesInRange: dataRange withBytes: [patchData bytes]];
	
	if (dataRange.location == NSNotFound)
	{
		NSLog(@"CEPO patch failed, %@ not found", patchData);
	}
	
	
		//BORD 03 94 FF F7 C4 FD 00 28
	
	dataToFind = [NSData dataWithBytes:"\x03\x94\xFF\xF7\xC4\xFD\x00\x28" length:8];
	patchData =  [NSData dataWithBytes:"\x03\x94\x00\x20\x00\x20\x00\x28" length:8];
	dataRange = [myData rangeOfData:dataToFind options:0 range:searchRange];
	[myData replaceBytesInRange: dataRange withBytes: [patchData bytes]];
	
	
	
	if (dataRange.location == NSNotFound)
	{
		NSLog(@"BORD patch failed, %@ not found", patchData);
	}
	
		//ECID 03 94 FF F7 AF FD 00 28
	
	dataToFind = [NSData dataWithBytes:"\x03\x94\xFF\xF7\xAF\xFD\x00\x28" length:8];
	patchData =  [NSData dataWithBytes:"\x03\x94\x00\x20\x00\x20\x00\x28" length:8];
	dataRange = [myData rangeOfData:dataToFind options:0 range:searchRange];
	[myData replaceBytesInRange: dataRange withBytes: [patchData bytes]];
	
	if (dataRange.location == NSNotFound)
	{
		NSLog(@"ECID patch failed, %@ not found", patchData);
	}
	
		//SHSH [patchClass patchFile:one bytes:"\x4F\xF0\xFF\x30\x01\xE0\x4F\xF0\xFF\x30" withBytes:"\x00\x20\x00\x20\x01\xE0\x00\x20\x00\x20" length:10]; //SHSH
	
		//4F F0 FF 30 01 E0 4F F0 FF 30
	
	dataToFind = [NSData dataWithBytes:"\x4F\xF0\xFF\x30\x01\xE0\x4F\xF0\xFF\x30" length:10];
	patchData =  [NSData dataWithBytes:"\x00\x20\x00\x20\x01\xE0\x00\x20\x00\x20" length:10];
	dataRange = [myData rangeOfData:dataToFind options:0 range:searchRange];
	[myData replaceBytesInRange: dataRange withBytes: [patchData bytes]];
	
	if (dataRange.location == NSNotFound)
	{
		NSLog(@"SHSH patch failed, %@ not found", patchData);
	}
	
	[myData writeToFile:newFile atomically:YES];
	
	return [patchClass createBSDiffFromOriginal:inputFile newFile:newFile];
}

+ (NSString *)createBSDiffFromOriginal:(NSString *)original newFile:(NSString *)newFile
{
	NSString *newNameBase = [original stringByDeletingPathExtension];
	NSMutableString *patchFile = [[NSMutableString alloc] initWithString:newNameBase];
	[patchFile replaceOccurrencesOfString:@"_abdec" withString:@"" options:NSLiteralSearch range:NSMakeRange(0, [patchFile length])];
	[patchFile appendString:@".patch"];
	NSTask *theTask = [NSTask launchedTaskWithLaunchPath:@"/usr/bin/bsdiff" arguments:[NSArray arrayWithObjects:original, newFile, patchFile, nil]];
	[theTask waitUntilExit];
	return [patchFile autorelease];
	
}

#define JUMP_RANGE NSMakeRange(0x1340E, 2)
#define SIG_RANGE NSMakeRange(0x2BEF6, 20)


	//179958

+ (NSString *)patchASRFile:(NSString *)inputFile
{
	
	/*
	 
	 RawPatch(ASRfile, "0x1340E", "F5 E7") 'jump : originally 4D F2 on b5/b6 (maybe earlier too)
	 RawPatch(ASRfile, "0x2BEF6", "F6 93 B6 C7 4F 33 E1 BA E2 9D BC 30 1B 81 DE D2 0D 65 10 76") 'sig fix
	 
	 
	 */

	NSString *newFile = [inputFile stringByAppendingString:@"_patched"];
	NSMutableData *myData = [[NSMutableData alloc] initWithContentsOfMappedFile:inputFile];
	char *jump_PROPER = "\x4D\xF2";
	char *sig_PROPER = "\xFD\x4A\xDF\xB2\xC6\xB1\x9A\x72\x1C\xBB\x80\xE0\xD9\x7E\x8B\xC4\x32\x61\x21\x9A";
	
	NSData *jumpProperData = [NSData dataWithBytes:jump_PROPER length:strlen(jump_PROPER)];
	NSData *sig_ProperData = [NSData dataWithBytes:sig_PROPER length:strlen(sig_PROPER)];
	
	NSData *jump_OGData = [myData subdataWithRange:JUMP_RANGE];
	NSData *sig_OGData = [myData subdataWithRange:SIG_RANGE];
	
	if ([jump_OGData isEqualToData:jumpProperData])
	{
		[myData replaceBytesInRange:JUMP_RANGE withBytes:"\xF5\xE7"];
		NSLog(@"asr jump patched successfully");
	}

	if ([sig_OGData isEqualToData:sig_ProperData])
	{
		[myData replaceBytesInRange:SIG_RANGE withBytes:"\xF6\x93\xB6\xC7\x4F\x33\xE1\xBA\xE2\x9D\xBC\x30\x1B\x81\xDE\xD2\x0D\x65\x10\x76"];
		NSLog(@"sigcheck patched successfully");
	}
	
	NSLog(@"sigRangeLocation: %lld", SIG_RANGE.location);
	
	BOOL writeFile = [myData writeToFile:newFile atomically:YES];
	[myData release];
	if (writeFile)
	{
			
		NSLog(@"success!");
		return [patchClass createBSDiffFromOriginal:inputFile newFile:newFile];
		
	}
	return nil;
}

+ (void)patchTest:(NSString *)inputFile
{
	NSMutableData *myData = [[NSMutableData alloc] initWithContentsOfMappedFile:inputFile];
	NSString *newFile = [inputFile stringByAppendingPathExtension:@"patched"];
	NSData *dataToFind = [NSData dataWithBytes:"\x03\x93\xFF\xF7\x2F\xFE\x00\x28" length:8];
	NSData *patchData = [NSData dataWithBytes:"\x03\x93\x00\x20\x00\x20\x00\x28" length:8];
	NSRange searchRange = NSMakeRange(0, myData.length);
	NSRange dataRange = [myData rangeOfData:dataToFind options:0 range:searchRange];
	[myData replaceBytesInRange: dataRange withBytes: [patchData bytes]];
	[myData writeToFile:newFile atomically:YES];
	
}

-(NSString*)stringFromData:(NSData*)data position:(NSUInteger*)position
{
    NSUInteger start = *position;
    NSData* endStringData = [NSData dataWithBytes:"\0" length:1];
    NSRange searchRange = NSMakeRange(start, data.length - start);
    NSRange endStringRange = [data rangeOfData:endStringData options:0 range:searchRange];
    *position = endStringRange.location;
    NSRange stringRange = NSMakeRange(start, *position - start);
    NSData* stringData = [data subdataWithRange:stringRange];
    return [[[NSString alloc] initWithData:stringData encoding:NSASCIIStringEncoding] autorelease];
}

@end
