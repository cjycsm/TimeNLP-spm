//
//  TimePoint.swift
//  
//
//  Created by 陈嘉谊 on 2021/2/5.
//

import Foundation

public class TimePoint {
    
    /**
     * 时间表达式单元规范化对应的内部类,
     * 对应时间表达式规范化的每个字段，
     * 六个字段分别是：年-月-日-时-分-秒，
     * 每个字段初始化为-1
     */
    public var tunit: [Int]
    
    init() {
        tunit = [-1, -1, -1, -1, -1, -1]
    }
    
}
