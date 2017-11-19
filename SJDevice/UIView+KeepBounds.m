//
//  UIView+KeepBounds.m
//  SJAnimations
//
//  Created by jocentzhou on 2017/10/24.
//  Copyright © 2017年 shejun.zhou. All rights reserved.
//

#import "UIView+KeepBounds.h"
#import <objc/runtime.h>

@implementation UIView (KeepBounds)

- (void)setIsKeepBounds:(BOOL)isKeepBounds {
    if (isKeepBounds) {
        UIPanGestureRecognizer *panGesture = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(panGestureAction:)];
        [self addGestureRecognizer:panGesture];
    }
    objc_setAssociatedObject(self, @selector(isKeepBounds), @(isKeepBounds), OBJC_ASSOCIATION_ASSIGN);
}
- (BOOL)isKeepBounds {
    return [objc_getAssociatedObject(self, _cmd) boolValue];
}

- (void)panGestureAction:(UIPanGestureRecognizer *)recognizer {
    
    if ([(UIPanGestureRecognizer *)recognizer state] == UIGestureRecognizerStateBegan) {
        
    }
    else if ([(UIPanGestureRecognizer *)recognizer state] == UIGestureRecognizerStateChanged) {
        CGPoint translatedPoint = [recognizer translationInView:self.superview];
        CGFloat x = recognizer.view.center.x + translatedPoint.x;
        CGFloat y = recognizer.view.center.y + translatedPoint.y;
        recognizer.view.center = CGPointMake(x, y);
        [recognizer setTranslation:CGPointMake(0, 0) inView:self.superview];
    }
    else if (([(UIPanGestureRecognizer *)recognizer state] == UIGestureRecognizerStateEnded) || ([(UIPanGestureRecognizer *)recognizer state] == UIGestureRecognizerStateCancelled)) {
        CGPoint translatedPoint = [recognizer translationInView:self.superview];
        
        CGFloat x = recognizer.view.center.x + translatedPoint.x;
        CGFloat y = recognizer.view.center.y + translatedPoint.y;
        recognizer.view.center = CGPointMake(x, y);
        [recognizer setTranslation:CGPointMake(0, 0) inView:self.superview];
        
        x = recognizer.view.center.x;
        y = recognizer.view.center.y;
        
        CGFloat top = y;
        CGFloat left = x;
        CGFloat bottom = SCREEN_HEIGHT-top-recognizer.view.frame.size.height/2.0;
        CGFloat right = SCREEN_WIDTH-left-recognizer.view.frame.size.width/2.0;
        
        if (top < left && top < bottom && top < right) {
            if (left < right) {//left
                x = recognizer.view.frame.size.width/2.0;
                y = recognizer.view.center.y;
            }
            else {//right
                x = SCREEN_WIDTH-recognizer.view.frame.size.width/2.0;
                y = recognizer.view.center.y;
            }
        }
        else if (left < top && left < bottom && left < right) {//left
            x = recognizer.view.frame.size.width/2.0;
            y = recognizer.view.center.y;
        }
        else if (bottom < top && bottom < left && bottom < right) {//bottom
            x = recognizer.view.center.x;
            y = SCREEN_HEIGHT-recognizer.view.frame.size.height/2.0;
        }
        else {//right
            x = SCREEN_WIDTH-recognizer.view.frame.size.width/2.0;
            y = recognizer.view.center.y;
        }
        
        if (x < recognizer.view.frame.size.width/2.0) {
            x = recognizer.view.frame.size.width;
        }
        if (y < recognizer.view.frame.size.height/2.0+64) {
            y = recognizer.view.frame.size.height/2.0+64;
        }
        CGFloat velocityX = (0.2 *[recognizer velocityInView:self.superview].x);
        [UIView beginAnimations:nil context:NULL];
        [UIView setAnimationDuration:ABS(velocityX * 0.00002 + 0.2)];
        [UIView setAnimationCurve:UIViewAnimationCurveEaseOut];
        recognizer.view.center = CGPointMake(x, y);
        [UIView commitAnimations];
    }
}

@end
