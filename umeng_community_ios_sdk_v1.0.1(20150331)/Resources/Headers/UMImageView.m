//
//  UMImageView.m
//  UMImageView
//
//  Created by Shaun Harrison on 9/15/09.
//  Copyright (c) 2009-2010 enormego
//  Modifyed by Umeng on 6/6/12
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in
//  all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
//  THE SOFTWARE.
//

#import "UMImageView.h"
#import "UMImageLoader.h"

@implementation UMAnimatedGifFrame

@synthesize data, delay, disposalMethod, area, header;

- (void) dealloc
{
    self.data = nil;
    self.header = nil;
	[super dealloc];
}
@end

@implementation UMImageView
@synthesize imageURL, placeholderImage, delegate;
@synthesize status = _status;
@synthesize isGif = _isGif;

#pragma mark -
#pragma mark AboutGif

// the decoder
// decodes GIF image data into separate frames
// based on the Wikipedia Documentation at:
//
// http://en.wikipedia.org/wiki/Graphics_Interchange_Format#Example_.gif_file
// http://en.wikipedia.org/wiki/Graphics_Interchange_Format#Animated_.gif
//
- (void)decodeGIF:(NSData *)GIFData
{
	GIF_pointer = GIFData;
    
    [self freeBuffer];
	
    GIF_buffer = [[NSMutableData alloc] init];
	GIF_global = [[NSMutableData alloc] init];
	GIF_screen = [[NSMutableData alloc] init];
	GIF_frames = [[NSMutableArray alloc] init];
	
    // Reset file counters to 0
	dataPointer = 0;
	
	[self GIFSkipBytes: 6]; // GIF89a, throw away
	[self GIFGetBytes: 7]; // Logical Screen Descriptor
    
    //add for analytics
    if(GIF_buffer==nil)
    {
        NSLog(@"GIF_buffer is nil");
        return;
    }
	
    // Deep copy
	[GIF_screen setData: GIF_buffer];
	
    // Copy the read bytes into a local buffer on the stack
    // For easy byte access in the following lines.
    int length = (int)[GIF_buffer length];
	unsigned char aBuffer[length];
	[GIF_buffer getBytes:aBuffer length:length];
	
	if (aBuffer[4] & 0x80) GIF_colorF = 1; else GIF_colorF = 0; 
	if (aBuffer[4] & 0x08) GIF_sorted = 1; else GIF_sorted = 0;
	GIF_colorC = (aBuffer[4] & 0x07);
	GIF_colorS = 2 << GIF_colorC;
	
	if (GIF_colorF == 1)
    {
		[self GIFGetBytes: (3 * GIF_colorS)];
        
        // Deep copy
		[GIF_global setData:GIF_buffer];
    }
	
	unsigned char bBuffer[1];
	while ([self GIFGetBytes:1] == YES)
    {
        [GIF_buffer getBytes:bBuffer length:1];
        
        if (bBuffer[0] == 0x3B)
        { // This is the end
                break;
        }
        
        switch (bBuffer[0])
        {
            case 0x21:
            // Graphic Control Extension (#n of n)
            [self GIFReadExtensions];
            break;
            case 0x2C:
            // Image Descriptor (#n of n)
            [self GIFReadDescriptor];
            break;
        }
    }
	
	// clean up stuff
    [self resetBuffer];
}

// 
// Returns a subframe as NSMutableData.
// Returns nil when frame does not exist.
//
// Use this to write a subframe to the filesystems (cache etc);
- (NSData*) getFrameAsDataAtIndex:(int)index
{
	if (index < [GIF_frames count])
    {
		return ((UMAnimatedGifFrame *)[GIF_frames objectAtIndex:index]).data;
    }
	else
    {
		return nil;
    }
}

// 
// Returns a subframe as an autorelease UIImage.
// Returns nil when frame does not exist.
//
// Use this to put a subframe on your GUI.
- (UIImage*) getFrameAsImageAtIndex:(int)index
{
    NSData *frameData = [self getFrameAsDataAtIndex: index];
    UIImage *image = nil;
    
    if (frameData != nil)
    {
		image = [UIImage imageWithData:frameData];
    }
    
    return image;
}

