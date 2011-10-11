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

+ (NSString *)patchDFUFile:(NSString *)inputFile;
+ (NSString *)patchKernelFile:(NSString *)inputFile;
+ (NSString *)patchASRFile:(NSString *)inputFile;
+ (NSString *)createBSDiffFromOriginal:(NSString *)original newFile:(NSString *)newFile;
@end
