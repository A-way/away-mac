//

#import "AwaySettingsWindowController.h"
#import "AwaySpinningAnimation.h"
#import "Away.h"


@interface NSString (CString)

+ (instancetype) stringWithCString:(const char *)str;

@end

@implementation NSString (CString)

+ (instancetype) stringWithCString:(const char *)str {
    if (NULL == str) {
        return @"";
    }
    return [NSString stringWithUTF8String:str];
}

@end



@interface AwaySettingsWindowController () <NSWindowDelegate>

@property (copy) NSString *remote;
@property (copy) NSString *passkey;
@property (copy) NSString *port;

@property (weak) IBOutlet NSButton *settingsBtn;
@property (weak) IBOutlet NSTextField *remoteTextField;
@property (weak) IBOutlet NSSecureTextFieldCell *passkeyTextField;
@property (weak) IBOutlet NSTextField *portTextField;

@end

@implementation AwaySettingsWindowController

+ (void)displayMe {
    AwaySettingsWindowController *controller = [[AwaySettingsWindowController alloc] initWithWindowNibName:@"AwaySettingsWindowController"];
    struct settings s = {0};
    away_settings_get(&s);
    controller.remote = [NSString stringWithCString:s.remote];
    controller.passkey = [NSString stringWithCString:s.passkey];
    controller.port = [NSString stringWithCString:s.port];
    away_settings_free(&s);
    [controller.window center];
    [[NSApplication sharedApplication] runModalForWindow:controller.window];
}

- (void)windowDidLoad {
    [super windowDidLoad];
    self.window.delegate = self;
    self.remoteTextField.stringValue = self.remote;
    self.passkeyTextField.stringValue = self.passkey;
    self.portTextField.stringValue = self.port;
}



- (IBAction)reloadSettings:(NSButton*)sender {
    NSString *port = [self.portTextField.stringValue stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    NSString *remote = [self.remoteTextField.stringValue stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    NSString *passkey = [self.passkeyTextField.stringValue stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    
    self.settingsBtn.enabled = NO;
    AwaySpinningAnimation *animation = [[AwaySpinningAnimation alloc] initWithView:self.settingsBtn speed:.25 completion:^{
        self.settingsBtn.enabled = YES;
    }];
    [animation startAnimation];
    
    dispatch_async(dispatch_get_global_queue(QOS_CLASS_USER_INITIATED, 0), ^{
        struct settings s = {[remote UTF8String], [passkey UTF8String], [port UTF8String]};
        away_settings_change(s);
        dispatch_async(dispatch_get_main_queue(), ^{
            [animation stopAnimation];
        });
    });
}

- (void)windowWillClose:(NSNotification *)notification {
    [[NSApplication sharedApplication] stopModal];
}

@end
