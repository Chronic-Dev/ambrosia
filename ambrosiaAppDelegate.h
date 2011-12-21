//
//  ambrosiaAppDelegate.h
//  ambrosia
//
//  Created by Kevin Bradley on 4/14/11.
//  Copyright 2011 Chronic-Dev Team. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "include/libpois0n.h"

@interface ambrosiaAppDelegate : NSObject <NSApplicationDelegate> {
    NSWindow *window;
	IBOutlet NSButton *ipswButton;
	IBOutlet NSButton *pois0nButton;
	BOOL poisoning;
	IBOutlet NSProgressIndicator *downloadBar;
	IBOutlet NSTextField *downloadProgressField;
	IBOutlet NSTextField *instructionField;
	IBOutlet NSImageView *instructionImage;
	
	AFirmware *currentFirmware;
}



- (IBAction)poison:(id)sender;
@property (assign) IBOutlet NSWindow *window;
@property (assign) IBOutlet NSProgressIndicator *downloadBar;
@property (assign) IBOutlet NSTextField *downloadProgressField;
@property (assign) IBOutlet NSTextField *instructionField;
@property (assign) IBOutlet NSImageView *instructionImage;
@property (assign) IBOutlet NSButton *ipswButton;
@property (assign) IBOutlet NSButton *pois0nButton;
@property (assign) AFirmware *currentFirmware;
@property (readwrite, assign) BOOL poisoning;

- (NSArray *)dumpKernelSymbolsFromFirmwareFolder:(NSString *)outputFolder;
- (NSArray *)dumpCSymbolsFromFirmwareFolder:(NSString *)outputFolder;

-(NSArray *)kbagArray;
- (void)setDownloadProgress:(double)theProgress;
- (void)setInstructionText:(NSString *)instructions;
- (void)setDownloadText:(NSString *)downloadString;
- (IBAction)sendCommand:(id)sender;
- (IBAction)testRun:(id)sender;
- (void)startOverMan;
- (void)killiTunes;
- (void)showProgress;
- (void)hideProgress;
- (int)inject;
- (IBAction)poison:(id)sender;
- (IBAction)sendCommand:(id)sender;
- (void)processPFHeaders:(NSArray *)cacheArray fromCache:(NSString *)dyldcacheFile;
- (void)processFHeaders:(NSArray *)cacheArray fromCache:(NSString *)dyldcacheFile;


- (BOOL)hasDownloadLink:(NSDictionary *)theDict;
- (NSDictionary *)dictionaryForWikiFirmware:(NSString *)theString;
- (NSString *)dmgNameFromFullName:(NSString *)theName;
- (BOOL)isDMG:(NSString *)theString;
@end
