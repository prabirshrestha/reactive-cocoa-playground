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

#import "RCLocationManager.h"

#define MAX_MONITORING_REGIONS 20

#define kDefaultUserDistanceFilter  kCLLocationAccuracyBestForNavigation
#define kDefaultUserDesiredAccuracy kCLLocationAccuracyBest
#define kDefaultRegionDistanceFilter  kCLLocationAccuracyBestForNavigation
#define kDefaultRegionDesiredAccuracy kCLLocationAccuracyBest
#define kDefaultRegionRadiusDistance  500

NSString * const RCLocationManagerUserLocationDidChangeNotification = @"RCLocationManagerUserLocationDidChangeNotification";
NSString * const RCLocationManagerNotificationLocationUserInfoKey = @"newLocation";

@interface RCLocationManager () <CLLocationManagerDelegate>
{
    BOOL _isUpdatingUserLocation;
    BOOL _isOnlyOneRefresh;

}

@property (nonatomic, readonly) CLLocationManager *userLocationManager;
@property (nonatomic, readonly) CLLocationManager *regionLocationManager;

- (void)_init;
- (void)_addRegionForMonitoring:(CLRegion *)region desiredAccuracy:(CLLocationAccuracy)accuracy;
- (BOOL)region:(CLRegion *)region inRegion:(CLRegion *)otherRegion;
- (BOOL)isMonitoringThisCoordinate:(CLLocationCoordinate2D)coordinate;
- (BOOL)isMonitoringThisRegion:(CLRegion *)region;

@end

@interface RCLocationManager () // Blocks

// Location Blocks
@property (copy) RCLocationManagerLocationUpdateBlock locationBlock;
@property (copy) RCLocationManagerLocationUpdateFailBlock errorLocationBlock;

// Region Blocks
@property (copy) RCLocationManagerRegionUpdateBlock regionBlock;
@property (copy) RCLocationManagerRegionUpdateFailBlock errorRegionBlock;

@end

@implementation RCLocationManager

@synthesize delegate = _delegate;

@synthesize location = _location;
@synthesize purpose = _purpose;

@synthesize userLocationManager = _userLocationManager;
@synthesize regionLocationManager = _regionLocationManager;

@synthesize userDistanceFilter = _userDistanceFilter;
@synthesize userDesiredAccuracy = _userDesiredAccuracy;
@synthesize regionDistanceFilter = _regionDistanceFilter;
@synthesize regionDesiredAccuracy = _regionDesiredAccuracy;

@synthesize regions = _regions;

@synthesize locationBlock, errorRegionBlock, regionBlock, errorLocationBlock;

+ (RCLocationManager *)sharedManager {
    static RCLocationManager *_sharedClient = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedClient = [[RCLocationManager alloc] init];
    });
    
    return _sharedClient;
}

- (id)init
{
    NSLog(@"[%@] init:", NSStringFromClass([self class]));
    
    if (self = [super init]) {
        // Init
        [self _init];
    }
    
    return self;
}

- (id)initWithUserDistanceFilter:(CLLocationDistance)userDistanceFilter userDesiredAccuracy:(CLLocationAccuracy)userDesiredAccuracy purpose:(NSString *)purpose delegate:(id<RCLocationManagerDelegate>)delegate
{
    
    NSLog(@"[%@] init:", NSStringFromClass([self class]));
    
    if (self = [super init]) {
        // Init
        [self _init];
        _userLocationManager.distanceFilter = userDistanceFilter;
        _userLocationManager.desiredAccuracy = userDesiredAccuracy;
        _purpose = purpose;
        
        self.delegate = delegate;
    }
    
    return self;
}

- (void)_init
{
    NSLog(@"[%@] _init:", NSStringFromClass([self class]));
    
    _isUpdatingUserLocation = NO;
    _isOnlyOneRefresh = NO;
    
    _userLocationManager = [[CLLocationManager alloc] init];
    _userLocationManager.distanceFilter = kDefaultUserDistanceFilter;
    _userLocationManager.desiredAccuracy = kDefaultUserDesiredAccuracy;
    _userLocationManager.delegate = self;
    
    _regionLocationManager = [[CLLocationManager alloc] init];
    _regionLocationManager.distanceFilter = kDefaultRegionDistanceFilter;
    _regionLocationManager.desiredAccuracy = kDefaultRegionDesiredAccuracy;
    _regionLocationManager.delegate = self;
    
}

#pragma mark - Private

/**
 * @discussion check if region is correct
 */
