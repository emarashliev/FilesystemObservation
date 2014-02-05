//
//  TLKObservationManager.m
//  FilesystemObservation
//
//  Created by Emil Marashliev on 2/5/14.
//  Copyright (c) 2014 Emil Marashliev. All rights reserved.
//

#import "TLKObservationManager.h"
#import "TLKConfiguration.h"
#import <CoreServices/CoreServices.h>



static void callbackFunction( ConstFSEventStreamRef streamRef,
                             void *clientCallBackInfo,
                             size_t numEvents,
                             void *eventPaths,
                             const FSEventStreamEventFlags eventFlags[],
                             const FSEventStreamEventId eventIds[] )__attribute__((const));

static CFStringRef eventTypeForFlag(FSEventStreamEventFlags flag)__attribute__((const));




@implementation TLKObservationManager

static id _sharedManager;

+ (instancetype)sharedManager
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


- (void)attachListener
{

    CFArrayRef pathsToWatch = (__bridge CFArrayRef)[TLKConfiguration sharedConfiguration].config[@"pathsToWatch"];
    void *callbackInfo = NULL; // could put stream-specific data here.
    FSEventStreamRef stream;
    CFAbsoluteTime latency = [[TLKConfiguration sharedConfiguration].config[@"otherConfigurations"][@"latencyInSeconds"] doubleValue];
    
    /* Create the stream, passing in a callback */
    stream = FSEventStreamCreate(NULL,
                                 &callbackFunction,
                                 callbackInfo,
                                 pathsToWatch,
                                 kFSEventStreamEventIdSinceNow, /* Or a previous event ID */
                                 latency,
                                 kFSEventStreamCreateFlagFileEvents /* Flags explained in reference */ );
    FSEventStreamScheduleWithRunLoop(stream, CFRunLoopGetCurrent(), kCFRunLoopDefaultMode);
    FSEventStreamStart(stream);
    CFRunLoopRun();
}


@end

CFStringRef eventTypeForFlag(const FSEventStreamEventFlags eventFlag)
{
    NSMutableArray * array = [ NSMutableArray array ] ;
    const char * flags[] = {
        "MustScanSubDirs",
        "UserDropped",
        "KernelDropped",
        "EventIdsWrapped",
        "HistoryDone",
        "RootChanged",
        "Mount",
        "Unmount",
        "ItemCreated",
        "ItemRemoved",
        "ItemInodeMetaMod",
        "ItemRenamed",
        "ItemModified",
        "ItemFinderInfoMod",
        "ItemChangeOwner",
        "ItemXattrMod",
        "ItemIsFile",
        "ItemIsDir",
        "ItemIsSymlink",
        "OwnEvent"
    } ;
    
    
    long bit = 1 ;
    for( int index=0, count = sizeof( flags ) / sizeof( flags[0]); index < count; ++index ) {
        if ( ( eventFlag & bit ) != 0 ) {
            [array addObject:[NSString stringWithUTF8String:flags[ index ]]] ;
        }
        bit <<= 1 ;
    }

    NSString * result = [array componentsJoinedByString:@" "];
    return (__bridge CFStringRef)result;
}


void callbackFunction( ConstFSEventStreamRef streamRef,
                      void *clientCallBackInfo,
                      size_t numEvents,
                      void *eventPaths,
                      const FSEventStreamEventFlags eventFlags[],
                      const FSEventStreamEventId eventIds[] )
{
    int i;
    char **paths = eventPaths;
    
    for (i=0; i<numEvents; i++) {
        /* flags are unsigned long, IDs are uint64_t */
        CFStringRef eventStr = eventTypeForFlag(eventFlags[i]);
        CFIndex length = CFStringGetLength(eventStr);
        CFIndex maxSize =
        CFStringGetMaximumSizeForEncoding(length,
                                          kCFStringEncodingUTF8);
        char *event = (char *)malloc(maxSize);

        CFStringGetCString(eventStr, event, maxSize,
                           kCFStringEncodingUTF8);
        printf("Change %llu in %s,  %s\n", eventIds[i], paths[i], event);
    }

    
    
}

