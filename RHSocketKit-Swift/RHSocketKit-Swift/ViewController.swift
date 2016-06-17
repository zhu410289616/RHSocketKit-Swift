//
//  ViewController.swift
//  RHSocketKit-Swift
//
//  Created by zhuruhong on 16/6/17.
//  Copyright © 2016年 zhuruhong. All rights reserved.
//

import UIKit

class ViewController: UIViewController, RHAsyncSocketDelegate {
    
    var socket: RHAsyncSocket?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        socket = RHAsyncSocket(delegate: self, delegateQueue: dispatch_get_main_queue())
        socket!.connect(host: "www.baidu.com", port: 80)
        
    }
    
    func didConnectToHost(socket: RHAsyncSocket, host: String, port: Int) {
        print("host: \(host), port:\(port)")
    }
    
    func didReadData(socket: RHAsyncSocket, data: NSData) {
        print("data: \(data)")
    }
    
    func didWriteData(socket: RHAsyncSocket) {
        print("didWriteData")
    }
    
    func didDisconnect(socket: RHAsyncSocket, error: NSError) {
        print("didDisconnect: \(error)")
    }
    
}

