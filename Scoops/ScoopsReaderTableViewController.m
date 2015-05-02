//
//  ScoopsReaderTableViewController.m
//  Scoops
//
//  Created by Miguel Angel Vélez Serrano on 30/4/15.
//  Copyright (c) 2015 Miguel Ángel Vélez Serrano. All rights reserved.
//

#import "ScoopsReaderTableViewController.h"
#import "Scoop.h"
#import "ScoopViewController.h"
#import "AzureSession.h"

@interface ScoopsReaderTableViewController () {
    
    AzureSession *azureSession;
}

@property (strong, nonatomic) NSMutableArray *scoops;

@end

@implementation ScoopsReaderTableViewController


- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"Scoops Reader";
    azureSession = [AzureSession sharedAzureSession];
    [self populateModelFromAzure];
}


#pragma mark - modelo
- (void)populateModelFromAzure{
    
    self.scoops = [[NSMutableArray alloc] init];
    
    MSClient *client = [azureSession client];
    
    MSTable *table = [client tableWithName:@"news"];
    MSQuery *queryModel = [[MSQuery alloc]initWithTable:table];
    [queryModel readWithCompletion:^(NSArray *items, NSInteger totalCount, NSError *error) {
        for (id item in items) {
            NSLog(@"item -> %@", item);
            Scoop *scoop = [[Scoop alloc] initWithTitle:item[@"title"]
                                                  photo:nil
                                                   text:item[@"text"]
                                               authorId:item[@"authorId"]
                                             authorName:item[@"authorName"]
                                                  coors:CLLocationCoordinate2DMake(0, 0)
                                                 status:[item[@"status"] integerValue]];
            [self.scoops addObject:scoop];
            scoop.id = item[@"id"];
        }
        [self.tableView reloadData];
    }];
}



#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
    return [self.scoops count];
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    // Averiguar el scoop
    Scoop *scoop = [self.scoops objectAtIndex:indexPath.row];
    
    // Crear la celda
    static NSString *cellId = @"cellId";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellId];
    
    if (cell == nil) {
        // La tenemos que crear nosotros desde cero
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle
                                      reuseIdentifier:cellId];
    }
    
    // Configurar
    // Sincronizar modelo (scoop) --> vista (celda)
    cell.imageView.image = [UIImage imageWithData:scoop.image];
    cell.textLabel.text = scoop.title;
    cell.detailTextLabel.text = scoop.authorName;
    
    // Devolver
    return cell;
}




#pragma mark - Table view delegate

// In a xib-based application, navigation from a table can be handled in -tableView:didSelectRowAtIndexPath:
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    // Averiguar el scoop
    Scoop *scoop = scoop = [self.scoops objectAtIndex:indexPath.row];
    
    ScoopViewController *sVC = [[ScoopViewController alloc] initWithScoop:scoop];
    [self.navigationController pushViewController:sVC animated:YES];
}


@end
