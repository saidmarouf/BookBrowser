//
//  CoreDataHelper.h
//  BookBrowser
//
//  Created by Said Marouf on 9/21/14.
//
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Book;

@interface CoreDataHelper : NSObject

@property (strong, nonatomic) NSManagedObjectContext *managedObjectContext;

- (instancetype) initWithManagedObjectContext:(NSManagedObjectContext *)managedObjectContext;

- (Book *) persistBookFromDictionary:(NSDictionary *)bookInfo
                              pageID:(NSUInteger)pageID
                               order:(NSUInteger)bookLocalOrder;
- (void) deleteBooksForPageID:(NSUInteger)pageID;

extern NSString * const bookTitleKey;
extern NSString * const bookAuthorKey;

@end
