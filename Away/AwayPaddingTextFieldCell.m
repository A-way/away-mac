//

#import "AwayPaddingTextFieldCell.h"

@implementation AwayPaddingTextFieldCell

- (NSRect)drawingRectForBounds:(NSRect)rect {
    NSRect r = {
        rect.origin.x + _padding.left,
        rect.origin.y + _padding.bottom,
        rect.size.width - (_padding.left + _padding.right),
        rect.size.height - (_padding.bottom + _padding.top)
    };
    return [super drawingRectForBounds: r];
}

@end
