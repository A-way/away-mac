//

#import "AppDelegate.h"
#import "AwayViewController.h"
#import "AwaySettingsWindowController.h"
#import <ServiceManagement/ServiceManagement.h>


@interface NSImage (Resize)

- (NSImage *)resize:(CGSize)size;

@end

@implementation NSImage (Resize)

- (NSImage *)resize:(CGSize)size {
    CGSize originSize = self.size;
    [self setSize:size];
    NSImage *result = [[NSImage alloc] initWithSize:size];
    [result lockFocus];
    [[NSGraphicsContext currentContext] setImageInterpolation:NSImageInterpolationHigh];
    CGRect rect = CGRectMake(0, 0, size.width, size.height);
    [self drawAtPoint:NSZeroPoint fromRect:rect operation:NSCompositingOperationCopy fraction:1.0];
    [result unlockFocus];
    [self setSize:originSize];
    return result;
}

@end

@interface AppDelegate ()

@property (weak) IBOutlet NSWindow *window;
@property (strong) NSStatusItem *statusItem;
@property (strong) NSPopover *popover;

@end

@implementation AppDelegate

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
    self.statusItem = [[NSStatusBar systemStatusBar] statusItemWithLength:NSVariableStatusItemLength];
    NSImage *icon = [[NSApp applicationIconImage] resize:CGSizeMake(16, 16)];
//    icon.template = YES;
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
    
    [self setupAppAutoLaunch];
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

- (void)setupAppAutoLaunch {
    NSString *const kLauncherId = @"A-way.AwayLauncher";
    NSString *const kKillLaucher = @"killLauncher";
    
    SMLoginItemSetEnabled((__bridge CFStringRef)(kLauncherId), YES);
    NSString *appId = NSBundle.mainBundle.bundleIdentifier;
    [NSDistributedNotificationCenter.defaultCenter postNotificationName:kKillLaucher object:appId];
}

@end

