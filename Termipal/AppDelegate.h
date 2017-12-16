//
//  AppDelegate.h
//  TermStalker
//
//  Created by Pauli Ojala on 15/02/16.
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

#import <Cocoa/Cocoa.h>
#import "PalAttachedWindow.h"
#import "AxWindowWatcher.h"


@interface AppDelegate : NSObject <NSApplicationDelegate>

@property (strong) IBOutlet PalAttachedWindow *window;

@property (strong) AxWindowWatcher *axWindowWatcher;

@property (strong) NSString *versionString;
@property (strong) NSString *watchedAppId;
@property (strong) NSString *mainJSProgram;
@property (strong) NSArray *mainUIDefinition;


- (void)exitAndReactivateOriginal;

- (void)performJSActionNamed:(NSString *)actionName;

@end

