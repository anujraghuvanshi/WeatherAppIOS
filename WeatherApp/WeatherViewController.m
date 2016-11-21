//
//  WeatherViewController.m
//  WeatherApp
//
//  Created by Vishal Deep on 19/08/16.
//  Copyright © 2016 Training. All rights reserved.
//

#import "WeatherViewController.h"
#import "LocationViewController.h"
#import "CollectionViewCell.h"
#import "TableViewCell.h"
#import "GlobalViewController.h"
@import SystemConfiguration;

#define BaseUrl "https://api.forecast.io/forecast"
#define APIKEY "60f3120e246aa6baf3871fc4b98cd6ec"


@interface WeatherViewController (){
    
}

@property (strong) NSMutableArray *submittedDataArray;


@end

@implementation WeatherViewController
@synthesize reachability;
@synthesize internetWorking;




#pragma mark ViewDidLoad

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationController.navigationBarHidden = YES;
    [self setBorderToViews];
    
    hourlyClimateImageArray = [[NSMutableArray alloc]init];
    dayClimateImageArray = [[NSMutableArray alloc]init];
    minTemperatures = [[NSMutableArray alloc]init];
    maxTemperatures = [[NSMutableArray alloc]init];
    hourlyTempArray = [[NSMutableArray alloc]init];
    timeArray = [[NSMutableArray alloc]init];
    dayArray = [[NSMutableArray alloc]init];
    
    NSDictionary *savedValue = [[NSUserDefaults standardUserDefaults]
                                objectForKey:@"userLocationData"];
    _cityName.text = savedValue[@"city"];

    GlobalViewController *fetchManageObjectContext = [[GlobalViewController alloc]init];
    NSManagedObjectContext *context = [fetchManageObjectContext managedObjectContext];
    newDataForEntity = [NSEntityDescription insertNewObjectForEntityForName:@"WeatherRecord" inManagedObjectContext:context];

    [self fetchRecordMethod];
    [self actionsWithInternet];
    
    
    operationQueue = [NSOperationQueue new];
    
//    NSInvocationOperation *operation = [[NSInvocationOperation alloc] initWithTarget:self
//                                                                            selector:@selector(callApi)
//                                                                              object:nil];
//    // Add the operation to the queue and let it to be executed.
//    [operationQueue addOperation:operation];

    
    // The same story as above, just tell here to execute the colorRotatorTask method.
//    operation = [[NSInvocationOperation alloc] initWithTarget:self
//                                                     selector:@selector(colorRotatorTask)
//                                                       object:nil];
//    [operationQueue addOperation:operation];

}

-(void)fetchRecordMethod{
    GlobalViewController *fetchManageObjectContext = [[GlobalViewController alloc]init];
    NSManagedObjectContext *managedObjectContext = [fetchManageObjectContext managedObjectContext];
    
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] initWithEntityName:@"WeatherRecord"];
    self.submittedDataArray = [[managedObjectContext executeFetchRequest:fetchRequest error:nil] mutableCopy];
    NSLog(@"submittedDataArray is :%@",_submittedDataArray);
}



#pragma mark ViewDidAppear

-(void)viewDidAppear:(BOOL)animated
{
//    [_weatherImage addSubview:[self blurTheImage:_weatherImage.image]];
//    [_weatherImage addSubview:[self blurTheImage:_weatherImage.image :_weatherImage]];
}

#pragma mark DataReduction

-(void)dataReductionIfNeeded:(NSMutableDictionary *)dict {
    NSMutableArray *baseArray = [dict[@"hourly"][@"data"] mutableCopy];
    NSMutableArray *tempArray = [baseArray mutableCopy];
    
    NSMutableDictionary *tempDictionary = [dict mutableCopy];
    
    [tempDictionary removeObjectForKey:@"hourly"];
    
    for(id object in baseArray) {
        NSString *currentTimeString = [self timeStampToHour :object[@"time"]];
        
        NSDateFormatter *dateFormatter=[[NSDateFormatter alloc] init];
        [dateFormatter setDateFormat:@"h a"];
        NSString *currentTimeInDevice = [dateFormatter stringFromDate:[NSDate date]];
        
        if ([currentTimeString isEqualToString: currentTimeInDevice]) {
            NSLog(@"Time Matches");
            break;
        }
        else
        {
            [tempArray removeObject:object];
        }
    }
    baseArray = [tempArray mutableCopy];
    
    NSMutableDictionary *tempDict = [[NSMutableDictionary alloc]init];
    [tempDict setValue:baseArray forKey:@"data"];
    
    [tempDictionary setValue:tempDict forKey:@"hourly"];
    
    json = [tempDictionary mutableCopy];

}

