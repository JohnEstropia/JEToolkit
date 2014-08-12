//
//  UIDevice+JEToolkit.m
//  JEToolkit
//
//  Created by John Rommel Estropia on 2014/08/12.
//  Copyright (c) 2014 John Rommel Estropia. All rights reserved.
//

#import "UIDevice+JEToolkit.h"

#include <sys/socket.h>
#include <sys/sysctl.h>
#include <net/if.h>
#include <net/if_dl.h>

@implementation UIDevice (JEToolkit)

#pragma mark - Private

- (NSString *)sysCtlWithName:(const char *)sysCtlName {
    
    size_t size;
    sysctlbyname(sysCtlName, NULL, &size, NULL, 0);
    
    char *answer = malloc(size);
    sysctlbyname(sysCtlName, answer, &size, NULL, 0);
    
    NSString *results = [NSString stringWithCString:answer encoding:NSUTF8StringEncoding];
    free(answer);
    
    return results;
}

#pragma mark - Public

- (NSString *)platform {
    
    return [self sysCtlWithName:"hw.machine"];
}

- (NSString *)hardwareName {
    
    return [self sysCtlWithName:"hw.model"];
}

@end
