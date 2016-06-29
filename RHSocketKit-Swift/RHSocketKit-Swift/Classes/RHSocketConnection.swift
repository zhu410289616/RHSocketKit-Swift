//
//  RHSocketConnection.swift
//  RHSocketKit-Swift
//
//  Created by zhuruhong on 16/6/29.
//  Copyright © 2016年 zhuruhong. All rights reserved.
//

import Foundation

public class RHSocketConnection: NSObject, RHAsyncSocketDelegate {
    var asyncSocket: RHAsyncSocket!
    
    override init() {
        super.init()
        self.asyncSocket = RHAsyncSocket(delegate: self, delegateQueue: dispatch_get_main_queue())
    }
    
    //RHSocketConnectionDelegate
    
    func connect(host hostName: String, port: Int) {
        self.asyncSocket.connect(host: hostName, port: port)
    }
    
    func disconnect() {
        self.asyncSocket.disconnect()
    }
    
    func isConnected() -> Bool {
        return self.asyncSocket.isConnected()
    }
    
    func writeData(data: NSData, timeout: NSTimeInterval) -> Int? {
        let writeLength = self.asyncSocket.writeData(data, timeout: timeout)
        print("writeLength: \(writeLength)")
        return writeLength
    }
    
    //RHAsyncSocketDelegate
    
    public func didConnectToHost(socket: RHAsyncSocket, host: String, port: Int) {
        print("host: \(host), port: \(port)")
    }
    
    public func didReadData(socket: RHAsyncSocket, data: NSData?) {
        print("data: \(data)")
    }
    
    public func didDisconnect(socket: RHAsyncSocket, error: NSError?) {
        print("error: \(error?.description)")
    }
}