#pragma mark Call Apibbbb
- (void)callApi {
    
    NSDictionary *savedValue = [[NSUserDefaults standardUserDefaults]
                                objectForKey:@"userLocationData"];
    
    NSString *api = [NSString stringWithFormat:@"%s/%s",BaseUrl ,APIKEY];
    urlStr = [NSString stringWithFormat: @"%@/%@,%@",api,savedValue [@"lattitude"],savedValue [@"longitude"]];
    NSURLSession* session = [NSURLSession sessionWithConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration] delegate:nil delegateQueue:[NSOperationQueue mainQueue]];
    [[session dataTaskWithURL:[NSURL URLWithString:urlStr]
            completionHandler:^(NSData *data, NSURLResponse *response, NSError *error){
                               if (data){
                                   //Converting responce data into NSDictionary
                                   json = [NSJSONSerialization JSONObjectWithData:data options: NSJSONReadingMutableContainers error: nil];
                                   
                                   NSLog(@"%@",json);
                                   
                                   //Updating UI
                                   [self loadData];
//                                   [self writeStringToFile:data];
                               }
                               else {
                                   NSLog(@"Error In Parsing the JSON");
                               }
                           }]resume];
}

#pragma mark Loading data to View

-(void)loadData {
    [self loadDataToView:json];
    [_collectionView reloadData];
    [_table reloadData];
    //[self saveValuesToUserDefaults];
}

-(void)loadDataToView:(NSDictionary*)dict  {
    //getting the temperature
    
    NSString * temp = dict[@"currently"][@"temperature"];
    float fehrenheit  = temp.floatValue;
    NSLog(@"This ia current temperature : %f",fehrenheit);
    
//    float celcius = (fehrenheit - 32.0)*( 5.0 /9.0);
    
    
    tempInfehrenheit = [NSString stringWithFormat:@"%.f °F", fehrenheit];
    
    [newDataForEntity setValue:tempInfehrenheit forKey:@"currentTemp"];
    
    NSMutableAttributedString *string = [[NSMutableAttributedString alloc] initWithString:tempInfehrenheit];
    NSRange range = (NSRange){2,3};
    [string enumerateAttribute:NSFontAttributeName inRange:range options:NSAttributedStringEnumerationLongestEffectiveRangeNotRequired usingBlock:^(id value, NSRange range, BOOL *stop) {
        UIFont *replacementFont =  [UIFont fontWithName:@"Palatino-Roman" size:26.0];
        [string addAttribute:NSFontAttributeName value:replacementFont range:range];
    }];
    
    _currentTemperature.attributedText  = string;
    
    
    //getting the weekly data
    NSArray *dailyDataArray = [[NSArray alloc]init];
    dailyDataArray = dict[@"daily"][@"data"];
    
    for (int i=0 ; i<dailyDataArray.count; i++) {
        NSData * dailyData = [dailyDataArray objectAtIndex:i];
        NSString * minTemp = [dailyData valueForKey:@"temperatureMin"];
        NSString *maxTemp = [dailyData valueForKey:@"temperatureMax"];
        
//        NSString * minTemps = [self getCelcius:minTemp.floatValue];
//        NSString * maxTemps = [self getCelcius:maxTemp.floatValue];
        NSString * minTemps = [NSString stringWithFormat:@"%.f°",minTemp.floatValue];
        NSString * maxTemps = [NSString stringWithFormat:@"%.f°",maxTemp.floatValue];

        
        [minTemperatures addObject:minTemps];
        [maxTemperatures addObject:maxTemps];
        
        //getting day
        
        NSString *dayString = [dailyData valueForKey:@"time"];
        NSString *days = [self convertDateFormat:dayString];
        [dayArray addObject:days];
        
        //set Images
        
        dayClimateImage = [dailyData valueForKey:@"icon"];
        [self weatherConditionImages];
    }
    
    //getting the hourly data
    NSArray *hourlyDataArray = [[NSArray alloc]init];
    hourlyDataArray = dict[@"hourly"][@"data"];
    
    for (int i=0; i<hourlyDataArray.count; i++) {
        NSData * hourlyData = [hourlyDataArray objectAtIndex:i];
        NSString *hourTempKey = [hourlyData valueForKey:@"temperature"];
//        NSString *hourTemp = [self getCelcius:hourTempKey.floatValue];
        
        NSString *hourTemp = [NSString stringWithFormat:@"  %.f°",hourTempKey.floatValue];

        [hourlyTempArray addObject:hourTemp];
        
        hourClimateImage = [hourlyData valueForKey:@"icon"];
        [self hourlyImage];
        
        //setting the hour
        NSString *time = [hourlyData valueForKey:@"time"];
        hourlyTime = [self timeStampToHour:time];
        [timeArray addObject:hourlyTime];
        CurrentTimeWithFormat = [self timeStampToHourAndMinute :json [@"currently"][@"time"]];

    }

}

