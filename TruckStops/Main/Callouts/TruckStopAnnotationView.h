//
//  TruckStopAnnotationView.h
//  TruckStops
//
//  Created by Chris Woodard on 5/7/18.
//  Copyright © 2018 Code. All rights reserved.
//

#import <MapKit/MapKit.h>

#import "TruckStops-Swift.h"

@interface TruckStopAnnotationView : MKAnnotationView
-(instancetype)initFromAnnotation:(TruckStop *)annotation;
@end
