//
//  PalJavaScriptMicroUIApp.m
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

#import "PalJavaScriptMicroUIApp.h"
#import "ENOJSPath.h"
#import "ENOJSUrl.h"
#import "PalJSApp.h"
#import "ENOJSProcess.h"
#import "ENOJSConsole.h"
#import "PalJSMicroUI.h"
#import "PalJSDialog.h"


NSString * const kPalJavaScriptErrorDomain = @"PalJavaScriptErrorDomain";


@interface PalJavaScriptMicroUIApp ()

@property (nonatomic, strong) JSVirtualMachine *jsVM;
@property (nonatomic, strong) JSContext *jsContext;
@property (nonatomic, strong) NSDictionary *jsModules;
@property (nonatomic, strong) PalJSApp *jsAppGlobalObject;
@property (nonatomic, strong) PalJSMicroUI *jsMicroUI;
@property (nonatomic, strong) PalJSDialog *jsDialog;

@property (nonatomic, assign) BOOL inException;

@end


@implementation PalJavaScriptMicroUIApp

- (id)initWithVersion:(NSString *)version microUIViewController:(PalBaseViewController *)viewCtrl
{
    self = [super init];
    
    
    self.jsVM = [[JSVirtualMachine alloc] init];
    self.jsContext = [[JSContext alloc] initWithVirtualMachine:self.jsVM];
    
    self.jsAppGlobalObject = [[PalJSApp alloc] init];
    self.jsAppGlobalObject.jsApp = self;
    
    self.jsMicroUI = [[PalJSMicroUI alloc] init];
    self.jsMicroUI.palBaseViewController = viewCtrl;
    
    self.jsDialog = [[PalJSDialog alloc] init];
    
    //NSLog(@"%s, inited app global: %@", __func__, self.jsAppGlobalObject);
    
    // initialize available modules
    
    NSMutableDictionary *modules = [NSMutableDictionary dictionary];
    
    modules[@"termipal"] = @{
                              // singletons
                              @"app": self.jsAppGlobalObject,
                              @"microUI": self.jsMicroUI,
                              @"dialog": self.jsDialog,
                              /*
                              @"ipcMain": self.jsIPCMain,
                              @"nativeImage": [[ENOJSNativeImageAPI alloc] init],
                              */
                              
                              // classes that can be constructed
                              };
    
    modules[@"path"] = [[ENOJSPath alloc] init];
    modules[@"url"] = [[ENOJSUrl alloc] init];
    
    self.jsModules = modules;
    
    
    // add exception handler and global functions
    
    __weak PalJavaScriptMicroUIApp *weakSelf = self;
    
    self.jsContext.exceptionHandler = ^(JSContext *context, JSValue *exception) {
        [weakSelf _jsException:exception];
    };
    
    self.jsContext[@"require"] = ^(NSString *arg) {
        id module = weakSelf.jsModules[arg];
        return module;
    };
    
    ENOJSProcess *jsProcess = [[ENOJSProcess alloc] initWithVersions:@{ @"termipal": version }];
    jsProcess.cwd = [NSFileManager defaultManager].currentDirectoryPath;
    jsProcess.argv = [NSProcessInfo processInfo].arguments;
    jsProcess.env = [NSProcessInfo processInfo].environment;
    self.jsContext[@"process"] = jsProcess;
    
    // stdout/stderr properties need to be manually patched onto the process object
    // because they are macros on C side and can't be used as property names.
    [self.jsContext evaluateScript:@""
     "process.stdout = process.getStdoutFdSocket();"
     "process.stderr = process.getStderrFdSocket();"
     ];
                                  
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
            *outError = [NSError errorWithDomain:kPalJavaScriptErrorDomain
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
