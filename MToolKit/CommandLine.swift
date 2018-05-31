//
//  CommandLine.swift
//  MToolKit
//
//  Created by gaoliang5 on 2018/5/30.
//  Copyright © 2018年 gaoliang5. All rights reserved.
//

import Foundation

class CommandLine {
	class func runCommand(_ command: String) -> String {
		let task = Process()
		task.launchPath = "/bin/sh"
		task.arguments = ["-c", String(command)]
		let pipe = Pipe()
		task.standardOutput = pipe
		try? task.run()
		let outData = pipe.fileHandleForReading.readDataToEndOfFile()
		defer {
			task.waitUntilExit()
			let status = task.terminationStatus
			
			if status == 0 {
				print("Task succeeded.")
			} else {
				print("Task failed.")
			}
		}
		return String(data: outData, encoding: String.Encoding.utf8) ?? "parser failure"
	}
}


