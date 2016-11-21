//
//  ViewController.m
//  WeatherApp
//
//  Created by Vishal Deep on 17/08/16.
//  Copyright © 2016 Training. All rights reserved.
//

#import "LocationViewController.h"
#import "GlobalViewController.h"


@interface LocationViewController ()
{
    CLGeocoder *geocoder;
    CLPlacemark *placemark;
}
@end

@implementation LocationViewController

@synthesize locationManager;


#pragma mark - View LifeCycle
- (void)viewDidLoad
{
    [super viewDidLoad];
    arrayOfDictionary = [[NSMutableArray alloc]init];
    dictionary =[[NSMutableDictionary alloc]init];
    
    
    self.navigationController.navigationBarHidden = YES;
    
    GlobalViewController *fetchManageObjectContext = [[GlobalViewController alloc]init];
    NSManagedObjectContext *context = [fetchManageObjectContext managedObjectContext];
    newDataForEntity = [NSEntityDescription insertNewObjectForEntityForName:@"WeatherRecord" inManagedObjectContext:context];
    
    _city.delegate = self;
    _state.delegate = self;
    _country.delegate = self;
    _pinCode.delegate = self;    ;

    [self disableButton];
    


}

#pragma mark ViewDidAppear

//-(void)viewDidAppear:(BOOL)animated
//{
////    [self blurTheImage];
//}


-(UIStatusBarStyle) preferredStatusBarStyle
{
    return UIStatusBarStyleLightContent;
}

- (IBAction)switchBtn:(id)sender {
    switchCase = (UISwitch *) sender;

    if(switchCase.isOn){
        NSLog(@"Switch State is Enabled");
        [self startUpadatingLocation];
    }
    else{
        NSLog(@"Switch State is Disabled");

        _city.text = nil;
        _state.text = nil;
        _pinCode.text =nil;
        _country.text =nil;
        
    }
//    [self disableButton];
}

#pragma mark Update Location
-(void)startUpadatingLocation{

    geocoder = [[CLGeocoder alloc] init];
    if (locationManager == nil)
    {
        locationManager = [[CLLocationManager alloc] init];
        locationManager.delegate = self;
        locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters;
        [locationManager requestAlwaysAuthorization];
    }
    [locationManager startUpdatingLocation];
    
}



- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    // Turn off the location manager to save power.
    
    [self.locationManager stopUpdatingLocation];
}

#pragma mark - CLLocationManager delegate methods

