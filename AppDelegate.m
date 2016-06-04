//
//  AppDelegate.m
//  BCDClock
//
//  Created by Dave on 04/06/2016.
//
//

#import "AppDelegate.h"

@interface NSStatusBar (can_position)
- (NSStatusItem *)_statusItemWithLength:(CGFloat)length	withPriority:(int)priority;
@end


@interface AppDelegate ()
@property (nonatomic, strong, readwrite) NSStatusItem *statusItem;
@property (nonatomic, strong, readwrite) NSTimer *timer;
@property bool menuIsOpen;
@property NSInteger _type;
@end

@implementation AppDelegate

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
	// Settings:
	[[NSUserDefaults standardUserDefaults] registerDefaults:@{@"type": [NSNumber numberWithInteger:3]}];
	[self setType:[[NSUserDefaults standardUserDefaults] integerForKey:@"type"]];

	// Menu is shut.
	self.menuIsOpen=false;
	// Set up the statusitem.
	self.statusItem = [[NSStatusBar systemStatusBar] _statusItemWithLength:NSVariableStatusItemLength withPriority:-20];
	self.statusItem.menu = self.menu;
	// Set up the timer.
	self.timer = [NSTimer scheduledTimerWithTimeInterval:(NSTimeInterval)1.0 target:self selector:@selector(onTick:) userInfo:nil repeats:YES];
	[[NSRunLoop mainRunLoop] addTimer:self.timer forMode:NSRunLoopCommonModes];	// Ensure we update while menu is open.
}
- (void)applicationWillTerminate:(NSNotification *)aNotification {[self.timer invalidate];}

- (void)menuWillOpen:(id)sender {self.menuIsOpen=true;[self onTick:self.timer];}	// Track whether the menu is open. Only update the menu if it is.
- (void)menuDidClose:(id)sender {self.menuIsOpen=false;}

- (void) onTick:(NSTimer*)timer
{
	NSImage *img=[self getImage:[[[NSApplication sharedApplication] mainMenu] menuBarHeight]];	// Get the image.
	[self.statusItem setLength:[img size].width];
	[self.statusItem.button setImage:img];	// Set the image.
	[self.statusItem.button setBounds:NSMakeRect(0,0,[img size].width,[img size].height)];	// Set the bounds
	
	if (self.menuIsOpen)	// Update the menus if necessary.
	{
		NSDateFormatter *datefmt=[[NSDateFormatter alloc] init];[datefmt setDateFormat:@"EE d MMM yyyy"];
		NSDateFormatter *timefmt=[[NSDateFormatter alloc] init];[timefmt setTimeStyle:NSDateFormatterMediumStyle];[timefmt setDateStyle:NSDateFormatterNoStyle];
		NSDate *date=[NSDate date];
		[[self.menu itemAtIndex:1] setTitle: [datefmt stringFromDate:date]];
		[[self.menu itemAtIndex:0] setTitle: [timefmt stringFromDate:date]];
	}
}

- (void)setType:(NSInteger)type
{
	self._type=type;
	for (int i=0;i<4;i++) [[self.submenu itemAtIndex:i] setState:(i==type)?NSOnState:NSOffState];
	[[NSUserDefaults standardUserDefaults] setInteger:type forKey:@"type"];
	[[NSUserDefaults standardUserDefaults] synchronize];
}

-(IBAction) doType0:(id)sender {[self setType:0];}
-(IBAction) doType1:(id)sender {[self setType:1];}
-(IBAction) doType2:(id)sender {[self setType:2];}
-(IBAction) doType3:(id)sender {[self setType:3];}

static char hours[12][16]={"twelve","one","two","three","four","five","six","seven","eight","nine","ten","eleven"};
static char minutes[13][20]={"shortly after","five past","ten past","quarter past","twenty past","twentyfive past","half past",
	"twentyfive to","twenty to","quarter to","ten to","five to","nearly"};

- (NSImage*)getImage:(int)barHeight {
	NSDateComponents *date = [[NSCalendar currentCalendar] components:NSCalendarUnitHour|NSCalendarUnitMinute|NSCalendarUnitSecond fromDate:[NSDate date]];
	int hour=(int)[date hour],minute=(int)[date minute],second=(int)[date second],pm=0;
	if (hour==24) hour=0;if (hour>=12) hour-=12,pm=1;if (hour==0) hour=12;	// jiggle PM.
	
	NSDictionary *dict=@{NSFontAttributeName:[NSFont menuBarFontOfSize:13]};
	
	
	NSString *str=0;int width=40,height=barHeight;
	switch (self._type)
	{
	case 2:
		str=[NSString stringWithFormat:@"%2d:%02d:%02d %s",hour,minute,second,pm?"pm":"am"];
		break;
	case 3:
		if (!minute) str=(pm && hour==0)?@"Midnight":[NSString stringWithFormat:@"%s o'clock",hours[hour%12]];
		else
		{
			float f=((second/60.f)+minute+2.5)/5.f;
			str=[NSString stringWithFormat:@"%s %s",minutes[(int)f],hours[(((int)f<=6)?hour:hour+1)%12]];
		}
		str=[NSString stringWithFormat:@"%@%@",[[str substringToIndex:1] uppercaseString],[str substringFromIndex:1]];	// force first char upper.
		break;
	}

	if (str) {
		NSSize s=[str sizeWithAttributes:dict];
		width=s.width+8,height=s.height;
	}
	NSImage* image = [[NSImage alloc] initWithSize:NSMakeSize(width, barHeight)];
	[image lockFocus];

	if (str) [str drawAtPoint:NSMakePoint(4,1+(barHeight-height)/2) withAttributes:dict];
	switch (self._type)
	{
	case 0:
		[[NSColor lightGrayColor] set];
		NSRectFill(NSMakeRect(22,8,2,2));NSRectFill(NSMakeRect(22,12,2,2));
		NSRectFill(NSMakeRect(10,8,2,2));NSRectFill(NSMakeRect(10,12,2,2));
		[self bcdDrawV:30 forVal:second%10 upto:5];
		[self bcdDrawV:26 forVal:second/10 upto:4];
		[self bcdDrawV:18 forVal:minute%10 upto:5];
		[self bcdDrawV:14 forVal:minute/10 upto:4];
		[self bcdDrawV:6 forVal:hour%10 upto:5];
		[self bcdDrawV:2 forVal:hour/10 upto:3];
		break;
	case 1:
		[[NSColor lightGrayColor] set];
		NSRectFill(NSMakeRect(5,8,28,1));NSRectFill(NSMakeRect(5,14,28,1));
		
		[self bcdDrawH:4 forVal:second upto:6];
		[self bcdDrawH:10 forVal:minute upto:6];
		[self bcdDrawH:16 forVal:hour upto:4];
		break;
	}
	
	[image unlockFocus];
	return image;
}

- (void)bcdDrawV:(int)x forVal:(int)v upto:(int)n {
	for (int s=1,i=1;i<n;s*=2,i++) {
		[(v&s)?[NSColor blackColor] : [NSColor lightGrayColor] set];
		NSRectFill(NSMakeRect(x,(i*4),3,3));
	}
}

- (void)bcdDrawH:(int)y forVal:(int)v upto:(int)n {
	for (int s=1,i=1;i<=n;s*=2,i++) {
		[(v&s)?[NSColor blackColor] : [NSColor lightGrayColor] set];
		NSRectFill(NSMakeRect(35-(i*5),y,3,3));
	}
}


@end
