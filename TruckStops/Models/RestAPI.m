//
//  RestAPI.m
//  TruckStops
//
//  Created by Chris Woodard on 5/4/18.
//  Copyright © 2018 Code. All rights reserved.
//

#import "RestAPI.h"

@interface RestAPI () <NSURLSessionDelegate>
@property (nonatomic, strong) NSOperationQueue *sessionQueue;
@property (nonatomic, strong) NSURLSession *session;
@end

@implementation RestAPI

+(RestAPI *)shared {
    static RestAPI *client = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        client = [[RestAPI alloc] init];
        client.sessionQueue = [[NSOperationQueue alloc] init];
        client.sessionQueue.maxConcurrentOperationCount = 4;
        NSURLSessionConfiguration *config = [NSURLSessionConfiguration defaultSessionConfiguration];
        [config setAllowsCellularAccess:YES];
        config.timeoutIntervalForRequest = 30;
        config.timeoutIntervalForResource = 30;
        config.networkServiceType = NSURLNetworkServiceTypeDefault;
        config.requestCachePolicy = NSURLRequestReloadIgnoringCacheData;
        client.session = [NSURLSession sessionWithConfiguration:config delegate:client delegateQueue:client.sessionQueue];
    });
    return client;
}

-(void)fetchRestStopsWithin:(double)miles ofLatitude:(double)lat andLongitude:(double)lon completion:(void(^)(NSError *err, NSDictionary *results))completion {

    __block NSError *connectionError = nil;
    
    NSString *urlString = [[NSString alloc] initWithFormat:@"http://webapp.transflodev.com/svc1.transflomobile.com/api/v3/stations/%@", @(miles)];
    NSURL *url = [NSURL URLWithString:urlString];
    
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:url];
    
    [request setValue:@"Basic amNhdGFsYW5AdHJhbnNmbG8uY29tOnJMVGR6WmdVTVBYbytNaUp6RlIxTStjNmI1VUI4MnFYcEVKQzlhVnFWOEF5bUhaQzdIcjVZc3lUMitPTS9paU8= " forHTTPHeaderField:@"Authorization"];
    [request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];

    [request setHTTPMethod:@"POST"];
    request.timeoutInterval = 30;

    request.HTTPBody = [NSJSONSerialization dataWithJSONObject:@{ @"lat" : @(lat), @"lng" : @(lon)} options:NSJSONWritingPrettyPrinted error:nil];
    
    __block NSData *responseData = nil;
    __block NSHTTPURLResponse *httpResponse = nil;

    NSURLSessionDataTask *task = [self.session dataTaskWithRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        connectionError = error;
        responseData = data;
        httpResponse = (NSHTTPURLResponse *)response;
        
        NSDictionary *results = nil;
        if(200 == httpResponse.statusCode) {
            NSMutableDictionary *stations = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableLeaves error:nil];
            results = @{@"StatusCode":@200, @"Stations" : stations};
        }
        else {
            results = @{@"StatusCode":@(httpResponse.statusCode)};
        }
        
        if(completion) {
            completion(connectionError, results);
        }
    }];

    [task resume];    
}
@end
