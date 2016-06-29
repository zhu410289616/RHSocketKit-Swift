//
//  RHSocketVariableLengthEncoder.swift
//  RHSocketKit-Swift
//
//  Created by zhuruhong on 16/6/19.
//  Copyright © 2016年 zhuruhong. All rights reserved.
//

import Foundation

public class RHSocketVariableLengthEncoder: NSObject, RHSocketEncoderProtocol {
    var countOfLengthByte = 2
    var maxFrameSize: Int = 65536
    
    convenience override init() {
        self.init(countOfLengthByte: 2, maxFrameSize: 65535)
    }
    
    init(countOfLengthByte: Int, maxFrameSize: Int) {
        self.countOfLengthByte = countOfLengthByte
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
        
        var dataLen = data?.length
        let sendData = NSMutableData()
        
        sendData.appendBytes(&dataLen, length: self.countOfLengthByte)
        sendData.appendData(data!)
        
        let timeout = upstreamPacket.timeout
        
        output.didEncode(sendData, timeout: timeout!)
    }
}