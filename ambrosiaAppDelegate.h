//
//  ambrosiaAppDelegate.h
//  ambrosia
//
//  Created by Kevin Bradley on 4/14/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface ambrosiaAppDelegate : NSObject <NSApplicationDelegate> {
    NSWindow *window;
	IBOutlet NSButton *ipswButton;
	
	AFirmware *currentFirmware;
}

@property (assign) IBOutlet NSWindow *window;
@property (assign) IBOutlet NSButton *ipswButton;
@property (assign) AFirmware *currentFirmware;

- (IBAction)testRun:(id)sender;

@end
