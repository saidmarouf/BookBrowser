//
//  ContinuousLoadingViewController.h
//  BookBrowser
//
//  Created by Said Marouf on 9/18/14.
//
//

#import <UIKit/UIKit.h>

@interface ScrollAwareViewController : UIViewController <UIScrollViewDelegate>

- (void) loadMoreItems;

@end
