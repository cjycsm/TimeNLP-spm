//
//  TimeUnit.swift
//  TimeNLP
//
//  Created by 陈嘉谊 on 2021/2/5.
//

import Foundation

public class TimeUnit {
    
    enum RangeTime: Int {
        case rt_day_break = 3 //凌晨
        case rt_early_morning = 8 //早
        case rt_morning = 10 //上午
        case rt_noon = 12 //中午、午间
        case rt_afternoon = 15 //下午、午后
        case rt_night = 18 //晚上、傍晚
        case rt_late_night = 20 //晚、晚间
        case rt_mid_night = 23  //深夜
    }
    
    public var timeExpression: String?
    
    public var timeNorm: String
    
    public var time: Date?
    
    public var timeFull: [Int]?
        
    public var tp: TimePoint
    
    public var tpOrigin: TimePoint
    
    public var isAllDayTime: Bool
    
    weak public var normalizer: TimeNormalizer?
    
    private var isFirstTimeSolveContext: Bool
    
    init() {
        isAllDayTime = true
        isFirstTimeSolveContext = true
        timeNorm = ""
        tp = TimePoint()
        tpOrigin = TimePoint()
    }
    
    /**
     * 时间表达式规范化的入口
     * <p>
     * 时间表达式识别后，通过此入口进入规范化阶段，
     * 具体识别每个字段的值
     */
    func timeNormalization() {
        guard let normalizer = normalizer, let timeBase = normalizer.timeBase else {return}

        normSetYear()
        normSetMonth()
        normSetDay()
        normSetMonthFuzzyDay()
        normSetBaseRelated()
        normSetCurRelated()
        normSetHour()
        normSetMinute()
        normSetSecond()
        normSetTotal()
        modifyTimeBase()
        
        tpOrigin.tunit = tp.tunit
        
        let timeGrid = timeBase.components(separatedBy: "-")
        var tunitpointer = 5;
        while tunitpointer >= 0 && tp.tunit[tunitpointer] < 0 {
            tunitpointer -= 1
        }
        for i in 0..<tunitpointer {
            if (tp.tunit[i] < 0) {
                tp.tunit[i] = Int(timeGrid[i]) ?? 0
            }
        }
        var resultTmp: [String] = []
        resultTmp[0] = "\(tp.tunit[0])"
        if tp.tunit[0] >= 10 && tp.tunit[0] < 100 {
            resultTmp[0] = "19\(tp.tunit[0])"
        } else if tp.tunit[0] > 0 && tp.tunit[0] < 10 {
            resultTmp[0] = "200\(tp.tunit[0])"
        }
        
        for i in 1..<6 {
            resultTmp[i] = "\(tp.tunit[i])"
        }
        
        var date =  now()
        if Int(resultTmp[0]) != -1 {
            timeNorm += resultTmp[0] + "年"
            date = date.ng_fs_setYear(Int(resultTmp[0])!)
            if Int(resultTmp[1]) != -1 {
                timeNorm += resultTmp[1] + "月"
                date = date.ng_fs_setMonth(Int(resultTmp[1])!)
                if Int(resultTmp[2]) != -1 {
                    timeNorm += resultTmp[2] + "日"
                    date = date.ng_fs_setDay(Int(resultTmp[2])!)
                    if Int(resultTmp[3]) != -1 {
                        timeNorm += resultTmp[3] + "时"
                        date = date.ng_fs_setHour(Int(resultTmp[3])!)
                        if Int(resultTmp[4]) != -1 {
                            timeNorm += resultTmp[4] + "分"
                            date = date.ng_fs_setMinute(Int(resultTmp[4])!)
                            if Int(resultTmp[5]) != -1 {
                                timeNorm += resultTmp[5] + "秒"
                                date = date.ng_fs_setSecond(Int(resultTmp[5])!)
                            } else {
                                date = date.ng_fs_setSecond(0)
                            }
                        } else {
                            date = date.ng_fs_setMinute(0)
                            date = date.ng_fs_setSecond(0)
                        }
                    } else {
                        date = date.ng_fs_setHour(8)
                        date = date.ng_fs_setMinute(0)
                        date = date.ng_fs_setSecond(0)
                    }
                }
            }
            time = date
        } else {
            time = nil
        }
        timeFull = tp.tunit
    }
    
