//
//  CrashInfo.swift
//  MToolKit
//
//  Created by gaoliang5 on 2018/5/16.
//  Copyright © 2018年 gaoliang5. All rights reserved.
//

import Foundation

class CrashInfo {
	var path : String?
	var incidentIdentifier : String? // 触发id
	var crashReporterKey : String? // crash id
	var hardwareModel : String? // 硬件信息
	var process : String? // 进程信息
	var identifier : String? // crash app bundle id
	var version : String? // app version
	var codeType : String? // 系统架构 arm-64 , armv7 等
	var parentProcess : String? //父进程
	var dateTime : String? // crash 时间
	var launchTime : String? // 启动时间
	var OSVersion : String? // 系统版本
	var reportVersion : String? // 报告版本
	var exceptionType : String? //
	var exceptionSubtype : String? // 异常子类型
	var crashThread : String? //  Triggered by Thread，异常崩溃线程
	
	init(crashFilePath : String) {
		path = crashFilePath
	}
	
	func parserCrashFile() {
	}
	
	func arch() -> String? {
		if codeType != nil {
			if (codeType!.contains("ARM-64")) {
				return "arm64"
			}
		}
		return nil
	}
	
}
