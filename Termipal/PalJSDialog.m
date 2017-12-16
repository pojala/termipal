//
//  PalJSDialog.m
//  Termipal
//
//  Created by Pauli Ojala on 17/12/2017.
//  Copyright © 2017 Lacquer. All rights reserved.
//

#import "PalJSDialog.h"
#import <AppKit/AppKit.h>


@implementation PalJSDialog

- (void)showOpenDialogWithProperties:(NSDictionary *)props callback:(JSValue *)cb
{
    NSString *title = props[@"title"];
    NSArray *filters = props[@"filters"];
    
    NSOpenPanel *openPanel = [NSOpenPanel openPanel];
    if (title)
        openPanel.title = title;
    
    if (filters) {
        
    }
    
    openPanel.canChooseFiles = YES;
    openPanel.allowsMultipleSelection = NO;
    
    NSModalResponse result = [openPanel runModal];

    if (result != NSModalResponseOK) {
        [cb callWithArguments:@[]];
        return; // --
    }
    NSArray *urls = openPanel.URLs;
    NSMutableArray *files = [NSMutableArray arrayWithCapacity:urls.count];
    for (NSURL *url in urls) {
        [files addObject:url.path];
    }
    [cb callWithArguments:@[files]];
    
}

@end
