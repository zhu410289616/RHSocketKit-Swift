//
//  RHAsyncSocketBuffer.swift
//  RHSocketKit-Swift
//
//  Created by zhuruhong on 16/6/30.
//  Copyright © 2016年 zhuruhong. All rights reserved.
//

import Foundation

public class RHAsyncSocketBuffer: NSObject {
    var dataBuffer = NSMutableData()
    var dataBufferOffset = 0
    
    func availableBytes() -> (data: NSData, length: Int) {
        let length = dataBuffer.length - dataBufferOffset
        let range = NSRange(location: dataBufferOffset, length: length)
        return (dataBuffer.subdataWithRange(range), length)
    }
    
    func reset() -> Void {
        dataBuffer = NSMutableData()
        dataBufferOffset = 0
    }
}

public class RHAsyncSocketWriteBuffer: RHAsyncSocketBuffer {
    func didWrite(bytesWritten: Int) -> Void {
        guard bytesWritten > 0 else {
            return
        }
        
        let readed = dataBufferOffset + bytesWritten
        let range = NSRange(location: readed, length: dataBuffer.length - readed)
        dataBuffer = NSMutableData(data: dataBuffer.subdataWithRange(range))
    }
}

public class RHAsyncSocketReadBuffer: RHAsyncSocketBuffer {
    func didRead(bytesRead: Int) -> Void {
        guard bytesRead > 0 else {
            return
        }
        
        let readed = dataBufferOffset + bytesRead
        let range = NSRange(location: readed, length: dataBuffer.length - readed)
        dataBuffer = NSMutableData(data: dataBuffer.subdataWithRange(range))
    }
}