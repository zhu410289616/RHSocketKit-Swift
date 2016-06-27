//
//  RHAsyncSocket.swift
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
    optional func didReadData(socket: RHAsyncSocket, data: NSData?)
    
    /**
     * Called when a socket has completed writing the requested data. Not called if there is an error.
     **/
    optional func didWriteData(socket: RHAsyncSocket)
    
    /**
     * Called when a socket disconnects with or without error.
     **/
    optional func didDisconnect(socket: RHAsyncSocket, error: NSError?)
    
}

public class RHAsyncSocket: NSObject, NSStreamDelegate {
    
    let RHSwiftSocketQueueName = "RHSwiftSocketQueue"
    let RHSwiftSocketQueueOrTargetQueueKey = 1
    
    var delegate: RHAsyncSocketDelegate?
    var delegateQueue: dispatch_queue_t?
    
    var socketQueue: dispatch_queue_t!
    var IsOnSocketQueueOrTargetQueueKey: UnsafePointer<Void>!
    
    var host: String!
    var port: Int!
    
    var readStream: NSInputStream?
    var writeStream: NSOutputStream?
    
    convenience override init() {
        self.init(delegate: nil, delegateQueue: nil, socketQueue: nil)
    }
    
    convenience init(delegate: RHAsyncSocketDelegate?, delegateQueue: dispatch_queue_t?) {
        self.init(delegate: delegate, delegateQueue: delegateQueue, socketQueue: nil)
    }
    
    init(delegate: RHAsyncSocketDelegate?, delegateQueue: dispatch_queue_t?, socketQueue: dispatch_queue_t?) {
        self.delegate = delegate
        self.delegateQueue = delegateQueue
        super.init()
        
        if socketQueue != nil {
            self.socketQueue = socketQueue
        } else {
            self.socketQueue = dispatch_queue_create(RHSwiftSocketQueueName, DISPATCH_QUEUE_SERIAL)
        }
        IsOnSocketQueueOrTargetQueueKey = unsafeBitCast(RHSwiftSocketQueueOrTargetQueueKey, UnsafePointer<Void>.self)
        
        let nonNullUnusedPointer = unsafeBitCast(self, UnsafeMutablePointer<Void>.self)
        dispatch_queue_set_specific(self.socketQueue, IsOnSocketQueueOrTargetQueueKey, nonNullUnusedPointer, nil)
    }
    
    func connect(host host: String, port: Int) -> (result: Int, error: NSError?) {
        return connect(host: host, port: port, timeout: -1)
    }
    
    func connect(host host: String, port: Int, timeout: NSTimeInterval) -> (result: Int, error: NSError?) {
        
        
        //        let error = self.badParamError("Invalid host parameter (nil or \"\"). Should be a domain name or IP address string.")
        
        if dispatch_get_specific(IsOnSocketQueueOrTargetQueueKey) != nil {
            createReadAndWriteStream(host, port: port)
        } else {
            dispatch_sync(self.socketQueue, {
                self.createReadAndWriteStream(host, port: port)
            })
        }
        return (0, nil)
    }
    
    func isConnected() -> Bool {
        var result = false
        
        if dispatch_get_specific(IsOnSocketQueueOrTargetQueueKey) != nil {
            //            result = (self.flags == 1)
            result = true
        } else {
            dispatch_sync(socketQueue!, {
                result = true
            })
        }
        
        return result
    }
    
    func createReadAndWriteStream(host: String, port: Int) -> Bool {
        assert(dispatch_get_specific(IsOnSocketQueueOrTargetQueueKey) != nil, "Must be dispatched on socketQueue")
        
        if readStream != nil || writeStream != nil {
            // Streams already created
            return true
        }
        
        if !isConnected() {
            // Cannot create streams until file descriptor is connected
            return false
        }
        
        autoreleasepool({
            self.host = host
            self.port = port
            
            NSStream.getStreamsToHostWithName(host, port: port, inputStream: &readStream, outputStream: &writeStream)
            readStream?.delegate = self
            writeStream?.delegate = self
            
            addStreamsToRunLoop()
            openStreams()
        })
        
        return true
    }
    
