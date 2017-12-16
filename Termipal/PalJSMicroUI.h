//
//  PalJSMicroUI.h
//  Termipal
//
//  Created by Pauli Ojala on 17/12/2017.
//  Copyright © 2017 Lacquer. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <JavaScriptCore/JavaScriptCore.h>
@class PalBaseViewController;


@protocol PalJSMicroUIExports <JSExport>

- (BOOL)loadUIDefinition:(NSArray *)array;

@property (nonatomic, readonly) NSArray *UIDefinition;
@property (nonatomic, readonly) NSDictionary *currentUIValues;

@end


@interface PalJSMicroUI : NSObject <PalJSMicroUIExports>

@property (weak) PalBaseViewController *palBaseViewController;

@property (nonatomic, strong) NSArray *UIDefinition;

@end
