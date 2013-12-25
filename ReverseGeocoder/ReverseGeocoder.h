//
//  ReverseGeocoder.h - ReverseGeocoder
//  Created by Jeff Grimes on 20-Aug-12 - Copyright (c) 2012 Jeff Grimes - All Rights Reserved
//

#import     <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>
#import      <AddressBook/ABPerson.h>

// -- http://www.cimgf.com/2010/05/02/my-current-prefix-pch-file --

#define then

#ifdef DEBUG
    #define DLog(...) NSLog (@"%s %@", __PRETTY_FUNCTION__, [NSString stringWithFormat: __VA_ARGS__])
    #define ALog(...) [[NSAssertionHandler currentHandler] handleFailureInFunction: [NSString stringWithCString: __PRETTY_FUNCTION__ encoding: NSUTF8StringEncoding] \
                                                                              file: [NSString stringWithCString: __FILE__            encoding: NSUTF8StringEncoding] \
                                                                        lineNumber: __LINE__  description: __VA_ARGS__]
#else
    #ifndef NS_BLOCK_ASSERTIONS
    #define NS_BLOCK_ASSERTIONS
    #endif
    #define DLog(...) do { } while (0)
    #define ALog(...) NSLog (@"%s %@", __PRETTY_FUNCTION__, [NSString stringWithFormat: __VA_ARGS__])
#endif

@protocol GeocoderProtocol <NSObject>
- (void)          gotUserLocation;
- (void)     gotUserLocationError;
- (void)        gotUserPlacemarks;
- (void)   gotUserPlacemarksError;
- (void) locationServicesDisabled;
@end

@interface ReverseGeocoder : NSObject <CLLocationManagerDelegate>
{
@private
    BOOL delegateHasPlacemarks;
}

@property (nonatomic,   weak) id <GeocoderProtocol>       geocoderDelegate;
@property (nonatomic, strong)            CLGeocoder              *geocoder;
@property (nonatomic, strong)     CLLocationManager       *locationManager;
@property (nonatomic, strong)               NSTimer         *locationTimer;
@property (nonatomic, strong)               NSTimer        *geocodingTimer;
@property (nonatomic, assign)                 float               latitude;
@property (nonatomic, assign)                 float              longitude;
@property (nonatomic, strong)              NSString               *address;
@property (nonatomic, strong)              NSString                  *city;
@property (nonatomic, strong)              NSString                 *state;
@property (nonatomic, strong)              NSString               *zipcode;
@property (nonatomic, strong)              NSString               *country;
@property (nonatomic, strong)              NSString    *administrativeArea;
@property (nonatomic, strong)              NSString *subAdministrativeArea;
@property (nonatomic, strong)              NSString              *locality;

+ (BOOL) areLocationServicesEnabled;

- (CLAuthorizationStatus) getAuthStatus;
- (void) reverseGeocode;
- (void) stopActivity;

- (void) locationManager: (CLLocationManager *) manager didUpdateToLocation: (CLLocation *) newLocation fromLocation: (CLLocation *) oldLocation;
- (void) locationManager: (CLLocationManager *) manager didFailWithError: (NSError *) error;
- (void) locationManager: (CLLocationManager *) manager didChangeAuthorizationStatus: (CLAuthorizationStatus) status;

@end