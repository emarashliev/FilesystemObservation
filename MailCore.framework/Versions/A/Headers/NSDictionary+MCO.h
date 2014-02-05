//
//  NSDictionary+MCO.h
//  mailcore2
//
//  Created by DINH Viêt Hoà on 1/29/13.
//  Copyright (c) 2013 MailCore. All rights reserved.
//

#ifndef __MAILCORE_NSDICTIONARY_MCO_H_

#define __MAILCORE_NSDICTIONARY_MCO_H_

#import <Foundation/Foundation.h>

#ifdef __cplusplus
namespace mailcore {
    class HashMap;
}
#endif

@interface NSDictionary (MCO)

#ifdef __cplusplus
+ (NSDictionary *) mco_dictionaryWithMCHashMap:(mailcore::HashMap *)hashmap;

- (mailcore::HashMap *) mco_mcHashMap;
#endif

@end

#endif