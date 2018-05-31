//
//  CrashFileInfo.swift
//  MToolKit
//
//  Created by gaoliang5 on 2018/5/16.
//  Copyright © 2018年 gaoliang5. All rights reserved.
//

import Foundation
import SwiftyBeaver

///  swift string 处理
/// https://stackoverflow.com/questions/39676939/how-does-string-index-work-in-swift
// MARK: crash file 
class CrashFileInfo {
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
	var crashContent : [String]?
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
	
	var primitiveCrashCodes : [String.SubSequence]? // 初始的崩溃代码
	var handlerCrashCodes : [String] = [String]() // 解析后的代码
	
	var dsymPath : String = ""
	
	var dsymItem : CrashDsymItem?
	
	convenience init() {
		self.init(crashFilePath: "", dsymPath: "")
	}
	
	init(crashFilePath : String, dsymPath: String = "") {
		if crashFilePath.count < 1 {
			return 
		}
		path = crashFilePath
		self.dsymPath = dsymPath
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
		
		let crashThreadValue = "Thread " + infos[crashThread]!.mtk_trimmingWhiteSpaces() + "[\\s\\S]*?\n\n"
		self.crashContent = content?.mtk_matchRegular(crashThreadValue)
//		self.crashContent = crashContent?.joined(separator: "\n###\n")
		
		let binaryImages = "(?<=Binary Images:\n)[^\n]*"
		let binaryImagesContent = content?.mtk_matchRegular(binaryImages)
		if binaryImagesContent!.count > 0 {
			dsymItem = CrashDsymItem(binaryImagesContent![0])
			self.dsymPath = dsymItem!.dsymUUIDPath()
			let _  = crashCode2SymbolicCode() //消除警告
		}
	}
// 符号化解析
	func crashCode2SymbolicCode() -> String {
		if self.crashContent != nil {
			handlerCrashCodes.removeAll()
			
			for info in crashContent! {
				primitiveCrashCodes = info.split(separator: "\n")
				
				for crashLine in primitiveCrashCodes! {
					let crashItem = String(crashLine)
					if crashItem.mtk_startWithDigtail() {
						let result = ParserCrashLineItem.parser(crashLineString: crashItem, dsymItem: dsymItem!, dsymPath: dsymPath)
						handlerCrashCodes.append(result)
					} else {
						handlerCrashCodes.append(crashItem)
					}
				}
				
				for result in handlerCrashCodes {
					SwiftyBeaver.debug(result)
				}
			}
			return handlerCrashCodes.joined(separator: "\n")
		}
		return ""
	}
}


/// 选择enum 的好处是，可以确定具体的类型，之前的string 别名用法,通过enum 来实现，非常的方便
///
/// - arm64: 64 位，5s 之后的设备
/// - armv7: 5c 之前的设备
/// - armv7s: 5c 设备
enum Arch : String {
	case arm64 = "arm64"
	case armv7 = "armv7"
	case armv7s = "armv7s"
}
//MARK: - crash line
class CrashLineItem  {
	static let fixCount = 6
	var lineNumber : String = ""
	var programID : String = ""
	var errorAddress : String = ""
	var baseAddress : String = ""
	var offset : String = ""
	var arch : Arch = .arm64
	var dsymPath : String = ""
	
	init( lineNumber : String, 
		  programID : String, 
		  errorAddress : String, 
		  baseAddress : String, 
		  offset : String) {
		self.lineNumber = lineNumber
		self.programID = programID
		self.errorAddress = errorAddress
		self.baseAddress = baseAddress
		self.offset = offset
	}
	convenience init?(_ result : [String]) {
		guard result.count == CrashLineItem.fixCount && result[2].starts(with: "0x") && result[3].starts(with: "0x") else {
			return nil
		}
		self.init(lineNumber: result[0], 
				  programID: result[1], 
				  errorAddress: result[2],
				  baseAddress : result[3],
				  offset : result[5]
		)
	}
	
	func description() -> String {
		 return [self.lineNumber, self.programID, self.errorAddress, self.baseAddress, self.offset].joined(separator: ", ")
	}
	
	func buildAtoSCommand() -> String {
		return String(format: "atos -arch %@ -o \"%@\" -l %@ %@", arch.rawValue, self.dsymPath, self.baseAddress, self.errorAddress)
	}
}

class ParserCrashLineItem {
//	6   SinaNews  0x0000000101308478 0x10006c000 + 19514488
	class func parser(crashLineString : String, dsymItem : CrashDsymItem, dsymPath : String) -> String {
		let result = crashLineString.mtk_matchRegular("([^\\s])+") //空白字符
		let item = CrashLineItem(result)
		guard item != nil else {
			return crashLineString;
		}
		guard item!.programID == dsymItem.dsymID else {
			return crashLineString
		}
		item!.arch = dsymItem.arch
		item!.dsymPath = dsymPath
		return CommandLine.runCommand(item!.buildAtoSCommand())
	}
}

//MARK: - get crash dsym
class CrashDsymItem {
	var dsymID = ""
	var arch : Arch 
	private var uuid : String {
		set {
//			8-4-4-4-12.
			let upper = newValue.uppercased()
			var dsymUUID = ""
			var index = 0
			
			for c in upper {
				index += 1
				dsymUUID.append(c)
				if index == 8 || index == 12 || index == 16 || index == 20 {
					dsymUUID.append("-")
				}
			}
			_uuid = dsymUUID
		}
		get {
			return _uuid
		}
	}
	private var _uuid : String = "" 
	
	init(_ dsymInfo : String) {
		let result = dsymInfo.mtk_matchRegular("([^\\s])+") //空白字符
		if result.count == 7 {
			dsymID = result[3]
			arch = Arch(rawValue: result[4])!
			uuid = result[5].mtk_subString("<", ">")
		} else {
			dsymID = ""
			arch = Arch(rawValue: "")!
			uuid = ""
		}
	}	
	
	private func findDsymUUIDPath() -> String {
		guard _uuid.count > 0 else {
			return "find dsym fail"
		}
		let findDsymUUIDCommand = "mdfind \"com_apple_xcode_dsym_uuids == \(self.uuid)\""
		return CommandLine.runCommand(findDsymUUIDCommand)
	}
	
	func dsymUUIDPath() -> String {
		let path = findDsymUUIDPath().trimmingCharacters(in: CharacterSet.newlines)
		guard path.count > 0  else {
			return ""
		}
		let lastPath = "/Contents/Resources/DWARF/\(dsymID)"
		return path.appending(lastPath)
	}
}
