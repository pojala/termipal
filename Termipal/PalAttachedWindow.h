//
//  StalkerWindow.h
//  TermStalker
//
//  Created by Pauli Ojala on 24/03/16.
//  Copyright © 2016 Pauli Ojala. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "PalBaseViewController.h"
#import "AxWindowWatcher.h"


@interface PalAttachedWindow : NSWindow

@property (nonatomic, strong) PalBaseViewController *baseViewController;

@property (nonatomic, weak) AxWindowWatcher *axWindowWatcher;

@end
