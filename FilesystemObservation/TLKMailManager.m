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

- (void)sendMail
{
    MCOSMTPSession *smtpSession = [[MCOSMTPSession alloc] init];
    smtpSession.hostname = @"smtp.gmail.com";
    smtpSession.port = 465;
    smtpSession.username = @"sdfsdf@gmail.com";
    smtpSession.password = @"sdfsfsdf";
    smtpSession.authType = MCOAuthTypeSASLPlain;
    smtpSession.connectionType = MCOConnectionTypeTLS;
    
    MCOMessageBuilder *builder = [[MCOMessageBuilder alloc] init];
    MCOAddress *from = [MCOAddress addressWithDisplayName:@"Emil Marashliev"
                                                  mailbox:@"marashliev@gmail.com"];
    MCOAddress *to = [MCOAddress addressWithDisplayName:nil
                                                mailbox:@"emil.marashliev@telerik.com"];
    [[builder header] setFrom:from];
    [[builder header] setTo:@[to]];
    [[builder header] setSubject:@"My message"];
    [builder setHTMLBody:@"This is a test message!"];
    NSData * rfc822Data = [builder data];
    
    MCOSMTPSendOperation *sendOperation =
    [smtpSession sendOperationWithData:rfc822Data];
    [sendOperation start:^(NSError *error) {
        if(error) {
            NSLog(@"Error sending email: %@", error);
        } else {
            NSLog(@"Successfully sent email!");
        }
    }];
}

@end
