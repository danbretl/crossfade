//
//  PLFClipView.m
//  CrossFade
//
//  Created by Dan Bretl on 4/16/13.
//  Copyright (c) 2013 Picturelife. All rights reserved.
//

#import "PLFClipView.h"

@implementation PLFClipView

- (UIView *) hitTest:(CGPoint) point withEvent:(UIEvent *)event {
    UIView * view = nil;
    if ([self pointInside:point withEvent:event]) {
        view = self.scrollView;
    }
    return view;
}

@end