- (void)_addRegionForMonitoring:(CLRegion *)region desiredAccuracy:(CLLocationAccuracy)accuracy
{
    NSSet *regions = self.regionLocationManager.monitoredRegions;
    NSLog(@"[%@] _addRegionForMonitoring:desiredAccuracy: [regions count]: %d", NSStringFromClass([self class]), [regions count]);
    
    NSAssert([CLLocationManager regionMonitoringAvailable] || [CLLocationManager regionMonitoringEnabled], @"RegionMonitoring not available!");
    NSAssert([regions count] < MAX_MONITORING_REGIONS, @"Only support %d regions!", MAX_MONITORING_REGIONS);
    NSAssert(accuracy < self.regionLocationManager.maximumRegionMonitoringDistance, @"Accuracy is too long!");
    
    
    [self.regionLocationManager startMonitoringForRegion:region desiredAccuracy:accuracy];
    
}

/**
 * @discussion only check if region is inside otherRegion
 */
- (BOOL)region:(CLRegion *)region inRegion:(CLRegion *)otherRegion
{
    NSLog(@"[%@] region:containsRegion:", NSStringFromClass([self class]));
    
    CLLocation *location = [[CLLocation alloc] initWithLatitude:region.center.latitude longitude:region.center.longitude];
    CLLocation *otherLocation = [[CLLocation alloc] initWithLatitude:otherRegion.center.latitude longitude:otherRegion.center.longitude];
    
    if ([region containsCoordinate:otherRegion.center] || [otherRegion containsCoordinate:region.center]) {
        if ([location distanceFromLocation:otherLocation] + region.radius <= otherRegion.radius ) {
            return YES;
        } else if ([location distanceFromLocation:otherLocation] + otherRegion.radius <= region.radius ) {
            return NO;
        }
    }
    return NO;
}

/**
 * @discussion check if coordinate is in a region
 */
- (BOOL)isMonitoringThisCoordinate:(CLLocationCoordinate2D)coordinate
{
    NSLog(@"[%@] isMonitoringThisCoordinate:", NSStringFromClass([self class]));
    
    NSSet *regions = self.regionLocationManager.monitoredRegions;
    
    for (CLRegion *reg in regions) {
        if ([reg containsCoordinate:coordinate]) {
            return YES;
        }
    }
    return NO;
}

/**
 * @discussion check if region is inside other region
 */
- (BOOL)isMonitoringThisRegion:(CLRegion *)region
{
    NSLog(@"[%@] isMonitoringThisRegion:", NSStringFromClass([self class]));
    
    NSSet *regions = self.regionLocationManager.monitoredRegions;
    
    for (CLRegion *reg in regions) {
        if ([self region:region inRegion:reg]) {
                return YES;
        }
    }
    return NO;
}

#pragma mark - Setters

- (void)setUserDistanceFilter:(CLLocationDistance)userDistanceFilter
{
    NSLog(@"[%@] setUserDistanceFilter:%f", NSStringFromClass([self class]), userDistanceFilter);
    
    _userDistanceFilter = userDistanceFilter;
    [_userLocationManager setDistanceFilter:_userDistanceFilter];
}

- (void)setUserDesiredAccuracy:(CLLocationAccuracy)userDesiredAccuracy
{
    NSLog(@"[%@] setUserDesiredAccuracy:%f", NSStringFromClass([self class]), userDesiredAccuracy);
    
    _userDesiredAccuracy = userDesiredAccuracy;
    [_userLocationManager setDesiredAccuracy:_userDesiredAccuracy];
}

- (void)setRegionDistanceFilter:(CLLocationDistance)regionDistanceFilter
{
    NSLog(@"[%@] setRegionDistanceFilter:%f", NSStringFromClass([self class]), regionDistanceFilter);
    
    _regionDistanceFilter = regionDistanceFilter;
    [_regionLocationManager setDistanceFilter:_regionDistanceFilter];
}

- (void)setRegionDesiredAccuracy:(CLLocationAccuracy)regionDesiredAccuracy
{
    NSLog(@"[%@] setRegionDesiredAccuracy:%f", NSStringFromClass([self class]), regionDesiredAccuracy);
    
    _regionDesiredAccuracy = regionDesiredAccuracy;
    [_regionLocationManager setDesiredAccuracy:_regionDesiredAccuracy];
}

- (void)setDelegate:(id<RCLocationManagerDelegate>)delegate
{
    NSLog(@"[%@] setDelegate:", NSStringFromClass([self class]));
    
    if (_delegate != delegate) {
        _delegate = delegate;
    }
}

