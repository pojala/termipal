//
//  PalBaseView.m
//  Termipal
//
//  Created by Pauli Ojala on 15/12/2017.
//  Copyright © 2017 Lacquer. All rights reserved.
//

#import "PalBaseView.h"
#import "PalAttachedWindow.h"
#import "AppDelegate.h"


@implementation PalBaseView

- (BOOL)canBecomeKeyView
{
    return YES;
}

- (void)mouseDown:(NSEvent *)event
{
    PalAttachedWindow *window = (id)self.window;
    window.axWindowWatcher.insideUserActionInFloater = YES;
    
    if (event.clickCount == 2) {
        AppDelegate *appDelegate = [NSApplication sharedApplication].delegate;
        [appDelegate exitAndReactivateOriginal];
    }
}

- (void)keyDown:(NSEvent *)event
{
    NSLog(@"%s", __func__);
}

@end
