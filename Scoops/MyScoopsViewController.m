//
//  MyScoopsViewController.m
//  Scoops
//
//  Created by Miguel Angel Vélez Serrano on 26/4/15.
//  Copyright (c) 2015 Miguel Ángel Vélez Serrano. All rights reserved.
//

#import "MyScoopsViewController.h"
#import "MyScoopViewController.h"
#import "Scoop.h"

@interface MyScoopsViewController ()

@property (strong, nonatomic) NSMutableArray *scoopsPublished;
@property (strong, nonatomic) NSMutableArray *scoopsNotPublished;
@property (nonatomic) BOOL showPublished;

@end

@implementation MyScoopsViewController

- (id) initWithScoops: (NSArray *) arrayOfScoops {
    
    if (self = [super initWithNibName:nil bundle:nil]) {
        _arrayOfMyScoops = [[NSArray alloc] initWithArray:arrayOfScoops];
        _scoopsPublished = [[NSMutableArray alloc] init];
        _scoopsNotPublished = [[NSMutableArray alloc] init];
        for (Scoop *scoop in arrayOfScoops) {
            if (scoop.published) {
                [_scoopsPublished addObject:scoop];
            } else {
                [_scoopsNotPublished addObject:scoop];
            }
        }
        _showPublished = YES;
    }
    
    return self;
}


- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)segmentedControlAction:(id)sender {
    
    if(self.segmentedControl.selectedSegmentIndex == 0) {
        // Noticias publicadas
        NSLog(@"Noticias publicadas!!!");
        self.showPublished = YES;
    } else {
        // Noticias No publicadas
        NSLog(@"Noticias NO publicadas!!!");
        self.showPublished = NO;
    }
    
    [self.scoopsTableView reloadData];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    if(self.showPublished) {
        // Noticias publicadas
        return [self.scoopsPublished count];
    } else {
        // Noticias No publicadas
        return [self.scoopsNotPublished count];
    }
    
}


- (UITableViewCell *)tableView:(UITableView *)tableView
         cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    // Averiguar el scoop
    Scoop *scoop = nil;
    if (self.showPublished) {
        scoop = [self.scoopsPublished objectAtIndex:indexPath.row];
    } else {
        scoop = [self.scoopsNotPublished objectAtIndex:indexPath.row];
    }
    
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
    cell.detailTextLabel.text = scoop.author;
    
    // Devolver
    return cell;
}


#pragma mark - Table view delegate

-(void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
    NSLog(@"didSelectRow");
    
    // Averiguar el scoop
    Scoop *scoop = nil;
    if (self.showPublished) {
        scoop = [self.scoopsPublished objectAtIndex:indexPath.row];
    } else {
        scoop = [self.scoopsNotPublished objectAtIndex:indexPath.row];
    }
    
    MyScoopViewController *sVC = [[MyScoopViewController alloc] initWithScoop:scoop];
    [self.navigationController pushViewController:sVC animated:YES];
}

















@end
