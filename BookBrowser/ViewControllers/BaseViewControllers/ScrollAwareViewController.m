//
//  ContinuousLoadingViewController.m
//  BookBrowser
//
//  Created by Said Marouf on 9/18/14.
//
//

#import "ScrollAwareViewController.h"

@interface ScrollAwareViewController ()

@end


@implementation ScrollAwareViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
 Detect when we reach bottom of CollectionView
 */
- (void) scrollViewDidScroll:(UIScrollView *)scrollView {
    
    if(scrollView.contentSize.height <= scrollView.bounds.size.height)
        return;
    
    NSInteger scrollOffset = scrollView.contentOffset.y;
    NSInteger h = scrollView.contentSize.height - scrollView.bounds.size.height;
    if(scrollOffset >= (h - 20)) {
        if([self respondsToSelector:@selector(loadMoreItems)])
            [self performSelector:@selector(loadMoreItems) withObject:nil afterDelay:0.0];
    }
}

- (void) loadMoreItems {
}

@end
