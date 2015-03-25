//
//  UMImageLoader.m
//  UMImageLoader
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

#import "UMImageLoader.h"
#import "UMImageLoadConnection.h"
#import "UMCache.h"

static UMImageLoader* __imageLoader;

inline static NSString* keyForURL(NSURL* url, NSString* style) {
	if(style) {
        return [NSString stringWithFormat:@"EGOImageLoader-%@-%lu", [UMUtils md5Value:[url absoluteString]], (unsigned long)[style hash]];
	} else {
        NSString *string = [NSString stringWithFormat:@"EGOImageLoader-%@", [UMUtils md5Value:[url absoluteString]]];
        return string;
	}
}

#define kImageNotificationLoadedPercent(s) [@"kEGOImageLoaderNotificationLoadedPercent-" stringByAppendingString:keyForURL(s, nil)]
#define kImageNotificationLoaded(s) [@"kEGOImageLoaderNotificationLoaded-" stringByAppendingString:keyForURL(s, nil)]
#define kImageNotificationLoadFailed(s) [@"kEGOImageLoaderNotificationLoadFailed-" stringByAppendingString:keyForURL(s, nil)]


@implementation UMImageLoader
@synthesize currentConnections=_currentConnections;
@synthesize isGif = _isGif;
@synthesize cache_seconds = _cache_seconds;

+ (UMImageLoader*)sharedImageLoader {
	@synchronized(self) {
		if(!__imageLoader) {
			__imageLoader = [[[self class] alloc] init];
		}
	}
	
	return __imageLoader;
}

- (id)init {
	if((self = [super init])) {
		connectionsLock = [[NSLock alloc] init];
		currentConnections = [[NSMutableDictionary alloc] init];
        
        self.isGif = NO;
        self.cache_seconds = UMCACHE_DEFAULT_CACHE_SECONDS;
	}
	
	return self;
}

- (void)setCache_seconds:(NSTimeInterval)cache_seconds
{
    if(cache_seconds>0.0)
    {
        _cache_seconds = cache_seconds;
    }
}

- (UMImageLoadConnection*)loadingConnectionForURL:(NSURL*)aURL {
	UMImageLoadConnection* connection = [[self.currentConnections objectForKey:aURL] retain];
	if(!connection) return nil;
	else return [connection autorelease];
}

- (void)cleanUpConnection:(UMImageLoadConnection*)connection {
	if(!connection.imageURL) return;
	
	connection.delegate = nil;
	
	[connectionsLock lock];
	[currentConnections removeObjectForKey:connection.imageURL];
	self.currentConnections = [[currentConnections copy] autorelease];
	[connectionsLock unlock];	
}

- (void)clearCacheForURL:(NSURL*)aURL {
	[self clearCacheForURL:aURL style:nil];
}

- (void)clearCacheForURL:(NSURL*)aURL style:(NSString*)style {
	[[UMCache currentCache] removeCacheForKey:keyForURL(aURL, style)];
}

- (BOOL)isLoadingImageURL:(NSURL*)aURL {
	return [self loadingConnectionForURL:aURL] ? YES : NO;
}

- (void)cancelLoadForURL:(NSURL*)aURL {
	UMImageLoadConnection* connection = [self loadingConnectionForURL:aURL];
	[NSObject cancelPreviousPerformRequestsWithTarget:connection selector:@selector(start) object:nil];
	[connection cancel];
	[self cleanUpConnection:connection];
}

- (UMImageLoadConnection*)loadImageForURL:(NSURL*)aURL {
	UMImageLoadConnection* connection;
	
	if((connection = [self loadingConnectionForURL:aURL])) {
		return connection;
	} else {
		connection = [[UMImageLoadConnection alloc] initWithImageURL:aURL delegate:self];
	
		[connectionsLock lock];
		[currentConnections setObject:connection forKey:aURL];
		self.currentConnections = [[currentConnections copy] autorelease];
		[connectionsLock unlock];
		[connection performSelector:@selector(start) withObject:nil afterDelay:0.01];
		[connection release];
		
		return connection;
	}
}