//
// This method converts the arrays of GIF data to an animation, counting
// up all the seperate frame delays, and setting that to the total duration
// since the iPhone Cocoa framework does not allow you to set per frame
// delays.
//
// Returns nil when there are no frames present in the GIF, or
// an autorelease UIImageView* with the animation.
- (void) setAnimationData
{
	if ([GIF_frames count] > 0)
    {
        self.image = [self getFrameAsImageAtIndex:0];
		
		// Add all subframes to the animation
		NSMutableArray *array = [[NSMutableArray alloc] init];
		for (int i = 0; i < [GIF_frames count]; i++)
        {		
            [array addObject: [self getFrameAsImageAtIndex:i]];
        }
		
		NSMutableArray *overlayArray = [[NSMutableArray alloc] init];
		UIImage *firstImage = [array objectAtIndex:0];
		CGSize size = firstImage.size;
		CGRect rect = CGRectZero;
		rect.size = size;
		
		UIGraphicsBeginImageContext(size);
		CGContextRef ctx = UIGraphicsGetCurrentContext();
		
		int i = 0;
		UMAnimatedGifFrame *lastFrame = nil;
		for (UIImage *image in array) 
        {
			UMAnimatedGifFrame *frame = [GIF_frames objectAtIndex:i];
			if (lastFrame) 
            {
				switch (lastFrame.disposalMethod) 
                {
					case 1:
						// Do not dispose
						break;
					case 2:
						// Restore to background color
						CGContextClearRect(ctx, lastFrame.area);
						break;
					case 3:
						// TODO Restore to previous
						break;
				}
			}
			CGContextSaveGState(ctx);
			CGContextScaleCTM(ctx, 1.0, -1.0);
			CGContextTranslateCTM(ctx, 0.0, -size.height);
			CGContextDrawImage(ctx, rect, image.CGImage);
			CGContextRestoreGState(ctx);
			[overlayArray addObject:UIGraphicsGetImageFromCurrentImageContext()];
			lastFrame = frame;
			i++;
		}
		UIGraphicsEndImageContext();
		
		[self setAnimationImages:overlayArray];
		
		[overlayArray release];
        [array release];
		
		// Count up the total delay, since Cocoa doesn't do per frame delays.
		double total = 0;
		for (UMAnimatedGifFrame *frame in GIF_frames) 
        {
			total += frame.delay;
		}
		
		// GIFs store the delays as 1/100th of a second,
        // UIImageViews want it in seconds.
		[self setAnimationDuration:total/100];
		
		// Repeat infinite
		[self setAnimationRepeatCount:0];
		
        [self startAnimating];
        
    }
	else
    {
		NSLog(@"decode gif data is nil,frame is Zero!");
    }
}

- (void)GIFReadExtensions
{
	// 21! But we still could have an Application Extension,
	// so we want to check for the full signature.
	unsigned char cur[1], prev[1];

    memset(cur,0,sizeof(cur));
    memset(prev,0,sizeof(prev));
    
    [self GIFGetBytes:1];
    [GIF_buffer getBytes:cur length:1];
    
	while (cur[0] != 0x00)
    {
		
		// TODO: Known bug, the sequence F9 04 could occur in the Application Extension, we
		//       should check whether this combo follows directly after the 21.
		if ((cur[0] == 0x04) && prev[0] == 0xF9)
        {
			[self GIFGetBytes:5];
            
			UMAnimatedGifFrame *frame = [[UMAnimatedGifFrame alloc] init];
			
			unsigned char buffer[5];
        
            memset(buffer, 0, sizeof(buffer));
        
			[GIF_buffer getBytes:buffer length:5];
			frame.disposalMethod = (buffer[0] & 0x1c) >> 2;
			//NSLog(@"flags=%x, dm=%x", (int)(buffer[0]), frame.disposalMethod);
			
			// We save the delays for easy access.
			frame.delay = (buffer[1] | buffer[2] << 8);
			
			unsigned char board[8];
			board[0] = 0x21;
			board[1] = 0xF9;
			board[2] = 0x04;
			
			for(int i = 3, a = 0; a < 5; i++, a++)
            {
				board[i] = buffer[a];
            }
			
			frame.header = [NSData dataWithBytes:board length:8];
            
			[GIF_frames addObject:frame];
			[frame release];
			break;
        }
		
		prev[0] = cur[0];
        [self GIFGetBytes:1];
		[GIF_buffer getBytes:cur length:1];
    }	
}

