//
//  RHSocketPacket.swift
//  RHSocketKit-Swift
//
//  Created by zhuruhong on 16/6/17.
//  Copyright © 2016年 zhuruhong. All rights reserved.
//

import Foundation

@objc public protocol RHSocketPacket: NSObjectProtocol {
    var object: AnyObject? { get set }
    optional var pid: NSNumber? { get set }
    func dataWithPacket() -> NSData?
    func stringWithPacket() -> NSString?
}

@objc public protocol RHUpstreamPacket: RHSocketPacket {
    optional var timeout: NSTimeInterval { get  set }
}

@objc public protocol RHDownstreamPacket: RHSocketPacket {
    
}

public class RHSocketPacketContext: NSObject, RHDownstreamPacket, RHUpstreamPacket {
    
    public var object: AnyObject?
    
    public func dataWithPacket() -> NSData? {
        if ((object?.isKindOfClass(NSData)) != nil) {
            return object as? NSData
        } else if (object?.isKindOfClass(NSString)) != nil {
            return object?.dataUsingEncoding(NSUTF8StringEncoding, allowLossyConversion: true)
        }
        return nil
    }
    
    public func stringWithPacket() -> NSString? {
        if ((object?.isKindOfClass(NSString)) != nil) {
            return object as? String
        } else if ((object?.isKindOfClass(NSData)) != nil) {
            return NSString(data: unsafeBitCast(object, NSData.self), encoding: NSUTF8StringEncoding)
        }
        return nil
    }
}

public class RHSocketPacketRequest: RHSocketPacketContext {
    public var pid: NSNumber?
    public var timeout: NSTimeInterval = -1
}

public class RHSocketPacketResponse: RHSocketPacketContext {
    public var pid: NSNumber?
    
    override convenience init() {
        self.init(object: nil)
    }
    
    public init(object: AnyObject?) {
        super.init()
        self.object = object
    }
}
