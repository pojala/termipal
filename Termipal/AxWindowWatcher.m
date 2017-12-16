//
//  AxWindowWatcher.m
//  Termipal
//
//  Created by Pauli Ojala on 15/12/2017.
//  Copyright © 2017 Lacquer. All rights reserved.
//

#import "AxWindowWatcher.h"




@interface AxWindowWatcher ()

@property (strong) NSRunningApplication *followedApp;
@property (assign) AXUIElementRef axApp;
@property (assign) AXObserverRef axObserver;
@property (assign) CFTypeRef axFocusedWindow;

@property (strong) NSWindow *window;

@property (assign) BOOL windowHiddenByWindowPosition;

- (void)axNotification:(NSString *)notifName withElement:(AXUIElementRef)element;

@end


// This class logs to stderr so that we don't pollute stdout.
static void logToStderr(NSString *str)
{
    if ( !str) return;
    fprintf(stderr, "%s\n", str.UTF8String);
}


// Observer callback function for the C-based Accessibility API.
// This just forwards notifications to the Obj-C side.
static void axObserverCb(AXObserverRef observer, AXUIElementRef element, CFStringRef notification, void * __nullable refcon)
{
    NSString *notifName = (__bridge id)notification;
    AxWindowWatcher *self = (__bridge id)refcon;
    
    [self axNotification:notifName withElement:element];
}



@implementation AxWindowWatcher

- (id)initWithAppBundleId:(NSString *)appId floaterWindow:(NSWindow *)window
{
    self = [super init];
    
    NSArray *apps = [[NSWorkspace sharedWorkspace] runningApplications];
    
    NSRunningApplication *foundApp = nil;
    for (NSRunningApplication *app in apps) {
        if ([app.bundleIdentifier isEqual:appId]) {
            foundApp = app;
            break;
        }
    }
    if ( !foundApp) {
        logToStderr(@"** app bundle not found");
        return nil; // --
    }
    self.followedApp = foundApp;
    self.window = window;
    
    _axApp = AXUIElementCreateApplication(_followedApp.processIdentifier);
    
    AXError axErr;
    
    axErr = AXObserverCreate(_followedApp.processIdentifier, axObserverCb, &_axObserver);
    CFRunLoopAddSource(CFRunLoopGetCurrent(), AXObserverGetRunLoopSource(_axObserver), kCFRunLoopDefaultMode);
    
    AXObserverAddNotification(_axObserver, _axApp, kAXMainWindowChangedNotification, (__bridge void *)self);
    AXObserverAddNotification(_axObserver, _axApp, kAXFocusedWindowChangedNotification, (__bridge void *)self);
    AXObserverAddNotification(_axObserver, _axApp, kAXApplicationActivatedNotification, (__bridge void *)self);
    AXObserverAddNotification(_axObserver, _axApp, kAXApplicationDeactivatedNotification, (__bridge void *)self);
    
    CFTypeRef frontWindow = NULL;
    axErr = AXUIElementCopyAttributeValue( _axApp, kAXMainWindowAttribute, &frontWindow );
    if ( !frontWindow) {
        logToStderr(@"** could not get main window from AXUIElement");
        return nil; // --
    }
    
    // To catch the focus window, we'll activate the followed app
    // and wait a bit for its window to be ready.
    // These wait times are entirely unscientific and can be changed.
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [_followedApp activateWithOptions:NSApplicationActivateAllWindows];
        
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [self _listenToFocusWindow];
            
            if (_axFocusedWindow) {
                [self _setFloaterVisible:YES];
            }
            
            // ensure we catch focus even if it comes late
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                [self _listenToFocusWindow];
            });
            
        });
    });
    
    return self;
}


