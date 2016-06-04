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

-(IBAction) setType:(id)sender;
-(IBAction) setLogin:(id)sender;

@end

