//
//  BookEngine.m
//  BookBrowser
//
//  Created by Said Marouf on 9/18/14.
//
//

#import "BookEngine.h"
#import "Helpers.h"
#import "Book.h"

NSUInteger const defaultBookCount = 24;

static NSString *baseUrl = @"http://turbine-production-eu.herokuapp.com:80";

@implementation BookEngine

+ (instancetype) sharedEngine {
    static BookEngine *engine = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        engine = [[self alloc] init];
    });
    
    return engine;
}

- (NSURLSessionDataTask *) booksForCategory:(NSString *)bookID
                     page:(NSUInteger)page
                    count:(NSUInteger)count
          completionBlock:(void(^)(NSArray *books))completionBlock
               errorBlock:(void(^)(NSError *error))errorBlock {
    
    if(!bookID || bookID.length == 0) {
        NSString *errorDescription = [NSString stringWithFormat:@"Invalid Book ID"];
        NSError *error = [NSError errorWithDomain:NSStringFromClass([self class]) code:0 userInfo:@{NSLocalizedDescriptionKey : errorDescription}];
        if(errorBlock)
            errorBlock(error);
        return nil;
    }
    
    NSMutableString *targetUrlString = [NSMutableString stringWithFormat:@"%@/%@/%@/%@",
                                        baseUrl,
                                        @"categories",
                                        [Helpers encodURLParameterString:bookID],
                                        @"books"];

    NSMutableArray *parameters = [[NSMutableArray alloc] init];
    if(page > 0) {
        NSString *param = [NSString stringWithFormat:@"page=%lu", page];
        [parameters addObject:param];
    }
    if(count > 0) {
        NSString *param = [NSString stringWithFormat:@"per_page=%lu", count];
        [parameters addObject:param];
    }
    if([parameters count]) {
        NSString *urlParams = [parameters componentsJoinedByString:@"&"];
        [targetUrlString appendFormat:@"?%@", urlParams];
    }
    
    NSURL *targetURL = [NSURL URLWithString:targetUrlString];
    
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:targetURL cachePolicy:NSURLRequestReloadIgnoringLocalCacheData timeoutInterval:60];
    
    NSURLSessionConfiguration *sessionConfiguration = [NSURLSessionConfiguration defaultSessionConfiguration];
    NSURLSession *session = [NSURLSession sessionWithConfiguration:sessionConfiguration];
    
    NSURLSessionDataTask *task = [session dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        
        if (error && errorBlock) {
            errorBlock(error);
            return;
        }
        
        //JSON.....
        NSError *jsonError = nil;
        NSArray *booksData = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:&jsonError];
        if(jsonError && errorBlock) {
            if (jsonError && errorBlock)
                errorBlock(jsonError);
        }
        else {
            
            if(booksData && [booksData isKindOfClass:[NSArray class]]) {
                if(completionBlock) {
                    if(completionBlock)
                        completionBlock(booksData);
                }
            }
            else {
                if(errorBlock)
                    dispatch_async(dispatch_get_main_queue(), ^{
                        errorBlock(jsonError);
                    });
            }
        }
    }];
    
    [task resume];
    
    return task;
}

- (NSURLSessionDataTask *) booksForCategory:(NSString *)bookID
          completionBlock:(void(^)(NSArray *books))completionBlock
               errorBlock:(void(^)(NSError *error))errorBlock {
    
    return [self booksForCategory:bookID
                      page:1
                     count:defaultBookCount
           completionBlock:completionBlock
                errorBlock:errorBlock];
    
}

@end
