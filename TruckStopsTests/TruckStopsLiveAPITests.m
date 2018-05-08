//
//  TruckStopsLiveAPITests.m
//  TruckStopsTests
//
//  Created by Chris Woodard on 5/4/18.
//  Copyright © 2018 Code. All rights reserved.
//

#import <XCTest/XCTest.h>
#import <CoreLocation/CoreLocation.h>

#import "RestAPI.h"
#import "TruckStops-Swift.h"

@interface TruckStopsLiveAPITests : XCTestCase

@end

@implementation TruckStopsLiveAPITests

- (void)setUp {
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

- (void)testGetTruckStopsWithin20MilesOfTampaFL {

    const double tampaLat = 27.95;
    const double tampaLon = -82.457;
    
    CLLocation *tampaLoc = [[CLLocation alloc] initWithLatitude:(CLLocationDegrees)tampaLat longitude:(CLLocationDegrees)tampaLon];
    
    XCTestExpectation *requestFinished = [self expectationWithDescription:@"Wait for Async Request to Finish"];
    
    RestAPI *api = [RestAPI shared];
    __block NSDictionary *restStops = nil;
    __block NSError *err = nil;
    [api fetchRestStopsWithin:20.0 ofLatitude:tampaLat andLongitude:tampaLon completion:^(NSError *connectionError, NSDictionary *results) {
        restStops = results;
        err = connectionError;
        [requestFinished fulfill];
    }];
    
    [self waitForExpectations:@[requestFinished] timeout:20];
    
    XCTAssertNil(err, @"Error occurred: %@", [err localizedDescription]);
    XCTAssertNotNil(restStops, @"Got nil results");
    NSDictionary *stations = restStops[@"Stations"];
    XCTAssertNotNil(stations, @"Got nil rest stops");
    NSArray *truckStops = stations[@"truckStops"];
    HolderOfTruckStops *holder = [[HolderOfTruckStops alloc] initWithTruckStopsFromResults:truckStops];
    
    XCTAssertNotNil(holder, @"Unable to allocate HolderOfTruckStops");
    XCTAssertFalse( 0 == [holder numberOfPins], @"No pins");
    
    NSArray *pins = [holder pins];
    XCTAssertNotNil(pins, @"Pins is nil");
    
    XCTAssertEqual([holder numberOfPins], pins.count, @"Count mismatch");
}

- (void)testGetTruckStopsWithin200MilesOfTampaFL {

    const double tampaLat = 27.95;
    const double tampaLon = -82.457;
    
    CLLocation *tampaLoc = [[CLLocation alloc] initWithLatitude:(CLLocationDegrees)tampaLat longitude:(CLLocationDegrees)tampaLon];
    
    XCTestExpectation *requestFinished = [self expectationWithDescription:@"Wait for Async Request to Finish"];
    
    RestAPI *api = [RestAPI shared];
    __block NSDictionary *restStops = nil;
    __block NSError *err = nil;
    [api fetchRestStopsWithin:200.0 ofLatitude:tampaLat andLongitude:tampaLon completion:^(NSError *connectionError, NSDictionary *results) {
        restStops = results;
        err = connectionError;
        [requestFinished fulfill];
    }];
    
    [self waitForExpectations:@[requestFinished] timeout:20];
    
    XCTAssertNil(err, @"Error occurred: %@", [err localizedDescription]);
    XCTAssertNotNil(restStops, @"Got nil results");
    NSDictionary *stations = restStops[@"Stations"];
    XCTAssertNotNil(stations, @"Got nil rest stops");
    NSArray *truckStops = stations[@"truckStops"];
    
    HolderOfTruckStops *holder = [[HolderOfTruckStops alloc] initWithTruckStopsFromResults:truckStops];
    
    XCTAssertNotNil(holder, @"Unable to allocate HolderOfTruckStops");
    XCTAssertFalse( 0 == [holder numberOfPins], @"No pins");
    
    NSArray *pins = [holder pins];
    XCTAssertNotNil(pins, @"Pins is nil");
    
    XCTAssertEqual([holder numberOfPins], pins.count, @"Count mismatch");
}

@end
