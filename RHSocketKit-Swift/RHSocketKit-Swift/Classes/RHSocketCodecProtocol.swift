//
//  RHSocketCodecProtocol.swift
//  RHSocketKit-Swift
//
//  Created by zhuruhong on 16/6/17.
//  Copyright © 2016年 zhuruhong. All rights reserved.
//

import Foundation

public protocol RHSocketEncoderOutputProtocol: NSObjectProtocol {
    func didEncode(encodedData: NSData, timeout: NSTimeInterval)
}

public protocol RHSocketDecoderOutputProtocol: NSObjectProtocol {
    func didDecode(decodedPacket: RHDownstreamPacket)
}

public protocol RHSocketEncoderProtocol: NSObjectProtocol {
    func encode(upstreamPacket: RHUpstreamPacket, output: RHSocketEncoderOutputProtocol)
}

public protocol RHSocketDecoderProtocol: NSObjectProtocol {
    func decode(downstreamPacket: RHDownstreamPacket, output: RHSocketDecoderOutputProtocol) -> Int
}