//
//  StalkerWindow.m
//  TermStalker
//
//  Created by Pauli Ojala on 24/03/16.
//  Copyright © 2016 Pauli Ojala. All rights reserved.
//

#import "PalAttachedWindow.h"
#import "PalBaseView.h"


@implementation PalAttachedWindow

- (id)init
{
    self = [super initWithContentRect:NSMakeRect(0, 0, 200, 30)
                            styleMask:NSWindowStyleMaskBorderless
                              backing:NSBackingStoreBuffered
                                defer:NO];
    
    self.hasShadow = NO;
    
    self.baseViewController = [[PalBaseViewController alloc] init];
    
    PalBaseView *baseView = (id)self.baseViewController.view;
    self.contentView = baseView;
    
    baseView.blendingMode = NSVisualEffectBlendingModeBehindWindow;
    baseView.state = NSVisualEffectStateActive;
    baseView.material = NSVisualEffectMaterialMediumLight;
    
    return self;
}

- (BOOL)canBecomeMainWindow
{
    return NO;
}

- (BOOL)canBecomeKeyWindow
{
    return NO;
}

@end
