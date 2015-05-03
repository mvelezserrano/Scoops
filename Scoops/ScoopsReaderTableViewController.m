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

@synthesize activityIndicator;

- (id) initWithStyle:(UITableViewStyle)style {
    
    if (self = [super initWithStyle:style]) {
        self.title = @"Scoops Reader";
        azureSession = [AzureSession sharedAzureSession];
        [self getHeadlines];
    }
    
    return self;
}

/*
- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"Scoops Reader";
    azureSession = [AzureSession sharedAzureSession];
    [self getHeadlines];
}
*/

-(void)loadView {
    [super loadView];
    self.activityIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
    self.activityIndicator.color = [UIColor darkGrayColor];
    [self.view addSubview:self.activityIndicator];
    self.activityIndicator.center = CGPointMake(self.view.frame.size.width / 2, self.view.frame.size.height / 2);
    [self.activityIndicator startAnimating];
}

- (void) viewWillAppear:(BOOL)animated {
    
    [super viewWillAppear:animated];
    //[self populateModelFromAzure];
    //[self getHeadlines];
    [self addReloadScoopsButton];
}


#pragma mark - modelo
/*- (void)populateModelFromAzure{
    
    self.scoops = [[NSMutableArray alloc] init];
    [self.scoops removeAllObjects];
    
    MSClient *client = [azureSession client];
    
    MSTable *table = [client tableWithName:@"news"];
    MSQuery *queryModel = [[MSQuery alloc]initWithTable:table];
    [queryModel orderByDescending:@"creationDate"];
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
            scoop.rating = [item[@"valoracion"] integerValue];
        }
        [self.tableView reloadData];
    }];
}
*/

- (void) getHeadlines {
    
    self.scoops = [[NSMutableArray alloc] init];
    [self.scoops removeAllObjects];
    
    MSClient *client = [azureSession client];
    
    [client invokeAPI:@"getheadlines"
                 body:nil
           HTTPMethod:@"GET"
           parameters:nil
              headers:nil
           completion:^(id result, NSHTTPURLResponse *response, NSError *error) {
               if ([result count]>0) {
                   for (id item in result) {
                       Scoop *scoop = [[Scoop alloc] init];
                       scoop.id = item[@"id"];
                       scoop.title = item[@"title"];
                       scoop.authorName = item[@"authorName"];
                       scoop.imageURL = item[@"imageurl"];
                       scoop.downloaded = NO;
                       [self.scoops addObject:scoop];
                   }
                   [self.tableView reloadData];
               } else {
                   [self.activityIndicator stopAnimating];
               }
    }];

}


- (void) addReloadScoopsButton {
    
    // Add the reload Scoops button
    UIBarButtonItem *reloadScoops = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemRefresh
                                                                              target:self
                                                                              action:@selector(getHeadlines)];
    self.navigationItem.leftBarButtonItem = reloadScoops;
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
    //cell.imageView.image = scoop.image;
    
    //[self downloadScoopImage: scoop.imageURL];
    
    NSLog(@"LastPathComponent: %@", [scoop.imageURL lastPathComponent]);
    
    MSClient *client = [azureSession client];
    NSDictionary *parameters = @{@"containerName" : @"scoops",
                                 @"blobName" : [scoop.imageURL lastPathComponent]};
    
    [client invokeAPI:@"getsasurlforblob" body:nil HTTPMethod:@"GET" parameters:parameters headers:nil completion:^(id result, NSHTTPURLResponse *response, NSError *error) {
        
        if (!error) {
            
            NSURL *imageSasURL = [NSURL URLWithString:[result objectForKey:@"sasUrl"]];
            [self handleSaSURLToDownload:imageSasURL
                     completionHandleSaS:^(id result, NSError *error) {
                         NSLog(@"Descarga del storage completa");
                         scoop.image = result;
                         cell.imageView.image = result;
                         [cell setNeedsLayout];
                     }];
        } else {
            NSLog(@"Error: %@", error);
        }
    }];
    
    
    cell.textLabel.text = scoop.title;
    cell.detailTextLabel.text = scoop.authorName;
    
    // Devolver
    return cell;
}


- (void)handleSaSURLToDownload:(NSURL *)theUrl completionHandleSaS:(void (^)(id result, NSError *error))completion{
    
    NSMutableURLRequest * request = [NSMutableURLRequest requestWithURL:theUrl];
    
    [request setHTTPMethod:@"GET"];
    [request setValue:@"image/jpeg" forHTTPHeaderField:@"Content-Type"];
    
    NSURLSessionDownloadTask * downloadTask = [[NSURLSession sharedSession]downloadTaskWithRequest:request completionHandler:^(NSURL *location, NSURLResponse *response, NSError *error) {
        
        if (!error) {
            
            UIImage *image = [UIImage imageWithData:[NSData dataWithContentsOfURL:location]];
            completion(image, error);
        }
    }];
    [downloadTask resume];
    
}


#pragma mark - Table view delegate

// In a xib-based application, navigation from a table can be handled in -tableView:didSelectRowAtIndexPath:
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    // Averiguar el scoop
    Scoop *scoop = scoop = [self.scoops objectAtIndex:indexPath.row];
    
    ScoopViewController *sVC = [[ScoopViewController alloc] initWithScoop:scoop];
    [self.navigationController pushViewController:sVC animated:YES];
}


-(void) tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if([indexPath row] == ((NSIndexPath*)[[tableView indexPathsForVisibleRows] lastObject]).row){
        [self.activityIndicator stopAnimating];
    }
}



@end
