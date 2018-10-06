//

#import "AppDelegate.h"
#import "AwayViewController.h"
#import "AwaySettingsWindowController.h"



@interface AppDelegate ()

@property (weak) IBOutlet NSWindow *window;
@property (strong) NSStatusItem *statusItem;
@property (strong) NSPopover *popover;

@end

@implementation AppDelegate

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
    self.statusItem = [[NSStatusBar systemStatusBar] statusItemWithLength:NSVariableStatusItemLength];
    NSImage *icon = [NSApp applicationIconImage];
//    icon.template = YES;
    [icon setSize:NSMakeSize(16, 16)];
    [self.statusItem setImage:icon];
    self.statusItem.action = @selector(togglePopover:);
    
    self.popover = [[NSPopover alloc] init];
    self.popover.behavior = NSPopoverBehaviorTransient;
    AwayViewController *controller = [[AwayViewController alloc] initWithNibName:@"AwayViewController" bundle:nil];
    self.popover.contentViewController = controller;

    NSString *dir = NSSearchPathForDirectoriesInDomains(NSApplicationSupportDirectory, NSUserDomainMask, YES).firstObject;
    NSString *path = [dir stringByAppendingPathComponent:@"Away"];
    away_initialize((char*)[path UTF8String]);
    if (away_settings_exist() == 0) {
        [AwaySettingsWindowController displayMe];
    } else {
        away_start();
    }
}


- (IBAction)togglePopover:(id)sender {
    if ([self.popover isShown]) {
        [self.popover performClose:sender];
    } else {
        [self.popover showRelativeToRect:self.statusItem.button.bounds ofView:self.statusItem.button preferredEdge:NSRectEdgeMinY];
    }
    
}

- (void)applicationWillTerminate:(NSNotification *)aNotification {
    // Insert code here to tear down your application
}

@end
