//
//  RHSocketHttpEncoder.swift
//  RHSocketKit-Swift
//
//  Created by zhuruhong on 16/6/29.
//  Copyright © 2016年 zhuruhong. All rights reserved.
//

import Foundation

public class RHSocketHttpEncoder: NSObject, RHSocketEncoderProtocol {
    
    func encode(upstreamPacket: RHUpstreamPacket, output: RHSocketEncoderOutputProtocol) {
        let data = upstreamPacket.dataWithPacket()
        guard data != nil else {
            return
        }
        let crlfString = "\r\n"
        let sendData = NSMutableData(data: data!)
        sendData.appendData(crlfString.dataUsingEncoding(NSASCIIStringEncoding)!)
        let timeout = upstreamPacket.timeout
        
        output.didEncode(sendData, timeout: timeout!)
    }
    
}