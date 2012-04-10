#import "URLConnection.h"

@interface URLConnection () {
    NSURLConnection *connection;
    NSURLRequest    *request;
    NSMutableData   *data;
    NSURLResponse   *response;
    long long       downloadSize;
    
    URLConnectionCompletionBlock completionBlock;
    URLConnectioErrorBlock errorBlock;
    URLConnectioUploadProgressBlock uploadBlock;
    URLConnectioDownloadProgressBlock downloadBlock;
}

- (id)initWithRequest:(NSURLRequest *)request 
      completionBlock:(URLConnectionCompletionBlock)completionBlock
           errorBlock:(URLConnectioErrorBlock)errorBlock
  uploadPorgressBlock:(URLConnectioUploadProgressBlock)uploadBlock
downloadProgressBlock:(URLConnectioDownloadProgressBlock)downloadBlock;
- (void)start;

@end

@implementation URLConnection

+ (void)asyncConnectionWithRequest:(NSURLRequest *)request 
                   completionBlock:(URLConnectionCompletionBlock)completionBlock
                        errorBlock:(URLConnectioErrorBlock)errorBlock
               uploadPorgressBlock:(URLConnectioUploadProgressBlock)uploadBlock
             downloadProgressBlock:(URLConnectioDownloadProgressBlock)downloadBlock {
    
    URLConnection *connection = [[URLConnection alloc] initWithRequest:request 
                                                       completionBlock:completionBlock 
                                                            errorBlock:errorBlock
                                                   uploadPorgressBlock:uploadBlock
                                                 downloadProgressBlock:downloadBlock];
    [connection start];
    [connection release];
}

+ (void)asyncConnectionWithRequest:(NSURLRequest *)request 
                   completionBlock:(URLConnectionCompletionBlock)completionBlock 
                        errorBlock:(URLConnectioErrorBlock)errorBlock {
    [URLConnection asyncConnectionWithRequest:request 
                              completionBlock:completionBlock 
                                   errorBlock:errorBlock 
                          uploadPorgressBlock:nil 
                        downloadProgressBlock:nil];
}

+ (void)asyncConnectionWithURLString:(NSString *)urlString
                     completionBlock:(URLConnectionCompletionBlock)completionBlock 
                          errorBlock:(URLConnectioErrorBlock)errorBlock {
    
    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:urlString]];
    
    [URLConnection asyncConnectionWithRequest:request 
                              completionBlock:completionBlock 
                                   errorBlock:errorBlock];
}



- (id)initWithRequest:(NSURLRequest *)_request 
      completionBlock:(URLConnectionCompletionBlock)_completionBlock
           errorBlock:(URLConnectioErrorBlock)_errorBlock
  uploadPorgressBlock:(URLConnectioUploadProgressBlock)_uploadBlock
downloadProgressBlock:(URLConnectioDownloadProgressBlock)_downloadBlock {
    
    self = [super init];
    if (self) {
        request =           [_request retain];
        completionBlock =   [_completionBlock copy];
        errorBlock =        [_errorBlock copy];
        uploadBlock =       [_uploadBlock copy];
        downloadBlock =     [_downloadBlock copy];
    }
    return self;
}

- (void)dealloc {
    [request release];
    [data release];
    [response release];
    
    [completionBlock release];
    [errorBlock release];
    [uploadBlock release];
    [downloadBlock release];
    
    [super dealloc];
}

- (void)start {
    connection  = [[NSURLConnection alloc] initWithRequest:request delegate:self];
    data        = [[NSMutableData alloc] init];
    
    [connection start];    
}




#pragma mark NSURLConnectionDelegate

- (void)connectionDidFinishLoading:(NSURLConnection *)_connection {
    if(completionBlock) completionBlock(data, response);
}

- (void)connection:(NSURLConnection *)_connection 
  didFailWithError:(NSError *)error {
    if(errorBlock) errorBlock(error);
}

- (void)connection:(NSURLConnection *)connection 
didReceiveResponse:(NSHTTPURLResponse *)_response {
    response = [_response retain];
    downloadSize = [response expectedContentLength];
}

- (void)connection:(NSURLConnection *)connection 
    didReceiveData:(NSData *)_data {
    [data appendData:_data];
    
    if (downloadSize != -1) {
        float progress = (float)data.length / (float)downloadSize;
        if(downloadBlock) downloadBlock(progress);
    }
}

- (void)connection:(NSURLConnection *)connection   
   didSendBodyData:(NSInteger)bytesWritten
 totalBytesWritten:(NSInteger)totalBytesWritten
totalBytesExpectedToWrite:(NSInteger)totalBytesExpectedToWrite {
    float progress= (float)totalBytesWritten/(float)totalBytesExpectedToWrite;
    if (uploadBlock) uploadBlock(progress);
}


@end
