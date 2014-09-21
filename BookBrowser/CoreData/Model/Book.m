//
//  Book.m
//  BookBrowser
//
//  Created by Said Marouf on 9/20/14.
//
//

#import "Book.h"
#import "Author.h"


@implementation Book

@dynamic bookUnifiedAuthor;
@dynamic bookTitle;
@dynamic pageID;
@dynamic localOrderIndex;
@dynamic book_auth;

+ (NSString *) entityName {
    return @"Book";
}

@end
