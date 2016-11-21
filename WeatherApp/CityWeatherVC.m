//
//  CityWeatherVC.m
//  WeatherApp
//
//  Created by Vishal Deep on 31/08/16.
//  Copyright © 2016 Training. All rights reserved.
//

#import "CityWeatherVC.h"
#import "CityWeatherTableCell.h"
#import "WeatherViewController.h"

@interface CityWeatherVC ()


@property (strong) NSMutableArray *submittedDataArray;

@end

@implementation CityWeatherVC

- (void)viewDidLoad {
    
    [super viewDidLoad];
    // Do any additional setup after loading the view.
//    savedValue = [[NSUserDefaults standardUserDefaults]
//                  objectForKey:@"cityWeatherData"];
//    
//    keys =  [savedValue allKeys];

    fetchManageObjectContext = [[GlobalViewController alloc]init];
    NSManagedObjectContext *managedObjectContext = [fetchManageObjectContext managedObjectContext];
    
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] initWithEntityName:@"WeatherRecord"];
    self.submittedDataArray = [[managedObjectContext executeFetchRequest:fetchRequest error:nil] mutableCopy];
    
}



#pragma mark - Table Delegate And DataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
//    return [keys arrayByAddingObjectsFromArray:keys].count;
    return [_submittedDataArray count];
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath

{
    static NSString *CellIdentifier = @"CityWeatherCell";
    CityWeatherTableCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    NSManagedObject *cityData = [self.submittedDataArray objectAtIndex:indexPath.row];
    cell.cityNameLbl.text = [cityData valueForKey:@"city"];
    cell.cityTimeLbl.text = [cityData valueForKey:@"pincode"];
    cell.cityTemperatureLbl.text = [cityData valueForKey:@"state"];
//    cell.cityTemperatureLbl.text = [cityData valueForKey:@"currentTemp"];
    return cell;
}
-(IBAction) TempFormatsegmentedControl:(id) sender{
    
    if (_segmentedControl.selectedSegmentIndex == 0) {
        
    } else{
        
    }
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the specified item to be editable.
    return YES;
}


- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSManagedObjectContext *context = [fetchManageObjectContext managedObjectContext];
    
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete object from database
        [context deleteObject:[self.submittedDataArray objectAtIndex:indexPath.row]];
        
        NSError *error = nil;
        if (![context save:&error]) {
            NSLog(@"Can't Delete! %@ %@", error, [error localizedDescription]);
            return;
        }
        // Remove device from table view
        [self.submittedDataArray removeObjectAtIndex:indexPath.row];
        [self.tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
