//
//  HPFFormatter.h
//  Pods
//
//  Created by Jonathan TIRET on 09/11/2015.
//
//

#import <Foundation/Foundation.h>

@interface HPFFormatter : NSObject

- (NSString *)digitsOnlyFromPlainText:(NSString *)plainTextNumber;
+ (void)logFromError:(NSError *)error client:(NSString *)client;

@end
