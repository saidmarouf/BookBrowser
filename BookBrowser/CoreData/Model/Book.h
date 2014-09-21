//
//  Book.h
//  BookBrowser
//
//  Created by Said Marouf on 9/20/14.
//
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Author;

@interface Book : NSManagedObject

@property (nonatomic, retain) NSString * bookUnifiedAuthor;
@property (nonatomic, retain) NSString * bookTitle;
@property (nonatomic, retain) NSNumber * pageID;
@property (nonatomic, retain) NSNumber * localOrderIndex;
@property (nonatomic, retain) NSSet *book_auth;

+ (NSString *) entityName;

@end

@interface Book (CoreDataGeneratedAccessors)

- (void)addBook_authObject:(Author *)value;
- (void)removeBook_authObject:(Author *)value;
- (void)addBook_auth:(NSSet *)values;
- (void)removeBook_auth:(NSSet *)values;

@end
