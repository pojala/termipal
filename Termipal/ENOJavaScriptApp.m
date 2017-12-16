//
//  ENOJavaScriptApp.m
//  Electrino
//
//  Created by Pauli Olavi Ojala on 03/05/17.
//  Copyright © 2017 Pauli Olavi Ojala.
//
//  This software may be modified and distributed under the terms of the MIT license.  See the LICENSE file for details.
//

#import "ENOJavaScriptApp.h"
#import "ENOJSPath.h"
#import "ENOJSUrl.h"
#import "PalJSApp.h"
#import "ENOJSProcess.h"
#import "ENOJSConsole.h"


NSString * const kENOJavaScriptErrorDomain = @"ENOJavaScriptErrorDomain";


@interface ENOJavaScriptApp ()

@property (nonatomic, strong) JSVirtualMachine *jsVM;
@property (nonatomic, strong) JSContext *jsContext;
@property (nonatomic, strong) NSDictionary *jsModules;
@property (nonatomic, strong) PalJSApp *jsAppGlobalObject;

@property (nonatomic, assign) BOOL inException;

@end


@implementation ENOJavaScriptApp

- (id)initWithVersion:(NSString *)version
{
    self = [super init];
    
    
    self.jsVM = [[JSVirtualMachine alloc] init];
    self.jsContext = [[JSContext alloc] initWithVirtualMachine:self.jsVM];
    
    self.jsAppGlobalObject = [[PalJSApp alloc] init];
    self.jsAppGlobalObject.jsApp = self;
    
    //NSLog(@"%s, inited app global: %@", __func__, self.jsAppGlobalObject);
    
    // initialize available modules
    
    NSMutableDictionary *modules = [NSMutableDictionary dictionary];
    
    modules[@"termipal"] = @{
                              // singletons
                              @"app": self.jsAppGlobalObject,
                              /*
                              @"ipcMain": self.jsIPCMain,
                              @"nativeImage": [[ENOJSNativeImageAPI alloc] init],
                              
                              // classes that can be constructed
                              @"BrowserWindow": [ENOJSBrowserWindow class],
                              @"Tray": [ENOJSTray class],
                               */
                              };
    
    modules[@"path"] = [[ENOJSPath alloc] init];
    modules[@"url"] = [[ENOJSUrl alloc] init];
    
    self.jsModules = modules;
    
    
    // add exception handler and global functions
    
    __block __weak ENOJavaScriptApp *weakSelf = self;
    
    self.jsContext.exceptionHandler = ^(JSContext *context, JSValue *exception) {
        [weakSelf _jsException:exception];
    };
    
    self.jsContext[@"require"] = ^(NSString *arg) {
        id module = weakSelf.jsModules[arg];
        return module;
    };
    
    self.jsContext[@"process"] = [[ENOJSProcess alloc] initWithVersions:@{
                                                                          @"termipal": version
                                                                          }];
                                  
    self.jsContext[@"console"] = [[ENOJSConsole alloc] init];
    
    return self;
}

- (void)dealloc
{
    self.jsContext.exceptionHandler = NULL;
    self.jsContext[@"require"] = nil;
}

- (void)_jsException:(JSValue *)exception
{
    NSLog(@"%s, %@", __func__, exception);
    
    if (self.inException) {  // prevent recursion, just in case
        return; // --
    }
    
    self.inException = YES;
    
    self.lastException = exception.toString;
    self.lastExceptionLine = [exception valueForProperty:@"line"].toInt32;
    
    self.inException = NO;
}

- (BOOL)loadMainJS:(NSString *)js error:(NSError **)outError
{
    self.lastException = nil;
    
    [self.jsContext evaluateScript:js];
    
    if (self.lastException) {
        if (outError) {
            *outError = [NSError errorWithDomain:kENOJavaScriptErrorDomain
                                           code:101
                                       userInfo:@{
                                                  NSLocalizedDescriptionKey: self.lastException,
                                                  @"SourceLineNumber": @(self.lastExceptionLine),
                                                  }];
        }
        return NO; // --
    }
    
    return YES;
}




@end