- (void)_listenToFocusWindow
{
    if (_axFocusedWindow) {
        AXObserverRemoveNotification(_axObserver, _axFocusedWindow, kAXWindowMovedNotification);
        AXObserverRemoveNotification(_axObserver, _axFocusedWindow, kAXWindowResizedNotification);
        AXObserverRemoveNotification(_axObserver, _axFocusedWindow, kAXWindowMiniaturizedNotification);
        AXObserverRemoveNotification(_axObserver, _axFocusedWindow, kAXWindowDeminiaturizedNotification);
        AXObserverRemoveNotification(_axObserver, _axFocusedWindow, kAXUIElementDestroyedNotification);
        
        CFRelease(_axFocusedWindow);
        _axFocusedWindow = NULL;
    }
    
    AXError axErr;
    axErr = AXUIElementCopyAttributeValue(_axApp, kAXFocusedWindowAttribute, &_axFocusedWindow);
    
    CFBooleanRef cfBool = NULL;
    BOOL f;
    AXUIElementCopyAttributeValue(_axFocusedWindow, kAXMainAttribute, (const void **)&cfBool);
    f = (cfBool) ? CFEqual(cfBool, kCFBooleanTrue) : NO;
    if (cfBool) CFRelease(cfBool);
    
    if ( !f) {
        if (_axFocusedWindow) CFRelease(_axFocusedWindow);
        _axFocusedWindow = NULL;
        [self _setFloaterVisible:NO];
        return; // --
    }
    
    CFArrayRef attrs = nil;
    AXUIElementCopyAttributeNames(_axFocusedWindow, &attrs);
    
    CFTypeRef cfRef = NULL;
    AXUIElementCopyAttributeValue(_axFocusedWindow, CFSTR("AXProxy"), (const void **)&cfRef);
    
    AXUIElementCopyAttributeValue(_axFocusedWindow, kAXModalAttribute, (const void **)&cfBool);
    if (cfBool) CFRelease(cfBool);
    
    CFStringRef cfStr = NULL;
    AXUIElementCopyAttributeValue(_axFocusedWindow, kAXRoleAttribute, (const void **)&cfStr);
    if (cfStr) CFRelease(cfStr);
    
    AXUIElementCopyAttributeValue(_axFocusedWindow, kAXSubroleAttribute, (const void **)&cfStr);
    if (cfStr) CFRelease(cfStr);
    
    AXUIElementCopyAttributeValue(_axFocusedWindow, kAXRoleDescriptionAttribute, (const void **)&cfStr);
    if (cfStr) CFRelease(cfStr);
    
    AXUIElementCopyAttributeValue(_axFocusedWindow, kAXTitleAttribute, (const void **)&cfStr);
    
    // Recognizing the modern-style "Open" window used by TextEdit
    // and other standard document-based Cocoa apps isn't easy.
    // To Accessibility, it looks just like a plain window.
    // Hence we resort to looking for the window title here so that we can ignore it.
    if ([[(__bridge NSString *)cfStr lowercaseString] isEqual:@"open"]) {
        if (cfStr) CFRelease(cfStr);
        if (_axFocusedWindow) CFRelease(_axFocusedWindow);
        _axFocusedWindow = NULL;
        [self _setFloaterVisible:NO];
        return; // --
    }
    if (cfStr) CFRelease(cfStr);
    
    
    AXUIElementCopyAttributeValue(_axFocusedWindow, kAXDescriptionAttribute, (const void **)&cfStr);
    if (cfStr) CFRelease(cfStr);
    
    if ( !_axFocusedWindow) {
        [self _setFloaterVisible:NO];
        return; // --
    }
    
    AXObserverAddNotification(_axObserver, _axFocusedWindow, kAXWindowMovedNotification, (__bridge void *)self);
    AXObserverAddNotification(_axObserver, _axFocusedWindow, kAXWindowResizedNotification, (__bridge void *)self);
    AXObserverAddNotification(_axObserver, _axFocusedWindow, kAXWindowMiniaturizedNotification, (__bridge void *)self);
    AXObserverAddNotification(_axObserver, _axFocusedWindow, kAXWindowDeminiaturizedNotification, (__bridge void *)self);
    AXObserverAddNotification(_axObserver, _axFocusedWindow, kAXUIElementDestroyedNotification, (__bridge void *)self);
    
    [self _updateWindowPosition];
}

- (void)_setFloaterVisible:(BOOL)f
{
    if (f) {
        [self.window orderFront:nil];
    } else {
        [self.window orderOut:nil];
    }
}

- (void)_hideFloaterIfNoVisibleWindows
{
    [self _listenToFocusWindow];
}

// There's no API available to acquire the screen for an AX window or even a CGWindowID,
// so instead look for a screen that contains this window frame.
- (NSScreen *)_screenForWindowWithFrame:(CGRect)windowFrame
{
    NSScreen *primaryScreen = [NSScreen screens].firstObject;
    
    CGFloat foundDim = 0.0;
    NSScreen *foundScreen = nil;
    
    for (NSScreen *screen in [NSScreen screens]) {
        CGRect frame = screen.frame;
        
        frame.origin.y = primaryScreen.frame.size.height - frame.origin.y - frame.size.height;
        
        CGRect isect = CGRectIntersection(windowFrame, frame);
        
        CGFloat isectDim = isect.size.width * isect.size.height;
        
        if (isectDim > foundDim) {
            foundScreen = screen;
            foundDim = isectDim;
        }
    }
    
    return foundScreen;
}