- (void)loadImageForURL:(NSURL*)aURL observer:(id<UMImageLoaderObserver>)observer {
	if(!aURL) return;
    

    
//    NSMethodSignature *sig = [self methodSignatureForSelector:@selector(addObserver:forURL:)];
//    
//    NSInvocation *invocation = [NSInvocation invocationWithMethodSignature:sig];
//    
//    [invocation setTarget:self];
//    
//    [invocation setSelector:@selector(addObserver:forURL:)];
//    
//    [invocation setArgument:observer atIndex:2];
//    
//    [invocation setArgument:aURL atIndex:3];
//
//    [invocation performSelectorInBackground:@selector(invoke) withObject:nil];
    
    [self addObserver:observer forURL:aURL];
    
    [self loadImageForURL:aURL];
    //create connect in background
//    [self performSelectorInBackground:@selector(loadImageForURL:) withObject:aURL];
}

- (UIImage*)imageForURL:(NSURL*)aURL shouldLoadWithObserver:(id<UMImageLoaderObserver>)observer autoLoad:(BOOL)autoLoad{
	if(!aURL) return nil;
    
    
	
	UIImage* anImage = [[UMCache currentCache] imageForKey:keyForURL(aURL,nil)];
	
	if(anImage) {
		return anImage;
	} else {
        if(autoLoad)
        {
            [self loadImageForURL:aURL observer:observer];
        }
		return nil;
	}
}



- (NSData *)dataForURL:(NSURL*)aURL shouldLoadWithObserver:(id<UMImageLoaderObserver>)observer isGif:(BOOL)isGif{
    if(!aURL) return nil;
	
    self.isGif = isGif;
    
	NSData* data = [[UMCache currentCache] dataForKey:keyForURL(aURL,nil)];
	
	if(data) {
		return data;
	} else {
		[self loadImageForURL:aURL observer:observer];
		return nil;
	}
}

- (void)addObserver:(id<UMImageLoaderObserver>)observer forURL:(NSURL*)aURL
{
    if([observer respondsToSelector:@selector(imageLoaderDidLoadPercent:)]) {
		[[NSNotificationCenter defaultCenter] addObserver:observer selector:@selector(imageLoaderDidLoadPercent:) name:kImageNotificationLoadedPercent(aURL) object:self];
	}
	
	if([observer respondsToSelector:@selector(imageLoaderDidLoad:)]) {
		[[NSNotificationCenter defaultCenter] addObserver:observer selector:@selector(imageLoaderDidLoad:) name:kImageNotificationLoaded(aURL) object:self];
	}
	
	if([observer respondsToSelector:@selector(imageLoaderDidFailToLoad:)]) {
		[[NSNotificationCenter defaultCenter] addObserver:observer selector:@selector(imageLoaderDidFailToLoad:) name:kImageNotificationLoadFailed(aURL) object:self];
	}
}

- (void)removeObserver:(id<UMImageLoaderObserver>)observer {
	[[NSNotificationCenter defaultCenter] removeObserver:observer name:nil object:self];
}

- (void)removeObserver:(id<UMImageLoaderObserver>)observer forURL:(NSURL*)aURL {
	[[NSNotificationCenter defaultCenter] removeObserver:observer name:kImageNotificationLoadedPercent(aURL) object:self];
	[[NSNotificationCenter defaultCenter] removeObserver:observer name:kImageNotificationLoaded(aURL) object:self];
	[[NSNotificationCenter defaultCenter] removeObserver:observer name:kImageNotificationLoadFailed(aURL) object:self];
}

- (BOOL)hasLoadedImageURL:(NSURL*)aURL {
	return [[UMCache currentCache] hasCacheForKey:keyForURL(aURL,nil)];
}

#pragma mark -
#pragma mark URL Connection delegate methods

- (void)imageLoadConnectionDidReceivePercent:(float)percent connection:(UMImageLoadConnection *)connection
{
    NSNotification* notification = [NSNotification notificationWithName:kImageNotificationLoadedPercent(connection.imageURL)
                                                                 object:self
                                                               userInfo:[NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithFloat:percent],@"percent",connection.imageURL,@"imageURL",nil]];
    
    [[NSNotificationCenter defaultCenter] performSelectorOnMainThread:@selector(postNotification:) withObject:notification waitUntilDone:YES];
}

