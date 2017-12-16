//
//  PalJSDialog.h
//  Termipal
//
//  Created by Pauli Ojala on 17/12/2017.
//  Copyright © 2017 Lacquer. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <JavaScriptCore/JavaScriptCore.h>

@protocol PalJSDialogExports <JSExport>

JSExportAs(showOpenDialog,
- (void)showOpenDialogWithProperties:(NSDictionary *)props callback:(JSValue *)cb
);

@end


@interface PalJSDialog : NSObject <PalJSDialogExports>

@end
