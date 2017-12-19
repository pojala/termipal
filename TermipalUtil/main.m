//
//  main.m
//  TermipalUtil
//
//  Created by Pauli Ojala on 03/12/2017.
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

#import <Foundation/Foundation.h>
#import "AppDelegate.h"
#import "PalAttachedWindow.h"


int main(int argc, const char * argv[]) {
    @autoreleasepool {
        const char *versionStr = "0.0.2";
        NSString *mainJSDir = [[NSFileManager defaultManager] currentDirectoryPath];
        
        // -- get command line args
        NSString *programJS = nil;
        for (int i = 1; i < argc; i++) {
            if (0 == strcmp(argv[i], "--version")) {
                printf("Termipal version %s\n"
                       "Copyright (c) 2017 Pauli Olavi Ojala.\n"
                       , versionStr);
                exit(0);
            }
            else if (0 == strcmp(argv[i], "--js") && i < argc-1) {
                programJS = [NSString stringWithUTF8String:argv[++i]];
                continue;
            }
            else if (0 == strcmp(argv[i], "--js-file") && i < argc-1) {
                NSString *path = [NSString stringWithUTF8String:argv[++i]];
                NSError *err = nil;
                programJS = [NSString stringWithContentsOfFile:path encoding:NSUTF8StringEncoding error:&err];
                if (err) {
                    fprintf(stderr, "** error reading JS file: %s\n", err.description.UTF8String);
                    return (int)err.code; // --
                }
                mainJSDir = [path stringByDeletingLastPathComponent];
                continue;
            }
            
            NSString *path = [NSString stringWithUTF8String:argv[i]];
            if ([path.lowercaseString rangeOfString:@".js"].location != NSNotFound) {
                NSError *err = nil;
                programJS = [NSString stringWithContentsOfFile:path encoding:NSUTF8StringEncoding error:&err];
                if (err) {
                    fprintf(stderr, "** error reading JS file: %s\n", err.description.UTF8String);
                    return (int)err.code; // --
                }
                mainJSDir = [path stringByDeletingLastPathComponent];
                continue;
            }
        }
        if (programJS.length < 1) {
            fprintf(stderr,
                    "\n** No JavaScript program provided.\n"
                    "Please use either --js to provide an inline script, or just pass a .js file as argument.\n"
                    "For version, copyright and author info, use --version.\n"
                    "\nWhen Termipal is running, it attaches a so-called 'MicroUI' window to your terminal.\n"
                    "To exit Termipal, either click on the arrow at the right-side end of its window, or just double-click the window.\n"
                    "\n"
                    );
            return 3; // --
        }
        
        
        NSString *terminalAppId = @"com.apple.Terminal";
        for (NSRunningApplication *app in [NSWorkspace sharedWorkspace].runningApplications) {
            if (app.active) {
                //NSLog(@"active running app is: %@", app);
                terminalAppId = app.bundleIdentifier;
            }
        }
        
        
        // -- start the Cocoa app
        
        [NSApplication sharedApplication];
        
        NSApp.activationPolicy = NSApplicationActivationPolicyRegular;
        
        AppDelegate *appDelegate = [[AppDelegate alloc] init];
        NSApp.delegate = appDelegate;
        
        PalAttachedWindow *window = [[PalAttachedWindow alloc] init];
        appDelegate.window = window;
        
        appDelegate.watchedAppId = terminalAppId;
        appDelegate.versionString = [NSString stringWithUTF8String:versionStr];
        appDelegate.mainJSProgram = programJS ?: @"";
        appDelegate.mainJSDir = mainJSDir;

        [NSApp run];
        
        //int nsRet = NSApplicationMain(argc, argv);
        //NSLog(@"NSApp returned with %d", nsRet);
    }
    return 0;
}