    /**
     * 年-规范化方法
     * <p>
     * 该方法识别时间表达式单元的年字段
     */
    func normSetYear() {
        var match = matchTimeExpression(rule: "[0-9]{2}(?=年)")
        if !match.isEmpty, let timeExpression = timeExpression {
            tp.tunit[0] = Int(timeExpression[Range(match[0].range, in: timeExpression)!]) ?? 0
            if tp.tunit[0] >= 0 && tp.tunit[0] < 100 {
                if tp.tunit[0] < 30 {
                    tp.tunit[0] = tp.tunit[0] + 2000
                } else {
                    tp.tunit[0] = tp.tunit[0] + 1900
                }
            }
        }
        match = matchTimeExpression(rule: "[0-9]?[0-9]{3}(?=年)")
        if !match.isEmpty, let timeExpression = timeExpression {
            tp.tunit[0] = Int(timeExpression[Range(match[0].range, in: timeExpression)!]) ?? 0
        }
    }
    
    /**
     * 月-规范化方法
     * <p>
     * 该方法识别时间表达式单元的月字段
     */
    func normSetMonth() {
        let match = matchTimeExpression(rule: "((10)|(11)|(12)|([1-9]))(?=月)")
        if !match.isEmpty, let timeExpression = timeExpression {
            tp.tunit[1] = Int(timeExpression[Range(match[0].range, in: timeExpression)!]) ?? 0
        }
        preferFuture(1)
    }
    
    /**
     * 月-日 兼容模糊写法
     * <p>
     * 该方法识别时间表达式单元的月、日字段
     * <p>
     */
    func normSetMonthFuzzyDay() {
        var match = matchTimeExpression(rule: "((10)|(11)|(12)|(0[1-9])|([1-9]))(月|\\.|-|/)([0-3][0-9]|[1-9])(?!(\\.|-|/))")
        if !match.isEmpty, let timeExpression = timeExpression {
            let matchStr = String(timeExpression[Range(match[0].range, in: timeExpression)!])
            match = self.match(matchStr, rule: "(月|\\.|-|/)")
            if !match.isEmpty {
                let month = String(matchStr.prefix(match[0].range.location))
                let day = String(matchStr.suffix(from: matchStr.index(matchStr.startIndex, offsetBy: match[0].range.location + 1)))
                tp.tunit[1] = Int(month) ?? 0
                tp.tunit[2] = Int(day) ?? 0
                preferFuture(1)
            }
        }
    }
    
    /**
     * 日-规范化方法
     * <p>
     * 该方法识别时间表达式单元的日字段
     */
    func normSetDay() {
        let match = matchTimeExpression(rule: "((?<!\\d))([0-3][0-9]|[1-9])(?=(日|号))")
        if !match.isEmpty, let timeExpression = timeExpression {
            tp.tunit[2] = Int(timeExpression[Range(match[0].range, in: timeExpression)!]) ?? 0
            preferFuture(2)
        }
    }
    
