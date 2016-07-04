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
    
    //数据读取缓冲区
    var readBuffer = NSMutableData()
    //数据写入缓冲区
    var writeBuffer = NSMutableData()
    
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
        
        let error = self.badParamError("Invalid host parameter (nil or \"\"). Should be a domain name or IP address string.")
        
        if dispatch_get_specific(IsOnSocketQueueOrTargetQueueKey) != nil {
            createReadAndWriteStream(host, port: port)
        } else {
            dispatch_sync(self.socketQueue, {
                self.createReadAndWriteStream(host, port: port)
            })
        }
        return (0, error)
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
    
    private func createReadAndWriteStream(host: String, port: Int) -> Bool {
        assertOnSocketQueue()
        
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
    
    private func addStreamsToRunLoop() -> Bool {
        assertOnSocketQueue()
        
        let runLoop = NSRunLoop.currentRunLoop()
        readStream?.scheduleInRunLoop(runLoop, forMode: NSDefaultRunLoopMode)
        writeStream?.scheduleInRunLoop(runLoop, forMode: NSDefaultRunLoopMode)
        
        return true
    }
    
    private func removeStreamsFromRunLoop() -> Bool {
        assertOnSocketQueue()
        
        let runLoop = NSRunLoop.currentRunLoop()
        readStream?.removeFromRunLoop(runLoop, forMode: NSDefaultRunLoopMode)
        writeStream?.removeFromRunLoop(runLoop, forMode: NSDefaultRunLoopMode)
        
        return true
    }
    
    func openStreams() -> Void {
        assertOnSocketQueue()
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
            print("\(eventCode.rawValue) OpenCompleted")
            
            if readStream?.streamStatus == NSStreamStatus.Open && writeStream?.streamStatus == NSStreamStatus.Open {
                delegate?.didConnectToHost!(self, host: self.host, port: self.port)
                writeData(nil, timeout: -1)
            }
            break
        case NSStreamEvent.HasBytesAvailable:
            print("\(eventCode.rawValue) HasBytesAvailable")
            let bufferSize = 4096
            var buffer = [UInt8](count: bufferSize, repeatedValue: 0)
            let bytesRead = readStream?.read(&buffer, maxLength: bufferSize)
            if bytesRead > 0 {
                delegate?.didReadData!(self, data: NSData(bytes: buffer, length: bytesRead!))
            } else {
                print("bytesRead = \(bytesRead)")
            }
            break
        case NSStreamEvent.HasSpaceAvailable:
            print("\(eventCode.rawValue) HasSpaceAvailable")
            writeData(nil, timeout: -1)
            break
        case NSStreamEvent.ErrorOccurred:
            print("\(eventCode.rawValue) ErrorOccurred")
            disconnect()
            delegate?.didDisconnect!(self, error: aStream.streamError)
            break
        case NSStreamEvent.EndEncountered:
            print("\(eventCode.rawValue) EndEncountered")
            disconnect()
            delegate?.didDisconnect!(self, error: aStream.streamError)
            break
        default:
            break
        }
    }
    
    private func close(error: NSError?) -> Void {
        assertOnSocketQueue()
        
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
    
    func writeData(data: NSData?, timeout: NSTimeInterval) {
        dispatch_async(self.socketQueue, {
            if nil != data && data!.length > 0 {
                self.writeBuffer.appendData(data!)
            }
            self.pumpWriting()
        })
    }
    
    func pumpWriting() -> Void {
        assertOnSocketQueue()
        
        let dataLength = self.writeBuffer.length
        
        guard dataLength > 0 && (writeStream?.hasSpaceAvailable)! else {
            return
        }
        
        let buffer = unsafeBitCast(self.writeBuffer.bytes, UnsafePointer<UInt8>.self)
        let bytesWritten = writeStream?.write(buffer, maxLength: dataLength)
        print("bytesWritten = \(bytesWritten)")
        
        if bytesWritten == -1 {
            self.badParamError("Error writing to stream")
            return
        }
        
        guard bytesWritten > 0 else {
            return
        }
        
        let range = NSRange(location: 0, length: bytesWritten!)
        writeBuffer = NSMutableData(data: writeBuffer.subdataWithRange(range))
    }
    
    //-----------------------------------------------------
    
    func assertOnSocketQueue() -> Void {
        assert(dispatch_get_specific(IsOnSocketQueueOrTargetQueueKey) != nil, "Must be dispatched on socketQueue")
    }
    
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