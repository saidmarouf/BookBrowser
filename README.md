#BookBrowser

Endless Scrolling UICollectionView with CoreData


Demonstrates the use of a `UICollectionView` that is backed by CoreData and which allows for endless scrolling i.e. loads more items when reaching the bottom of the `UICollectionView`. The application interacts with a RESTful API to download a number of books. These books are cached within CoreData for viewing on initial load and whenever the API or user is offline.


###Endless Scrolling

The scrolling of the `UICollectionView` is tracked, and whenever it reaches the bottom an API request is made to load more books. If the API fails, more items are loaded via CoreData.


###API Interactions
The BookEngine class provides the interfaces to the API. Contains two main methods:

```
- (NSURLSessionDataTask *) booksForCategory:(NSString *)categoryID
                     page:(NSUInteger)page
                    count:(NSUInteger)count
          completionBlock:(void(^)(NSArray *books))completionBlock
               errorBlock:(void(^)(NSError *error))errorBlock;
```
this method gets books for a certain `categoryID` adjusted by the `page` and `count` parameters. Responses are passed back via blocks.


```
- (NSURLSessionDataTask *) booksForCategory:(NSString *)categoryID
          completionBlock:(void(^)(NSArray *books))completionBlock
               errorBlock:(void(^)(NSError *error))errorBlock;
```
this second method gets books for a certain `categoryID` using default `page` and `count` parameters.


##CoreData

### The Model
For the sake of this assignment, our model contains 2 entities: `Book` and `Author`.
An important attribute within the `Book` entity is called `pageID` which is used to map a book to a certain page. This is useful when loading more books from our cache.
Another important attribute is the `localOrderIndex` which is used to order books of the same page.. this was used so that the order of the books matches the order they were fetched at from the API. 
This provides a better experience as users will not get a different order each time.
Both attributes are used within our sort descriptors and predicates.