- (void)_updateWindowPosition
{
    CFTypeRef position = NULL;
    AXUIElementCopyAttributeValue(_axFocusedWindow, kAXPositionAttribute, &position);
    
    CFTypeRef size = NULL;
    AXUIElementCopyAttributeValue(_axFocusedWindow, kAXSizeAttribute, &size);
    
    CGRect frame;
    AXValueGetValue(position, kAXValueCGPointType, &frame.origin);
    AXValueGetValue(size, kAXValueCGSizeType, &frame.size);
    
    if (position) CFRelease(position);
    if (size) CFRelease(size);
    
    //CGWindowID cgWin = 0;
    //_AXUIElementGetWindow(_axFocusedWindow, &cgWin);
    
    NSScreen *windowScreen = [self _screenForWindowWithFrame:frame];
    if ( !windowScreen) {
        [self.window orderOut:nil];
        self.windowHiddenByWindowPosition = YES;
        return; // --
    }
    
    NSScreen *primaryScreen = [NSScreen screens].firstObject;
    
    frame.origin.y = primaryScreen.frame.size.height - frame.origin.y - frame.size.height;
    
    const double yOff = -1;
    const double xOff = 5;
    
    NSRect winFrame = self.window.frame;
    winFrame.origin.x = NSMinX(frame) + xOff;
    winFrame.origin.y = NSMinY(frame) - winFrame.size.height - yOff;
    winFrame.size.width = frame.size.width - 2*xOff;
    
    // Check if the window is mostly outside of its screen
    NSRect isect = NSIntersectionRect(winFrame, windowScreen.frame);
    if (isect.size.width < winFrame.size.width*0.501) {
        [self.window orderOut:nil];
        self.windowHiddenByWindowPosition = YES;
        return; // --
    }
    
    
    if (self.windowHiddenByWindowPosition) {
        // Restore previously hidden window now that followed window is on a screen again
        self.windowHiddenByWindowPosition = NO;
        [self.window orderFront:nil];
    }
    
    if (self.window.visible) {
        [self.window setFrame:winFrame display:YES animate:YES];
    } else {
        [self.window setFrame:winFrame display:NO];
    }
    
}



// Accessibility notifications forwarded from C API
- (void)axNotification:(NSString *)notifName withElement:(AXUIElementRef)element
{
    if ([notifName isEqualToString:(__bridge id)kAXApplicationActivatedNotification]) {
        [self _setFloaterVisible:YES];
    }
    else if ([notifName isEqualToString:(__bridge id)kAXApplicationDeactivatedNotification]) {
        if (_insideUserActionInFloater) {
            [_followedApp activateWithOptions:NSApplicationActivateIgnoringOtherApps];
            _insideUserActionInFloater = NO;
        } else {
            [self _setFloaterVisible:NO];
        }
    }
    else if ([notifName isEqualToString:(__bridge id)kAXMainWindowChangedNotification]) {
        //NSLog(@"main window change, element: %@", (__bridge id)element);
    }
    else if ([notifName isEqualToString:(__bridge id)kAXFocusedWindowChangedNotification]) {
        [self _setFloaterVisible:YES];
        [self _listenToFocusWindow];
    }
    else if ([notifName isEqualToString:(__bridge id)kAXWindowMovedNotification]
             || [notifName isEqualToString:(__bridge id)kAXWindowResizedNotification]) {
        [self _updateWindowPosition];
    }
    else if ([notifName isEqualToString:(__bridge id)kAXWindowMiniaturizedNotification]) {
        [self _hideFloaterIfNoVisibleWindows];
    }
    else if ([notifName isEqualToString:(__bridge id)kAXWindowDeminiaturizedNotification]) {
        // nothing to do here, focusedWindowChanged will do the wakeup
    }
    else if ([notifName isEqualToString:(__bridge id)kAXUIElementDestroyedNotification]) {
        
        CFTypeRef obj = NULL;
        AXUIElementCopyAttributeValue(_axApp, kAXMainWindowAttribute, (const void **)&obj);
        BOOL hasMainWindow = (obj != NULL);
        if (obj) CFRelease(obj);
        
        if ( !hasMainWindow) {
            [self _setFloaterVisible:NO];
        }
    }
}

@end
