//
//  RHSocketVariableLengthDecoder.swift
//  RHSocketKit-Swift
//
//  Created by zhuruhong on 16/6/19.
//  Copyright © 2016年 zhuruhong. All rights reserved.
//

import Foundation

public class RHSocketVariableLengthDecoder: NSObject, RHSocketDecoderProtocol {
    var countOfLengthByte = 2
    var maxFrameSize: Int = 65536
    var nextDecoder: RHSocketDecoderProtocol?
    
    convenience override init() {
        self.init(countOfLengthByte: 2, maxFrameSize: 65535)
    }
    
    init(countOfLengthByte: Int, maxFrameSize: Int) {
        self.countOfLengthByte = countOfLengthByte
        self.maxFrameSize = maxFrameSize
    }
    
    public func decode(downstreamPacket: RHDownstreamPacket, output: RHSocketDecoderOutputProtocol) -> Int {
        let object = downstreamPacket.object
        guard object != nil else {
            return -1
        }
        
        guard ((object?.isKindOfClass(NSData)) != nil) else {
            return -1
        }
        
        let downstreamData = unsafeBitCast(object, NSData.self)
        var headIndex = 0
        
        while downstreamData.length - headIndex > self.countOfLengthByte {
            let lenData = downstreamData.subdataWithRange(NSRange(location: headIndex, length: self.countOfLengthByte))
            var frameLen = 0//TODO: tool
            lenData.getBytes(&frameLen, range: NSRange(location: 0, length: self.countOfLengthByte))
            
            guard frameLen < self.maxFrameSize - self.countOfLengthByte else {
                return -1
            }
            
            guard downstreamData.length - headIndex >= self.countOfLengthByte + frameLen else {
                break
            }
            
            let frameData = downstreamData.subdataWithRange(NSRange(location: headIndex, length: self.countOfLengthByte + frameLen))
            
            let rspData = frameData.subdataWithRange(NSRange(location: self.countOfLengthByte, length: frameLen))
            let ctx = RHSocketPacketResponse(object: rspData)
            
            if self.nextDecoder != nil {
                self.nextDecoder?.decode(ctx, output: output)
            } else {
                output.didDecode(ctx)
            }
            
            headIndex += frameData.length
        }//while
        return headIndex
    }
}