//
//  GDorisPhotoAlbumCell.m
//  GDoris
//
//  Created by GIKI on 2018/8/13.
//  Copyright © 2018年 GIKI. All rights reserved.
//

#import "GDorisPhotoAlbumCell.h"

@interface GDorisPhotoAlbumCell ()
@property (nonatomic, strong) UIImageView * photoView;
@property (nonatomic, strong) UILabel * titleLabel;
@property (nonatomic, strong) UILabel * subTitleLabel;
@property (nonatomic, strong) UIView * line;
@end

@implementation GDorisPhotoAlbumCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(nullable NSString *)reuseIdentifier
{
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        [self.contentView addSubview:({
            _photoView = [UIImageView new];
            _photoView;
        })];
        [self.contentView addSubview:({
            _titleLabel = [UILabel new];
            _titleLabel.textColor = [UIColor blackColor];
            _titleLabel.font = [UIFont boldSystemFontOfSize:17];
            _titleLabel;
        })];
        [self.contentView addSubview:({
            _subTitleLabel = [UILabel new];
            _subTitleLabel.textColor = [UIColor lightGrayColor];
            _subTitleLabel.font = [UIFont systemFontOfSize:14];
            _subTitleLabel;
        })];
        [self.contentView addSubview:({
            _line = [UIView new];
            _line.backgroundColor = GDorisColorCreate(@"ededed");
            _line;
        })];
        self.accessoryType  = UITableViewCellAccessoryDisclosureIndicator;
    }
    return self;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    CGFloat cellW = self.frame.size.width;
    CGFloat cellH = self.frame.size.height;
    
    CGSize psize = {56,56};
    CGFloat pleft = 11;
    CGFloat ptop = (cellH - psize.height)*0.5;
    CGRect pRect = {{pleft,ptop},psize};
    self.photoView.frame = pRect;
    
    self.titleLabel.frame = CGRectMake(CGRectGetMaxX(self.photoView.frame)+20, CGRectGetMinY(self.photoView.frame)+4, cellW-CGRectGetMaxX(self.photoView.frame)-25-50, 22);
    self.subTitleLabel.frame = CGRectMake(CGRectGetMaxX(self.photoView.frame)+20, CGRectGetMaxY(self.titleLabel.frame)+4, CGRectGetWidth(self.titleLabel.frame), 22);
    CGFloat lineHeight = 1/[UIScreen mainScreen].scale;
    self.line.frame = CGRectMake(15, self.contentView.frame.size.height-lineHeight, self.frame.size.width-15, lineHeight);
}

- (void)configCollectionModel:(GDorisCollection*)collection
{
    self.photoView.image = collection.coverImage;
    NSString * collectionName = collection.name;
    self.titleLabel.text = collectionName;
    NSInteger collectionCount = collection.count;
    self.subTitleLabel.text = [NSString stringWithFormat:@"（%ld）",(long)collectionCount];
}

@end
