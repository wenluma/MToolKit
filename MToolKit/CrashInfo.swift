//
//  CrashInfo.swift
//  MToolKit
//
//  Created by gaoliang5 on 2018/5/16.
//  Copyright © 2018年 gaoliang5. All rights reserved.
//

import Foundation
import SwiftyBeaver

///  swift string 处理
/// https://stackoverflow.com/questions/39676939/how-does-string-index-work-in-swift
class CrashInfo {
	var path : String?
	var incidentIdentifier : String = "Incident Identifier:" // 触发id
	var crashReporterKey : String = "CrashReporter Key:" // crash id
	var hardwareModel : String = "Hardware Model:" // 硬件信息
	var process : String = "Process:" // 进程信息
	var identifier : String = "Identifier:" // crash app bundle id
	var version : String = "Version:" // app version
	var codeType : String = "Code Type:" // 系统架构 arm-64 , armv7 等
	var parentProcess : String = "Parent Process:" //父进程
	var dateTime : String = "Date/Time:" // crash 时间
	var launchTime : String = "Launch Time:" // 启动时间
	var OSVersion : String = "OS Version:" // 系统版本
	var reportVersion : String = "Report Version:" // 报告版本
	var exceptionType : String = "Exception Type:" //
	var exceptionSubtype : String = "Exception Subtype:" // 异常子类型
	var crashThread : String = "Triggered by Thread:" //  Triggered by Thread，异常崩溃线程
	
	lazy var prefixs = [incidentIdentifier, 
				   crashReporterKey,
				   hardwareModel,
				   process,
				   identifier,
				   version,
				   codeType,
				   parentProcess,
				   dateTime,
				   launchTime,
				   OSVersion,
				   reportVersion,
				   exceptionType,
				   exceptionSubtype,
				   crashThread]
	
	var infos = [String:String]()
	
	var primitiveCrashCodes : [String]? // 初始的崩溃代码
	var handlerCrashCodes : [String]? // 解析后的代码
	
	convenience init() {
		self.init(crashFilePath: "")
	}
	
	init(crashFilePath : String) {
		if crashFilePath.count < 1 {
			return
		}
		path = crashFilePath
		parserCrashFile()
	}
	
	func parserCrashFile() {
		func hasColon( _ line: String.SubSequence) -> Bool {
			return line.index(of: ":") != nil
		}
		
		func prefixColonKey(_ line: String.SubSequence) -> String {
			return String(line[...line.index(line.index(of: ":")!, offsetBy: 0)])
		}
		func prefixColonAfterValue(_ line :String.SubSequence, _ key : String) -> String {
			//			String(line) 的原因是， String.SubSequence 会依赖之前的subSquence 项，进行切割。类似累加的概念。
			return String(String(line).suffix(from: key.endIndex))
		}
		
		
		let content = try? String(contentsOfFile: path!)
//		CharacterSet.newlines
		let lines = content?.split(separator: "\n")
				
		for line in lines! {
			if hasColon(line) {
				let key = prefixColonKey(line)
				if prefixs .contains(key) {
					let value = prefixColonAfterValue(line, key)
					infos[key] = value
				}
			}
		}
		
		let crashThreadValue = "Thread " + infos[crashThread]!.mtk_trimmingWhiteSpaces() + "([\\s\\S]*)\n\n"
		primitiveCrashCodes = content?.mtk_matchRegular(crashThreadValue)
		if primitiveCrashCodes != nil {
			for info in primitiveCrashCodes! {
				SwiftyBeaver.debug(info)
			}
		}
	}
}
