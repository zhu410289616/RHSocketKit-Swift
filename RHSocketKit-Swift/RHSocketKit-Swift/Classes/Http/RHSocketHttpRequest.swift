//
//  RHSocketHttpRequest.swift
//  RHSocketKit-Swift
//
//  Created by zhuruhong on 16/6/29.
//  Copyright © 2016年 zhuruhong. All rights reserved.
//

import Foundation

public class RHSocketHttpRequest: RHSocketPacketRequest {
    var requestPath = "GET /index.html HTTP/1.1"
    var host = "Host:www.baidu.com"
    var connection = "Connection:close"
    
    public override func dataWithPacket() -> NSData? {
        let crlfString = "\r\n"
        let packetData = NSMutableData()
        
        packetData.appendData(requestPath.dataUsingEncoding(NSASCIIStringEncoding)!)
        packetData.appendData(crlfString.dataUsingEncoding(NSASCIIStringEncoding)!)
        packetData.appendData(host.dataUsingEncoding(NSASCIIStringEncoding)!)
        packetData.appendData(crlfString.dataUsingEncoding(NSASCIIStringEncoding)!)
        packetData.appendData(connection.dataUsingEncoding(NSASCIIStringEncoding)!)
        packetData.appendData(crlfString.dataUsingEncoding(NSASCIIStringEncoding)!)
        
        self.object = packetData
        return packetData
    }
}