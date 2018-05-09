//
//  TruckStopAnnotationView.m
//  TruckStops
//
//  Created by Chris Woodard on 5/7/18.
//  Copyright © 2018 Code. All rights reserved.
//

#import "TruckStopAnnotationView.h"

@interface TruckStopAnnotationView ()
@property (nonatomic, strong) TruckStop *stopInfo;
@property (nonatomic, strong) UILabel *cityStateCountryLabel;
@property (nonatomic, strong) UILabel *distanceLabel;
@property (nonatomic, strong) UILabel *rawLine1Label;
@property (nonatomic, strong) UILabel *rawLine2Label;
@property (nonatomic, strong) UILabel *rawLine3Label;
@property (assign, nonatomic) NSInteger contentHeight;
@end

@implementation TruckStopAnnotationView

-(instancetype)initFromAnnotation:(TruckStop *)annotation {
    self = [super initWithFrame:CGRectMake(0,0,140,0)];
    if(self) {
        self.contentHeight = 0;
        [self configureUI:annotation];
        [self configureRawLines:annotation];
    }
    return self;
}

- (void)configureCityStateCountry:(TruckStop *)stopInfo {
    self.cityStateCountryLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 17, 140, 17)];
    self.cityStateCountryLabel.font = [UIFont systemFontOfSize:14];
    NSMutableString *cityStateCountry = [[NSMutableString alloc] init];
    if(stopInfo.city) {
        [cityStateCountry appendString:stopInfo.city];
    }
    if(stopInfo.state) {
        [cityStateCountry appendFormat:@" %@", stopInfo.state];
    }
    if(stopInfo.country) {
        [cityStateCountry appendFormat:@" %@", stopInfo.country];
    }
    self.cityStateCountryLabel.text = cityStateCountry;
    [self addSubview:self.cityStateCountryLabel];
}

-(void)configureDistance:(TruckStop *)stopInfo {
    self.distanceLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 34, 140, 17)];
    self.distanceLabel.font = [UIFont systemFontOfSize:12];
    self.distanceLabel.text = stopInfo.distance;
    [self addSubview:self.distanceLabel];
}

-(void)configureRawLines:(TruckStop *)stopInfo {
    CGFloat y = 51;
    if(stopInfo.rawline1) {
        self.rawLine1Label = [[UILabel alloc] initWithFrame:CGRectMake(0, y, 140, 17)];
        self.rawLine1Label.text = stopInfo.rawline1;
        [self addSubview:self.rawLine1Label];
        self.rawLine1Label.font = [UIFont systemFontOfSize:11];
        y += 17;
    }
    if(stopInfo.rawline2) {
        self.rawLine2Label = [[UILabel alloc] initWithFrame:CGRectMake(0, y, 140, 17)];
        self.rawLine2Label.text = stopInfo.rawline2;
        [self addSubview:self.rawLine2Label];
        self.rawLine2Label.font = [UIFont systemFontOfSize:11];
        y += 17;
    }
    if(stopInfo.rawline3) {
        self.rawLine3Label = [[UILabel alloc] initWithFrame:CGRectMake(0, y, 140, 17)];
        self.rawLine3Label.text = stopInfo.rawline3;
        self.rawLine3Label.font = [UIFont systemFontOfSize:11];
        [self addSubview:self.rawLine3Label];
        y += 17;
    }
    self.contentHeight = y;
}

-(void)configureUI:(TruckStop *)stopInfo {
    [self configureCityStateCountry:stopInfo];
    [self configureDistance:stopInfo];
    [self configureRawLines:stopInfo];
}

-(CGSize)intrinsicContentSize {
    return CGSizeMake(120, self.contentHeight);
}

-(void)dealloc {
    [self.cityStateCountryLabel removeFromSuperview];
    self.cityStateCountryLabel = nil;
    [self.distanceLabel removeFromSuperview];
    self.distanceLabel = nil;
    [self.rawLine1Label removeFromSuperview];
    self.rawLine1Label = nil;
    [self.rawLine2Label removeFromSuperview];
    self.rawLine2Label = nil;
    [self.rawLine3Label removeFromSuperview];
    self.rawLine3Label = nil;
}

@end
