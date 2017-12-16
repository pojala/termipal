//
//  AppDelegate.h
//  TermStalker
//
//  Created by Pauli Ojala on 15/02/16.
//  Copyright © 2016 Pauli Ojala. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "PalAttachedWindow.h"
#import "AxWindowWatcher.h"



@interface AppDelegate : NSObject <NSApplicationDelegate>

@property (strong) IBOutlet PalAttachedWindow *window;

@property (strong) AxWindowWatcher *axWindowWatcher;
@property (assign) BOOL inStalkerAction;

@property (strong) NSString *mainJSProgram;

- (void)exitAndReactivateOriginal;

@end

