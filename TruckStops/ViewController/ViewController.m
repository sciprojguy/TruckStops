//
//  ViewController.m
//  TruckStops
//
//  Created by Chris Woodard on 5/3/18.
//  Copyright © 2018 Code. All rights reserved.
//

#import <CoreLocation/CoreLocation.h>
#import <MapKit/MapKit.h>

#import "ViewController.h"
#import "RestAPI.h"
#import "TruckStopAnnotationView.h"

#import "TruckStops-Swift.h"

typedef enum {
    Map = 0,
    Satellite = 1
} MapMode;

@interface ViewController () <MKMapViewDelegate, UISearchBarDelegate, CLLocationManagerDelegate>
@property (weak, nonatomic) IBOutlet UISearchBar *searchBar;
@property (weak, nonatomic) IBOutlet MKMapView *stopsMap;
@property (weak, nonatomic) IBOutlet UISegmentedControl *mapMode;
@property (weak, nonatomic) IBOutlet UISegmentedControl *userTrackingMode;

@property (strong, nonatomic) CLLocationManager *locationManager;

@property (strong, nonatomic) HolderOfTruckStops *holderOfTruckstops;
@property (strong, nonatomic) RestAPI *restAPI;
@property (strong, nonatomic) CLLocation *currentUserLocation;

@property (strong, nonatomic) NSString *filterString;

@property (assign, nonatomic) MapMode mapModeValue;
@property (assign, nonatomic) CGFloat zoomRadius;

@property (strong, nonatomic) NSTimer *timerTask;

@property (assign, nonatomic) BOOL trackTheUser;
@property (assign, nonatomic) BOOL savedTrackTheUser;
@property (nonatomic, assign) BOOL nextRegionChangeIsFromUserInteraction;

@end

@implementation ViewController

//MARK: - view lifecycle

-(void)viewDidLoad {
    [super viewDidLoad];
    self.zoomRadius = 100.0;
    self.restAPI = [RestAPI shared];
    [self configureLocationTracking];
    [self configureUI];
}

-(void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

//MARK: - error alerts

-(void)showConnectionErrorAlert {
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Error" message:@"Unable to get a connection or connection lost.  Try again later." preferredStyle:UIAlertControllerStyleAlert];
    [alert addAction:[UIAlertAction actionWithTitle:@"Okay" style:UIAlertActionStyleCancel handler:nil]];
    [self presentViewController:alert animated:YES completion:nil];
}

-(void)showAPIErrorAlert {
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Error" message:@"Unable to retrieve nearby truck stops.  Try again later." preferredStyle:UIAlertControllerStyleAlert];
    [alert addAction:[UIAlertAction actionWithTitle:@"Okay" style:UIAlertActionStyleCancel handler:nil]];
    [self presentViewController:alert animated:YES completion:nil];
}

-(void)showLocationDisabledAlert {
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Error" message:@"This app needs location services to function properly.  Please go to 'Settings' and enable them for this app." preferredStyle:UIAlertControllerStyleAlert];
    [alert addAction:[UIAlertAction actionWithTitle:@"Okay" style:UIAlertActionStyleCancel handler:nil]];
    [self presentViewController:alert animated:YES completion:nil];
}

//MARK: - UI setup

-(void)configureUI {

    self.stopsMap.showsUserLocation = YES;
    self.stopsMap.userTrackingMode = MKUserTrackingModeNone;
    self.stopsMap.delegate = self;
    [self.stopsMap registerClass:[TruckStopMapPin class] forAnnotationViewWithReuseIdentifier:@"TruckStop"];
    self.trackTheUser = YES;
    self.userTrackingMode.selectedSegmentIndex = 0;
    
    //read settings.plist and get map mode
    Settings *settings = [Settings shared];
    NSInteger mapType = [settings mapType];
    if(Map == mapType) {
        self.stopsMap.mapType = MKMapTypeStandard;
        self.mapMode.selectedSegmentIndex = 0;
    }
    else {
        self.stopsMap.mapType = MKMapTypeSatellite;
        self.mapMode.selectedSegmentIndex = 1;
    }
    
    //todo: add touch up handler in map...
}

-(void)tapHandler {

}

-(void)configureLocationTracking {
    self.locationManager = [[CLLocationManager alloc] init];
    self.locationManager.delegate = self;
    self.locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters;
    self.locationManager.distanceFilter = 100;  //100m between updates
    self.locationManager.pausesLocationUpdatesAutomatically = YES;
    [self.locationManager requestAlwaysAuthorization];
    self.trackTheUser = YES;
}

-(CGFloat)zoomRadiusInMeters {
    return self.zoomRadius * 1609.34;
}

-(void)restoreTrackingSetting:(NSTimer *)timer {
    if(self.timerTask) {
        [self.timerTask invalidate];
        self.timerTask = nil;
    }
    self.trackTheUser = self.savedTrackTheUser;
}

-(void)pauseTrackingFor5Seconds {
    if(self.timerTask) {
        [self.timerTask invalidate];
        self.timerTask = nil;
    }
    
    self.timerTask = [NSTimer scheduledTimerWithTimeInterval:5.0 target:self selector:@selector(restoreTrackingSetting:) userInfo:nil repeats:NO];
    self.savedTrackTheUser = self.trackTheUser;
    self.trackTheUser = NO;
}

-(void)pauseTrackingFor15Seconds {
    if(self.timerTask) {
        [self.timerTask invalidate];
        self.timerTask = nil;
    }
    self.timerTask = [NSTimer scheduledTimerWithTimeInterval:15.0 target:self selector:@selector(restoreTrackingSetting:) userInfo:nil repeats:NO];
    self.savedTrackTheUser = self.trackTheUser;
    self.trackTheUser = NO;
}

-(void)pauseTrackingFor30Seconds {
    if(self.timerTask) {
        [self.timerTask invalidate];
        self.timerTask = nil;
    }
    self.timerTask = [NSTimer scheduledTimerWithTimeInterval:30.0 target:self selector:@selector(restoreTrackingSetting:) userInfo:nil repeats:NO];
    self.savedTrackTheUser = self.trackTheUser;
    self.trackTheUser = NO;
}

-(void)stopTrackingLocation {
    [self.locationManager stopUpdatingLocation];
}

-(void)updateTruckstopLocations {

dispatch_async( dispatch_get_global_queue( DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        [self.restAPI fetchRestStopsWithin:self.zoomRadius ofLatitude:self.currentUserLocation.coordinate.latitude andLongitude:self.currentUserLocation.coordinate.longitude completion:^(NSError *err, NSDictionary *stopsDict) {

            if(err) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    [self showConnectionErrorAlert];
                });
            }
            else {
                if([@200 isEqualToNumber:stopsDict[@"StatusCode"]]) {
                    //grab truck stops
                    self.holderOfTruckstops = [[HolderOfTruckStops alloc] initWithTruckStopsFromResults:stopsDict[@"Stations"][@"truckStops"]];
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [self updateMapPins:NO];
                    });
                }
                else {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [self showAPIErrorAlert];
                    });
                }
            }
            
        }];
    });
}

