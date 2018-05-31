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
	
	func mtk_offset(_ offsetIndex: Int) -> String.Index {
		if self.count > offsetIndex {
			return self.index(self.startIndex, offsetBy: offsetIndex, limitedBy: self.endIndex)!
		}
		return self.startIndex
	}
	
	func mtk_subString(_ fromOffset : Int, _ endOffset : Int) -> String {
		if endOffset >= fromOffset && 
			fromOffset >= 0 &&
			endOffset < self.count {
			return String(self[self.mtk_offset(fromOffset)...self.mtk_offset(endOffset)])
		} else if (endOffset < 0 && endOffset > -self.count) && 
			(fromOffset > 0 && fromOffset < self.count) &&
		fromOffset + endOffset >= 0 {
			return String(self[mtk_offset(fromOffset)...mtk_offset(endOffset + self.count - 1)])
		}
		return ""
	}
	
	func mtk_subString(_ fromOffset : Int) -> String {
		return String(self[mtk_offset(fromOffset) ..< self.endIndex])
	}
	
	func mtk_subStringEndOffset(_ endOffset : Int) -> String {
		return String(self[self.startIndex ..< mtk_offset(endOffset)])
	}
	
	func mtk_subString(_ after : Character, _ before : Character) -> String {
		guard self.contains(after) && self.contains(before) else {
			return ""
		}
		let start = self.index(after: self.index(of: after)!)
		let end = self.index(before: self.index(of: before)!)
		if start <= end {
			return String(self[start...end])
		}
		return ""
	}
	
	func mtk_trimmingWhiteSpaces() -> String {
		return self.trimmingCharacters(in: .whitespaces)
	}
	
	func mtk_startWithDigtail() -> Bool {
		return self.prefix(while: { "0"..."9" ~= $0 }).count > 0
	}
}

func mainBundlePath(forResource: String?, ofType: String?) -> String? {
	return Bundle.main.path(forResource: forResource, ofType: ofType)
}
