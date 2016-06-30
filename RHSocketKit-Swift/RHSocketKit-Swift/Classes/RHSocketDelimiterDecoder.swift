//
//  RHSocketDelimiterDecoder.swift
//  RHSocketKit-Swift
//
//  Created by zhuruhong on 16/6/19.
//  Copyright © 2016年 zhuruhong. All rights reserved.
//

import Foundation

public class RHSocketDelimiterDecoder: NSObject, RHSocketDecoderProtocol {
    var delimiterData: NSData!
    var maxFrameSize: Int = 8192
    var nextDecoder: RHSocketDecoderProtocol?
    
    convenience init(delimiter: UInt8, maxFrameSize: Int) {
        self.init(delimiterData: NSData(bytes: unsafeBitCast(delimiter, UnsafePointer<UInt8>.self), length: 1), maxFrameSize: maxFrameSize)
    }
    
    init(delimiterData: NSData, maxFrameSize: Int) {
        self.delimiterData = delimiterData
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
        let dataLen: Int = downstreamData.length
        var headIndex = 0
        
        while true {
            guard dataLen < self.maxFrameSize else {
                return -1
            }
            
            let range = NSRange(location: headIndex, length: dataLen - headIndex)
            let resultRange = downstreamData.rangeOfData(self.delimiterData, options: NSDataSearchOptions(rawValue: 0), range: range)
            guard resultRange.length > 0 else {
                break
            }
            
            let frameLen = resultRange.location - headIndex
            let frameData = downstreamData.subdataWithRange(NSRange(location: headIndex, length: frameLen))
            
            let ctx = RHSocketPacketResponse(object: frameData)
            
            if self.nextDecoder != nil {
                self.nextDecoder?.decode(ctx, output: output)
            } else {
                output.didDecode(ctx)
            }
            
            headIndex = resultRange.location + resultRange.length
        }//while
        return headIndex
    }
}