    /**
     * 时-规范化方法
     * <p>
     * 该方法识别时间表达式单元的时字段
     */
    func normSetHour() {
        var match = matchTimeExpression(rule: "(?<!(周|星期|礼拜))([0-2]?[0-9])(?=(点|时))")
        if !match.isEmpty, let timeExpression = timeExpression {
            tp.tunit[3] = Int(timeExpression[Range(match[0].range, in: timeExpression)!]) ?? 0
            preferFuture(3)
            isAllDayTime = false
        }
        /*
         * 对关键字：早（包含早上/早晨/早间），上午，中午,午间,下午,午后,晚上,傍晚,晚间,晚,pm,PM的正确时间计算
         * 规约：
         * 1.中午/午间0-10点视为12-22点
         * 2.下午/午后0-11点视为12-23点
         * 3.晚上/傍晚/晚间/晚1-11点视为13-23点，12点视为0点
         * 4.0-11点pm/PM视为12-23点
         *
         * add by kexm
         */
        match = matchTimeExpression(rule: "凌晨")
        if !match.isEmpty {
            if tp.tunit[3] == -1 {
                tp.tunit[3] = RangeTime.rt_day_break.rawValue
            }
            preferFuture(3)
            isAllDayTime = false
        }
        
        match = matchTimeExpression(rule: "早上|早晨|早间|晨间|今早|明早")
        if !match.isEmpty {
            if tp.tunit[3] == -1 {
                tp.tunit[3] = RangeTime.rt_early_morning.rawValue
            }
            preferFuture(3)
            isAllDayTime = false
        }
        
        match = matchTimeExpression(rule: "上午")
        if !match.isEmpty {
            if tp.tunit[3] == -1 {
                tp.tunit[3] = RangeTime.rt_morning.rawValue
            }
            preferFuture(3)
            isAllDayTime = false
        }
        
        match = matchTimeExpression(rule: "(中午)|(午间)")
        if !match.isEmpty {
            if tp.tunit[3] >= 0 && tp.tunit[3] <= 10 {
                tp.tunit[3] += 12
            }
            if tp.tunit[3] == -1 {
                tp.tunit[3] = RangeTime.rt_noon.rawValue
            }
            preferFuture(3)
            isAllDayTime = false
        }
        
        match = matchTimeExpression(rule: "(下午)|(午后)|(pm)|(PM)")
        if !match.isEmpty {
            if tp.tunit[3] >= 0 && tp.tunit[3] <= 11 {
                tp.tunit[3] += 12
            }
            if tp.tunit[3] == -1 {
                tp.tunit[3] = RangeTime.rt_afternoon.rawValue
            }
            preferFuture(3)
            isAllDayTime = false
        }
        
        match = matchTimeExpression(rule: "晚上|夜间|夜里|今晚|明晚")
        if !match.isEmpty {
            if tp.tunit[3] >= 0 && tp.tunit[3] <= 11 {
                tp.tunit[3] += 12
            } else if tp.tunit[3] == 12 {
                tp.tunit[3] = 0
            }
            if tp.tunit[3] == -1 {
                tp.tunit[3] = RangeTime.rt_night.rawValue
            }
            preferFuture(3)
            isAllDayTime = false
        }
    }

    /**
     * 分-规范化方法
     * <p>
     * 该方法识别时间表达式单元的分字段
     */
    func normSetMinute() {
        var match = matchTimeExpression(rule: "([0-5]?[0-9](?=分(?!钟)))|((?<=((?<!小)[点时]))[0-5]?[0-9](?!刻))")
        if !match.isEmpty, let timeExpression = timeExpression {
            tp.tunit[4] = Int(timeExpression[Range(match[0].range, in: timeExpression)!]) ?? 0
            preferFuture(4)
            isAllDayTime = false
        }
        
        match = matchTimeExpression(rule: "(?<=[点时])[1一]刻(?!钟)")
        if !match.isEmpty {
            tp.tunit[4] = 15
            preferFuture(4)
            isAllDayTime = false
        }
        
        match = matchTimeExpression(rule: "(?<=[点时])半")
        if !match.isEmpty {
            tp.tunit[4] = 30
            preferFuture(4)
            isAllDayTime = false
        }
        
        match = matchTimeExpression(rule: "(?<=[点时])[3三]刻(?!钟)")
        if !match.isEmpty {
            tp.tunit[4] = 45
            preferFuture(4)
            isAllDayTime = false
        }
    }
    
    /**
     * 秒-规范化方法
     * <p>
     * 该方法识别时间表达式单元的秒字段
     */
    func normSetSecond() {
        let match = matchTimeExpression(rule: "([0-5]?[0-9](?=秒))|((?<=分)[0-5]?[0-9])")
        if !match.isEmpty, let timeExpression = timeExpression {
            tp.tunit[5] = Int(timeExpression[Range(match[0].range, in: timeExpression)!]) ?? 0
            isAllDayTime = false
        }
    }
    
