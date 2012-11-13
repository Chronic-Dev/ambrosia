//
//  patchClass.h
//  countHelper
//
//  Created by Kevin Bradley on 8/9/11.
//  Copyright 2011 nito, LLC. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@interface patchClass : NSObject {

	
}


+ (NSString *)popr0123FromFile:(NSString *)inputFile;
+ (NSString *)blxb4pop47FromFile:(NSString *)inputFile;
+ (NSString *)patchDFUFile:(NSString *)inputFile;
+ (NSString *)patchKernelFile:(NSString *)inputFile;
+ (NSString *)patchASRFile:(NSString *)inputFile;
+ (NSString *)createBSDiffFromOriginal:(NSString *)original newFile:(NSString *)newFile;
@end
