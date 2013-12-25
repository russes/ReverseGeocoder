//
//  ReverseGeocoder.h
//  ReverseGeocoder
//
//  Created by Jeff Grimes on 8/20/12.
//  Copyright (c) 2012 Jeff Grimes. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>
#import <AddressBook/ABPerson.h>

@protocol GeocoderProtocol <NSObject>
- (void)gotUserLocation;
- (void)gotUserLocationError;
- (void)gotUserPlacemarks;
- (void)gotUserPlacemarksError;
- (void)locationServicesDisabled;
@end

@interface ReverseGeocoder : NSObject <CLLocationManagerDelegate> {
@private
    BOOL delegateHasPlacemarks;
}

@property (nonatomic, weak) id <GeocoderProtocol> geocoderDelegate;
@property (nonatomic, strong) CLGeocoder *geocoder;
@property (nonatomic, strong) CLLocationManager *locationManager;
@property (nonatomic, strong) NSTimer *locationTimer;
@property (nonatomic, strong) NSTimer *geocodingTimer;
@property (nonatomic, assign) float latitude;
@property (nonatomic, assign) float longitude;
@property (nonatomic, strong) NSString *address;
@property (nonatomic, strong) NSString *city;
@property (nonatomic, strong) NSString *state;
@property (nonatomic, strong) NSString *zipcode;
@property (nonatomic, strong) NSString *country;
@property (nonatomic, strong) NSString *administrativeArea;
@property (nonatomic, strong) NSString *subAdministrativeArea;
@property (nonatomic, strong) NSString *locality;

+ (BOOL)areLocationServicesEnabled;

- (CLAuthorizationStatus)getAuthStatus;
- (void)reverseGeocode;
- (void)stopActivity;

- (void)locationManager:(CLLocationManager *)manager didUpdateToLocation:(CLLocation *)newLocation fromLocation:(CLLocation *)oldLocation;
- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error;
- (void)locationManager:(CLLocationManager *)manager didChangeAuthorizationStatus:(CLAuthorizationStatus)status;

@end