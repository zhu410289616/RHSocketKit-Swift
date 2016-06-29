//
//  RHSocketDelimiterEncoder.swift
//  RHSocketKit-Swift
//
//  Created by zhuruhong on 16/6/19.
//  Copyright © 2016年 zhuruhong. All rights reserved.
//

import Foundation

public class RHSocketDelimiterEncoder: NSObject, RHSocketEncoderProtocol {
    var delimiterData: NSData!
    var maxFrameSize: Int = 8192
    
    convenience init(delimiter: UInt8, maxFrameSize: Int) {
        self.init(delimiterData: NSData(bytes: unsafeBitCast(delimiter, UnsafePointer<UInt8>.self), length: 1), maxFrameSize: maxFrameSize)
    }
    
    init(delimiterData: NSData, maxFrameSize: Int) {
        self.delimiterData = delimiterData
        self.maxFrameSize = maxFrameSize
    }
    
    func encode(upstreamPacket: RHUpstreamPacket, output: RHSocketEncoderOutputProtocol) {
        let data = upstreamPacket.dataWithPacket()
        guard data?.length > 0 else {
            return
        }
        
        guard data?.length < self.maxFrameSize else {
            return
        }
        
        let sendData = NSMutableData(data: data!)
        sendData.appendData(self.delimiterData)
        let timeout = upstreamPacket.timeout
        
        output.didEncode(sendData, timeout: timeout!)
    }
}