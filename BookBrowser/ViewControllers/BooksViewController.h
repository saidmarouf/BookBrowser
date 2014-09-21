//
//  ViewController.h
//  BookBrowser
//
//  Created by Said Marouf on 9/18/14.
//
//

#import <UIKit/UIKit.h>
#import <CoreData/CoreData.h>
#import "ScrollAwareViewController.h"

@interface BooksViewController : ScrollAwareViewController <UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, NSFetchedResultsControllerDelegate>

@property (nonatomic, strong) UICollectionView *collectionView;
@property (strong, nonatomic) NSManagedObjectContext *managedObjectContext;
@property (strong, nonatomic) NSFetchedResultsController *fetchedResultsController;

- (void) refreshBooks;

extern NSUInteger const collectionViewSpacing;

@end

