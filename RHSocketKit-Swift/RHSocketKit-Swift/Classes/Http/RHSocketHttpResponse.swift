//
//  RHSocketHttpResponse.swift
//  RHSocketKit-Swift
//
//  Created by zhuruhong on 16/6/29.
//  Copyright © 2016年 zhuruhong. All rights reserved.
//

import Foundation

public class RHSocketHttpResponse: RHSocketPacketResponse {
    convenience init() {
        self.init(object: nil)
    }
}