    /**
     * 特殊形式的规范化方法
     * <p>
     * 该方法识别特殊形式的时间表达式单元的各个字段
     */
    func normSetTotal() {
        var tmpParser: [String] = []
        var tmpTarget: String = ""
        
        var match = matchTimeExpression(rule: "(?<!(周|星期|礼拜))([0-2]?[0-9]):[0-5]?[0-9]:[0-5]?[0-9]")
        if !match.isEmpty, let timeExpression = timeExpression {
            tmpTarget = String(timeExpression[Range(match[0].range, in: timeExpression)!])
            tmpParser = tmpTarget.components(separatedBy: ":")
            tp.tunit[3] = Int(tmpParser[0]) ?? 0
            tp.tunit[4] = Int(tmpParser[1]) ?? 0
            tp.tunit[5] = Int(tmpParser[2]) ?? 0
            preferFuture(3)
            isAllDayTime = false
        } else {
            match = matchTimeExpression(rule: "(?<!(周|星期))([0-2]?[0-9]):[0-5]?[0-9]")
            if !match.isEmpty, let timeExpression = timeExpression {
                tmpTarget = String(timeExpression[Range(match[0].range, in: timeExpression)!])
                tmpParser = tmpTarget.components(separatedBy: ":")
                tp.tunit[3] = Int(tmpParser[0]) ?? 0
                tp.tunit[4] = Int(tmpParser[1]) ?? 0
                preferFuture(3)
                isAllDayTime = false
            }
        }
   
        match = matchTimeExpression(rule: "[0-9]?[0-9]?[0-9]{2}-((10)|(11)|(12)|([1-9]))-((?<!\\d))([0-3][0-9]|[1-9])")
        if !match.isEmpty, let timeExpression = timeExpression {
            tmpTarget = String(timeExpression[Range(match[0].range, in: timeExpression)!])
            tmpParser = tmpTarget.components(separatedBy: "-")
            tp.tunit[0] = Int(tmpParser[0]) ?? 0
            tp.tunit[1] = Int(tmpParser[1]) ?? 0
            tp.tunit[2] = Int(tmpParser[2]) ?? 0
        }
        
        match = matchTimeExpression(rule: "((10)|(11)|(12)|([1-9]))/((?<!\\d))([0-3][0-9]|[1-9])/[0-9]?[0-9]?[0-9]{2}")
        if !match.isEmpty, let timeExpression = timeExpression {
            tmpTarget = String(timeExpression[Range(match[0].range, in: timeExpression)!])
            tmpParser = tmpTarget.components(separatedBy: "/")
            tp.tunit[0] = Int(tmpParser[1]) ?? 0
            tp.tunit[1] = Int(tmpParser[0]) ?? 0
            tp.tunit[2] = Int(tmpParser[1]) ?? 0
        }
    }
    
    func normSetBaseRelated() {
        var date = now()
        var flags = [false, false, false]
        
        var match = matchTimeExpression(rule: "\\d+(?=天[以之]?前)")
        if !match.isEmpty, let timeExpression = timeExpression {
            flags[2] = true
            let day = Int(timeExpression[Range(match[0].range, in: timeExpression)!]) ?? 0
            date = date.ng_fs_dateBySubtractingDays(day)
        }
        
        match = matchTimeExpression(rule: "\\d+(?=天[以之]?后)")
        if !match.isEmpty, let timeExpression = timeExpression {
            flags[2] = true
            let day = Int(timeExpression[Range(match[0].range, in: timeExpression)!]) ?? 0
            date = date.ng_fs_dateByAddingDays(day)
        }
        
        match = matchTimeExpression(rule: "\\d+(?=(个)?月[以之]?前)")
        if !match.isEmpty, let timeExpression = timeExpression {
            flags[1] = true
            let month = Int(timeExpression[Range(match[0].range, in: timeExpression)!]) ?? 0
            date = date.ng_fs_dateBySubtractingMonths(month)
        }
        
        match = matchTimeExpression(rule: "\\d+(?=(个)?月[以之]?后)")
        if !match.isEmpty, let timeExpression = timeExpression {
            flags[1] = true
            let month = Int(timeExpression[Range(match[0].range, in: timeExpression)!]) ?? 0
            date = date.ng_fs_dateByAddingMonths(month)
        }
        
        match = matchTimeExpression(rule: "\\d+(?=年[以之]?前)")
        if !match.isEmpty, let timeExpression = timeExpression {
            flags[0] = true
            let year = Int(timeExpression[Range(match[0].range, in: timeExpression)!]) ?? 0
            date = date.ng_fs_dateBySubtractingYears(year)
        }
        
        match = matchTimeExpression(rule: "\\d+(?=年[以之]?后)")
        if !match.isEmpty, let timeExpression = timeExpression {
            flags[0] = true
            let year = Int(timeExpression[Range(match[0].range, in: timeExpression)!]) ?? 0
            date = date.ng_fs_dateByAddingYears(year)
        }
        
        if flags[0] || flags[1] || flags[2] {
            tp.tunit[0] = date.ng_fs_year()
        }
        if flags[1] || flags[2] {
            tp.tunit[1] = date.ng_fs_month()
        }
        if flags[2] {
            tp.tunit[2] = date.ng_fs_day()
        }
    }
    
