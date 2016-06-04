//
//  AppDelegate.m
//  BCDClockHelper
//
//  Created by Dave on 04/06/2016.
//  Copyright © 2016 dmgaudio. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface AppDelegate : NSObject <NSApplicationDelegate>
@end

@implementation AppDelegate

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
	// If you find the app running, then bail.
	for (NSRunningApplication *app in [[NSWorkspace sharedWorkspace] runningApplications])
		if ([[app bundleIdentifier] isEqualToString:@"com.dmgaudio.BCDClock"]) [NSApp terminate:nil];
	
	// Where am I?
	NSArray *p = [[[NSBundle mainBundle] bundlePath] pathComponents];
	// Point at the app itself.
	NSMutableArray *pathComponents = [NSMutableArray arrayWithArray:p];
	[pathComponents removeLastObject];[pathComponents removeLastObject];[pathComponents removeLastObject];
	[pathComponents addObject:@"MacOS"];[pathComponents addObject:@"BCDClock"];
	// Launch it.
	[[NSWorkspace sharedWorkspace] launchApplication:[NSString pathWithComponents:pathComponents]];
	[NSApp terminate:nil];	// Bail.
}

@end

int main(int argc, const char * argv[]) {return NSApplicationMain(argc, argv);}

