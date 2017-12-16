//
//  PalBaseViewController.m
//  Termipal
//
//  Created by Pauli Ojala on 15/12/2017.
//  Copyright © 2017 Lacquer. All rights reserved.
//

#import "PalBaseViewController.h"
#import "PalBaseView.h"
#import "PalAttachedWindow.h"
#import "AppDelegate.h"


@interface PalBaseViewController ()

@property (nonatomic) NSMutableDictionary *viewIdsByTag;

@property (nonatomic) NSMutableDictionary *actionResultValuesByViewId;

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
    
    // TEST
    viewDescs = @[
            @{
                @"id": @"item1",
                @"type": @"label",
                @"text": @"Choose server:"
                },
            @{
                @"id": @"item2",
                @"type": @"popup",
                @"items": @[
                        
                        ]
                },
            ];
    
    self.viewIdsByTag = [NSMutableDictionary dictionary];
    NSInteger tag = 1000;
    NSRect frame;
    double w;
    double x = 9;
    double yMargin = 5;
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
        else if ([type isEqualToString:@"popup"]) {
            w = 160;
            frame = NSMakeRect(x, yMargin, w, 18);
            NSPopUpButton *popup = [[NSPopUpButton alloc] initWithFrame:frame];
            popup.controlSize = controlSize;
            popup.font = systemFont;
            [self.view addSubview:popup];
            
            NSMenu *menu = [[NSMenu alloc] init];
            NSMenuItem *menuItem;
            
            menuItem = [[NSMenuItem alloc] initWithTitle:@"Lorem ipsum" action:NULL keyEquivalent:@""];
            menuItem.target = self;
            menuItem.action = @selector(popUpAction:);
            menuItem.tag = tag;
            [menu addItem:menuItem];
            menuItem = [[NSMenuItem alloc] initWithTitle:@"Lorem ipsum 2" action:NULL keyEquivalent:@""];
            menuItem.target = self;
            menuItem.action = @selector(popUpAction:);
            menuItem.tag = tag;
            [menu addItem:menuItem];
            
            popup.menu = menu;
            popup.tag = tag;
            
            defaultVal = @(0);
        }
        
        if (viewId) {
            _viewIdsByTag[@(tag)] = viewId;
            
            if (defaultVal) {
                _actionResultValuesByViewId[viewId] = defaultVal;
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

@end
