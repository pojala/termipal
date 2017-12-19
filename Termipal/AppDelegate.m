//
//  AppDelegate.m
//  TermStalker
//
//  Created by Pauli Ojala on 15/02/16.
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

#import "AppDelegate.h"
#import "PalJavaScriptMicroUIApp.h"


@interface AppDelegate ()

@property PalJavaScriptMicroUIApp *jsApp;

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
#if 0
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
    "buttonClicked = () => {\n"
    "  let uiValues = app.getCurrentUIValues();\n"
    "  app.alert('popup selection is: '+uiValues.testPopup);\n"
    "  app.openUrl('https://google.com');\n"
    "}\n"
    ;
#endif
    
    // set up window watching for Terminal
    self.axWindowWatcher = [[AxWindowWatcher alloc] initWithAppBundleId:self.watchedAppId floaterWindow:self.window];
    
    [[NSWorkspace sharedWorkspace] addObserver:self forKeyPath:@"runningApplications" options:0 context:NULL];
    
    // set up our window
    self.window.level = NSStatusWindowLevel;
    self.window.axWindowWatcher = self.axWindowWatcher;
    
    // set up the JS engine
    self.jsApp = [[PalJavaScriptMicroUIApp alloc] initWithVersion:self.versionString
                                            microUIViewController:self.window.baseViewController];
    
    self.jsApp.jsContext[@"__dirname"] = self.mainJSDir;
    
    self.jsApp.jsAppGlobalObject.palBaseViewController = self.window.baseViewController;
    self.jsApp.jsAppGlobalObject.axWindowWatcher = self.axWindowWatcher;
    
    // load main script
    NSError *error = nil;
    if ( ![self.jsApp loadMainJS:self.mainJSProgram error:&error]) {
        logToStderr([NSString stringWithFormat:@"** Could not load JavaScript program: %@", error]);
        [NSApp terminate:nil]; // --
    }
    
    // send 'ready' event to the JS app
    if ( ![self.jsApp.jsAppGlobalObject emitReady:&error]) {
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
    if (self.jsApp.jsAppGlobalObject.exitCode != 0) {
        exit(self.jsApp.jsAppGlobalObject.exitCode);  // --
    }
}


- (void)exitAndReactivateOriginal
{
    [self.axWindowWatcher.followedApp activateWithOptions:NSApplicationActivateIgnoringOtherApps];
    [NSApp terminate:nil];
}

- (void)performJSActionNamed:(NSString *)actionName
{
    @try {
        JSValue *funcObj = self.jsApp.jsContext[actionName];
        [funcObj callWithArguments:@[]];
    }
    @catch (NSException *exc) {
        logToStderr([NSString stringWithFormat:@"** Exception while executing %@ handler: %@", actionName, exc]);
    }
}

@end

