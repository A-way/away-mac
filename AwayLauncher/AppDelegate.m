//

#import "AppDelegate.h"



@interface AppDelegate ()
@property (weak) IBOutlet NSWindow *window;
@end


@implementation AppDelegate

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
    NSString *const kLauncheeId = @"A-way.Away";
    NSString *const kKillLaucher = @"killLauncher";
    
    BOOL running = NO;
    NSArray *runningApps = NSWorkspace.sharedWorkspace.runningApplications;
    for (NSRunningApplication *app in runningApps) {
        if ([app.bundleIdentifier isEqualToString:kLauncheeId]) {
            running = YES;
        }
    }
    if (!running) {
        NSNotificationCenter *ndc = NSDistributedNotificationCenter.defaultCenter;
        [ndc addObserver:self selector:@selector(terminate) name:kKillLaucher object:kLauncheeId];
        
        NSString *path = NSBundle.mainBundle.bundlePath;
        for (int i = 0; i < 4; i++) {
            path = [path stringByDeletingLastPathComponent]; // locate launchee's path
        }
        [NSWorkspace.sharedWorkspace launchApplication:path];
    } else {
        [self terminate];
    }
}

- (void)terminate {
    [NSRunningApplication.currentApplication terminate];
}

- (void)applicationWillTerminate:(NSNotification *)aNotification {
    // Insert code here to tear down your application
}


@end
