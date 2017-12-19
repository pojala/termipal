//
//  ENOJSProcess.m
//  Electrino
//
//  Created by Pauli Olavi Ojala on 03/05/17.
//  Copyright © 2017 Pauli Olavi Ojala.
//
//  This software may be modified and distributed under the terms of the MIT license.  See the LICENSE file for details.
//

#import "ENOJSProcess.h"


@interface ENOJSProcess ()
@property (nonatomic) ENOJSProcessFdSocket *stdoutFdSocket;
@property (nonatomic) ENOJSProcessFdSocket *stderrFdSocket;
@end


@implementation ENOJSProcess

@synthesize platform;
@synthesize versions;
@synthesize cwd;
@synthesize argv;
@synthesize env;


- (id)initWithVersions:(NSDictionary *)versions
{
    self = [super init];
    
    self.platform = @"darwin";
    
    self.versions = versions;
    
    self.stdoutFdSocket = [[ENOJSProcessFdSocket alloc] initWithFilePtr:stdout];
    self.stderrFdSocket = [[ENOJSProcessFdSocket alloc] initWithFilePtr:stderr];
    
    return self;
}


- (id)getStdoutFdSocket
{
    return self.stdoutFdSocket;
}

- (id)getStderrFdSocket
{
    return self.stderrFdSocket;
}

@end
