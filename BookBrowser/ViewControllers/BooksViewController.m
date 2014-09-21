//
//  ViewController.m
//  BookBrowser
//
//  Created by Said Marouf on 9/18/14.
//
//

#import "BooksViewController.h"
#import "BookCell.h"
#import "LoadingCell.h"
#import "Book.h"
#import "Author.h"
#import "BookEngine.h"
#import "AppDelegate.h"
#import "CoreDataHelper.h"
#import "Helpers.h"

NSUInteger const collectionViewSpacing = 10;

@interface BooksViewController ()

@property (nonatomic, strong) BookEngine *bookEngine; //Could move to more centralized place in more complex xamples
@property (nonatomic, strong) NSURLSessionDataTask *currentTask;
@property (nonatomic, assign) NSUInteger currentPage;
@property (nonatomic, strong) CoreDataHelper *coreDataHelper;

- (LoadingCell *) loaderCell;
- (void) stopLoaderCell;
- (void) startLoaderCell;
- (void) preAPI;
- (void) postAPI;
- (void) resetCurrentPage;
- (void) updateCurrentPage;

- (NSUInteger) itemCount;
- (void) fetchMoreItemsFromCache;

@end


@implementation BooksViewController

static NSString *bookCellIdentifier = @"bookCell";
static NSString *loadingCellIdentifier = @"loadingCell";
static NSString *testCategoryID = @"Wma8RpqpC6UcWye2U8qUg-6a21w";

- (void) dealloc {
    _collectionView.delegate = nil;
    _collectionView.dataSource = nil;
    
    _fetchedResultsController.delegate = nil;
    
    if(_currentTask) {
        [_currentTask cancel];
        _currentTask = nil;
    }
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    CGRect vcBounds = self.view.bounds;
    
    UICollectionViewFlowLayout *flowLayout = [[UICollectionViewFlowLayout alloc] init];
    [flowLayout setScrollDirection:UICollectionViewScrollDirectionVertical];
    
    _collectionView = [[UICollectionView alloc] initWithFrame:vcBounds collectionViewLayout:flowLayout];
    [_collectionView setAutoresizingMask:UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight];
    [_collectionView setBackgroundColor:[UIColor whiteColor]];
    [_collectionView registerClass:[BookCell class] forCellWithReuseIdentifier:bookCellIdentifier];
    [_collectionView registerClass:[LoadingCell class] forCellWithReuseIdentifier:loadingCellIdentifier];
    _collectionView.dataSource = self;
    _collectionView.delegate = self;
    [self.view addSubview:_collectionView];
    
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemRefresh target:self action:@selector(refreshBooks)];
    self.title = @"Books";
    
    //Helpers
    _coreDataHelper = [[CoreDataHelper alloc] initWithManagedObjectContext:self.managedObjectContext];
    
    //Setup for API
    _bookEngine = [BookEngine sharedEngine];
    
    //Preload stored books for this category..
    //TODO: background execution solution needed...
    [self resetCurrentPage];
    [self preloadData];
    
    //Refresh our cached books from API
    [self refreshBooks];
}

- (void) viewDidAppear:(BOOL)animated {
    //Try if empty - assume categories should have some books.
    if([self itemCount] == 0)
        [self refreshBooks];
}


#pragma mark - CollectionView DataSource

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return [self itemCount] + 1;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    //Check if cell should be the loader.
    if(indexPath.row == [self itemCount]) {
        LoadingCell *loadingCell = [collectionView dequeueReusableCellWithReuseIdentifier:loadingCellIdentifier forIndexPath:indexPath];
        return loadingCell;
    }
    
    //Otherwise - Use BookCell
    BookCell *bookCell = [collectionView dequeueReusableCellWithReuseIdentifier:bookCellIdentifier forIndexPath:indexPath];
    
    Book *b = [self.fetchedResultsController objectAtIndexPath:indexPath];
    [bookCell setBook:b];
    
    return bookCell;
}


#pragma mark - CollectionView Delegate

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    NSInteger numberOfItems = [self itemCount];
    if(indexPath.row == numberOfItems) {
        return CGSizeMake(CGRectGetWidth(self.view.bounds) - 2*collectionViewSpacing, 42);
    }
    //Could cache cell sizes for better performance.
    return [Helpers cellSizeForViewController:self];
}

- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout insetForSectionAtIndex:(NSInteger)section {
    return UIEdgeInsetsMake(collectionViewSpacing, collectionViewSpacing, collectionViewSpacing, collectionViewSpacing);
}


#pragma mark - NSFetchResultsController delegate

- (void) controllerDidChangeContent:(NSFetchedResultsController *)controller {
    
    //We can fancy up things by tracking changes and later updating the collectionview using performBatchUpdates
    [_collectionView reloadData];
    [_collectionView.collectionViewLayout invalidateLayout];
}

- (NSUInteger) itemCount {
    return [[[self.fetchedResultsController sections] objectAtIndex:0] numberOfObjects];
}


#pragma mark - API

