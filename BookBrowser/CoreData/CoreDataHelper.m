//
//  CoreDataHelper.m
//  BookBrowser
//
//  Created by Said Marouf on 9/21/14.
//
//

#import "CoreDataHelper.h"
#import "Book.h"
#import "Author.h"

NSString * const bookTitleKey = @"title";
NSString * const bookAuthorKey = @"author";

@implementation CoreDataHelper

- (instancetype) initWithManagedObjectContext:(NSManagedObjectContext *)managedObjectContext {
    self = [super init];
    if(self) {
        
        _managedObjectContext = managedObjectContext;
    }
    return self;
}

- (Book *) persistBookFromDictionary:(NSDictionary *)bookInfo
                              pageID:(NSUInteger)pageID
                               order:(NSUInteger)bookLocalOrder {
    
    NSString *bookTitle = [bookInfo valueForKey:bookTitleKey];
    NSString *bookUnifiedAuthor = [bookInfo valueForKey:bookAuthorKey];
    NSArray *authors = [bookInfo objectForKey:@"authors"];
    
    Book *bookEntity = nil;
    if(bookTitle) {
        bookEntity = (Book *)[NSEntityDescription insertNewObjectForEntityForName:[Book entityName] inManagedObjectContext:_managedObjectContext];
        
        //Track api page book belongs to.
        //Allows for flexible fetching of more books when scrolling down.
        //This solution is based on the provided API and that there is no ordering provided by the API
        //I would like to identify which portion of books from this category to fetch.
        //
        [bookEntity setValue:@(pageID) forKey:@"pageID"];
        
        [bookEntity setValue:@(bookLocalOrder) forKey:@"localOrderIndex"];
        
        [bookEntity setValue:[bookTitle stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]] forKey:@"bookTitle"];
        
        if(bookUnifiedAuthor && bookUnifiedAuthor.length > 0)
            [bookEntity setValue:[bookUnifiedAuthor stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]] forKey:@"bookUnifiedAuthor"];
    }
    
    if(authors && [authors isKindOfClass:[NSArray class]] && [authors count]) {
        for(NSDictionary *author in authors) {
            
            NSString *authorFirstName = [author valueForKey:@"firstName"];
            NSString *authorLastName = [author valueForKey:@"lastName"];
            
            if(authorFirstName)
                authorFirstName = [authorFirstName stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
            if(authorLastName)
                authorLastName = [authorLastName stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
            
            if(authorFirstName.length > 0 && authorLastName.length > 0) {
                Author *authorEntity = (Author *)[NSEntityDescription insertNewObjectForEntityForName:[Author entityName] inManagedObjectContext:_managedObjectContext];
                [authorEntity setValue:authorFirstName forKey:@"firstName"];
                [authorEntity setValue:authorLastName forKey:@"lastName"];
                
                if(bookEntity)
                    [bookEntity addBook_authObject:authorEntity]; //this should add book to auth too.. right?
            }
        }
    }
    
    return bookEntity;
}

- (void) deleteBooksForPageID:(NSUInteger)pageID {
    
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] initWithEntityName:[Book entityName]];
    [fetchRequest setPredicate:[NSPredicate predicateWithFormat:@"pageID=%ld", pageID]];
    [fetchRequest setIncludesPropertyValues:NO]; //avoid loading all attribute data
    
    NSError *error;
    NSArray *booksForPageID = [_managedObjectContext executeFetchRequest:fetchRequest error:&error];
    for (NSManagedObject *book in booksForPageID)
        [_managedObjectContext deleteObject:book];
}

@end
