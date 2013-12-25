//
//  ReverseGeocoder.m - ReverseGeocoder
//  Created by Jeff Grimes on 20-Aug-12 - Copyright (c) 2012 Jeff Grimes - All Rights Reserved
//

#import "ReverseGeocoder.h"

const int  locationTimeLimit =  8;   // max time limit for getting location
const int geocodingTimeLimit =  8;   // max time limit for reverse-geocoding location
const int  staleCacheSeconds =  8;   // the lower this value, the pickier you are about cached location data - typical value is between 5 and 10

@implementation ReverseGeocoder

static ReverseGeocoder *sharedInstance = nil;

+ (id) sharedInstance
{
    @synchronized([ReverseGeocoder class])
    {
        if (sharedInstance == nil) sharedInstance = [[ReverseGeocoder alloc] init];
    }
    return sharedInstance;
}

+ (BOOL) areLocationServicesEnabled { return [CLLocationManager locationServicesEnabled]; }

- (id) init
{
    if (self = [super init])
    {
        self.geocoder                        = [[CLGeocoder alloc] init];
        self.locationManager                 = [[CLLocationManager alloc] init];
        self.locationManager.delegate        = self;
        self.locationManager.desiredAccuracy = kCLLocationAccuracyBest;
        self.locationTimer                   = [[NSTimer alloc] init];
        self.geocodingTimer                  = [[NSTimer alloc] init];

        delegateHasPlacemarks = NO;
    }
    return self;
}

- (void) callGotUserLocation
{
    if ([self.geocoderDelegate respondsToSelector: @selector(gotUserLocation)])
        then [self.geocoderDelegate gotUserLocation];
        else DLog (@"-- delegate doesn't implement gotUserLocation --");
}

- (void) callGotUserLocationError
{
    if (delegateHasPlacemarks) return;

    if ([self.geocoderDelegate respondsToSelector: @selector(gotUserLocationError)])
        then [self.geocoderDelegate gotUserLocationError];
        else DLog (@"-- delegate doesn't implement gotUserLocationError --");
}

- (void) callGotUserPlacemarks
{
    if ([self.geocoderDelegate respondsToSelector: @selector(gotUserPlacemarks)])
        then [self.geocoderDelegate gotUserPlacemarks];
        else DLog (@"-- delegate doesn't implement gotUserPlacemarks --");
}

- (void) callGotUserPlacemarksError
{
    if (delegateHasPlacemarks) return;

    if ([self.geocoderDelegate respondsToSelector: @selector(gotUserPlacemarksError)])
        then [self.geocoderDelegate gotUserPlacemarksError];
        else DLog (@"-- delegate does not implement gotUserPlacemarksError --");
}

- (void) callLocationServicesDisabled
{
    if ([self.geocoderDelegate respondsToSelector: @selector(locationServicesDisabled)])
        then [self.geocoderDelegate locationServicesDisabled];
        else DLog (@"-- delegate does not implement locationServicesDisabled --");
}

- (CLAuthorizationStatus)  getAuthStatus { return [CLLocationManager authorizationStatus]; }
- (                 void) reverseGeocode {   [self.locationManager startUpdatingLocation]; }

- (void) stopActivity
{
    delegateHasPlacemarks = YES;
    [self.locationManager stopUpdatingLocation];
}

- (void) geocodeLocation: (CLLocation *) location
{
    self.geocodingTimer = [NSTimer scheduledTimerWithTimeInterval: geocodingTimeLimit target: self selector: @selector(callGotUserPlacemarksError) userInfo: nil repeats: NO];

    [self.geocoder reverseGeocodeLocation: location completionHandler:

     ^(NSArray *placemarks, NSError *error)
     {
         [self.geocodingTimer invalidate];
         if (error == nil)
         {
             CLPlacemark *placemark = placemarks[0];
             
             self.address = [placemark addressDictionary][(NSString *) kABPersonAddressStreetKey];
             self.city    = [placemark addressDictionary][(NSString *)   kABPersonAddressCityKey];
             self.state   = [placemark addressDictionary][(NSString *)  kABPersonAddressStateKey];
             self.zipcode = [placemark postalCode];
             self.country = [placemark    country];
 
// -- You can also use the same format to fetch administrative area, sub-administrative area, and locality. --
             
             [self callGotUserPlacemarks];
         } else [self callGotUserPlacemarksError];
     }                  ];              // end of method call
}

- (void)locationManager: (CLLocationManager *) manager didUpdateToLocation: (CLLocation *) newLocation fromLocation: (CLLocation *) oldLocation
{
            NSDate      *eventDate = newLocation.timestamp;
    NSTimeInterval       howRecent = [eventDate timeIntervalSinceNow];
              BOOL isLocationFresh = abs(howRecent) < staleCacheSeconds;

    if (isLocationFresh)
    {
        [self.locationManager stopUpdatingLocation];
        [self.locationTimer             invalidate];
        
        self.latitude  = self.locationManager.location.coordinate.latitude;
        self.longitude = self.locationManager.location.coordinate.longitude;
        
        [self geocodeLocation: self.locationManager.location];
        DLog(@"-- obtained fresh location --");
    }
}

- (void) locationManager: (CLLocationManager *) manager didFailWithError: (NSError *) error
{
    DLog(@"-- location manager failed --");
    if ([CLLocationManager authorizationStatus] == kCLAuthorizationStatusDenied)
        then [self callLocationServicesDisabled];
        else [self     callGotUserLocationError];
}

- (void) locationManager: (CLLocationManager *) manager didChangeAuthorizationStatus: (CLAuthorizationStatus) status
{
    if (status == kCLAuthorizationStatusDenied)
        {
            DLog(@"-- user disabled location services --");
            [self callLocationServicesDisabled];
            return;
        }
    
    if (status == kCLAuthorizationStatusAuthorized)
        {
            DLog(@"-- user enabled location services --");
            self.locationTimer = [NSTimer scheduledTimerWithTimeInterval: locationTimeLimit target: self selector: @selector(callGotUserLocationError) userInfo: nil repeats: NO];
            return;
        }
}

#pragma mark - Memory Management

- (void) dealloc
{
    self.geocoderDelegate = nil;
    DLog (@"-- ReverseGeocoder - dealloc entered --");
}

@end