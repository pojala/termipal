//
//  ENOJSProcessFdSocket.h
//  Termipal
//
//  Created by Pauli Ojala on 18/12/2017.
//  Copyright © 2017 Lacquer. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <JavaScriptCore/JavaScriptCore.h>


@protocol ENOJSProcessFdSocketExports <JSExport>

- (void)write:(id)bufferOrString;

@end


@interface ENOJSProcessFdSocket : NSObject <ENOJSProcessFdSocketExports>

- (id)initWithFilePtr:(FILE *)f;

@end
