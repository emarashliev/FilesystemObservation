//
//  TLKMailManager.h
//  FilesystemObservation
//
//  Created by Emil Marashliev on 2/5/14.
//  Copyright (c) 2014 Emil Marashliev. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface TLKMailManager : NSObject

+ (instancetype)sharedManager;

- (void)sendMailWithBody:(NSString *)body;

@end
