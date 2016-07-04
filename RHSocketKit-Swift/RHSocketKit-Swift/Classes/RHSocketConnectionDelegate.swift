//
//  RHSocketConnectionDelegate.swift
//  RHSocketKit-Swift
//
//  Created by zhuruhong on 16/6/29.
//  Copyright © 2016年 zhuruhong. All rights reserved.
//

import Foundation

@objc protocol RHSocketConnectionDelegate: NSObjectProtocol {
    func connect(hostName: String, port: Int)
    func disconnect()
    func isConnected() -> Bool
    
//    func didDisconnect(con: RHSocketConnectionDelegate, error: NSError)
//    func didConnect(con: RHSocketConnectionDelegate, host: String, port: Int)
//    func didRead(con: RHSocketConnectionDelegate, data: NSData, tag: Int)
    
    func readData(timeout: NSTimeInterval)
    func writeData(data: NSData?, timeout: NSTimeInterval)
    func didReceived(con: RHSocketConnectionDelegate, packet: RHDownstreamPacket)
}