//
//  RHSocketUtils.swift
//  RHSocketKit-Swift
//
//  Created by zhuruhong on 16/6/19.
//  Copyright © 2016年 zhuruhong. All rights reserved.
//

import Foundation

public extension NSData {
    func reverse() -> NSData {
        let byteCount = self.length
        let dstData = NSMutableData(data: self)
        let halfLength = byteCount / 2
        for i in 0..<halfLength {
            let begin = NSRange(location: i, length: 1)
            let end = NSRange(location: byteCount - i - 1, length: 1)
            let beginData = self.subdataWithRange(begin)
            let endData = self.subdataWithRange(end)
            dstData.replaceBytesInRange(begin, withBytes: endData.bytes)
            dstData.replaceBytesInRange(end, withBytes: beginData.bytes)
        }//
        return dstData
    }
    
    func int8() -> Int8 {
        var val: Int8 = 0
        self.getBytes(&val, length: 1)
        return val
    }
    
    func int16() -> Int16 {
        var val: Int16 = 0
        self.getBytes(&val, length: 2)
        return val
    }
    
    func int32() -> Int32 {
        var val: Int32 = 0
        self.getBytes(&val, length: 4)
        return val
    }
    
    func int64() -> Int64 {
        var val: Int64 = 0
        self.getBytes(&val, length: 8)
        return val
    }
}

public extension Int8 {
    mutating func bytes() -> NSData {
        let valData = NSMutableData()
        valData.appendBytes(&self, length: 1)
        return valData
    }
}

public extension Int16 {
    mutating func bytes() -> NSData {
        let valData = NSMutableData()
        valData.appendBytes(&self, length: 2)
        return valData
    }
}

public extension Int32 {
    mutating func bytes() -> NSData {
        let valData = NSMutableData()
        valData.appendBytes(&self, length: 4)
        return valData
    }
}

public extension Int64 {
    mutating func bytes() -> NSData {
        let valData = NSMutableData()
        valData.appendBytes(&self, length: 8)
        return valData
    }
}