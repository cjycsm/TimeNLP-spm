//
//  String+NGPreHanding.swift
//  
//
//  Created by 陈嘉谊 on 2021/2/5.
//

import Foundation

public extension String {
    
    func match(rules: String) -> [NSTextCheckingResult] {
        if let regularExp = try? NSRegularExpression(pattern: rules, options: .caseInsensitive) {
            let match = regularExp.matches(in: self, options: .reportCompletion, range: NSMakeRange(0, count))
            return match
        }
        return []
    }
    
    /**
     * 该方法删除一字符串中所有匹配某一规则字串
     * 可用于清理一个字符串中的空白符和语气助词
     *
     * @param rules 删除规则
     * @return 清理工作完成后的字符串
     */
    func delKeyword(rules: String) -> String {
        var result = self
        var match = result.match(rules: rules)
        while !match.isEmpty {
            result = result.replacingOccurrences(of: result[Range(match[0].range, in: result)!], with: "")
            match = result.match(rules: rules)
        }
        return result
    }
    
    /**
     * 该方法可以将字符串中所有的用汉字表示的数字转化为用阿拉伯数字表示的数字
     * 如"这里有一千两百个人，六百零五个来自中国"可以转化为
     * "这里有1200个人，605个来自中国"
     * 此外添加支持了部分不规则表达方法
     * 如两万零六百五可转化为20650
     * 两百一十四和两百十四都可以转化为214
     * 一六零加一五八可以转化为160+158
     * 该方法目前支持的正确转化范围是0-99999999
     * 该功能模块具有良好的复用性
     *
     * @return 转化完毕后的字符串
     */
    func numberTranslator() -> String {
        var result = self
        
        var rules = "[一二两三四五六七八九123456789]万[一二两三四五六七八九123456789](?!(千|百|十))"
        var match = result.match(rules: rules)
        while !match.isEmpty {
            let s = result[Range(match[0].range, in: result)!].components(separatedBy: "万")
            var num: Int = 0
            if s.count == 2 {
                num += s[0].wordToNumber() * 10000 + s[1].wordToNumber() * 1000
            }
            result = result.replacingOccurrences(of: result[Range(match[0].range, in: result)!], with: "\(num)")
            match = result.match(rules: rules)
        }
        
        rules = "[一二两三四五六七八九123456789]千[一二两三四五六七八九123456789](?!(百|十))"
        match = result.match(rules: rules)
        while !match.isEmpty {
            let s = result[Range(match[0].range, in: result)!].components(separatedBy: "千")
            var num: Int = 0
            if s.count == 2 {
                num += s[0].wordToNumber() * 1000 + s[1].wordToNumber() * 100
            }
            result = result.replacingOccurrences(of: result[Range(match[0].range, in: result)!], with: "\(num)")
            match = result.match(rules: rules)
        }
        
        rules = "[一二两三四五六七八九123456789]百[一二两三四五六七八九123456789](?!十)"
        match = result.match(rules: rules)
        while !match.isEmpty {
            let s = result[Range(match[0].range, in: result)!].components(separatedBy: "百")
            var num: Int = 0
            if s.count == 2 {
                num += s[0].wordToNumber() * 100 + s[1].wordToNumber() * 10
            }
            result = result.replacingOccurrences(of: result[Range(match[0].range, in: result)!], with: "\(num)")
            match = result.match(rules: rules)
        }
        
        rules = "[零一二两三四五六七八九]"
        match = result.match(rules: rules)
        while !match.isEmpty {
            let num = String(result[Range(match[0].range, in: result)!]).wordToNumber()
            result = result.replacingOccurrences(of: result[Range(match[0].range, in: result)!], with: "\(num)")
            match = result.match(rules: rules)
        }
        
        rules = "(?<=(周|星期))[末天日]"
        match = result.match(rules: rules)
        while !match.isEmpty {
            let num = String(result[Range(match[0].range, in: result)!]).wordToNumber()
            result = result.replacingOccurrences(of: result[Range(match[0].range, in: result)!], with: "\(num)")
            match = result.match(rules: rules)
        }
        
        rules = "(?<!(周|星期))0?[0-9]?十[0-9]?"
        match = result.match(rules: rules)
        while !match.isEmpty {
            let s = result[Range(match[0].range, in: result)!].components(separatedBy: "十")
            var num: Int = 0
            if s.count == 0 {
                num += 10
            } else if s.count == 1 {
                let ten = Int(s[0]) ?? 0
                if ten == 0 {
                    num += 10
                } else {
                    num += ten * 10
                }
            } else if s.count == 2 {
                if s[0].count == 0 {
                    num += 10
                } else {
                    let ten = Int(s[0]) ?? 0
                    if ten == 0 {
                        num += 10
                    } else {
                        num += ten * 10
                    }
                }
                num += Int(s[1]) ?? 0
            }
            result = result.replacingOccurrences(of: result[Range(match[0].range, in: result)!], with: "\(num)")
            match = result.match(rules: rules)
        }
                
        rules = "0?[1-9]百[0-9]?[0-9]?"
        match = result.match(rules: rules)
        while !match.isEmpty {
            let s = result[Range(match[0].range, in: result)!].components(separatedBy: "百")
            var num: Int = 0
            if s.count == 1 {
                let hundred = Int(s[0]) ?? 0
                num += hundred * 100
            } else if s.count == 2 {
                let hundred = Int(s[0]) ?? 0
                num += hundred * 100
                num += Int(s[1]) ?? 0
            }
            result = result.replacingOccurrences(of: result[Range(match[0].range, in: result)!], with: "\(num)")
            match = result.match(rules: rules)
        }
        
        rules = "0?[1-9]千[0-9]?[0-9]?[0-9]?"
        match = result.match(rules: rules)
        while !match.isEmpty {
            let s = result[Range(match[0].range, in: result)!].components(separatedBy: "千")
            var num: Int = 0
            if s.count == 1 {
                let hundred = Int(s[0]) ?? 0
                num += hundred * 1000
            } else if s.count == 2 {
                let hundred = Int(s[0]) ?? 0
                num += hundred * 1000
                num += Int(s[1]) ?? 0
            }
            result = result.replacingOccurrences(of: result[Range(match[0].range, in: result)!], with: "\(num)")
            match = result.match(rules: rules)
        }
        
        rules = "[0-9]+万[0-9]?[0-9]?[0-9]?[0-9]?"
        match = result.match(rules: rules)
        while !match.isEmpty {
            let s = result[Range(match[0].range, in: result)!].components(separatedBy: "万")
            var num: Int = 0
            if s.count == 1 {
                let hundred = Int(s[0]) ?? 0
                num += hundred * 10000
            } else if s.count == 2 {
                let hundred = Int(s[0]) ?? 0
                num += hundred * 10000
                num += Int(s[1]) ?? 0
            }
            result = result.replacingOccurrences(of: result[Range(match[0].range, in: result)!], with: "\(num)")
            match = result.match(rules: rules)
        }
        
        return result
    }
    
    /**
     * 方法numberTranslator的辅助方法，可将[零-九]正确翻译为[0-9]
     *
     * @return 对应的整形数，如果不是大写数字返回-1
     */
    private func wordToNumber() -> Int {
        let dictionary = [["零", "0"],
                          ["一", "1"],
                          ["二", "两", "2"],
                          ["三", "3"],
                          ["四", "4"],
                          ["五", "5"],
                          ["六", "6"],
                          ["七", "天", "日", "末", "7"],
                          ["八", "8"],
                          ["九", "9"]];
        var result = -1
        for group in dictionary {
            let index = dictionary.firstIndex(of: group)!
            for word in group {
                if word == self {
                    result = index
                    break
                }
            }
            if result >= 0 {
                break
            }
        }
        return result
    }
    
}

