//
//  TLKMailManager.m
//  FilesystemObservation
//
//  Created by Emil Marashliev on 2/5/14.
//  Copyright (c) 2014 Emil Marashliev. All rights reserved.
//

#import "TLKMailManager.h"
#import "TLKConfiguration.h"
#import <MailCore/MailCore.h>

@interface TLKMailManager ()

@property (nonatomic, strong) id mailSession;

@end


@implementation TLKMailManager

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

- (void)sendMailWithBody:(NSString *)body
{
    [self setupSMTPSession];
    
    MCOMessageBuilder *builder = [[MCOMessageBuilder alloc] init];
    MCOAddress *from = [MCOAddress addressWithDisplayName:nil
                                                  mailbox:[TLKConfiguration sharedConfiguration].config[@"email"][@"from"]];
    
    NSMutableArray *toArray = [[NSMutableArray alloc] init];
    NSArray *toRawArray = [TLKConfiguration sharedConfiguration].config[@"email"][@"to"];
    [toRawArray enumerateObjectsUsingBlock:^(NSString *email, NSUInteger idx, BOOL *stop) {
        [toArray addObject:[MCOAddress addressWithDisplayName:nil
                                                      mailbox:email]];
    }];
    
    
    [[builder header] setFrom:from];
    [[builder header] setTo:toArray];
    [[builder header] setSubject:[TLKConfiguration sharedConfiguration].config[@"email"][@"subject"]];
    [builder setHTMLBody:body];
    NSData * rfc822Data = [builder data];
    
    MCOSMTPSendOperation *sendOperation = [self.mailSession sendOperationWithData:rfc822Data];
    [sendOperation start:^(NSError *error) {
        if(error) {
            NSLog(@"Error sending email: %@", error);
        } else {
            NSLog(@"Successfully sent email!");
        }
    }];
}

- (void)setupSMTPSession
{
    MCOSMTPSession *smtpSession = [[MCOSMTPSession alloc] init];
    smtpSession.hostname = [TLKConfiguration sharedConfiguration].config[@"emailServer"][@"hostname"];
    smtpSession.port = [[TLKConfiguration sharedConfiguration].config[@"emailServer"][@"port"] intValue];
    smtpSession.username = [TLKConfiguration sharedConfiguration].config[@"emailServer"][@"username"];
    smtpSession.password = [TLKConfiguration sharedConfiguration].config[@"emailServer"][@"password"];
    smtpSession.authType = MCOAuthTypeSASLPlain;
    smtpSession.connectionType = MCOConnectionTypeTLS;
    self.mailSession = smtpSession;
}

@end
