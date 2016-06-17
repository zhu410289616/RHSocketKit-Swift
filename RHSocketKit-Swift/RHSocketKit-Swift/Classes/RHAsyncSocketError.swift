//
//  RHAsyncSocketError.swift
//  RHSocketKit-Swift
//
//  Created by zhuruhong on 16/6/17.
//  Copyright © 2016年 zhuruhong. All rights reserved.
//

import Foundation

let RHAsyncSocketErrorDomain = "RHAsyncSocketErrorDomain"

@objc public enum RHAsyncSocketError: Int {
    case NoError = 0                    // Never used
    case BadConfigError                 // Invalid configuration
    case BadParamError                  // Invalid parameter was passed
    case ConnectTimeoutError            // A connect operation timed out
    case ReadTimeoutError               // A read operation timed out
    case WriteTimeoutError              // A write operation timed out
    case ReadMaxedOutError              // Reached set maxLength without completing
    case ClosedError                    // The remote peer closed the connection
    case OtherError                     // Description provided in userInfo
}