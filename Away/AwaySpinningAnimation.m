//

#import <QuartzCore/CAAnimation.h>
#import "AwaySpinningAnimation.h"


@interface AwaySpinningAnimation () <CAAnimationDelegate>

@property (weak) NSView *view;
@property (assign) CGFloat speed;
@property (copy) void (^completion)(void);
@property (assign) BOOL shouldStop;

@end

@implementation AwaySpinningAnimation

- (instancetype)initWithView:(NSView *)view speed:(CGFloat)speed completion:(void (^)(void))completion {
    self = [super init];
    if (self) {
        _view = view;
        _speed = speed;
        _completion = [completion copy];
        _shouldStop = NO;
    }
    return self;
}

- (void)startAnimation {
    self.shouldStop = NO;
    
    CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:@"transform.rotation"];
    animation.fromValue = @0.0;
    animation.toValue = @(M_PI * -2.0);
    animation.duration = 0.6;
    animation.delegate = self;
    
    CALayer *layer = self.view.layer;
    CGRect frame = layer.frame;
    layer.position = CGPointMake(CGRectGetMidX(frame), CGRectGetMidY(frame));
    layer.anchorPoint = CGPointMake(.5, .5);
    [layer addAnimation:animation forKey:nil];
}

- (void)stopAnimation {
    self.shouldStop = YES;
}

- (void)animationDidStop:(CAAnimation *)anim finished:(BOOL)flag {
    if (self.shouldStop) {
        if (self.completion) {
            self.completion();
        }
    } else {
        [self startAnimation];
    }
}

@end
