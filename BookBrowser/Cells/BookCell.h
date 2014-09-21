//
//  BookCellCollectionViewCell.h
//  BookBrowser
//
//  Created by Said Marouf on 9/18/14.
//
//

#import <UIKit/UIKit.h>

@class Book;

@interface BookCell : UICollectionViewCell

@property (nonatomic, weak) Book *book;

@end
