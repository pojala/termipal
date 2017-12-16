//
//  PalJavaScriptMicroUIApp.h
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

#import <Foundation/Foundation.h>
#import <JavaScriptCore/JavaScriptCore.h>
#import "PalJSApp.h"
#import "PalBaseViewController.h"


extern NSString * const kPalJavaScriptErrorDomain;


@interface PalJavaScriptMicroUIApp : NSObject

- (id)initWithVersion:(NSString *)version microUIViewController:(PalBaseViewController *)viewCtrl;

@property (nonatomic, readonly) JSContext *jsContext;

@property (nonatomic, readonly) PalJSApp *jsAppGlobalObject;

@property (nonatomic, strong) NSString *lastException;
@property (nonatomic, assign) NSInteger lastExceptionLine;


- (BOOL)loadMainJS:(NSString *)js error:(NSError **)outError;

@end
