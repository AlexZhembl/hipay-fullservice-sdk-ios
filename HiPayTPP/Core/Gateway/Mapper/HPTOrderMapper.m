//
//  HPTOrderMapper.m
//  Pods
//
//  Created by Jonathan TIRET on 09/10/2015.
//
//

#import "HPTOrderMapper.h"
#import "HPTAbstractMapper+Decode.h"
#import "HPTOrder.h"

@implementation HPTOrderMapper

- (BOOL)isValid
{
    return [super isValid] && [self.rawData objectForKey:@"id"] != nil;
}

@end
