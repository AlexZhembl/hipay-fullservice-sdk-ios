//
//  AbsractMapper.h
//  Pods
//
//  Created by Jonathan TIRET on 01/10/2015.
//
//

#import <Foundation/Foundation.h>

@interface HPTAbstractMapper (Decode)

- (id)getObjectForKey:(NSString *)key;
- (NSString *)getStringForKey:(NSString *)key;
- (NSNumber *)getEnumCharForKey:(NSString *)key;
- (NSString *)getLowercaseStringForKey:(NSString *)key;
- (NSNumber *)getNumberForKey:(NSString *)key;
- (NSInteger)getIntegerForKey:(NSString *)key;
- (NSInteger)getIntegerEnumValueWithKey:(NSString *)key defaultEnumValue:(NSInteger)defaultValue allValues:(NSDictionary *)allValues;
- (NSDate *)getDateISO8601ForKey:(NSString *)key;
- (NSDate *)getDateBasicForKey:(NSString *)key;
- (NSDate *)getDateForKey:(NSString *)key;

- (BOOL)isValid;

@end
