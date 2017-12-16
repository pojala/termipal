//
//  PalJSMicroUI.m
//  Termipal
//
//  Created by Pauli Ojala on 17/12/2017.
//  Copyright © 2017 Lacquer. All rights reserved.
//

#import "PalJSMicroUI.h"
#import "PalBaseViewController.h"


@interface PalJSMicroUI ()

@end


@implementation PalJSMicroUI

- (BOOL)loadUIDefinition:(NSArray *)array
{
    if ( ![array isKindOfClass:[NSArray class]])
        return NO; // --
    
    BOOL ok = [self.palBaseViewController buildUIFromUIDefinition:array];
    if (ok) {
        self.UIDefinition = array;
    }
    return ok;
}

- (NSDictionary *)currentUIValues
{
    return self.palBaseViewController.actionResultValuesByViewId;
}

@end
