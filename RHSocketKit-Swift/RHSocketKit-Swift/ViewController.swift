//
//  ViewController.swift
//  RHSocketKit-Swift
//
//  Created by zhuruhong on 16/6/17.
//  Copyright © 2016年 zhuruhong. All rights reserved.
//

import UIKit

class ViewController: UIViewController, RHAsyncSocketDelegate, RHSocketChannelDelegate {
    
    //socket
    var socket: RHAsyncSocket?
    
    //channel
    var channel: RHSocketChannel?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        //
//        testSocket()
        
        //
        testChannel()
        
    }
    
    // channel
    
    func testChannel() {
        channel = RHSocketChannel(host: "www.baidu.com", port: 80)
        channel?.delegate = self
        channel?.decoder = RHSocketHttpDecoder()
        channel?.encoder = RHSocketHttpEncoder()
        channel?.openConnection()
    }
    
    func channelOpened(channel: RHSocketChannel, host: String, port: Int) {
        print("channelOpened host: \(host), port:\(port)")
        
        let req = RHSocketHttpRequest()
        channel.asyncSendPacket(req)
    }
    
    func channelClosed(channel: RHSocketChannel, error: NSError) {
        print("channelClosed: \(error)")
    }
    
    func channelReceived(channel: RHSocketChannel, packet: AnyObject) {
        print("channelReceived: \(packet)")
    }
    
    // socket
    
    func testSocket() {
        socket = RHAsyncSocket(delegate: self, delegateQueue: dispatch_get_main_queue())
        socket!.connect(host: "www.baidu.com", port: 80)
    }
    
    func didConnectToHost(socket: RHAsyncSocket, host: String, port: Int) {
        print("host: \(host), port:\(port)")
    }
    
    func didReadData(socket: RHAsyncSocket, data: NSData?) {
        print("data: \(data)")
    }
    
    func didWriteData(socket: RHAsyncSocket) {
        print("didWriteData")
    }
    
    func didDisconnect(socket: RHAsyncSocket, error: NSError?) {
        print("didDisconnect: \(error)")
    }
    
}

