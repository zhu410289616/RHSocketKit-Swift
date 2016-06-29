//
//  RHSocketHttpDecoder.swift
//  RHSocketKit-Swift
//
//  Created by zhuruhong on 16/6/29.
//  Copyright © 2016年 zhuruhong. All rights reserved.
//

import Foundation

class RHSocketHttpDecoder: NSObject, RHSocketDecoderProtocol {
    
    func decode(downstreamPacket: RHDownstreamPacket, output: RHSocketDecoderOutputProtocol) -> Int {
        let downstreamData = downstreamPacket.object!
        let dataLen = downstreamData.length
        var headIndex = 0
        var crlfCount = 0
        
        for i in 0..<dataLen {
            var byte = 0
            let oneRange = NSRange(location: i, length: 1)
            
            downstreamData.getBytes(&byte, range: oneRange)
            if byte == 0x0a {
                crlfCount += 1
            }
            
            if crlfCount == 2 {
                let packetLen = i - headIndex
                let packetData = downstreamData.subdataWithRange(NSRange(location: headIndex, length: packetLen))
                
                let rsp = RHSocketHttpResponse(object: packetData)
                output.didDecode(rsp)
            }
            
            headIndex = i + 1
            crlfCount = 0
        }
        
        return headIndex
    }
}