- (void)setPurpose:(NSString *)purpose
{
    NSLog(@"[%@] setPurpose:%@", NSStringFromClass([self class]), purpose);
    
    if (![_purpose isEqualToString:purpose]) {
        self.userLocationManager.purpose = [purpose copy];
        self.regionLocationManager.purpose = [purpose copy];
        _purpose = [purpose copy];
    }
}

#pragma mark - Getters

- (CLLocation *)location
{
    NSLog(@"[%@] location:", NSStringFromClass([self class]));
    
    return self.userLocationManager.location;
}

- (NSSet *)regions
{
    return self.regionLocationManager.monitoredRegions;
}

#pragma mark - CLLocationManagerDelegate

- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error
{
	NSLog(@"[%@] locationManager:didFailWithError:%@", NSStringFromClass([self class]), error);
    
    // Call location block
    if (self.errorLocationBlock != nil) {
        self.errorLocationBlock(manager, error);
    }
    
    if ([self.delegate respondsToSelector:@selector(locationManager:didFailWithError:)]) {
        [self.delegate locationManager:self didFailWithError:error];
    }
}

- (void)locationManager:(CLLocationManager *)manager didUpdateToLocation:(CLLocation *)newLocation fromLocation:(CLLocation *)oldLocation
{
    NSLog(@"[%@] locationManager:didUpdateToLocation:fromLocation: %@", NSStringFromClass([self class]), newLocation);
    
    if (_isOnlyOneRefresh) {
        [_userLocationManager stopUpdatingLocation];
        _isOnlyOneRefresh = NO;
    }
    
    // Call location block
    if (self.locationBlock != nil) {
        self.locationBlock(manager, newLocation, oldLocation);
    }
    
    [[NSNotificationCenter defaultCenter] postNotificationName:RCLocationManagerUserLocationDidChangeNotification
                                                        object:self
                                                      userInfo:(
                                                                [NSDictionary dictionaryWithObject:newLocation
                                                                                            forKey:RCLocationManagerNotificationLocationUserInfoKey])];
    if ([self.delegate respondsToSelector:@selector(locationManager:didUpdateToLocation:fromLocation:)]) {
        [self.delegate locationManager:self didUpdateToLocation:newLocation fromLocation:oldLocation];
    }
}

- (void)locationManager:(CLLocationManager *)manager didEnterRegion:(CLRegion *)region
{
    NSLog(@"[%@] locationManager:didEnterRegion:%@ at %@", NSStringFromClass([self class]), region.identifier, [NSDate date]);
    	
    if (self.regionBlock != nil) {
        self.regionBlock(manager, region, YES);
    }
    
    if ([self.delegate respondsToSelector:@selector(locationManager:didEnterRegion:)]) {
        [self.delegate locationManager:self didEnterRegion:region];
    }
}


- (void)locationManager:(CLLocationManager *)manager didExitRegion:(CLRegion *)region
{
    NSLog(@"[%@] locationManager:didExitRegion:%@ at %@", NSStringFromClass([self class]), region.identifier, [NSDate date]);
    
    if (self.regionBlock != nil) {
        self.regionBlock(manager, region, NO);
    }
	
    if ([self.delegate respondsToSelector:@selector(locationManager:didExitRegion:)]) {
        [self.delegate locationManager:self didExitRegion:region];
    }
}


- (void)locationManager:(CLLocationManager *)manager monitoringDidFailForRegion:(CLRegion *)region withError:(NSError *)error
{
    NSLog(@"[%@] locationManager:monitoringDidFailForRegion:%@: %@", NSStringFromClass([self class]), region.identifier, error);
	
    if (self.errorRegionBlock != nil) {
        self.errorRegionBlock(manager, region, error);
    }
    
    if ([self.delegate respondsToSelector:@selector(locationManager:monitoringDidFailForRegion:withError:)]) {
        [self.delegate locationManager:self monitoringDidFailForRegion:region withError:error];
    }
}

#pragma mark Method's

+ (BOOL)locationServicesEnabled
{
    return [CLLocationManager locationServicesEnabled];
}

+ (BOOL)regionMonitoringAvailable
{
    return [CLLocationManager regionMonitoringAvailable];
}

+ (BOOL)regionMonitoringEnabled
{
    return [CLLocationManager regionMonitoringEnabled];
}

+ (BOOL)significantLocationChangeMonitoringAvailable
{
    return [CLLocationManager significantLocationChangeMonitoringAvailable];
}

