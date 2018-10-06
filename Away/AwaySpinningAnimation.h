//

#import <Foundation/Foundation.h>
#import <Cocoa/Cocoa.h>

@interface AwaySpinningAnimation : NSObject

- (instancetype)initWithView:(NSView *)view speed:(CGFloat)speed completion:(void (^)(void))completion;
- (void)startAnimation;
- (void)stopAnimation;

@end
