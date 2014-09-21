//
//  BookBrowserTests.m
//  BookBrowserTests
//
//  Created by Said Marouf on 9/18/14.
//
//

#import <UIKit/UIKit.h>
#import <XCTest/XCTest.h>
#import "BooksViewController.h"
#import "LoadingCell.h"
#import "Book.h"
#import "BookEngine.h"
#import "CoreDataHelper.h"
#import "Helpers.h"


/*
 To expose some private methods fro testing...
 */
@interface BooksViewController (Test)
- (void) preloadData;
- (void) resetCurrentPage;

- (NSUInteger) currentPage;
- (BookEngine *) bookEngine;
- (CoreDataHelper *) coreDataHelper;

@end


@interface BookBrowserTests : XCTestCase

@property (weak, nonatomic) BooksViewController *bVC;

@end

@implementation BookBrowserTests

- (void)setUp {
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.

    UINavigationController *navigationController = (UINavigationController *)[[[UIApplication sharedApplication] delegate] window].rootViewController;
    _bVC = (BooksViewController *)navigationController.topViewController;
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
    
    _bVC = nil;
}

- (void)testViewLoaded {
    // This is an example of a functional test case.
    XCTAssert(_bVC.view, @"BookViewController's view not loaded!");
}

- (void) testViewControllerConformsToCollectionViewDelegateProtocol {
    XCTAssertTrue([_bVC conformsToProtocol:@protocol(UICollectionViewDelegateFlowLayout)], @"ViewController does not conform to UICollectionViewDelegateFlowLayout");
}

- (void) testViewControllerConformsToFetchedResultsDelegate {
    XCTAssertTrue([_bVC conformsToProtocol:@protocol(NSFetchedResultsControllerDelegate)], @"ViewController does not conform to NSFetchedResultsControllerDelegate");
}

- (void) testViewControllerConformsToCollectionViewDataSource {
    XCTAssertTrue([_bVC conformsToProtocol:@protocol(UICollectionViewDataSource)], @"ViewController does not conform to UICollectionViewDataSource");
}

- (void) testNumberOfCollectionViewCells {

    NSUInteger expectedNumberOfCells = [[[_bVC.fetchedResultsController sections] objectAtIndex:0] numberOfObjects] + 1;
    NSUInteger actualNumberOfCells = [_bVC.collectionView numberOfItemsInSection:0];
    XCTAssertEqual(expectedNumberOfCells, actualNumberOfCells, @"CollectionView cell number not consistent with fetched results count");
}

- (void) testCalculatedCellSize {

    CGSize calculatedCellSize = [Helpers cellSizeForViewController:_bVC];
    
    XCTAssertGreaterThanOrEqual(calculatedCellSize.width, 0);
    XCTAssertGreaterThanOrEqual(calculatedCellSize.height, 0);
    
    XCTAssertEqual(calculatedCellSize.width, calculatedCellSize.height, @"Cell is Not Square");
}

- (void) testCurrentPageAfterReset {

    NSUInteger expectedCurrentPage = 1;
    [_bVC resetCurrentPage];
    NSUInteger actualCurrentPage = _bVC.currentPage;
    
    XCTAssertEqual(expectedCurrentPage, actualCurrentPage, @"Invalid currentPage after rest");
}

- (void) testDeletionOfBooksForPageID {
    
    /*
     Add a Book with pageID = 1000
     */
    Book *bookEntity = (Book *)[NSEntityDescription insertNewObjectForEntityForName:[Book entityName] inManagedObjectContext:_bVC.managedObjectContext];
    bookEntity.pageID = @(1000);
    bookEntity.bookTitle = @"someTitle";
    
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] initWithEntityName:[Book entityName]];
    [fetchRequest setPredicate:[NSPredicate predicateWithFormat:@"pageID=%ld", 1000]];
    [fetchRequest setIncludesPropertyValues:NO];
    
    /*
     Check Insertion Succeeded
     */
    NSError *error;
    NSArray *booksForPageID = [_bVC.managedObjectContext executeFetchRequest:fetchRequest error:&error];
    XCTAssertGreaterThan([booksForPageID count], 0, @"Must have at least one Book with pageID = 1000");
    
    /*
     Check Deletion Succeeds
     */

    [[_bVC coreDataHelper] deleteBooksForPageID:1000];
    booksForPageID = [_bVC.managedObjectContext executeFetchRequest:fetchRequest error:&error];
    XCTAssertEqual([booksForPageID count], 0, @"All Books with pageID = 1000 should have been deleted!");
}

- (void) testFRCBatchSize {
    NSUInteger expectedBatchSize = 24;
    NSUInteger actualBatchSize = _bVC.fetchedResultsController.fetchRequest.fetchBatchSize;
    XCTAssertEqual(expectedBatchSize, actualBatchSize, @"Batch Size Incorrect");
}

- (void) testAPIResultType {

    /*
     semaphore approach not mine
     */
    dispatch_semaphore_t semaphore = dispatch_semaphore_create(0);

    Class expectedClass = [NSArray class];
    [[_bVC bookEngine] booksForCategory:@"Wma8RpqpC6UcWye2U8qUg-6a21w" completionBlock:^(NSArray *books) {
        XCTAssertTrue([books isKindOfClass:expectedClass], @"Result of API is not an Array!");
        
        dispatch_semaphore_signal(semaphore);

    } errorBlock:^(NSError *error) {
        XCTFail(@"API Error while Unit Testing...");
        dispatch_semaphore_signal(semaphore);
    }];
    
    //willing to wait 3 seconds..
    while(dispatch_semaphore_wait(semaphore, DISPATCH_TIME_NOW))
        [[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode beforeDate:[NSDate dateWithTimeIntervalSinceNow:3]];
}

- (void)testPerformanceExample {
    // This is an example of a performance test case.
    [self measureBlock:^{
        // Put the code you want to measure the time of here.
        [_bVC preloadData];
    }];
}

@end
