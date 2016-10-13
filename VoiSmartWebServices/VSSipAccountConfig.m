//
//  VSSipAccountConfig.m
//  VoiSmart Web Services
//
//  Created by Alex on 13/11/13.
//  Copyright (c) 2013 Alex. All rights reserved.
//

#import "VSSipAccountConfig.h"

@implementation VSSipAccountConfig

-(NSInteger)port
{
    if (_port <= 0) {
        return 5060;
    }
    return _port;
}

- (NSString *)description
{
    return [NSString stringWithFormat:@"\nVSSipAccountConfig\nPrivate Id: %@\nPassword: %@\nRealm: %@\nHost: %@\nPort: %zu",
            self.privateId, self.password, self.realm, self.host, (long)self.port];
}

@end
