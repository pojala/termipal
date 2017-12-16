//
//  StalkerWindow.m
//  TermStalker
//
//  Created by Pauli Ojala on 24/03/16.
//  Copyright © 2017 Pauli Olavi Ojala.
//
/*
 Termipal is free software: you can redistribute it and/or modify
 it under the terms of the GNU General Public License as published by
 the Free Software Foundation, either version 3 of the License, or
 (at your option) any later version.
 
 This program is distributed in the hope that it will be useful,
 but WITHOUT ANY WARRANTY; without even the implied warranty of
 MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 GNU General Public License for more details.
 
 You should have received a copy of the GNU General Public License
 along with this program.  If not, see <http://www.gnu.org/licenses/>.
 */

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
