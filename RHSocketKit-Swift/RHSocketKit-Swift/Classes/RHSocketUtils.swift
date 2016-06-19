//
//  RHSocketUtils.swift
//  RHSocketKit-Swift
//
//  Created by zhuruhong on 16/6/19.
//  Copyright © 2016年 zhuruhong. All rights reserved.
//

import Foundation

func valueFromBytes(data: NSData) -> Int64 {
    let dataLen = data.length
    var value: Int64 = 0
    var offset = 0
    
    while offset < dataLen {
        var tempVal = 0
        data.getBytes(&tempVal, range: NSRange(location: offset, length: 1))
        value += (tempVal << (8 * offset))
        offset += 1
    }//while
    
    return value
}

func valueFromBytes(bytes: NSData, reverse: Bool) -> Int {
    return 0
}