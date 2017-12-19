//
//  ENOJSProcessFdSocket.h
//  Termipal
//
//  Created by Pauli Ojala on 18/12/2017.
//  Copyright © 2017 Pauli Olavi Ojala.
//
//  This software may be modified and distributed under the terms of the MIT license.  See the LICENSE file for details.
//

#import <Foundation/Foundation.h>
#import <JavaScriptCore/JavaScriptCore.h>


@protocol ENOJSProcessFdSocketExports <JSExport>

- (void)write:(id)bufferOrString;

@end


@interface ENOJSProcessFdSocket : NSObject <ENOJSProcessFdSocketExports>

- (id)initWithFilePtr:(FILE *)f;

@end
