//
//  ENOJSProcess.h
//  Electrino
//
//  Created by Pauli Olavi Ojala on 03/05/17.
//  Copyright © 2017 Pauli Olavi Ojala.
//
//  This software may be modified and distributed under the terms of the MIT license.  See the LICENSE file for details.
//

#import <Foundation/Foundation.h>
#import <JavaScriptCore/JavaScriptCore.h>
#import "ENOJSProcessFdSocket.h"


@protocol ENOJSProcessExports <JSExport>

@property (nonatomic, copy) NSString *platform;
@property (nonatomic, copy) NSDictionary *versions;
@property (nonatomic, copy) NSString *cwd;
@property (nonatomic, copy) NSArray *argv;
@property (nonatomic, copy) NSDictionary *env;

// we can't use properties named stdout/stderr because they are macros.
// instead we'll just manually patch the return values from these at runtime into stdout/stderr properties on the JS process object.
- (id)getStdoutFdSocket;
- (id)getStderrFdSocket;

@end


@interface ENOJSProcess : NSObject <ENOJSProcessExports>

- (id)initWithVersions:(NSDictionary *)versions;

@end
