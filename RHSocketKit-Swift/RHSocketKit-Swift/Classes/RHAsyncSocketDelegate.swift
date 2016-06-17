//
//  RHAsyncSocketDelegate.swift
//  RHSocketKit-Swift
//
//  Created by zhuruhong on 16/6/17.
//  Copyright © 2016年 zhuruhong. All rights reserved.
//

import Foundation

@objc public protocol RHAsyncSocketDelegate: NSObjectProtocol {
    
    /**
     * Called when a socket connects and is ready for reading and writing.
     * The host parameter will be an IP address, not a DNS name.
     **/
    optional func didConnectToHost(socket: RHAsyncSocket, host: String, port: Int)
    
    /**
     * Called when a socket has completed reading the requested data into memory.
     * Not called if there is an error.
     **/
    optional func didReadData(socket: RHAsyncSocket, data: NSData)
    
    /**
     * Called when a socket has completed writing the requested data. Not called if there is an error.
     **/
    optional func didWriteData(socket: RHAsyncSocket)
    
    /**
     * Called when a socket disconnects with or without error.
     **/
    optional func didDisconnect(socket: RHAsyncSocket, error: NSError)
    
}