// setting the image according to weather condition

-(void)weatherConditionImages {
    if ([dayClimateImage isEqualToString:@"clear-night"]) {
        [dayClimateImageArray addObject:@"clear-night.png"];
    }
    else if ([dayClimateImage isEqualToString:@"rain"])
    {
        [dayClimateImageArray addObject:@"rain.png"];
    }
    else if ([dayClimateImage isEqualToString:@"clear-day"])
    {
        [dayClimateImageArray addObject:@"clear-day.png"];
    }
    else if ([dayClimateImage isEqualToString:@"snow"])
    {
        [dayClimateImageArray addObject:@"snow.png"];
    }
    else if ([dayClimateImage isEqualToString:@"sleet"])
    {
        [dayClimateImageArray addObject:@"sleet.png"];
    }
    else if ([dayClimateImage isEqualToString:@"fog"])
    {
        [dayClimateImageArray addObject:@"fog.png"];
    }
    else if ([dayClimateImage isEqualToString:@"wind"])
    {
        [dayClimateImageArray addObject:@"wind.png"];
    }
    else if ([dayClimateImage isEqualToString:@"cloudy"])
    {
        [dayClimateImageArray addObject:@"cloudy.png"];
    }
    else if ([dayClimateImage isEqualToString:@"partly-cloudy-night"])
    {
        [dayClimateImageArray addObject:@"partly-cloudy-night.png"];
    }
    else if ([dayClimateImage isEqualToString:@"partly-cloudy-day"])
    {
        [dayClimateImageArray addObject:@"partly-cloudy-day.png"];
    }
    
    else{
        
    }

}

//-(void)getBackgoundImage {
//    if ([hourClimateImage isEqualToString:@"partly-cloudy-night"]) {
//        _weatherImage.image =[UIImage imageNamed:@"partly-cloudy-night-moon.jpg"];
//    }
//    else if ([hourClimateImage isEqualToString:@"clear-night"])
//    {
//        _weatherImage.image =[UIImage imageNamed:@"clear-night-sky.jpg"];
//    }
//    else if ([hourClimateImage isEqualToString:@"rain"])
//    {
//        _weatherImage.image =[UIImage imageNamed:@"rain.png"];
//    }
//    else if ([hourClimateImage isEqualToString:@"partly-cloudy-day"])
//    {
//        _weatherImage.image =[UIImage imageNamed:@"cloudy-day.jpg"];
//    }
//    else if ([hourClimateImage isEqualToString:@"clear-day"])
//    {
//        _weatherImage.image =[UIImage imageNamed:@"sun-clear.jpg"];
//    }
//    else{
//        
//    }
//}

