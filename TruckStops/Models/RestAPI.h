//
//  RestAPI.h
//  TruckStops
//
//  Created by Chris Woodard on 5/4/18.
//  Copyright © 2018 Code. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface RestAPI : NSObject

+(RestAPI *)shared;

-(void)fetchRestStopsWithin:(double)miles ofLatitude:(double)lat andLongitude:(double)lon completion:(void(^)(NSError *err, NSDictionary *results))completion;

@end
