//
//  ENOJSProcessFdSocket.m
//  Termipal
//
//  Created by Pauli Ojala on 18/12/2017.
//  Copyright © 2017 Lacquer. All rights reserved.
//

#import "ENOJSProcessFdSocket.h"

@interface ENOJSProcessFdSocket () {
    FILE *_fd;
}
@end


@implementation ENOJSProcessFdSocket

- (id)initWithFilePtr:(FILE *)f
{
    self = [super init];
    
    _fd = f;
    
    return self;
}

- (void)write:(id)bufferOrString
{
    if ( !bufferOrString)
        return;
    
    const char *utf8 = [bufferOrString description].UTF8String;
    size_t len = strlen(utf8);
    
    fwrite(utf8, 1, len, _fd);
}

@end
