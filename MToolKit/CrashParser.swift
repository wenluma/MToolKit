//
//  CrashParser.swift
//  MToolKit
//
//  Created by gaoliang5 on 2018/5/9.
//  Copyright © 2018年 gaoliang5. All rights reserved.
//

import Foundation
import SnapKit
import SwiftyBeaver

class CrashParserViewController: NSViewController {
//	MARK: - property
	var crashLab, dsymLab : NSTextField?
	var crashPathField, dsymPathField : NSTextField?
	var parserCrashTextView : NSTextView?
//	MARK: - override
	override func loadView() {
		view = NSView()
		self.view.wantsLayer = false //true ,可以改变 layer 背景色
		self.view.layer?.backgroundColor = CGColor.black
		
		crashLab = textField("crash log path:","", alignment: .right)
		dsymLab = textField("dsym path:", "", alignment: .right)
		crashPathField = textField("", "请输入crash log path", enableEdit: true)
		dsymPathField = textField("", "请输入dsym path", enableEdit: true)
		parserCrashTextView = textView("等待解析数据")
		
		self.view.addSubview(crashLab!)
		self.view.addSubview(dsymLab!)
		self.view.addSubview(crashPathField!)
		self.view.addSubview(dsymPathField!)
		view.addSubview(parserCrashTextView!)
	}
		
	override public func viewDidLoad() {
		super.viewDidLoad()
	}
	
	override func viewWillAppear() {
		 super.viewWillAppear()
	}
	
	override func viewWillLayout() {
		super.viewWillLayout()
	}
	
	override func viewDidLayout() {
		super.viewDidLayout()
	}
	
	override func updateViewConstraints() {
		super.updateViewConstraints()
		SwiftyBeaver.debug("#updateViewConstraints")
		
		crashLab!.snp.makeConstraints { (make) -> Void in
			make.left.top.equalTo(LayoutConst.edgePadding);
			make.width.lessThanOrEqualTo(100)
		}
		crashPathField?.snp.makeConstraints({ (make) in
			make.left.equalTo(crashLab!.snp.right).offset(LayoutConst.spacePadding)
			make.top.equalTo(crashLab!)
			make.right.equalTo(self.view).offset(-LayoutConst.edgePadding)
		})
		
		dsymLab!.snp.makeConstraints { (make) in
			make.left.equalTo(crashLab!.snp.left)
			make.top.equalTo(crashLab!.snp.bottom).offset(LayoutConst.spacePadding)
			make.width.equalTo(crashLab!.snp.width)
		}
		dsymPathField?.snp.makeConstraints({ (make) in
			make.left.equalTo(crashLab!.snp.right).offset(LayoutConst.spacePadding)
			make.top.equalTo(dsymLab!)
			make.right.equalTo(crashPathField!)
		})
		
		parserCrashTextView?.snp.makeConstraints({ (make) in
			make.top.equalTo(dsymLab!.snp.bottom).offset(LayoutConst.spacePadding)
			make.right.bottom.equalTo(-LayoutConst.edgePadding)
			make.left.equalTo(LayoutConst.edgePadding)
		})
	}
	
//	MARK: - create textField
	func textField( _ title : String, _ placeholderString : String, enableEdit :Bool = false, alignment: NSTextAlignment = .left) -> NSTextField {
		let textField = NSTextField()
		textField.isBezeled = false
		textField.drawsBackground = true
		textField.isEditable = enableEdit
		textField.stringValue = title
		textField.alignment = alignment
		textField.placeholderString = placeholderString
		return textField
	}
	
	func textView(_ text: String) -> NSTextView {
		let textView = NSTextView()
		textView.string = text
		return textView
	} 
}
