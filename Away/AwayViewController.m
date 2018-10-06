//

#import "AwayViewController.h"
#import "AwayRuleTableCellView.h"
#import "AwayPaddingTextFieldCell.h"
#import "AwaySettingsWindowController.h"



@interface AwayRule : NSObject

@property (copy) NSString *mode;
@property (copy) NSString *rule;

@end

@implementation AwayRule

- (instancetype)initWithMode:(NSString*)mode rule:(NSString*)rule {
    if (self) {
        self.mode = mode;
        self.rule = rule;
    }
    return self;
}

- (const char *)awayRule {
    return [[self.mode stringByAppendingString:self.rule] UTF8String];
}

- (NSUInteger)hash {
    return [self.mode hash] ^ [self.rule hash];
}

- (BOOL)isEqual:(id)object {
    if (self == object) {
        return YES;
    }
    
    if (![object isKindOfClass:[AwayRule class]]) {
        return NO;
    }
    return [self isEqualAwayRule:object];
}

- (BOOL)isEqualAwayRule:(AwayRule*)rule {
    return [self.mode isEqualToString:rule.mode] && [self.rule isEqualToString:rule.rule];
}

@end



@interface RuleDataSourceDelegate : NSObject <NSTableViewDelegate, NSTableViewDataSource>

@property (strong) NSMutableArray *rules;

@end

@implementation RuleDataSourceDelegate

- (instancetype)initWithRules:(NSMutableArray*)rules {
    if (self) {
        self.rules = rules;
    }
    return self;
}

#pragma mark - NSTableViewDataSource

- (NSInteger)numberOfRowsInTableView:(NSTableView *)tableView {
    return [self.rules count];
}

#pragma mark - NSTableViewDelegate

- (NSView*)tableView:(NSTableView *)tableView viewForTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row {
    static NSString *cellId = @"RuleCell";
    AwayRule *ar = self.rules[row];
    AwayRuleTableCellView *cell = [tableView makeViewWithIdentifier:cellId owner:nil];
    cell.modeTextField.stringValue = ar.mode;
    cell.textField.stringValue = ar.rule;
    return cell;
}

@end



@interface AwayViewController () <NSTabViewDelegate>

@property (strong) NSArray *awayModeBtns;
@property (weak) IBOutlet NSButton *ruleBtn;
@property (weak) IBOutlet NSButton *awayBtn;
@property (weak) IBOutlet NSButton *passBtn;
@property (weak) IBOutlet NSButton *dropBtn;

@property (weak) IBOutlet NSButton *settingsBtn;


@property (weak) IBOutlet NSPopUpButton *modesBtn;
@property (weak) IBOutlet NSTextField *ruleInput;
@property (weak) IBOutlet NSTabView *ruleTab;

@property (weak) NSTableView *displayRulesTable;
@property (weak) IBOutlet NSTableView *rulesTable;
@property (weak) IBOutlet NSTableView *recentRulesTable;
@property (strong) NSMutableArray *rules;
@property (strong) NSMutableArray *recentRules;
@property (strong) RuleDataSourceDelegate *rulesDelegate;
@property (strong) RuleDataSourceDelegate *recentRulesDelegate;

@end

@implementation AwayViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    AwayPaddingTextFieldCell *cell = self.ruleInput.cell;
    cell.padding = NSEdgeInsetsMake(0, 30, 0, 0);
    
    _awayModeBtns = @[self.ruleBtn, self.awayBtn, self.passBtn, self.dropBtn];
    
    self.ruleTab.delegate = self;
    
    _rules = [NSMutableArray array];
    [self reloadRules];
    _recentRules = [NSMutableArray arrayWithCapacity:10];
    _rulesDelegate = [[RuleDataSourceDelegate alloc] initWithRules:_rules];
    _recentRulesDelegate = [[RuleDataSourceDelegate alloc] initWithRules:_recentRules];
    self.rulesTable.delegate = _rulesDelegate;
    self.rulesTable.dataSource = _rulesDelegate;
    self.recentRulesTable.delegate = _recentRulesDelegate;
    self.recentRulesTable.dataSource = _recentRulesDelegate;
    self.displayRulesTable = self.recentRulesTable;
    
}