- (void)startUpdatingLocation
{
    NSLog(@"[%@] startUpdatingLocation:", NSStringFromClass([self class]));
    
    _isUpdatingUserLocation = YES;
    [self.userLocationManager startUpdatingLocation];
}

- (void)startUpdatingLocationWithBlock:(RCLocationManagerLocationUpdateBlock)block errorBlock:(RCLocationManagerLocationUpdateFailBlock)errorBlock {
    
    self.locationBlock = block;
    self.errorLocationBlock = errorBlock;
    
    [self startUpdatingLocation];
}

- (void)retriveUserLocationWithBlock:(RCLocationManagerLocationUpdateBlock)block errorBlock:(RCLocationManagerLocationUpdateFailBlock)errorBlock {
    
    _isOnlyOneRefresh = YES;
    
    [self startUpdatingLocationWithBlock:block errorBlock:errorBlock];
}

- (void)updateUserLocation
{
    NSLog(@"[%@] updateUserLocation:", NSStringFromClass([self class]));
    
    if (!_isOnlyOneRefresh) {
        _isOnlyOneRefresh = YES;
        [_userLocationManager startUpdatingLocation];
    }
}

- (void)stopUpdatingLocation
{
    NSLog(@"[%@] stopUpdatingLocation:", NSStringFromClass([self class]));
    
    _isUpdatingUserLocation = NO;
    [self.userLocationManager stopUpdatingLocation];
}

- (void)addCoordinateForMonitoring:(CLLocationCoordinate2D)coordinate
{
    NSLog(@"[%@] addCoordinateForMonitoring:", NSStringFromClass([self class]));
    
    [self addCoordinateForMonitoring:coordinate withRadius:kDefaultRegionRadiusDistance desiredAccuracy:kDefaultRegionDesiredAccuracy];
}

- (void)addCoordinateForMonitoring:(CLLocationCoordinate2D)coordinate withRadius:(CLLocationDistance)radius
{
    [self addCoordinateForMonitoring:coordinate withRadius:radius desiredAccuracy:kDefaultRegionDesiredAccuracy];
}

- (void)addCoordinateForMonitoring:(CLLocationCoordinate2D)coordinate withRadius:(CLLocationDistance)radius desiredAccuracy:(CLLocationAccuracy)accuracy
{
    NSLog(@"[%@] addCoordinateForMonitoring:withRadius:", NSStringFromClass([self class]));
    
    CLRegion *region = [[CLRegion alloc] initCircularRegionWithCenter:coordinate radius:radius identifier:[NSString stringWithFormat:@"Region with center (%f, %f) and radius (%f)", coordinate.latitude, coordinate.longitude, radius]];
    
    [self addRegionForMonitoring:region desiredAccuracy:accuracy];
}

- (void)addRegionForMonitoring:(CLRegion *)region
{
    NSLog(@"[%@] addRegionForMonitoring:", NSStringFromClass([self class]));
    
    [self addRegionForMonitoring:region desiredAccuracy:kDefaultRegionDesiredAccuracy];
}

- (void)addRegionForMonitoring:(CLRegion *)region desiredAccuracy:(CLLocationAccuracy)accuracy
{
    NSLog(@"[%@] addRegionForMonitoring:", NSStringFromClass([self class]));
    
    if (![self isMonitoringThisRegion:region]) {
        [self _addRegionForMonitoring:region desiredAccuracy:accuracy];
    }
}

- (void)addRegionForMonitoring:(CLRegion *)region desiredAccuracy:(CLLocationAccuracy)accuracy updateBlock:(RCLocationManagerRegionUpdateBlock)block errorBlock:(RCLocationManagerRegionUpdateFailBlock)errorBlock {
    
    self.regionBlock = block;
    self.errorRegionBlock = errorBlock;
    
    [self addRegionForMonitoring:region desiredAccuracy:accuracy];
}

- (void)stopMonitoringForRegion:(CLRegion *)region
{
    NSLog(@"[%@] stopMonitoringForRegion:", NSStringFromClass([self class]));
    
    [self.regionLocationManager stopMonitoringForRegion:region];
}

- (void)stopMonitoringAllRegions
{
    NSSet *regions = self.regionLocationManager.monitoredRegions;
    NSLog(@"[%@] stopMonitoringAllRegion: [regions count]: %d", NSStringFromClass([self class]), [regions count]);
    
    for (CLRegion *reg in regions) {
        [self.regionLocationManager stopMonitoringForRegion:reg];
    }
}

@end