    func normSetCurRelated() {
        var date = now()
        var flags = [false, false, false]
        
        var match = matchTimeExpression(rule: "前年")
        if !match.isEmpty {
            flags[0] = true
            date = date.ng_fs_dateBySubtractingYears(2)
        }
        
        match = matchTimeExpression(rule: "去年")
        if !match.isEmpty {
            flags[0] = true
            date = date.ng_fs_dateBySubtractingYears(1)
        }
        
        match = matchTimeExpression(rule: "今年")
        if !match.isEmpty {
            flags[0] = true
        }
        
        match = matchTimeExpression(rule: "明年")
        if !match.isEmpty {
            flags[0] = true
            date = date.ng_fs_dateByAddingYears(1)
        }
        
        match = matchTimeExpression(rule: "后年")
        if !match.isEmpty {
            flags[0] = true
            date = date.ng_fs_dateByAddingYears(2)
        }
        
        match = matchTimeExpression(rule: "上(个)?月")
        if !match.isEmpty {
            flags[1] = true
            date = date.ng_fs_dateByAddingMonths(1)
        }
        
        match = matchTimeExpression(rule: "(本|这个)月")
        if !match.isEmpty {
            flags[1] = true
        }
        
        match = matchTimeExpression(rule: "下(个)?月")
        if !match.isEmpty {
            flags[1] = true
            date = date.ng_fs_dateByAddingMonths(1)
        }
        
        match = matchTimeExpression(rule: "大前天")
        if !match.isEmpty {
            flags[2] = true
            date = date.ng_fs_dateBySubtractingDays(3)
        }
        
        match = matchTimeExpression(rule: "(?<!大)前天")
        if !match.isEmpty {
            flags[2] = true
            date = date.ng_fs_dateBySubtractingDays(2)
        }
        
        match = matchTimeExpression(rule: "昨")
        if !match.isEmpty {
            flags[2] = true
            date = date.ng_fs_dateBySubtractingDays(1)
        }
        
        match = matchTimeExpression(rule: "今(?!年)")
        if !match.isEmpty {
            flags[2] = true
        }
        
        match = matchTimeExpression(rule: "明(?!年)")
        if !match.isEmpty {
            flags[2] = true
            date = date.ng_fs_dateByAddingDays(1)
        }
        
        match = matchTimeExpression(rule: "(?<!大)后天")
        if !match.isEmpty {
            flags[2] = true
            date = date.ng_fs_dateByAddingDays(2)
        }
        
        match = matchTimeExpression(rule: "大后天")
        if !match.isEmpty {
            flags[2] = true
            date = date.ng_fs_dateByAddingDays(3)
        }
        
        match = matchTimeExpression(rule: "(?<=(上上(周|星期|礼拜)))[1-7]?")
        if !match.isEmpty, let timeExpression = timeExpression  {
            flags[2] = true
            var week = Int(timeExpression[Range(match[0].range, in: timeExpression)!]) ?? 0
            week = max(week, 1)
            date = date.ng_fs_dateBySubtractingWeeks(2)
            var weekday = date.ng_fs_weekday()
            weekday = weekday == 1 ? 7 : weekday - 1
            date = date.ng_fs_dateByAddingDays(week - weekday)
            date = preferFutureWeek(weekDay: week, date: date)
        }
        
        match = matchTimeExpression(rule: "(?<=((?<!上)上(周|星期|礼拜)))[1-7]?")
        if !match.isEmpty, let timeExpression = timeExpression  {
            flags[2] = true
            var week = Int(timeExpression[Range(match[0].range, in: timeExpression)!]) ?? 0
            week = max(week, 1)
            date = date.ng_fs_dateBySubtractingWeeks(1)
            var weekday = date.ng_fs_weekday()
            weekday = weekday == 1 ? 7 : weekday - 1
            date = date.ng_fs_dateByAddingDays(week - weekday)
            date = preferFutureWeek(weekDay: week, date: date)
        }
        
        match = matchTimeExpression(rule: "(?<=((?<!下)下(周|星期|礼拜)))[1-7]?")
        if !match.isEmpty, let timeExpression = timeExpression  {
            flags[2] = true
            var week = Int(timeExpression[Range(match[0].range, in: timeExpression)!]) ?? 0
            week = max(week, 1)
            date = date.ng_fs_dateByAddingWeeks(1)
            var weekday = date.ng_fs_weekday()
            weekday = weekday == 1 ? 7 : weekday - 1
            date = date.ng_fs_dateByAddingDays(week - weekday)
            date = preferFutureWeek(weekDay: week, date: date)
        }
        
        match = matchTimeExpression(rule: "(?<=(下下(周|星期|礼拜)))[1-7]?")
        if !match.isEmpty, let timeExpression = timeExpression  {
            flags[2] = true
            var week = Int(timeExpression[Range(match[0].range, in: timeExpression)!]) ?? 0
            week = max(week, 1)
            date = date.ng_fs_dateByAddingWeeks(2)
            var weekday = date.ng_fs_weekday()
            weekday = weekday == 1 ? 7 : weekday - 1
            date = date.ng_fs_dateByAddingDays(week - weekday)
            date = preferFutureWeek(weekDay: week, date: date)
        }
        
        match = matchTimeExpression(rule: "(?<=((?<!(上|下))(周|星期|礼拜)))[1-7]?")
        if !match.isEmpty, let timeExpression = timeExpression  {
            flags[2] = true
            var week = Int(timeExpression[Range(match[0].range, in: timeExpression)!]) ?? 0
            week = max(week, 1)
            var weekday = date.ng_fs_weekday()
            weekday = weekday == 1 ? 7 : weekday - 1
            date = date.ng_fs_dateByAddingDays(week - weekday)
            date = preferFutureWeek(weekDay: week, date: date)
        }
        
        if flags[0] || flags[1] || flags[2] {
            tp.tunit[0] = date.ng_fs_year()
        }
        if flags[1] || flags[2] {
            tp.tunit[1] = date.ng_fs_month()
        }
        if flags[2] {
            tp.tunit[2] = date.ng_fs_day()
        }
    }
    
