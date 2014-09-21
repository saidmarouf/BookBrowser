//
//  Author.m
//  BookBrowser
//
//  Created by Said Marouf on 9/20/14.
//
//

#import "Author.h"
#import "Book.h"


@implementation Author

@dynamic firstName;
@dynamic lastName;
@dynamic auth_book;

+ (NSString *) entityName {
    return @"Author";
}

@end
