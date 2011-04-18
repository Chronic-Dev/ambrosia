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
	
	AFirmware *currentFirmware;
}
- (IBAction)poison:(id)sender;
@property (assign) IBOutlet NSWindow *window;
@property (assign) IBOutlet NSButton *ipswButton;
@property (assign) IBOutlet NSButton *pois0nButton;
@property (assign) AFirmware *currentFirmware;
@property (readwrite, assign) BOOL poisoning;

- (IBAction)sendCommand:(id)sender;
- (IBAction)testRun:(id)sender;
- (void)startOverMan;
@end