    /**
    * 该方法用于更新timeBase使之具有上下文关联性
    */
    func modifyTimeBase() {
        guard let normalizer = normalizer, let timeBase = normalizer.timeBase else {return}
        let timeGrid = timeBase.components(separatedBy: "-")
        var s: String = ""
        
        for i in 0..<6 {
            if i != 0 {
                s.append("-")
            }
            if tp.tunit[i] != -1 {
                s.append("\(tp.tunit[i])")
            } else {
                s.append(timeGrid[i])
            }
        }
        normalizer.timeBase = s
    }
    
    private func matchTimeExpression(rule: String) -> [NSTextCheckingResult] {
        return match(timeExpression, rule: rule)
    }
    
    private func match(_ string: String?, rule: String) -> [NSTextCheckingResult] {
        if let regularExp = try? NSRegularExpression(pattern: rule, options: .caseInsensitive), let string = string {
            return regularExp.matches(in: string, options: .reportCompletion, range: NSMakeRange(0, string.count))
        }
        return []
    }
    
    /**
     * 根据上下文时间补充时间信息
     */
    private func checkContextTime(_ timeIndex: Int) {
        for i in 0..<timeIndex {
            if tp.tunit[i] == -1 && tpOrigin.tunit[i] != -1 {
                tp.tunit[i] = tpOrigin.tunit[i]
            }
        }
        if isFirstTimeSolveContext && timeIndex == 3 && tpOrigin.tunit[timeIndex] >= 12 && tp.tunit[timeIndex] < 12 {
            tp.tunit[timeIndex] += 12
        }
        isFirstTimeSolveContext = false
    }
    