//MARK: - map utility methods

-(void)updateMapPins:(BOOL)fromSearchBar {

    //remove old annotations
    NSArray *annotations = [self.stopsMap annotations];
    [self.stopsMap removeAnnotations:annotations];
    
    //add new annotations
    NSArray *newPins = [self.holderOfTruckstops pinsWithContaining:self.filterString userLocation:self.currentUserLocation];
    [self.stopsMap addAnnotations:newPins];
    
    if(fromSearchBar) {
    
        [self pauseTrackingFor30Seconds];
        
        NSDictionary *stats = [self geoStatsForPins:newPins];
        
        CGFloat minLat = [stats[@"LatMin"] doubleValue];
        CGFloat maxLat = [stats[@"LatMax"] doubleValue];
        CGFloat minLon = [stats[@"LonMin"] doubleValue];
        CGFloat maxLon = [stats[@"LonMax"] doubleValue];
        CGFloat latSpan = 1.25 * (maxLat - minLat);
        CGFloat lonSpan = 1.25 * (maxLon - minLon);
        CGFloat latMedian = minLat + latSpan/2.0;
        CGFloat lonMedian = minLon + lonSpan/2.0;
        CLLocationCoordinate2D centroid = CLLocationCoordinate2DMake(latMedian, lonMedian);
        MKCoordinateSpan span = MKCoordinateSpanMake(latSpan, lonSpan);
        MKCoordinateRegion region = MKCoordinateRegionMake(centroid, span);
        self.stopsMap.region = region;
        [self pauseTrackingFor30Seconds];
    }
}

//MARK: - map delegate methods