-(void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations {

    newLocation = [locations lastObject];
    [self fetchTheCurrentLocation];
    
    // Turn off the location manager to save power.
    [manager stopUpdatingLocation];
}

-(void)fetchTheCurrentLocation {
    [geocoder reverseGeocodeLocation:newLocation completionHandler:^(NSArray *placemarks, NSError *error) {
        
        if (error == nil && [placemarks count] > 0) {
            placemark = [placemarks lastObject];
            currentLatitude = [NSString stringWithFormat:@"%f",newLocation.coordinate.latitude];
            currentLongitude = [NSString stringWithFormat:@"%f",newLocation.coordinate.longitude];
            NSString * city = placemark.locality;
            NSString * state = placemark.administrativeArea;
            NSString * country = placemark.country;
            NSString * pincode = placemark.postalCode;
            
            _city.text = placemark.locality;
            _state.text = placemark.administrativeArea;
            _country.text = placemark.country;
            _pinCode.text = placemark.postalCode;
            [self disableButton];
 
            [newDataForEntity setValue:currentLatitude forKey:@"lattitude"];
            [newDataForEntity setValue:currentLongitude forKey:@"longitude"];
            [newDataForEntity setValue:placemark.locality forKey:@"city"];
            [newDataForEntity setValue:placemark.administrativeArea forKey:@"state"];
            [newDataForEntity setValue:placemark.postalCode forKey:@"pincode"];
            [newDataForEntity setValue:placemark.country forKey:@"country"];

            
            
            dictionary = [NSMutableDictionary                                               dictionaryWithDictionary: @{  @"lattitude" :currentLatitude,@"longitude" : currentLongitude, @"city": city , @"state" :  state ,@"country" : country , @"pinCode" : pincode
                                                                                                                          }];
            [[NSUserDefaults standardUserDefaults] setObject:dictionary forKey:@"userLocationData"];
            [[NSUserDefaults standardUserDefaults] synchronize];

            } else {
            NSLog(@"%@", error.debugDescription);
        }
        
    }];
}

- (void)locationManager:(CLLocationManager *)manager
       didFailWithError:(NSError *)error
{
    NSLog(@"Cannot find the location.");
}

#pragma mark Other Functions

- (void)textFieldDidEndEditing:(UITextField *)textField
{
    //check your all texfield length if not equal to zero in below if(condition)
    if((_city.text.length > 0) && (_state.text.length > 0)&& (_country.text.length > 0))
    {
        [_showBtn setEnabled:true];
    }
    else
    {
        [_showBtn setEnabled:false];
    }
}

-(void)disableButton {
    if ([_city.text isEqualToString:@""]||[_state.text isEqualToString:@""]||[_country.text isEqualToString:@""]|| [_pinCode.text isEqualToString:@""]) {
        
        [_showBtn setEnabled:false];
        _showBtn.highlighted = true;
    }
    else{
        [_showBtn setEnabled:true];
        _showBtn.highlighted = false;
    }
}

// fetch the location of the user values.

-(void)getLocationString {
    cityEnteredByUser = _city.text;
    stateEnteredByUser = _state.text;
    countryEnteredByUser = _country.text;
    pincodeEnteredByUser= _pinCode.text;
}

-(void)fetchLocationOfUserData {
    
    [self getLocationString];
    
    NSLog(@"%@",cityEnteredByUser);
    
    NSString *addressString = [NSString stringWithFormat:@"%@,%@,%@,%@", cityEnteredByUser, stateEnteredByUser, countryEnteredByUser, pincodeEnteredByUser ];
    
    [self getLocationFromAddressString :addressString];
    

    [newDataForEntity setValue:cityEnteredByUser forKey:@"city"];
    [newDataForEntity setValue:stateEnteredByUser forKey:@"state"];
    [newDataForEntity setValue:pincodeEnteredByUser forKey:@"pincode"];
    [newDataForEntity setValue:countryEnteredByUser forKey:@"country"];
    
    [newDataForEntity setValue:LattitudeFoundByUserData forKey:@"lattitude"];
    [newDataForEntity setValue:LongitudeFoundByUserData forKey:@"longitude"];
    
    
    dictionary = [NSMutableDictionary                                               dictionaryWithDictionary: @{   @"lattitude" :LattitudeFoundByUserData,@"longitude" : LongitudeFoundByUserData,  @"city": cityEnteredByUser , @"state" :  stateEnteredByUser ,@"country" : countryEnteredByUser , @"pinCode" : pincodeEnteredByUser
                                                                                                                   }];
    NSLog(@"%@",dictionary);
    [[NSUserDefaults standardUserDefaults] setObject:dictionary forKey:@"userLocationData"];
    [[NSUserDefaults standardUserDefaults] synchronize];
    NSArray * someArr = [NSArray arrayWithObject:newDataForEntity];
    NSLog(@"%@",someArr);
}

//convert string address to lattitude and longitude

-(CLLocationCoordinate2D) getLocationFromAddressString: (NSString*) addressStr {
    double latitude = 0, longitude = 0;
    NSString *esc_addr =  [addressStr stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]];
    NSString *req = [NSString stringWithFormat:@"http://maps.google.com/maps/api/geocode/json?sensor=false&address=%@", esc_addr];
    NSString *result = [NSString stringWithContentsOfURL:[NSURL URLWithString:req] encoding:NSUTF8StringEncoding error:NULL];
    if (result) {
        NSScanner *scanner = [NSScanner scannerWithString:result];
        if ([scanner scanUpToString:@"\"lat\" :" intoString:nil] && [scanner scanString:@"\"lat\" :" intoString:nil]) {
            [scanner scanDouble:&latitude];
            if ([scanner scanUpToString:@"\"lng\" :" intoString:nil] && [scanner scanString:@"\"lng\" :" intoString:nil]) {
                [scanner scanDouble:&longitude];
            }
        }
    }
    CLLocationCoordinate2D center;
    center.latitude= latitude;
    center.longitude = longitude;
    
    LattitudeFoundByUserData = [NSString stringWithFormat: @"%f",center.latitude];
    LongitudeFoundByUserData = [NSString stringWithFormat: @"%f",center.longitude];
    NSLog(@"getting Location Logitute : %@",LattitudeFoundByUserData);
    NSLog(@"getting Location Latitute : %@",LongitudeFoundByUserData);
    return center;
    
}

- (IBAction)showlocation:(id)sender {
    
    if (!switchCase.isOn) {
        [self fetchLocationOfUserData];
        
//        [[NSUserDefaults standardUserDefaults] setObject:arrayOfDictionary forKey:@"userLocationData"];
//        [[NSUserDefaults standardUserDefaults] synchronize];
    }
    
//    UIStoryboard* storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
//    UIViewController *weatherView =[storyboard instantiateViewControllerWithIdentifier:@"WeatherScene"];
//    [self presentViewController:weatherView animated:YES completion:nil];
    
}
@end
