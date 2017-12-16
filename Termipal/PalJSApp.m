//
//  PalJSApp.m
//  Termipal
//
//  Created by Pauli Olavi Ojala on 03/05/17.
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

#import <AppKit/AppKit.h>
#import "PalJSApp.h"
#import "PalJavaScriptMicroUIApp.h"
#import "PalBaseViewController.h"
#import "AxWindowWatcher.h"


@interface PalJSApp ()

@property (nonatomic, strong) NSMutableDictionary *eventCallbacks;

@end


@implementation PalJSApp

@synthesize openUrl;
@synthesize alert;

- (id)init
{
    self = [super init];
    
    self.eventCallbacks = [NSMutableDictionary dictionary];
    
    __weak PalJSApp *me = self;
    
    self.openUrl = ^(NSString *urlStr) {
        if (urlStr.length < 1)
            return; // --
        
        // toggle this flag so that the floater window gets hidden when the browser opens
        me.axWindowWatcher.insideUserActionInFloater = NO;
        
        NSURL *url = [NSURL URLWithString:urlStr];
        [[NSWorkspace sharedWorkspace] openURL:url];
    };
    
    self.alert = ^(NSString *str) {
        NSAlert *alert = [[NSAlert alloc] init];
        [alert setAlertStyle:NSAlertStyleInformational];
        [alert addButtonWithTitle:@"Ok"];
        [alert setMessageText:str ?: @"(No message provided)"];
        [alert runModal];
    };

    return self;
}

- (void)on:(NSString *)event withCallback:(JSValue *)cb
{
    if (event.length > 0 && cb) {
        NSMutableArray *cbArr = self.eventCallbacks[event] ?: [NSMutableArray array];
        [cbArr addObject:cb];
        
        self.eventCallbacks[event] = cbArr;
    }
}

- (BOOL)emitReady:(NSError **)outError
{
    self.jsApp.lastException = nil;
    
    for (JSValue *cb in self.eventCallbacks[@"ready"]) {
        //NSLog(@"%s, %@", __func__, cb);
        
        [cb callWithArguments:@[]];
        
        if (self.jsApp.lastException) {
            if (outError) {
                *outError = [NSError errorWithDomain:kPalJavaScriptErrorDomain
                                                code:102
                                            userInfo:@{
                                                       NSLocalizedDescriptionKey: self.jsApp.lastException,
                                                       @"SourceLineNumber": @(self.jsApp.lastExceptionLine),
                                                       }];
            }
            return NO;
        }
    }
    return YES;
}

- (BOOL)emitExitWithUIValues:(NSDictionary *)uiValues error:(NSError **)outError
{
    self.jsApp.lastException = nil;
    self.exitCode = 0;
    
    for (JSValue *cb in self.eventCallbacks[@"exit"]) {
        //NSLog(@"%s, %@", __func__, cb);
        
        JSValue *ret = [cb callWithArguments:@[uiValues ?: @""]];
        if (ret.isNumber) {
            self.exitCode = ret.toInt32;
        }
        
        if (self.jsApp.lastException) {
            if (outError) {
                *outError = [NSError errorWithDomain:kPalJavaScriptErrorDomain
                                                code:102
                                            userInfo:@{
                                                       NSLocalizedDescriptionKey: self.jsApp.lastException,
                                                       @"SourceLineNumber": @(self.jsApp.lastExceptionLine),
                                                       }];
            }
            return NO;
        }
    }
    return YES;
}

- (NSDictionary *)currentUIValues
{
    return self.palBaseViewController.actionResultValuesByViewId;
}

@end
