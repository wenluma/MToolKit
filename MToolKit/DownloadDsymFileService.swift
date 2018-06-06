//
//  DownloadDsymFileService.swift
//  MToolKit
//
//  Created by gaoliang5 on 2018/6/4.
//  Copyright © 2018年 gaoliang5. All rights reserved.
//

import Foundation
import Alamofire
import SwiftyBeaver

public typealias completeHandler<T> = (Bool, T?, Error?) -> ()

public typealias dsymLinksHandler = ([String]?) -> ()

class DownloadItem {
	var tag = ""
	var url = ""
	var results = [URL]()
	var success : completeHandler<String>?
	var evalute = ""
	init(tag : String = "" , url : String, evalute : String, success: @escaping completeHandler<String>) {
		self.tag = tag
		self.url = url
		self.evalute = evalute
		self.success = success
	}
}

class DownloadManager {
	
	class func dataRequest(url : String, evalute : String, dsymLinksHandler : @escaping dsymLinksHandler) {
		SessionManager.default.request(url).responseString { (stringResponse) in
			if stringResponse.result.isSuccess {
				let dsymLinks = stringResponse.result.value?.mtk_matchRegular(StringConst.htmlDsymConst)
				SwiftyBeaver.debug("dsym.count = \(dsymLinks?.count ?? 0)")
				for link in dsymLinks! {
					SwiftyBeaver.debug(link)
				}
				dsymLinksHandler(dsymLinks)
			} else {
				SwiftyBeaver.debug(stringResponse.result.error!)
				dsymLinksHandler(nil)
			}
		}.resume()

	}
	
	class func download(url : String, completionHanlder: @escaping completeHandler<String>) -> DownloadItem {
		let item = DownloadItem(url: url, evalute: "", success: completionHanlder)
		return download(item: item)
	}
	
	class func download(item: DownloadItem) -> DownloadItem {
		SwiftyBeaver.debug("开始请求 url = \(item.url)")
		SessionManager.default.request(item.url).responseString { [weak item] (stringResponse) in
			item?.success?(stringResponse.result.isSuccess, stringResponse.result.value, stringResponse.result.error)
			if stringResponse.result.isSuccess {
				let ary = stringResponse.result.value?.mtk_matchRegular(StringConst.htmlDsymConst)
				SwiftyBeaver.debug("dsym.count = \(ary?.count ?? 0)")
				for line in ary! {
					print(line)
				}
			} else {
				SwiftyBeaver.debug(stringResponse.result.error!)
			}
		}.resume()
		return item
	}
}

class RequestDsymFileModel {
	var path = ""
	var urlString = ""
	init?(path: String, urlString: String) {
		//		/Users/gaoliang5/Downloads/SinaNews_2018-06-01-165954_News.ips
		let lastPath = URL(fileURLWithPath: path).lastPathComponent.mtk_matchRegular("[0-9-]").first
		guard lastPath != nil else {
			return nil
		}
	}
	
	func downloadDsym(checkDsymClosure: @escaping () -> Bool) {
		
	}
}
