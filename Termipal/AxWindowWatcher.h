//
//  AxWindowWatcher.h
//  Termipal
//
//  Created by Pauli Ojala on 15/12/2017.
//  Copyright © 2017 Lacquer. All rights reserved.
//

#import <Cocoa/Cocoa.h>

/*
 Switches to the given app and starts watching its current focus window.
 The given attachedWindow will be displayed whenever the watched window is active.
 */

@interface AxWindowWatcher : NSObject

- (id)initWithAppBundleId:(NSString *)appId floaterWindow:(NSWindow *)window;

@property (readonly) NSRunningApplication *followedApp;
@property (assign) BOOL insideUserActionInFloater;

@end