- (void) GIFReadDescriptor
{	
	[self GIFGetBytes:9];
    
    // Deep copy
	NSMutableData *GIF_screenTmp = [NSMutableData dataWithData:GIF_buffer];
	
	unsigned char aBuffer[9];
    memset(aBuffer,0,sizeof(aBuffer));
	[GIF_buffer getBytes:aBuffer length:9];
	
	CGRect rect;
	rect.origin.x = ((int)aBuffer[1] << 8) | aBuffer[0];
	rect.origin.y = ((int)aBuffer[3] << 8) | aBuffer[2];
	rect.size.width = ((int)aBuffer[5] << 8) | aBuffer[4];
	rect.size.height = ((int)aBuffer[7] << 8) | aBuffer[6];
    
	UMAnimatedGifFrame *frame = [GIF_frames lastObject];
	frame.area = rect;
	
	if (aBuffer[8] & 0x80)
    {
        GIF_colorF = 1;
    }
    else
    {
        GIF_colorF = 0;
    }
	
	unsigned char GIF_code = GIF_colorC;
    unsigned char GIF_sort = GIF_sorted;
	
	if (GIF_colorF == 1)
    {
		GIF_code = (aBuffer[8] & 0x07);
        
		if (aBuffer[8] & 0x20)
        {
            GIF_sort = 1;
        }
        else
        {
        	GIF_sort = 0;
        }
    }
	
	int GIF_size = (2 << GIF_code);
	
	size_t blength = [GIF_screen length];
	unsigned char bBuffer[blength];
	[GIF_screen getBytes:bBuffer length:blength];
	
	bBuffer[4] = (bBuffer[4] & 0x70);
	bBuffer[4] = (bBuffer[4] | 0x80);
	bBuffer[4] = (bBuffer[4] | GIF_code);
	
	if (GIF_sort)
    {
		bBuffer[4] |= 0x08;
    }
	
    NSMutableData *GIF_string = [NSMutableData dataWithData:[@"GIF89a" dataUsingEncoding: NSUTF8StringEncoding]];
	[GIF_screen setData:[NSData dataWithBytes:bBuffer length:blength]];
    [GIF_string appendData: GIF_screen];
    
	if (GIF_colorF == 1)
    {
		[self GIFGetBytes:(3 * GIF_size)];
		[GIF_string appendData:GIF_buffer];
    }
    else
    {
		[GIF_string appendData:GIF_global];
    }
	
	// Add Graphic Control Extension Frame (for transparancy)
	[GIF_string appendData:frame.header];
	
	char endC = 0x2c;
	[GIF_string appendBytes:&endC length:sizeof(endC)];
	
	size_t clength = [GIF_screenTmp length];
	unsigned char cBuffer[clength];
	[GIF_screenTmp getBytes:cBuffer length:clength];
	
	cBuffer[8] &= 0x40;
	
	[GIF_screenTmp setData:[NSData dataWithBytes:cBuffer length:clength]];
	
	[GIF_string appendData: GIF_screenTmp];
	[self GIFGetBytes:1];
	[GIF_string appendData: GIF_buffer];
	
	while (true)
    {
		[self GIFGetBytes:1];
		[GIF_string appendData: GIF_buffer];
		
		unsigned char dBuffer[1];
    
        memset(dBuffer, 0, sizeof(dBuffer));

    
		[GIF_buffer getBytes:dBuffer length:1];
		
		long u = (long) dBuffer[0];
        
		if (u != 0x00)
        {
			[self GIFGetBytes:(int)u];
			[GIF_string appendData: GIF_buffer];
        }
        else
        {
            break;
        }
        
    }
	
	endC = 0x3b;
	[GIF_string appendBytes:&endC length:sizeof(endC)];
	
	// save the frame into the array of frames
	frame.data = GIF_string;
}

/* Puts (int) length into the GIF_buffer from file, returns whether read was succesfull */
- (bool) GIFGetBytes: (int) length
{
    if (GIF_buffer != nil)
    {
        [GIF_buffer release]; // Release old buffer
        GIF_buffer = nil;
    }
    
	if ([GIF_pointer length] >= dataPointer + length) // Don't read across the edge of the file..
    {
		GIF_buffer = [[NSData dataWithData:[GIF_pointer subdataWithRange:NSMakeRange(dataPointer, length)]] retain];
        dataPointer += length;
		return YES;
    }
    else
    {
        return NO;
    }
}

/* Skips (int) length bytes in the GIF, faster than reading them and throwing them away.. */
- (bool) GIFSkipBytes: (int) length
{
    if ([GIF_pointer length] >= dataPointer + length)
        {
        dataPointer += length;
        return YES;
        }
    else
        {
    	return NO;
        }
    
}

#pragma mark -
#pragma mark UMImageView

- (id)initWithImage:(UIImage *)image
{
    self = [super initWithImage:image];
    
    if(self)
    {
        self.opaque = YES;
        self.isAutoStart = YES;
    }
    
    return self;
}


