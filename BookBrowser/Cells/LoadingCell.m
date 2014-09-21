//
//  LoadingCollectionViewCell.m
//  BookBrowser
//
//  Created by Said Marouf on 9/18/14.
//
//

#import "LoadingCell.h"
#import "Helpers.h"

@interface LoadingCell()

@property (nonatomic, strong) UIActivityIndicatorView *loadingMoreBooksIndicator;

@end


@implementation LoadingCell

- (id)initWithFrame:(CGRect)frame {
    
    self = [super initWithFrame:frame];
    
    if (self) {
        
        [self setBackgroundColor:[UIColor whiteColor]];
        
        _loadingMoreBooksIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
        [_loadingMoreBooksIndicator setHidesWhenStopped:YES];
        [self addSubview:_loadingMoreBooksIndicator];
        
        [_loadingMoreBooksIndicator setTranslatesAutoresizingMaskIntoConstraints:NO];
        [Helpers centerView:_loadingMoreBooksIndicator within:self direction:NSLayoutAttributeCenterX];
        [Helpers centerView:_loadingMoreBooksIndicator within:self direction:NSLayoutAttributeCenterY];
        
        [self startIndicators];
    }
    
    return self;
}

- (void) startIndicators {
    [_loadingMoreBooksIndicator startAnimating];
}

- (void) stopIndicators {
    [_loadingMoreBooksIndicator stopAnimating];
}

@end
