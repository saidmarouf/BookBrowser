//
//  BookEngine.h
//  BookBrowser
//
//  Created by Said Marouf on 9/18/14.
//
//

#import <Foundation/Foundation.h>

@interface BookEngine : NSObject

+ (instancetype) sharedEngine;

/*
 Returns books for a category with passed page and per_page values
 */
- (NSURLSessionDataTask *) booksForCategory:(NSString *)bookID
                     page:(NSUInteger)page
                    count:(NSUInteger)count
          completionBlock:(void(^)(NSArray *books))completionBlock
               errorBlock:(void(^)(NSError *error))errorBlock;


/*
 Returns books for a category using the default page and per_page values
 */

- (NSURLSessionDataTask *) booksForCategory:(NSString *)bookID
          completionBlock:(void(^)(NSArray *books))completionBlock
               errorBlock:(void(^)(NSError *error))errorBlock;

extern NSUInteger const defaultBookCount;

@end