- (void)reloadRules {
    [self.rules removeAllObjects];
    char *r = NULL;
    char **rules = away_rules_get();
    if (rules != NULL) {
        for (int i = 0; (r = rules[i]) != NULL; ++i) {
            char m[2] = {r[0], '\0'};
            NSString *mode = [NSString stringWithUTF8String:m];
            NSString *rule = [NSString stringWithUTF8String:&r[1]];
            AwayRule *ar = [[AwayRule alloc] initWithMode:mode rule:rule];
            [self.rules addObject:ar];
            free(rules[i]);
        }
        free(rules);
    }
    [self.rulesTable reloadData];
}

- (void)viewDidAppear {
    [super viewDidAppear];
    [[NSApplication sharedApplication] activateIgnoringOtherApps:YES]; // https://stackoverflow.com/a/37870802
}

# pragma mark - IBAction

- (IBAction)quit:(id)sender {
    [NSApp terminate:sender];
}

- (IBAction)displaySettings:(id)sender {
    [AwaySettingsWindowController displayMe];
}

- (IBAction)delete:(id)sender {
    NSInteger row = [self.displayRulesTable selectedRow];
    if (row < 0) { return; }

    NSMutableArray *rules = ((RuleDataSourceDelegate*)self.displayRulesTable.dataSource).rules;
    AwayRule *ar = [rules objectAtIndex:row];
    if (away_rule_del((char*)[ar awayRule]) != 0) {
        return;
    }
    
    if (rules == self.rules) {
        NSInteger before = [self.recentRules count];
        [self.recentRules removeObject:ar];
        NSInteger after = [self.recentRules count];
        if (before != after) {
            [self.recentRulesTable reloadData];
        }
    }
    
    [rules removeObjectAtIndex:row];
    NSIndexSet *index = [NSIndexSet indexSetWithIndex:row];
    NSTableView *rt = self.displayRulesTable;
    [rt deselectAll:sender]; // clear selection style before animating (might seeing double blue strip).
    [rt beginUpdates];
    [rt removeRowsAtIndexes:index withAnimation:NSTableViewAnimationSlideLeft];
    [rt endUpdates];
    NSInteger prev = row - 1;
    if (prev >= 0) {
        [rt selectRowIndexes:[NSIndexSet indexSetWithIndex:prev] byExtendingSelection:NO];
    }
    [self reloadRules];
}

- (IBAction)addRule:(NSTextField *)sender {
    NSString *rule = sender.stringValue;
    if ([rule length] == 0) {
        return;
    }
    //TODO: validate user input rule.
    NSString *mode = self.modesBtn.selectedItem.title;
    AwayRule *ar = [[AwayRule alloc] initWithMode:mode rule:rule];

    if (away_rule_add((char*)[ar awayRule]) != 0) {
        return;
    }

    [self.recentRules insertObject:ar atIndex:0];
    sender.stringValue = @"";
    [self.ruleTab selectTabViewItemAtIndex:0];
    NSIndexSet *index = [NSIndexSet indexSetWithIndex:0];
    NSTableView *rt = self.recentRulesTable;
    [rt beginUpdates];
    [rt insertRowsAtIndexes:index withAnimation:NSTableViewAnimationSlideDown];
    [rt endUpdates];
    [self reloadRules];
}

- (IBAction)switchAwayMode:(NSButton *)sender {
    if (away_mode_change((int)sender.tag) != 0) {
        return;
    }
    [self.awayModeBtns enumerateObjectsUsingBlock:^(NSButton *obj, NSUInteger idx, BOOL *stop) {
        obj.state = NSOffState;
    }];
    sender.state = NSOnState;
}

- (IBAction)help:(id)sender {

}

#pragma mark - NSTabViewDelegate

- (void)tabView:(NSTabView *)tabView didSelectTabViewItem:(NSTabViewItem *)tabViewItem {
    NSInteger currIndex = [tabView indexOfTabViewItem:tabViewItem];
    if (currIndex == 0) {
        self.displayRulesTable = self.recentRulesTable;
    } else {
        self.displayRulesTable = self.rulesTable;
    }
}

@end
