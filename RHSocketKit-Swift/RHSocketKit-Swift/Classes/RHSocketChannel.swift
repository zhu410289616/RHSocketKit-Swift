//
//  RHSocketChannel.swift
//  RHSocketKit-Swift
//
//  Created by zhuruhong on 16/6/17.
//  Copyright © 2016年 zhuruhong. All rights reserved.
//

import Foundation

@objc public protocol RHSocketChannelDelegate: NSObjectProtocol {
    optional func channelOpened(channel: RHSocketChannel, host: String, port: Int)
    optional func channelClosed(channel: RHSocketChannel, error: NSError)
    optional func channelReceived(channel: RHSocketChannel, packet: AnyObject)
}

public class RHSocketChannel: RHSocketConnection, RHSocketEncoderOutputProtocol, RHSocketDecoderOutputProtocol {
    
    var host: String!
    var port: Int!
    
    var encoder: RHSocketEncoderProtocol?
    var decoder: RHSocketDecoderProtocol?
    
    var delegate: RHSocketChannelDelegate?
    
    private var receiveDataBuffer = NSMutableData()
    private var downstreamContext = RHSocketPacketResponse()
    
    init(host: String, port: Int) {
        self.host = host
        self.port = port
        super.init()
    }
    
    func openConnection() -> Void {
        self.disconnect()
        self.connect(host: host, port: port)
    }
    
    func closeConnection() -> Void {
        self.disconnect()
    }
    
    func asyncSendPacket(packet: RHUpstreamPacket) -> Void {
        guard self.encoder != nil else {
            return
        }
        self.encoder?.encode(packet, output: self)
    }
    
    //------------ RHAsyncSocketDelegate
    
    public override func didConnectToHost(socket: RHAsyncSocket, host: String, port: Int) {
        print("host: \(host), port:\(port)")
        
        delegate?.channelOpened!(self, host: host, port: port)
    }
    
    public override func didReadData(socket: RHAsyncSocket, data: NSData?) {
        print("data: \(data)")
        
        guard data!.length > 0 else {
            return
        }
        
        guard self.decoder != nil else {
            return
        }
        
        self.receiveDataBuffer.appendData(data!)
        
        self.downstreamContext.object = self.receiveDataBuffer
        let decodedLength = self.decoder?.decode(self.downstreamContext, output: self)
        guard decodedLength >= 0 else {
            closeConnection()
            return
        }
        
        let remainLength = self.receiveDataBuffer.length - decodedLength!
        let remainData = self.receiveDataBuffer.subdataWithRange(NSRange(location: decodedLength!, length: remainLength))
        self.receiveDataBuffer.setData(remainData)
    }
    
    //------------ RHSocketEncoderOutputProtocol
    
    func didEncode(encodedData: NSData, timeout: NSTimeInterval) {
        guard encodedData.length > 0 else {
            return
        }
        self.writeData(encodedData, timeout: timeout)
    }
    
    //------------ RHSocketDecoderOutputProtocol
    
    func didDecode(decodedPacket: RHDownstreamPacket) {
        self.delegate?.channelReceived!(self, packet: decodedPacket)
    }
}
