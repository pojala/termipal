//
//  ENOJavaScriptApp.h
//  Electrino
//
//  Created by Pauli Olavi Ojala on 03/05/17.
//  Copyright © 2017 Pauli Olavi Ojala.
//
//  This software may be modified and distributed under the terms of the MIT license.  See the LICENSE file for details.
//

#import <Foundation/Foundation.h>
#import <JavaScriptCore/JavaScriptCore.h>
#import "PalJSApp.h"


extern NSString * const kENOJavaScriptErrorDomain;


@interface ENOJavaScriptApp : NSObject

- (id)initWithVersion:(NSString *)version;

@property (nonatomic, readonly) JSContext *jsContext;

@property (nonatomic, readonly) PalJSApp *jsAppGlobalObject;

@property (nonatomic, strong) NSString *lastException;
@property (nonatomic, assign) NSInteger lastExceptionLine;


- (BOOL)loadMainJS:(NSString *)js error:(NSError **)outError;

@end
