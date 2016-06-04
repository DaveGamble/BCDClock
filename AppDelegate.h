//
//  AppDelegate.h
//  BCDClock
//
//  Created by Dave on 04/06/2016.
//
//

#import <Cocoa/Cocoa.h>

@interface AppDelegate : NSObject <NSApplicationDelegate>
@property (nonatomic, readonly) NSStatusItem *statusItem;
@property (nonatomic, strong) IBOutlet NSMenu *menu;
@property (nonatomic, strong) IBOutlet NSMenu *submenu;

-(IBAction) doType0:(id)sender;
-(IBAction) doType1:(id)sender;
-(IBAction) doType2:(id)sender;
-(IBAction) doType3:(id)sender;

@end

