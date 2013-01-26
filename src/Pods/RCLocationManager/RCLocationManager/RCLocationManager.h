/*
 Copyright 2012 Ricardo Caballero (hello@rcabamo.es)
 
 Licensed under the Apache License, Version 2.0 (the "License");
 you may not use this file except in compliance with the License.
 You may obtain a copy of the License at
 
 http://www.apache.org/licenses/LICENSE-2.0
 
 Unless required by applicable law or agreed to in writing, software
 distributed under the License is distributed on an "AS IS" BASIS,
 WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 See the License for the specific language governing permissions and
 limitations under the License.
 */

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>

extern NSString * const RCLocationManagerUserLocationDidChangeNotification;
extern NSString * const RCLocationManagerNotificationLocationUserInfoKey;

typedef void(^RCLocationManagerLocationUpdateBlock)(CLLocationManager *manager, CLLocation *newLocation, CLLocation *oldLocation);
typedef void (^RCLocationManagerLocationUpdateFailBlock)(CLLocationManager *manager, NSError *error);

typedef void(^RCLocationManagerRegionUpdateBlock)(CLLocationManager *manager, CLRegion *region, BOOL enter);
typedef void(^RCLocationManagerRegionUpdateFailBlock)(CLLocationManager *manager, CLRegion *region, NSError *error);

@protocol RCLocationManagerDelegate;

@interface RCLocationManager : NSObject

@property (nonatomic, assign) id<RCLocationManagerDelegate> delegate;

/**
 * @discussion the most recently retrieved user location.
 */
@property (nonatomic, readonly) CLLocation *location;

/**
 * @discussion string that describes the reason for using location services.
 */
@property (nonatomic, copy) NSString *purpose;

#pragma mark - Customization

@property (nonatomic, assign) CLLocationDistance userDistanceFilter;
@property (nonatomic, assign) CLLocationAccuracy userDesiredAccuracy;

@property (nonatomic, assign) CLLocationDistance regionDistanceFilter;
@property (nonatomic, assign) CLLocationAccuracy regionDesiredAccuracy;

@property (nonatomic, readonly) NSSet *regions;

+ (RCLocationManager *)sharedManager;

- (id)initWithUserDistanceFilter:(CLLocationDistance)userDistanceFilter userDesiredAccuracy:(CLLocationAccuracy)userDesiredAccuracy purpose:(NSString *)purpose delegate:(id<RCLocationManagerDelegate>)delegate;

+ (BOOL)locationServicesEnabled;
+ (BOOL)regionMonitoringAvailable;
+ (BOOL)regionMonitoringEnabled;
+ (BOOL)significantLocationChangeMonitoringAvailable;

- (void)startUpdatingLocation;
- (void)startUpdatingLocationWithBlock:(RCLocationManagerLocationUpdateBlock)block errorBlock:(RCLocationManagerLocationUpdateFailBlock)errorBlock; // USING BLOCKS
- (void)retriveUserLocationWithBlock:(RCLocationManagerLocationUpdateBlock)block errorBlock:(RCLocationManagerLocationUpdateFailBlock)errorBlock; // USING BLOCKS. Only 1 time. 
- (void)updateUserLocation;
- (void)stopUpdatingLocation;

- (void)addCoordinateForMonitoring:(CLLocationCoordinate2D)coordinate;
- (void)addCoordinateForMonitoring:(CLLocationCoordinate2D)coordinate withRadius:(CLLocationDistance)radius;
- (void)addCoordinateForMonitoring:(CLLocationCoordinate2D)coordinate withRadius:(CLLocationDistance)radius desiredAccuracy:(CLLocationAccuracy)accuracy;

- (void)addRegionForMonitoring:(CLRegion *)region;
- (void)addRegionForMonitoring:(CLRegion *)region desiredAccuracy:(CLLocationAccuracy)accuracy;
- (void)addRegionForMonitoring:(CLRegion *)region desiredAccuracy:(CLLocationAccuracy)accuracy updateBlock:(RCLocationManagerRegionUpdateBlock)block errorBlock:(RCLocationManagerRegionUpdateFailBlock)errorBlock; // USING BLOCKS
- (void)stopMonitoringForRegion:(CLRegion *)region;
- (void)stopMonitoringAllRegions;

@end

@protocol RCLocationManagerDelegate <NSObject>

@optional
- (void)locationManager:(RCLocationManager *)manager didFailWithError:(NSError *)error;
- (void)locationManager:(RCLocationManager *)manager didUpdateToLocation:(CLLocation *)newLocation fromLocation:(CLLocation *)oldLocation;
- (void)locationManager:(RCLocationManager *)manager didEnterRegion:(CLRegion *)region;
- (void)locationManager:(RCLocationManager *)manager didExitRegion:(CLRegion *)region;
- (void)locationManager:(RCLocationManager *)manager monitoringDidFailForRegion:(CLRegion *)region withError:(NSError *)error;

@end
