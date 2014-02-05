//
//  TLKConfiguration.h
//  FilesystemObservation
//
//  Created by Emil Marashliev on 2/5/14.
//  Copyright (c) 2014 Emil Marashliev. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface TLKConfiguration : NSObject

@property (readonly, nonatomic, strong) NSDictionary *config;

+ (instancetype)sharedConfiguration;


@end
