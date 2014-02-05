//
//  TLKConfiguration.m
//  FilesystemObservation
//
//  Created by Emil Marashliev on 2/5/14.
//  Copyright (c) 2014 Emil Marashliev. All rights reserved.
//

#include <unistd.h>
#include <sys/types.h>
#include <pwd.h>
#include <assert.h>

#import "TLKConfiguration.h"

@implementation TLKConfiguration
@synthesize config = _config;


static id _sharedManager;

+ (instancetype)sharedConfiguration
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedManager = [[self alloc] init];
    });
    return _sharedManager;
}

+ (id)alloc
{
    @synchronized(self){
        NSAssert(_sharedManager == nil, @"Attempt to allocate a second instance of singleton %@", [self class]);
        _sharedManager = [super alloc];
        return _sharedManager;
    }
    return nil;
}


- (NSDictionary *)loadConfig
{
    NSString *file = [[self homeDirectory]  stringByAppendingString:@"/.fobservation"];
    NSError *error;
    NSDictionary *json = [NSJSONSerialization JSONObjectWithData:[NSData dataWithContentsOfFile:file] options:NSJSONReadingAllowFragments error:&error];
    if (error) {
        NSLog(@"%@", error);
    }
    
    return json;
}


- (NSString *)homeDirectory
{
    struct passwd *pw = getpwuid(getuid());
    assert(pw);
    return [NSString stringWithUTF8String:pw->pw_dir];
}

- (NSDictionary *)config
{
    if (!_config) {
        _config = [self loadConfig];
    }
    
    return _config;
}



@end
