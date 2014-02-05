//
//  main.m
//  FilesystemObservation
//
//  Created by Emil Marashliev on 2/5/14.
//  Copyright (c) 2014 Emil Marashliev. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "TLKMailManager.h"
#import "TLKObservationManager.h"

int main(int argc, const char * argv[])
{

    @autoreleasepool {
        
        // insert code here...
        [[TLKObservationManager sharedManager] attachListener];

        
    }
    return 0;
}

