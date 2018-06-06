//
//  Path+MTK.swift
//  MToolKit
//
//  Created by gaoliang5 on 2018/6/6.
//  Copyright © 2018年 gaoliang5. All rights reserved.
//

import Foundation
import FileKit

extension Path {
	// MARK: - Paths appending
	func mtk_appending(pathComp: String) -> Path {
		return Path(rawValue.appending(Path.separator).appending(pathComp)).standardized
	}
}