    /**
     * 如果用户选项是倾向于未来时间，检查checkTimeIndex所指的时间是否是过去的时间，如果是的话，将大一级的时间设为当前时间的+1。
     * <p>
     * 如在晚上说“早上8点看书”，则识别为明天早上;
     * 12月31日说“3号买菜”，则识别为明年1月的3号。
     *
     * @param checkTimeIndex _tp.tunit时间数组的下标
     */
    private func preferFuture(_ timeIndex: Int) {
        /**1. 检查被检查的时间级别之前，是否没有更高级的已经确定的时间，如果有，则不进行处理.*/
        for i in 0..<timeIndex {
            if tp.tunit[i] != -1 {
                return
            }
        }
        /**2. 根据上下文补充时间*/
        checkContextTime(timeIndex)
        /**3. 根据上下文补充时间后再次检查被检查的时间级别之前，是否没有更高级的已经确定的时间，如果有，则不进行倾向处理.*/
        for i in 0..<timeIndex {
            if tp.tunit[i] != -1 {
                return
            }
        }
        /**4. 确认用户选项*/
        guard let normalizer = normalizer, normalizer.isPreferFuture else {return}
        /**5. 获取当前时间，如果识别到的时间小于当前时间，则将其上的所有级别时间设置为当前时间，并且其上一级的时间步长+1*/
        var date = now()
        let curTime = date.ng_fs_valueBy(timeIndex)
        if curTime <= tp.tunit[timeIndex] {
            return
        }
        /**6.准备增加的时间单位是被检查的时间的上一级，将上一级时间+1*/
        if tp.tunit[timeIndex] != -1 {
            date = date.ng_fs_dateByAddingValue(1, by: timeIndex - 1)
            for i in 0..<timeIndex {
                tp.tunit[i] = date.ng_fs_valueBy(i)
            }
        }
    }
    
    /**
     * 如果用户选项是倾向于未来时间，检查所指的day_of_week是否是过去的时间，如果是的话，设为下周。
     * <p>
     * 如在周五说：周一开会，识别为下周一开会
     *
     * @param weekday 识别出是周几（范围1-7）
     */
    private func preferFutureWeek(weekDay: Int, date: Date) -> Date {
        /**1. 确认用户选项*/
        guard let normalizer = normalizer, normalizer.isPreferFuture else {return date}
        /**2. 检查被检查的时间级别之前，是否没有更高级的已经确定的时间，如果有，则不进行倾向处理.*/
        let timeIndex = 2
        for i in 0..<timeIndex {
            if tp.tunit[i] != -1 {
                return date
            }
        }
        /**获取当前是在周几，如果识别到的时间小于当前时间，则识别时间为下一周*/
        let curDate = now()
        var curWeekday = curDate.ng_fs_weekday() - 1
        curWeekday = curWeekday == 0 ? 7 : curWeekday
        if curWeekday <= weekDay || curDate < date {
            return date
        }
        return date.ng_fs_dateByAddingWeeks(1)
    }
        
    private func now() -> Date {
        if let timeBase = normalizer?.timeBase, !timeBase.isEmpty {
            return Date.ng_fs_date(from: timeBase, format: "yyyy-MM-dd-HH-mm-ss")
        } else {
            return Date()
        }
    }
}
