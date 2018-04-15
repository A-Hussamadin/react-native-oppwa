#import "RNOppwa.h"

@implementation RNOppwa

OPPPaymentProvider *provider;

RCT_EXPORT_MODULE(RNOppwa);


-(instancetype)init
{
    self = [super init];
    if (self) {
      #ifdef DEBUG
        provider = [OPPPaymentProvider paymentProviderWithMode:OPPProviderModeTest];
     #else
        provider = [OPPPaymentProvider paymentProviderWithMode:OPPProviderModeLive];
     #endif
    }
    
    return self;
}

/**
 * transaction
 */
RCT_EXPORT_METHOD(transactionPayment: (NSDictionary*)options resolver:(RCTPromiseResolveBlock)resolve rejecter:(RCTPromiseRejectBlock)reject) {
    
    NSError * _Nullable error;
   
    
    OPPCardPaymentParams *params = [OPPCardPaymentParams cardPaymentParamsWithCheckoutID:[options valueForKey:@"checkoutID"]
                                                     error:&error];

    if (error) {
      reject(@"oppwa/card-init",error.description, error);
    } else {
      params.tokenizationEnabled = YES;
      OPPTransaction *transaction = [OPPTransaction transactionWithPaymentParams:params];

      [provider submitTransaction:transaction completionHandler:^(OPPTransaction * _Nonnull transaction, NSError * _Nullable error) {
        if (transaction.type == OPPTransactionTypeAsynchronous) {
          // Open transaction.redirectURL in Safari browser to complete the transaction
        }  else if (transaction.type == OPPTransactionTypeSynchronous) {
         resolve(transaction);
        } else {
          reject(@"oppwa/transaction",error.description, error);
          // Handle the error
        }
      }];
    }
}
/**
 * validate number
 * @return
 */
RCT_EXPORT_METHOD(isValidNumber:
            options:
            (NSDictionary *) options
            resolver:
            (RCTPromiseResolveBlock) resolve
            rejecter:
            (RCTPromiseRejectBlock) reject) {

        
        if (![OPPCardPaymentParams isNumberValid:[options valueForKey:@"cardNumber"] forPaymentBrand:@"VISA"]) {
            resolve([NSNull null]);
        }
        else {
           reject(@"oppwa/card-invalid", @"The card number is invalid.", nil);
        }
}

+ (BOOL)requiresMainQueueSetup
{
    return YES;
}

@end
