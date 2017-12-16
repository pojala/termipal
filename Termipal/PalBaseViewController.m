//
//  PalBaseViewController.m
//  Termipal
//
//  Created by Pauli Ojala on 15/12/2017.
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

#import "PalBaseViewController.h"
#import "PalBaseView.h"
#import "PalAttachedWindow.h"
#import "AppDelegate.h"


@interface PalBaseViewController ()

@property (nonatomic, strong) NSArray *uiDefinition;

@property (nonatomic, strong) NSMutableDictionary *viewIdsByTag;
@property (nonatomic, strong) NSMutableDictionary *actionHandlersByViewId;

@property (nonatomic, strong) NSMutableDictionary *actionResultValuesByViewId;

@end



@implementation PalBaseViewController

- (id)init
{
    self = [super init];
    
    self.view = [[PalBaseView alloc] initWithFrame:NSMakeRect(0, 0, 100, 100)];
    
    NSButton *closeButton = [[NSButton alloc] initWithFrame:NSMakeRect(78, 7, 16, 16)];
    closeButton.cell.bezeled = NO;
    closeButton.cell.bordered = NO;
    closeButton.image = [NSImage imageNamed:@"NSGoForwardTemplate"];
    closeButton.autoresizingMask = (NSViewMinXMargin);
    [self.view addSubview:closeButton];
    self.closeButton = closeButton;
    
    closeButton.target = NSApp.delegate;
    closeButton.action = @selector(exitAndReactivateOriginal);
    
    self.actionResultValuesByViewId = [NSMutableDictionary dictionary];
    
    return self;
}