-(void)hourlyImage{
    if ([hourClimateImage isEqualToString:@"clear-night"]) {
        [hourlyClimateImageArray addObject:@"clear-night.png"];
    }
    else if ([hourClimateImage isEqualToString:@"rain"])
    {
        [hourlyClimateImageArray addObject:@"rain.png"];
    }
    else if ([hourClimateImage isEqualToString:@"clear-day"])
    {
        [hourlyClimateImageArray addObject:@"clear-day.png"];
    }
    else if ([hourClimateImage isEqualToString:@"snow"])
    {
        [hourlyClimateImageArray addObject:@"snow.png"];
    }
    else if ([hourClimateImage isEqualToString:@"sleet"])
    {
        [hourlyClimateImageArray addObject:@"sleet.png"];
    }
    else if ([hourClimateImage isEqualToString:@"fog"])
    {
        [hourlyClimateImageArray addObject:@"fog.png"];
    }
    else if ([hourClimateImage isEqualToString:@"wind"])
    {
        [hourlyClimateImageArray addObject:@"wind.png"];
    }
    else if ([hourClimateImage isEqualToString:@"cloudy"])
    {
        [hourlyClimateImageArray addObject:@"cloudy.png"];
    }
    else if ([hourClimateImage isEqualToString:@"partly-cloudy-night"])
    {
        [hourlyClimateImageArray addObject:@"partly-cloudy-night.png"];
    }
    else if ([hourClimateImage isEqualToString:@"partly-cloudy-day"])
    {
        [hourlyClimateImageArray addObject:@"partly-cloudy-day.png"];
    }
    
    else{
        
    }
}

#pragma mark Convert Formats
//converting date format to day

- (NSString *)convertDateFormat:(NSString *)timeStamp {
    NSTimeInterval _interval = [timeStamp doubleValue];
    NSDate *date = [NSDate dateWithTimeIntervalSince1970:_interval];
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setTimeZone:[NSTimeZone localTimeZone]];
    [dateFormatter setDateFormat:@"EEEE"];
    NSString *dayName = [dateFormatter stringFromDate:date];
    return dayName;
}

//TimeStamp to hour format.

- (NSString *)timeStampToHour:(NSString *)timeStamp {
    
    NSTimeInterval _interval = [timeStamp doubleValue];
    NSDate *date = [NSDate dateWithTimeIntervalSince1970:_interval];
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setTimeZone:[NSTimeZone systemTimeZone]];
    [dateFormatter setDateFormat:@"h a"];
    NSString *time = [dateFormatter stringFromDate:date];
    return time;
}

//converting fehrenheit to celcius

-(NSString *)getCelcius : (float)fehrenheit {
    NSString * tempFormat = [NSString stringWithFormat:@"%.f °C",(fehrenheit - 32.0)*( 5.0 /9.0)];
    return tempFormat;
}

- (NSString *)timeStampToHourAndMinute:(NSString *)timeStamp {
    
    NSTimeInterval _interval = [timeStamp doubleValue];
    NSDate *date = [NSDate dateWithTimeIntervalSince1970:_interval];
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setTimeZone:[NSTimeZone timeZoneWithAbbreviation:@"EST"]];
    [dateFormatter setDateFormat:@"hh:mm a"];
    NSString *time = [dateFormatter stringFromDate:date];
    return time;
}

//Implementing For The collectionView
#pragma mark Collection DataSource/Delegate

- (NSInteger) collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    return hourlyTempArray.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    CollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"CollectionCell" forIndexPath:indexPath];

    if (indexPath.row == 0)
    {
        cell.timeLbl.text = @"Now";
    }
    else
    {
        cell.timeLbl.text = timeArray [indexPath.row];
    }
    cell.tempLbl.text = hourlyTempArray [indexPath.row];
    cell.weatherImage.image = [UIImage imageNamed:hourlyClimateImageArray [indexPath.row]];
    return cell;
}

// Implementing For The tableView

#pragma mark TableView DataSource/Delegate

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return minTemperatures.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"TableCell";
    TableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    cell.dayLbl.text = dayArray [indexPath.row];
    cell.minTempLbl.text = [NSString stringWithFormat:@"Min  : %@",minTemperatures[indexPath.row]];
    cell.maxTempLbl.text = [NSString stringWithFormat:@"Max : %@",maxTemperatures[indexPath.row]];
    cell.dayClimateImage.image = [UIImage imageNamed:dayClimateImageArray[indexPath.row]];
    cell.backgroundColor = [UIColor clearColor];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    return cell;
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 52;
}


#pragma mark other Functions

