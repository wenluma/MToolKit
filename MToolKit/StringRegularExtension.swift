//
//  StringRegularExtension.swift
//  MToolKit
//
//  Created by gaoliang5 on 2018/5/22.
//  Copyright © 2018年 gaoliang5. All rights reserved.
//

import Foundation

// MARK: - mtk_matchRegular 正则的表达式使用入口
extension String {
	func mtk_matchRegular(_ pattern: String) -> [String] {
		do {
			let regex = try NSRegularExpression(pattern: pattern)
			let results = regex.matches(in: self,
										range: NSRange(self.startIndex..., in: self))
			return results.map {
				String(self[Range($0.range, in: self)!])
			}
		} catch let error {
			print("invalid regex: \(error.localizedDescription)")
			return []
		}
	}
	
	func mtk_trimmingWhiteSpaces() -> String {
		return self.trimmingCharacters(in: .whitespaces)
	}
}
