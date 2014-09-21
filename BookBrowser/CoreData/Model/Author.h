//
//  Author.h
//  BookBrowser
//
//  Created by Said Marouf on 9/20/14.
//
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Book;

@interface Author : NSManagedObject

@property (nonatomic, retain) NSString * firstName;
@property (nonatomic, retain) NSString * lastName;
@property (nonatomic, retain) NSSet *auth_book;

+ (NSString *) entityName;

@end

@interface Author (CoreDataGeneratedAccessors)

- (void)addAuth_bookObject:(Book *)value;
- (void)removeAuth_bookObject:(Book *)value;
- (void)addAuth_book:(NSSet *)values;
- (void)removeAuth_book:(NSSet *)values;

@end
