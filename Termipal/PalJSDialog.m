//
//  PalJSDialog.m
//  Termipal
//
//  Created by Pauli Ojala on 17/12/2017.
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

#import "PalJSDialog.h"
#import <AppKit/AppKit.h>


@implementation PalJSDialog

- (void)showOpenDialogWithOptions:(NSDictionary *)opts callback:(JSValue *)cb
{
    NSString *title = opts[@"title"];
    NSString *defaultPath = opts[@"title"];
    NSArray *filters = opts[@"filters"];
    NSDictionary *properties = opts[@"properties"];
    /*
     title String
     defaultPath String
     filters Array
     properties Array - Contains which features the dialog should use, can contain openFile, openDirectory, multiSelections and createDirectory
     */
    
    NSOpenPanel *openPanel = [NSOpenPanel openPanel];
    if (title)
        openPanel.title = title;
    
    if (defaultPath)
        openPanel.directoryURL = [NSURL fileURLWithPath:defaultPath];
    
    if ([filters isKindOfClass:[NSArray class]]) {
        // TODO
    }
    
    BOOL multiSel = NO;
    BOOL chooseFiles = YES;
    BOOL chooseDirs = NO;
    BOOL createDir = NO;
    if (properties) {
        id val;
        if ((val = properties[@"openFile"]))
            chooseFiles = [val boolValue];
        if ((val = properties[@"openDirectory"]))
            chooseDirs = [val boolValue];
        if ((val = properties[@"multiSelections"]))
            multiSel = [val boolValue];
        if ((val = properties[@"createDirectory"]))
            createDir = [val boolValue];
    }
    openPanel.canChooseDirectories = chooseDirs;
    openPanel.canChooseFiles = chooseFiles;
    openPanel.allowsMultipleSelection = multiSel;
    openPanel.canCreateDirectories = createDir;
    
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
