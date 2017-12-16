//
//  AppDelegate.m
//  TermStalker
//
//  Created by Pauli Ojala on 15/02/16.
//  Copyright © 2016 Pauli Ojala. All rights reserved.
//

#import "AppDelegate.h"
#import "ENOJavaScriptApp.h"


@interface AppDelegate ()

@property NSString *watchedAppId;
@property ENOJavaScriptApp *jsApp;

@end


// This class logs to stderr so that we don't pollute stdout.
static void logToStderr(NSString *str)
{
    if ( !str) return;
    fprintf(stderr, "%s\n", str.UTF8String);
}



@implementation AppDelegate

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    // Global "running apps changed" notification from NSWorkspace
    if ([keyPath isEqualToString:@"runningApplications"]) {
        // TODO: check if Terminal has exited
    }
}

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
    // TESTING
    self.mainJSProgram = @""
    "const {app} = require('termipal');\n"
    "app.on('ready', () => { console.log('Hello'); });\n"
    "app.on('exit', (uiValues) =>  { "
    "  console.log('exiting... ');\n"
    "  for (viewId in uiValues) { \n"
    "    console.log(`view id: ${viewId}`);\n"
    "  }\n"
    "});"
    ;
    
    // set up window watching for Terminal
    self.watchedAppId = @"com.apple.Terminal";
    self.axWindowWatcher = [[AxWindowWatcher alloc] initWithAppBundleId:self.watchedAppId floaterWindow:self.window];
    
    [[NSWorkspace sharedWorkspace] addObserver:self forKeyPath:@"runningApplications" options:0 context:NULL];
    
    // set up our window
    self.window.level = NSStatusWindowLevel;
    self.window.axWindowWatcher = self.axWindowWatcher;
    
    // set up the JS engine
    ENOJavaScriptApp *jsApp = [ENOJavaScriptApp sharedApp];
    jsApp.jsContext[@"__dirname"] = [[NSFileManager defaultManager] currentDirectoryPath];
    
    // load code
    NSError *error = nil;
    if ( ![jsApp loadMainJS:self.mainJSProgram error:&error]) {
        logToStderr([NSString stringWithFormat:@"** Could not load JavaScript program: %@", error]);
        [NSApp terminate:nil]; // --
    }
    self.jsApp = jsApp;

    // send 'ready' event to the JS app
    if ( ![jsApp.jsAppGlobalObject emitReady:&error]) {
        logToStderr([NSString stringWithFormat:@"** Error executing app.on('ready') handler: %@", error]);
    }
    
}


- (void)applicationWillTerminate:(NSNotification *)aNotification
{
    NSError *error = nil;
    NSDictionary *uiValues = self.window.baseViewController.actionResultValuesByViewId;
    
    // send 'exit' event to the JS app
    if ( ![self.jsApp.jsAppGlobalObject emitExitWithUIValues:uiValues error:&error]) {
        logToStderr([NSString stringWithFormat:@"** Error executing app.on('exit') handler: %@", error]);
    }

}


- (void)exitAndReactivateOriginal
{
    [self.axWindowWatcher.followedApp activateWithOptions:NSApplicationActivateIgnoringOtherApps];
    [NSApp terminate:nil];
}

@end

