//
//  main.m
//  TermipalUtil
//
//  Created by Pauli Ojala on 03/12/2017.
//  Copyright © 2017 Lacquer. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AppDelegate.h"
#import "PalAttachedWindow.h"


int main(int argc, const char * argv[]) {
    @autoreleasepool {
        // -- get command line args
        NSString *uiJSON = nil;
        NSString *programJS = nil;
        for (int i = 1; i < argc; i++) {
            if (0 == strcmp(argv[i], "--ui") && i < argc-1) {
                uiJSON = [NSString stringWithUTF8String:argv[++i]];
            }
            else if (0 == strcmp(argv[i], "--js") && i < argc-1) {
                programJS = [NSString stringWithUTF8String:argv[++i]];
            }
            else if (0 == strcmp(argv[i], "--ui-file") && i < argc-1) {
                NSString *path = [NSString stringWithUTF8String:argv[++i]];
                NSError *err = nil;
                uiJSON = [NSString stringWithContentsOfFile:path encoding:NSUTF8StringEncoding error:&err];
                if (err) {
                    fprintf(stderr, "** error reading UI file: %s\n", err.description.UTF8String);
                    return (int)err.code; // --
                }
            }
            else if (0 == strcmp(argv[i], "--js-file") && i < argc-1) {
                NSString *path = [NSString stringWithUTF8String:argv[++i]];
                NSError *err = nil;
                programJS = [NSString stringWithContentsOfFile:path encoding:NSUTF8StringEncoding error:&err];
                if (err) {
                    fprintf(stderr, "** error reading JS file: %s\n", err.description.UTF8String);
                    return (int)err.code; // --
                }
            }
        }
        if (uiJSON.length < 1) {
#if 1
            uiJSON = @"{}";  // testing
#else
            fprintf(stderr, "** No UI JSON provided. Please use either --ui or --ui-file.\n");
            return 3; // --
#endif
        }
        
        
        // -- start the Cocoa app
        
        [NSApplication sharedApplication];
        
        NSApp.activationPolicy = NSApplicationActivationPolicyRegular;
        
        AppDelegate *appDelegate = [[AppDelegate alloc] init];
        NSApp.delegate = appDelegate;
        
        PalAttachedWindow *window = [[PalAttachedWindow alloc] init];
        appDelegate.window = window;
        
        appDelegate.mainJSProgram = programJS ?: @"";

        if ( ![window.baseViewController buildUIFromJSON:uiJSON]) {
            return 31;
        }
        
        [NSApp run];
        
        //int nsRet = NSApplicationMain(argc, argv);
        //NSLog(@"NSApp returned with %d", nsRet);
    }
    return 0;
}