- (id)initWithPlaceholderImage:(UIImage*)anImage 
{
	return [self initWithPlaceholderImage:anImage delegate:nil];
}

- (id)initWithPlaceholderImage:(UIImage*)anImage delegate:(id<UMImageViewDelegate>)aDelegate 
{
	if((self = [self initWithImage:anImage]))
    {
        self.status = UMImageView_Init;
//        self.hidden = YES;
		self.placeholderImage = anImage;
		self.delegate = aDelegate;
        self.isGif = NO;
        self.isAutoStart = YES;
	}
	
	return self;
}

- (BOOL)isCacheImage
{
    if(!self.imageURL)
    {
        return NO;
    }
    return [[UMImageLoader sharedImageLoader] hasLoadedImageURL:self.imageURL];
}

- (UIImage *)cutOffImage:(UIImage *)image
{
    if (!self.needCutOff) {
        return image;
    }
    float smallSize = self.frame.size.width < self.frame.size.height ? self.frame.size.width : self.frame.size.height;
    smallSize = smallSize * self.image.scale;
    CGSize size = CGSizeMake(smallSize, smallSize);
    CGRect rect;
    CGSize imageSize = image.size;
    //根据图片的大小计算出图片中间矩形区域的位置与大小
    if (imageSize.width > imageSize.height) {
        float leftMargin = (imageSize.width - imageSize.height) * 0.5;
        rect = CGRectMake(leftMargin, 0, imageSize.height, imageSize.height);
    }else{
        float topMargin = (imageSize.height - imageSize.width) * 0.5;
        rect = CGRectMake(0, topMargin, imageSize.width, imageSize.width);
    }
    
    CGImageRef imageRef = image.CGImage;
    //截取中间区域矩形图片
    CGImageRef imageRefRect = CGImageCreateWithImageInRect(imageRef, rect);
    
    UIImage *tmp = [[UIImage alloc] initWithCGImage:imageRefRect];
    CGImageRelease(imageRefRect);
    
    UIGraphicsBeginImageContext(size);
    CGRect rectDraw = CGRectMake(0, 0, size.width, size.height);
    [tmp drawInRect:rectDraw];
    // 从当前context中创建一个改变大小后的图片
    tmp = UIGraphicsGetImageFromCurrentImageContext();
    
    // 使当前的context出堆栈
    UIGraphicsEndImageContext();
    
    return tmp;
}

- (void)setImageURL:(NSURL *)aImageURL placeholderImage:(UIImage *)aPlaceholderImage
{
    self.placeholderImage = aPlaceholderImage;
    
    [self setImageURL:aImageURL];
}

- (void)setPlaceholderImage:(UIImage *)image
{
    placeholderImage = [image retain];
    self.image = placeholderImage;
    self.hidden = NO;
}

- (void)setImageURL:(NSURL *)aURL 
{
//    NSLog(@"setImageURL1 [%@]",aURL);
    self.opaque = YES;
	if(imageURL)
    {
        self.isCacheImage = NO;

        [[UMImageLoader sharedImageLoader] cancelLoadForURL:imageURL];
        
		[imageURL release];
		imageURL = nil;
	}
	
	if(!aURL) 
    {
		self.image = self.placeholderImage;
		imageURL = nil;
		return;
	} 
    else 
    {
		imageURL = [aURL retain];
	}

	[[UMImageLoader sharedImageLoader] removeObserver:self];
    
    
    if(self.isGif)
    {
        NSData *gifData = [[UMImageLoader sharedImageLoader] dataForURL:aURL shouldLoadWithObserver:self isGif:YES];
        
        if(gifData)
        {
            [self decodeGIF: gifData];
            [self setAnimationData];
            [self startAnimating];
            
            self.hidden = NO;
            // trigger the delegate callback if the image was found in the cache
            if(self.delegate&&[self.delegate respondsToSelector:@selector(imageViewLoadedImage:)]) 
            {
                [self.delegate imageViewLoadedImage:self];
            }
        }
        else
        {
            self.image = self.placeholderImage;
        }
    }
    else
    {
//        [self loadImage:aURL];
        //减少 iO 时间，改为子线程 iO
        [self performSelectorInBackground:@selector(loadImage:) withObject:aURL];
    }
    
}

