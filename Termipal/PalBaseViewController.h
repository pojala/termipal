//
//  PalBaseViewController.h
//  Termipal
//
//  Created by Pauli Ojala on 15/12/2017.
//  Copyright © 2017 Lacquer. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface PalBaseViewController : NSViewController

@property (nonatomic) NSButton *closeButton;

- (BOOL)buildUIFromJSON:(NSString *)json;

@property (nonatomic, readonly) NSDictionary *actionResultValuesByViewId;

@end