- (BOOL)buildUIFromJSON:(NSString *)json
{
    NSError *jsonErr = nil;
    id obj;
    if ( !(obj = [NSJSONSerialization JSONObjectWithData:[json dataUsingEncoding:NSUTF8StringEncoding]
                                    options:0
                                            error:&jsonErr])) {
        fprintf(stderr, "** %s failed: %s", __func__, jsonErr.description.UTF8String);
        return NO;
    }
    
    NSArray *viewDescs = nil;
    if ( ![obj isKindOfClass:[NSArray class]]) {
        viewDescs = @[ obj ];
    } else {
        viewDescs = obj;
    }
    
#if 0
    // TEST
    viewDescs = @[
            @{
                @"type": @"label",
                @"text": @"Choose server:"
                },
            @{
                @"id": @"testPopup",
                @"type": @"popup",
                @"items": @[
                        
                        ]
                },
            @{
                @"id": @"button1",
                @"type": @"button",
                @"text": @"Show help",
                @"action": @"buttonClicked",
                },
            ];
#endif
    
    self.uiDefinition = viewDescs;
    self.viewIdsByTag = [NSMutableDictionary dictionary];
    self.actionHandlersByViewId = [NSMutableDictionary dictionary];
    NSInteger tag = 1000;
    NSRect frame;
    double w;
    double x = 9;
    double yMargin = 4;
    double xIntv = 4;
    NSControlSize controlSize = NSControlSizeSmall;
    NSFont *systemFont = [NSFont systemFontOfSize:[NSFont systemFontSizeForControlSize:controlSize]];
    
    // white shadow makes text more legible against NSVisualEffectView's blurred background
    NSShadow *textShadow = [[NSShadow alloc] init];
    textShadow.shadowColor = [NSColor colorWithDeviceWhite:1.0 alpha:1.0];
    textShadow.shadowOffset = NSMakeSize(0, 0);
    textShadow.shadowBlurRadius = 2.0;
    
    for (NSDictionary *desc in viewDescs) {
        if ( ![desc isKindOfClass:[NSDictionary class]]) {
            fprintf(stderr, "Invalid object in view array: %s", [desc.class description].UTF8String);
            continue;
        }
        
        NSString *type = desc[@"type"];
        NSString *viewId = desc[@"id"];
        
        w = 0;
        id defaultVal = nil;
        
        if ([type isEqualToString:@"label"]) {
            NSString *text = desc[@"text"] ?: @"";
            NSDictionary *attrs = @{
                                    NSForegroundColorAttributeName: [NSColor blackColor],
                                    NSFontAttributeName: systemFont,
                                    NSShadowAttributeName: textShadow
                                    };
            NSSize size = [text sizeWithAttributes:attrs];
            w = ceil(size.width) + 4;
            frame = NSMakeRect(x, yMargin + 2, w, 15);
            
            NSTextField *field = [[NSTextField alloc] initWithFrame:frame];
            field.drawsBackground = NO;
            field.bezeled = NO;
            field.editable = NO;
            field.selectable = NO;
            field.attributedStringValue = [[NSAttributedString alloc] initWithString:text attributes:attrs];
            field.tag = tag;
            [self.view addSubview:field];
        }
        else if ([type isEqualToString:@"button"]) {
            NSString *text = desc[@"text"] ?: @"";
            NSDictionary *attrs = @{
                                    NSFontAttributeName: systemFont,
                                    };
            NSSize size = [text sizeWithAttributes:attrs];
            w = ceil(size.width) + 30;
            frame = NSMakeRect(x, yMargin, w, 20);
            
            NSButton *button = [[NSButton alloc] initWithFrame:frame];
            button.controlSize = controlSize;
            button.font = systemFont;
            button.tag = tag;
            button.title = text;
            button.bezelStyle = NSRoundedBezelStyle;
            button.target = self;
            button.action = @selector(buttonAction:);
            [self.view addSubview:button];
        }
        else if ([type isEqualToString:@"popup"]) {
            w = 160;
            frame = NSMakeRect(x, yMargin, w, 20);
            
            NSPopUpButton *popup = [[NSPopUpButton alloc] initWithFrame:frame];
            popup.controlSize = controlSize;
            popup.font = systemFont;
            [self.view addSubview:popup];
            
            NSMenu *menu = [[NSMenu alloc] init];
            NSMenuItem *menuItem;
            
            NSArray *items = desc[@"items"];
            if ([items isKindOfClass:[NSArray class]]) {
                for (NSString *item in items) {
                    menuItem = [[NSMenuItem alloc] initWithTitle:item.description action:NULL keyEquivalent:@""];
                    menuItem.target = self;
                    menuItem.action = @selector(popUpAction:);
                    menuItem.tag = tag;
                    [menu addItem:menuItem];
                }
            }
            
            popup.menu = menu;
            popup.tag = tag;
            
            defaultVal = @(0);
        }
        
        if (viewId) {
            _viewIdsByTag[@(tag)] = viewId;
            
            if (defaultVal) {
                _actionResultValuesByViewId[viewId] = defaultVal;
            }
            
            NSString *action = desc[@"action"];
            if (action) {
                _actionHandlersByViewId[viewId] = action;
            }
        }
        
        tag++;
        x += w + xIntv;
    }
    
    return YES;
}


- (void)popUpAction:(id)sender
{
    PalAttachedWindow *window = (id)self.view.window;
    window.axWindowWatcher.insideUserActionInFloater = YES;
    
    NSString *viewId = _viewIdsByTag[@([sender tag])];
    if ( !viewId)
        return; // --
    
    NSInteger idx = [[sender menu] indexOfItem:sender];
    
    //NSLog(@"%s, viewid '%@', idx %ld", __func__, viewId, idx);
    
    _actionResultValuesByViewId[viewId] = @(idx);
}

- (void)buttonAction:(id)sender
{
    PalAttachedWindow *window = (id)self.view.window;
    window.axWindowWatcher.insideUserActionInFloater = YES;

    NSString *viewId = _viewIdsByTag[@([sender tag])];
    if ( !viewId)
        return; // --
    
    NSString *actionName = _actionHandlersByViewId[viewId];
    
    //NSLog(@"clicked button: %@, action: '%@'", viewId, actionName);
    
    if (actionName.length > 0) {
        [((AppDelegate *)NSApp.delegate) performJSActionNamed:actionName];
    }
}

@end