- (void)loadImage:(NSURL *)aURL
{
    UIImage* anImage = [[UMImageLoader sharedImageLoader] imageForURL:aURL shouldLoadWithObserver:self autoLoad:self.isAutoStart];
    
    if(anImage)
    {
//        self.image = [self cutOffImage:anImage];
        UIImage *cutOffImage = [self cutOffImage:anImage];
        if ([cutOffImage isKindOfClass:[UIImage class]]) {
            self.image = cutOffImage;
        }
        self.hidden = NO;
        self.isCacheImage = YES;
        // trigger the delegate callback if the image was found in the cache
        if(self.delegate&&[self.delegate respondsToSelector:@selector(imageViewLoadedImage:)])
        {
            [self.delegate imageViewLoadedImage:self];
        }
    }
    else
    {
        self.isCacheImage = NO;
        self.image = self.placeholderImage;
    }
}

#pragma mark -
#pragma mark Image loading

- (void)startImageLoad
{
    if(self.isAutoStart)
    {
        return;
    }
    
    if(self.isCacheImage)
    {
        return;
    }
    
    if(!self.imageURL)
    {
        return;
    }
    
    [self cancelImageLoad];
    
    [[UMImageLoader sharedImageLoader] loadImageForURL:self.imageURL observer:self];
}

- (void)cancelImageLoad 
{
	[[UMImageLoader sharedImageLoader] cancelLoadForURL:self.imageURL];
	[[UMImageLoader sharedImageLoader] removeObserver:self];
}

- (void)imageLoaderDidLoadPercent:(NSNotification*)notification
{
	if(![[[notification userInfo] objectForKey:@"imageURL"] isEqual:self.imageURL]) return;
    
    if(self.delegate&&[self.delegate respondsToSelector:@selector(imageViewLoadedImageSizePercent:imageView:)])
    {
		[self.delegate imageViewLoadedImageSizePercent:[(NSNumber *)[[notification userInfo] objectForKey:@"percent"] floatValue] imageView:self];
	}
}

- (void)imageLoaderDidLoad:(NSNotification*)notification 
{
//    self.hidden = NO;
	if(![[[notification userInfo] objectForKey:@"imageURL"] isEqual:self.imageURL])
    {
        self.isCacheImage = NO;
        return;
    }

    self.status = UMImageView_Success;
    
    if(self.isGif)
    {
        NSData *gifData = [[notification userInfo] objectForKey:@"imageGif"];
        [self decodeGIF: gifData];
        [self setAnimationData];
        [self startAnimating];
    }
    else
    {
        UIImage* anImage = [[notification userInfo] objectForKey:@"image"];
        self.image = [self cutOffImage:anImage];
//        self.image = anImage;
    }
	
    //self.frame = CGRectMake(self.frame.origin.x, self.frame.origin.y, anImage.size.width, anImage.size.height);
//	[self setNeedsDisplay];
	
	if(self.delegate&&[self.delegate respondsToSelector:@selector(imageViewLoadedImage:)])
    {
		[self.delegate imageViewLoadedImage:self];
	}	
}

- (void)imageLoaderDidFailToLoad:(NSNotification*)notification
{
    self.status = UMImageView_Failed;
	if(![[[notification userInfo] objectForKey:@"imageURL"] isEqual:self.imageURL]) return;
	
	if(self.delegate&&[self.delegate respondsToSelector:@selector(imageViewFailedToLoadImage:error:)]) 
    {
		[self.delegate imageViewFailedToLoadImage:self error:[[notification userInfo] objectForKey:@"error"]];
	}
}
- (void) startAnimating
{
    [super startAnimating];
}

- (void) setCacheSecondes:(NSTimeInterval)secondes;
{
    if(secondes<=0.0)
    {
        NSLog(@"[%f] is error",secondes);
        return;
    }

    [[UMImageLoader sharedImageLoader] setCache_seconds:secondes];
}

- (void) clearCache
{
    [[UMImageLoader sharedImageLoader] clearCacheForURL:self.imageURL];
}

- (void) resetBuffer
{
    if (GIF_buffer != nil)
    {
	    [GIF_buffer release];
        GIF_buffer = nil;
    }
    
    if (GIF_screen != nil)
    {
		[GIF_screen release];
        GIF_screen = nil;
    }
    
    if (GIF_global != nil)
    {
        [GIF_global release];
        GIF_global = nil;
    }
}
- (void) freeBuffer
{
    [self resetBuffer];
    
    if (GIF_frames != nil)
    {
        [GIF_frames removeAllObjects];
        [GIF_frames release];
        GIF_frames = nil;
    }

}

#pragma mark -
- (void) dealloc {
    
	self.delegate = nil;
	self.imageURL = nil;
	self.placeholderImage = nil;
    
    [self freeBuffer];
    
    [[UMImageLoader sharedImageLoader] removeObserver:self];
    
    [super dealloc];
}

@end