    func addStreamsToRunLoop() -> Bool {
        assert(dispatch_get_specific(IsOnSocketQueueOrTargetQueueKey) != nil, "Must be dispatched on socketQueue")
        
        let runLoop = NSRunLoop.currentRunLoop()
        readStream?.scheduleInRunLoop(runLoop, forMode: NSDefaultRunLoopMode)
        writeStream?.scheduleInRunLoop(runLoop, forMode: NSDefaultRunLoopMode)
        
        return true
    }
    
    func removeStreamsFromRunLoop() -> Bool {
        assert(dispatch_get_specific(IsOnSocketQueueOrTargetQueueKey) != nil, "Must be dispatched on socketQueue")
        
        let runLoop = NSRunLoop.currentRunLoop()
        readStream?.removeFromRunLoop(runLoop, forMode: NSDefaultRunLoopMode)
        writeStream?.removeFromRunLoop(runLoop, forMode: NSDefaultRunLoopMode)
        
        return true
    }
    
    func openStreams() -> Void {
        assert(dispatch_get_specific(IsOnSocketQueueOrTargetQueueKey) != nil, "Must be dispatched on socketQueue")
        assert((readStream != nil && writeStream != nil), "Read/Write stream is null")
        
        let readStatus = readStream?.streamStatus
        if readStatus == NSStreamStatus.NotOpen {
            readStream?.open()
        }
        
        let writeStatus = writeStream?.streamStatus
        if writeStatus == NSStreamStatus.NotOpen {
            writeStream?.open()
        }
    }
    
    public func stream(aStream: NSStream, handleEvent eventCode: NSStreamEvent) {
        print(" >>> eventCode: \(eventCode.rawValue)")
        
        switch eventCode {
        case NSStreamEvent.OpenCompleted:
            print("OpenCompleted")
            delegate?.didConnectToHost!(self, host: self.host, port: self.port)
            break
        case NSStreamEvent.HasBytesAvailable:
            print("HasBytesAvailable")
            let defaultBytesToRead = 4096
            var buffer = [UInt8](count: defaultBytesToRead, repeatedValue: 0)
            let result = readStream?.read(&buffer, maxLength: defaultBytesToRead)
            delegate?.didReadData!(self, data: NSData(bytes: buffer, length: result!))
            break
        case NSStreamEvent.HasSpaceAvailable:
            print("HasSpaceAvailable")
            break
        case NSStreamEvent.ErrorOccurred:
            print("ErrorOccurred")
            delegate?.didDisconnect!(self, error: aStream.streamError)
            break
        case NSStreamEvent.EndEncountered:
            print("EndEncountered")
            delegate?.didDisconnect!(self, error: aStream.streamError)
            break
        default:
            break
        }
    }
    
    func close(error: NSError?) -> Void {
        assert(dispatch_get_specific(IsOnSocketQueueOrTargetQueueKey) != nil, "Must be dispatched on socketQueue")
        
        removeStreamsFromRunLoop()
        
        readStream?.close()
        readStream = nil
        
        writeStream?.close()
        writeStream = nil
    }
    
    func disconnect() -> Void {
        // Synchronous disconnection, as documented in the header file
        
        if dispatch_get_specific(IsOnSocketQueueOrTargetQueueKey) != nil {
            close(nil)
        } else {
            dispatch_sync(socketQueue!, {
                self.close(nil)
            })
        }
    }
    
    //-----------------------------------------------------
    
    func writeData(data: NSData, timeout: NSTimeInterval) {
        let buffer = unsafeBitCast(data.bytes, UnsafePointer<UInt8>.self)
        self.writeStream?.write(buffer, maxLength: data.length)
    }
    
    //-----------------------------------------------------
    
    func badParamError(errorMsg: String) -> NSError {
        let userInfo = [NSLocalizedDescriptionKey : errorMsg]
        return NSError(domain: RHAsyncSocketErrorDomain, code: RHAsyncSocketError.BadParamError.rawValue, userInfo: userInfo)
    }
    
    func connectTimeoutError() -> NSError {
        let errorMsg = "Attempt to connect to host timed out"
        let userInfo = [NSLocalizedDescriptionKey : errorMsg]
        return NSError(domain: RHAsyncSocketErrorDomain, code: RHAsyncSocketError.ConnectTimeoutError.rawValue, userInfo: userInfo)
    }
}