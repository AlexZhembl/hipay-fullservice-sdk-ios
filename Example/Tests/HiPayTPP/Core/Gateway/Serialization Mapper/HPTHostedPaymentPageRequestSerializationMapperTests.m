//
//  HPTHostedPaymentPageRequestSerializationMapperTests.m
//  HiPayTPP
//
//  Created by Jonathan TIRET on 14/10/2015.
//  Copyright © 2015 Jonathan TIRET. All rights reserved.
//

#import <XCTest/XCTest.h>
#import <HiPayTPP/HPTHostedPaymentPageRequestSerializationMapper.h>
#import <HiPayTPP/HPTAbstractSerializationMapper+Encode.h>

@interface HPTHostedPaymentPageRequestSerializationMapperTests : XCTestCase

@end

@implementation HPTHostedPaymentPageRequestSerializationMapperTests

- (void)setUp {
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

//- (void)testSerialization
//{
//    HPTHostedPaymentPageRequest *request = [[HPTHostedPaymentPageRequest alloc] init];
//    
//    OCMockObject *mockedMapper = [OCMockObject partialMockForObject:[[HPTHostedPaymentPageRequestSerializationMapper alloc] initWithRequest:request]];
//    HPTHostedPaymentPageRequestSerializationMapper *mapper = (HPTHostedPaymentPageRequestSerializationMapper *)mockedMapper;
//    
//    [[[mockedMapper expect] andReturn:@"test"] getStringForKey:@"firstname"];
//    
//    NSDictionary *result = mapper.serializedRequest;
//    
//    XCTAssertEqualObjects([result objectForKey:@"firstname"], @"John");
//    
//    [mockedMapper verify];
//}

@end