//This removes all older elements and reloads new ones
//This will also replace/update the preloaded books from Core Data.
- (void) refreshBooks {
    
    if(_currentTask)
        return;
    
    [self resetCurrentPage]; //reset...
    
    self.title = @"Updating Category..."; //This is for the sake of testing.
    [self preAPI];
    
    _currentTask = [_bookEngine booksForCategory:testCategoryID completionBlock:^(NSArray *books) {
        
        if(books && [books count]) {
            
            dispatch_async(dispatch_get_main_queue(), ^{
                
                //remove Books with pageID = _currentPage
                //will be replaced by following books.
                //This is to keep books up to date and keep other pages available as long as they have not been updated via the API.
                //Note we only delete older books if we have gotton a new set of books for a certain pageID.
                [_coreDataHelper deleteBooksForPageID:_currentPage];
                
                NSUInteger localOrder = 0; //used to keep order within books of certain pageID.
                for(NSDictionary *bookInfo in books) {
                    if([_coreDataHelper persistBookFromDictionary:bookInfo pageID:_currentPage order:localOrder])
                        localOrder++;
                }
                
                [self preloadData]; //preload after our refresh
                [_collectionView reloadData];
                [_collectionView.collectionViewLayout invalidateLayout];
                [_collectionView scrollToItemAtIndexPath:[NSIndexPath indexPathForItem:0 inSection:0] atScrollPosition:UICollectionViewScrollPositionTop animated:YES];
            });
        }
        
        [self postAPI];
        
    } errorBlock:^(NSError *error) {
        NSLog(@"Error:  %@", error);
        if([error code] == -1009)
            NSLog(@"No Internet!!");
        
        [self postAPI];
    }];
}

//Loads more items and attaches to the bottom of the collection view as we scroll to the bottom.
- (void) loadMoreItems {
    
    if(_currentTask)
        return;
    
    self.title = @"Loading More...";
    [self preAPI];
    
    _currentTask = [_bookEngine booksForCategory:testCategoryID page:_currentPage count:defaultBookCount completionBlock:^(NSArray *books) {
        
        if(books) {
            dispatch_async(dispatch_get_main_queue(), ^{
                
                [_coreDataHelper deleteBooksForPageID:_currentPage];
                
                NSUInteger localOrder = 0; //used to keep order within books of certain pageID.
                for(NSDictionary *bookInfo in books) {
                    if([_coreDataHelper persistBookFromDictionary:bookInfo pageID:_currentPage order:localOrder])
                        localOrder++;
                }
                
                [self updateCurrentPage];
            });
        }
        else {
            //try loading cached ones instead..
            dispatch_async(dispatch_get_main_queue(), ^{
                [self fetchMoreItemsFromCache];
            });
        }
        
        [self postAPI];
        
    } errorBlock:^(NSError *error) {
        //try loading cached books if API fails
        dispatch_async(dispatch_get_main_queue(), ^{
            [self fetchMoreItemsFromCache];
        });
        
        _currentTask = nil;
        [self postAPI];
    }];
}

- (void) postAPI {
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.navigationItem.rightBarButtonItem setEnabled:YES];
        [self stopLoaderCell];
        
        self.title = @"Books"; //Just for testing
        _currentTask = nil;
    });
}

- (void) preAPI {
    [self.navigationItem.rightBarButtonItem setEnabled:NO];
    [self startLoaderCell];
}

- (void) resetCurrentPage {
    _currentPage = 1;
}

- (void) updateCurrentPage {
    _currentPage++;
}


#pragma mark - Core Data

- (void) fetchMoreItemsFromCache {
    
    [_fetchedResultsController.fetchRequest setFetchLimit:_currentPage*defaultBookCount];
    
    NSError *error;
    if([_fetchedResultsController performFetch:&error]) {
        [self updateCurrentPage];
        [_collectionView reloadData];
        [_collectionView.collectionViewLayout invalidateLayout];
    }
    else {
        NSLog(@"Error: %@", error);
    }
}

- (void) preloadData {
    
    [_fetchedResultsController.fetchRequest setFetchLimit:defaultBookCount];
    
    NSError *error;
    if(![self.fetchedResultsController performFetch:&error])
        NSLog(@"Error fetching results %@", error);
    
    [self updateCurrentPage];
}

- (NSFetchedResultsController *) fetchedResultsController {
    
    if(_fetchedResultsController)
        return _fetchedResultsController;
    
    //Initial Batch of Books returned with the initialization of our NSFetchedResultsController
    
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *bookEntity = [NSEntityDescription entityForName:[Book entityName] inManagedObjectContext:_managedObjectContext];
    [fetchRequest setEntity:bookEntity];
    
    [fetchRequest setFetchBatchSize:defaultBookCount];
    [fetchRequest setFetchLimit:defaultBookCount];
    
    // We will sort by our pageID attribute - just for the sake of this example and assignment and provided API.
    NSSortDescriptor *pageIDSortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"pageID" ascending:YES];
    NSSortDescriptor *orderSortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"localOrderIndex" ascending:YES];
    
    [fetchRequest setSortDescriptors:[NSArray arrayWithObjects:pageIDSortDescriptor, orderSortDescriptor, nil]];
    
    _fetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest managedObjectContext:_managedObjectContext sectionNameKeyPath:nil cacheName:nil];
    _fetchedResultsController.delegate = self;
    
    return _fetchedResultsController;
}


#pragma mark - Cell Helpers

- (void) stopLoaderCell {
    LoadingCell *cell = [self loaderCell];
    if(cell)
        [cell stopIndicators];
}

- (void) startLoaderCell {
    LoadingCell *cell = [self loaderCell];
    if(cell)
        [cell startIndicators];
}

- (LoadingCell *) loaderCell {
    NSInteger numberOfItems = [self itemCount];
    LoadingCell *cell = (LoadingCell *)[_collectionView cellForItemAtIndexPath:[NSIndexPath indexPathForItem:numberOfItems inSection:0]];
    return cell;
}

- (void) viewWillTransitionToSize:(CGSize)size withTransitionCoordinator:(id<UIViewControllerTransitionCoordinator>)coordinator {
    [_collectionView.collectionViewLayout invalidateLayout];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
