#import <Foundation/Foundation.h>

typedef void (^URLConnectionCompletionBlock)        (NSData *data, NSURLResponse *response);
typedef void (^URLConnectioErrorBlock)              (NSError *error);
typedef void (^URLConnectioUploadProgressBlock)     (float progress);
typedef void (^URLConnectioDownloadProgressBlock)   (float progress);


@interface URLConnection : NSObject 

+ (void)asyncConnectionWithRequest:(NSURLRequest *)request 
                   completionBlock:(URLConnectionCompletionBlock)completionBlock
                        errorBlock:(URLConnectioErrorBlock)errorBlock
               uploadPorgressBlock:(URLConnectioUploadProgressBlock)uploadBlock
             downloadProgressBlock:(URLConnectioDownloadProgressBlock)downloadBlock;

+ (void)asyncConnectionWithRequest:(NSURLRequest *)request 
                   completionBlock:(URLConnectionCompletionBlock)completionBlock 
                        errorBlock:(URLConnectioErrorBlock)errorBlock;

+ (void)asyncConnectionWithURLString:(NSString *)urlString
                     completionBlock:(URLConnectionCompletionBlock)completionBlock 
                          errorBlock:(URLConnectioErrorBlock)errorBlock;

@end