- (void)imageLoadConnectionDidFinishLoading:(UMImageLoadConnection *)connection {

    if(self.isGif)
    {
        NSData* gifData = connection.responseData;
        
        if(!gifData) {
            
            NSError* error = [NSError errorWithDomain:[connection.imageURL host] code:406 userInfo:nil];            
            NSNotification* notification = [NSNotification notificationWithName:kImageNotificationLoadFailed(connection.imageURL)
                                                                         object:self
                                                                       userInfo:[NSDictionary dictionaryWithObjectsAndKeys:error,@"error",connection.imageURL,@"imageURL",nil]];
            
            [[NSNotificationCenter defaultCenter] performSelectorOnMainThread:@selector(postNotification:) withObject:notification waitUntilDone:YES];
            
        } else {
            [[UMCache currentCache] setData:connection.responseData forKey:keyForURL(connection.imageURL,nil) withTimeoutInterval:self.cache_seconds];
            
            [currentConnections removeObjectForKey:connection.imageURL];
            self.currentConnections = [[currentConnections copy] autorelease];
            
            NSNotification* notification = [NSNotification notificationWithName:kImageNotificationLoaded(connection.imageURL)
                                                                         object:self
                                                                       userInfo:[NSDictionary dictionaryWithObjectsAndKeys:gifData,@"imageGif",connection.imageURL,@"imageURL",nil]];
            
            [[NSNotificationCenter defaultCenter] performSelectorOnMainThread:@selector(postNotification:) withObject:notification waitUntilDone:YES];
        }
        
    }
    else
    {
        UIImage* anImage = [UIImage imageWithData:connection.responseData];
        
        if(!anImage) {
            NSError* error = [NSError errorWithDomain:[connection.imageURL host] code:406 userInfo:nil];
            

            NSNotification* notification = [NSNotification notificationWithName:kImageNotificationLoadFailed(connection.imageURL)
                                                                         object:self
                                                                       userInfo:[NSDictionary dictionaryWithObjectsAndKeys:error,@"error",connection.imageURL,@"imageURL",nil]];
            
            [[NSNotificationCenter defaultCenter] performSelectorOnMainThread:@selector(postNotification:) withObject:notification waitUntilDone:YES];
            
        } else {
            [[UMCache currentCache] setData:connection.responseData forKey:keyForURL(connection.imageURL,nil) withTimeoutInterval:self.cache_seconds];
            
            [currentConnections removeObjectForKey:connection.imageURL];
            self.currentConnections = [[currentConnections copy] autorelease];
            
            NSNotification* notification = [NSNotification notificationWithName:kImageNotificationLoaded(connection.imageURL)
                                                                         object:self
                                                                       userInfo:[NSDictionary dictionaryWithObjectsAndKeys:anImage,@"image",connection.imageURL,@"imageURL",nil]];
            
            [[NSNotificationCenter defaultCenter] performSelectorOnMainThread:@selector(postNotification:) withObject:notification waitUntilDone:YES];
        }
    }
	

	[self cleanUpConnection:connection];
}

- (void)imageLoadConnection:(UMImageLoadConnection *)connection didFailWithError:(NSError *)error {
	[currentConnections removeObjectForKey:connection.imageURL];
	self.currentConnections = [[currentConnections copy] autorelease];
	
	NSNotification* notification = [NSNotification notificationWithName:kImageNotificationLoadFailed(connection.imageURL)
																 object:self
															   userInfo:[NSDictionary dictionaryWithObjectsAndKeys:error,@"error",connection.imageURL,@"imageURL",nil]];
	
	[[NSNotificationCenter defaultCenter] performSelectorOnMainThread:@selector(postNotification:) withObject:notification waitUntilDone:YES];

	[self cleanUpConnection:connection];
}

#pragma mark -

- (void)dealloc {
	self.currentConnections = nil;
	[currentConnections release], currentConnections = nil;
	[connectionsLock release], connectionsLock = nil;
	[super dealloc];
}

@end