//Writing data to the json file
- (void)writeStringToFile:(NSData*)data {
    
    // Build the path, and create if needed.
    NSString* filePath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    NSString* fileName = @"data.json";
    NSString* fileAtPath = [filePath stringByAppendingPathComponent:fileName];
    
    if (![[NSFileManager defaultManager] fileExistsAtPath:fileAtPath]) {
        
    }
    else{
        NSLog(@"File Saved");
        [[NSFileManager defaultManager] createFileAtPath:fileAtPath contents:nil attributes:nil];
    }
    // Write Data to the file
    [data writeToFile:fileAtPath atomically:YES];
}

// Blur the Background Image
-(void)blurTheImage {
    UIVisualEffect *blurEffect;
    blurEffect = [UIBlurEffect effectWithStyle:UIBlurEffectStyleLight];
    UIVisualEffectView *visualEffectView;
    visualEffectView = [[UIVisualEffectView alloc] initWithEffect:blurEffect];
    visualEffectView.frame = _weatherImage.bounds;
    [_weatherImage addSubview:visualEffectView];
    
//    [[_weatherImage addSubview:[self blurTheImage:_weatherImage.image]];
    
}

//Adding Border  To The Views.
-(void)setBorderToViews {
    self.collectionView.layer.borderColor = [UIColor whiteColor].CGColor;
    self.collectionView.layer.borderWidth = 1;
    self.collectionView.clipsToBounds = YES;
    self.table.layer.borderColor = [UIColor whiteColor].CGColor;
    self.table.layer.borderWidth = 1;
    self.table.clipsToBounds = YES;
}


-(UIStatusBarStyle) preferredStatusBarStyle
{
    return UIStatusBarStyleLightContent;
}


// Reloading the View
-(IBAction)reloadView {
    [self viewDidLoad];
}

#pragma mark Check internet

- (void)checkInternetConnection
{
    reachability = [Reachability reachabilityForInternetConnection];
    
    [self performSelector:@selector(updateInterfaceWithReachability:)withObject:reachability];
}

- (void)updateInterfaceWithReachability:(Reachability *)curReach
{
    if(curReach == reachability)
    {
        NetworkStatus netStatus = [curReach currentReachabilityStatus];
        switch (netStatus)
        {
            case NotReachable:
            {
                internetWorking = -1;
                break;
            }
            case ReachableViaWiFi:
            {
                internetWorking = 0;
                break;
            }
            case ReachableViaWWAN:
            {
                internetWorking = 0;
                break;
            }
        }
    }
}

-(void)noNetworkAlert
{
    [[NSNotificationCenter defaultCenter] postNotificationName:@"ShowServerError" object:nil];
}


#pragma mark actions according to internet

-(void)actionsWithInternet {
    [self checkInternetConnection];

    if (internetWorking == 0) // Working internet Connection
    {
        [self callApi];    }
    else {
        NSLog(@"OOPS... Check Internet");
        [self parseJsonFromFile];
        [self dataReductionIfNeeded:json];
        [self loadData];
    }
}

//Parsing Data From json File

- (NSMutableDictionary *)parseJsonFromFile {
    // Retrieve local JSON file called data.json

    NSString* filePath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    NSString* fileName = @"data.json";
    
    NSString* fileAtPath = [filePath stringByAppendingPathComponent:fileName];
    
    // Load the file into an NSData object called JSONData
    NSError *error = nil;
    
    NSData *data = [NSData dataWithContentsOfFile:fileAtPath options:NSDataReadingMappedIfSafe error:&error];
    json = [NSJSONSerialization JSONObjectWithData:data options: NSJSONReadingAllowFragments error: nil];
    return json;
}

-(void)saveValuesToUserDefaults {
    NSDictionary *savedValue = [[NSUserDefaults standardUserDefaults]
                                objectForKey:@"userLocationData"];
    
   NSMutableDictionary* collectionDictionary = [NSMutableDictionary dictionaryWithDictionary: @{ @"city": savedValue[@"city"] , @"currentTime" :  CurrentTimeWithFormat ,@"temp" :[NSString stringWithFormat:@"%@°", tempInfehrenheit]
                                                                                                                                               }];
    [[NSUserDefaults standardUserDefaults] setObject:collectionDictionary forKey:@"cityWeatherData"];
    [[NSUserDefaults standardUserDefaults] synchronize];
    NSLog(@"This is my dictionary data %@",collectionDictionary);
}




#pragma mark Memory Warning

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    
}

@end