-(MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(id<MKAnnotation>)annotation {

    MKAnnotationView *pinView = nil;
    if(NO == [annotation isKindOfClass:[MKUserLocation class]]) {
        pinView = [mapView dequeueReusableAnnotationViewWithIdentifier:@"TruckStop" forAnnotation:annotation];
        if(nil == pinView) {
            pinView = [[TruckStopMapPin alloc] initWithAnnotation:annotation reuseIdentifier:@"TruckStop"];
        }
        
        pinView.canShowCallout = YES;
        pinView.detailCalloutAccessoryView = [[TruckStopAnnotationView alloc] initFromAnnotation:annotation];
        
    }
    else {
        pinView = [[UserLocationMapPin alloc] initWithAnnotation:annotation reuseIdentifier:@"UserLocation"];
    }
    
    return pinView;
}

-(void)mapView:(MKMapView *)mapView didSelectAnnotationView:(MKAnnotationView *)view {
    [self pauseTrackingFor15Seconds];
}

//adapted from https://www.transpire.com/insights/blog/mkmapview-change-user-interaction

- (void)mapView:(MKMapView *)mapView regionWillChangeAnimated:(BOOL)animated
{
    UIView* view = mapView.subviews.firstObject;
    
    //    Look through gesture recognizers to determine
    //    whether this region change is from user interaction
    for(UIGestureRecognizer* recognizer in view.gestureRecognizers)
    {
        //    The user caused of this...
        if(recognizer.state == UIGestureRecognizerStateBegan
           || recognizer.state == UIGestureRecognizerStateEnded)
        {
            self.nextRegionChangeIsFromUserInteraction = YES;
            break;
        }
    }
}

-(void)mapView:(MKMapView *)mapView regionDidChangeAnimated:(BOOL)animated {
    if(self.nextRegionChangeIsFromUserInteraction) {
        self.nextRegionChangeIsFromUserInteraction = NO;

        CLLocationCoordinate2D center = mapView.region.center;
        CLLocation *newLoc = [[CLLocation alloc] initWithLatitude:center.latitude longitude:center.longitude];
        self.currentUserLocation = newLoc;
        CGFloat gpsRadius = MIN(mapView.region.span.latitudeDelta, mapView.region.span.longitudeDelta);
        self.zoomRadius = [self degreesToMiles:gpsRadius]/2.0;
        [self updateTruckstopLocations];
        [self pauseTrackingFor5Seconds];
    }
}

//MARK: - search bar delegate methods

-(void)searchBarSearchButtonClicked:(UISearchBar *)searchBar {
    self.filterString = searchBar.text;
    [self updateMapPins:YES];
    [searchBar resignFirstResponder];
}

-(void)searchBarCancelButtonClicked:(UISearchBar *)searchBar {
    self.filterString = @"";
    [searchBar resignFirstResponder];
}

-(void)searchBarTextDidEndEditing:(UISearchBar *)searchBar {
    if([searchBar.text length]<1) {
        self.filterString = @"";
    }
    [self updateMapPins:YES];
}

//MARK: - utilities

-(CGFloat)degreesToMiles:(CGFloat)degrees {
    return degrees * 69.0;
}

-(CGFloat)milesToDegrees:(CGFloat)miles {
    return miles / 69.0;
}

//MARK: - button Actions

-(IBAction)zoomToUser:(id)sender {
   CGFloat degreesIn100miles = 2.0 * [self milesToDegrees:100.0];
    MKCoordinateSpan span = MKCoordinateSpanMake(degreesIn100miles, degreesIn100miles);
    MKCoordinateRegion region = MKCoordinateRegionMake(self.currentUserLocation.coordinate, span);
    [self.stopsMap setRegion:region];
}

-(IBAction)switchMapMode:(UISegmentedControl *)mapModeControl {
    NSInteger selectedIndex = mapModeControl.selectedSegmentIndex;
    if(Map == selectedIndex) {
        self.stopsMap.mapType = MKMapTypeStandard;
    }
    else
    if(Satellite == selectedIndex) {
        self.stopsMap.mapType = MKMapTypeSatellite;
    }
    [Settings shared].mapType = selectedIndex;
    [[Settings shared] save];
}

//MARK: - get a region all the pins will fit in

-(NSDictionary *)geoStatsForPins:(NSArray *)annotations {

    CGFloat latMin = 9999.99;
    CGFloat lonMin = 9999.99;
    CGFloat latMax = -9999.99;
    CGFloat lonMax = -9999.99;
    CGFloat latAvg = 0.0;
    CGFloat lonAvg = 0.0;
    
    for( TruckStop *annotation in annotations ) {
        latMin = MIN(latMin, annotation.coordinate.latitude);
        lonMin = MIN(lonMin, annotation.coordinate.longitude);
        latMax = MAX(latMax, annotation.coordinate.latitude);
        lonMax = MAX(lonMax, annotation.coordinate.longitude);
        lonAvg += annotation.coordinate.longitude;
        latAvg += annotation.coordinate.latitude;
    }
    
    if([annotations count]>0) {
        latAvg /= [annotations count];
        lonAvg /= [annotations count];
    }
    
    return @{@"LatMin":@(latMin), @"LonMin":@(lonMin), @"LatMax":@(latMax), @"LonMax":@(lonMax), @"AvgLat":@(latAvg), @"AvgLon":@(lonAvg)};
}

//MARK: - track the user

-(IBAction)userTrackingChanged:(UISegmentedControl *)trackUser {
    if(0 == trackUser.selectedSegmentIndex) {
        self.trackTheUser = YES;
    }
    else {
        self.trackTheUser = NO;
    }
}

-(void)moveMapToLocation {
    if(self.locationManager.location) {
        self.currentUserLocation = self.locationManager.location;
        [self zoomToUser:nil];
        [self updateTruckstopLocations];
    }
}

//MARK: - location delegate methods

-(void)locationManager:(CLLocationManager *)manager didChangeAuthorizationStatus:(CLAuthorizationStatus)status {
    switch(status) {
        case kCLAuthorizationStatusDenied:
        case kCLAuthorizationStatusRestricted:
            [self showLocationDisabledAlert];
            break;
        case kCLAuthorizationStatusAuthorizedAlways:
        case kCLAuthorizationStatusAuthorizedWhenInUse:
            [self.locationManager startUpdatingLocation];
            break;
        default:
            break;
    }
}

-(void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray<CLLocation *> *)locations {
    if(YES == _trackTheUser) {
        [self moveMapToLocation];
    }
}

@end
