//
//  AppDelegate.swift
//  MToolKit
//
//  Created by gaoliang5 on 2018/5/3.
//  Copyright © 2018年 gaoliang5. All rights reserved.
//

import Cocoa
import SwiftyBeaver
import SnapKit

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {

//	@IBOutlet weak var window: NSWindow!
	var window : NSWindow! = NSWindow(contentRect: NSZeroRect, styleMask: [.borderless], backing: .buffered, defer: false)
	var windowController :  NSWindowController?

	func applicationDidFinishLaunching(_ aNotification: Notification) {
		setupLog()
		createNewWindow()
		windowController = NSWindowController(window: window)
		windowController?.showWindow(window)
	}
	
	func applicationWillTerminate(_ aNotification: Notification) {
		// Insert code here to tear down your application
	}

	//MARK: setup log
	private func setupLog() {
		let log = SwiftyBeaver.self
		// add log destinations. at least one is needed!
		let console = ConsoleDestination()  // log to Xcode Console
		let file = FileDestination()  // log to default swiftybeaver.log file
//		let cloud = SBPlatformDestination(appID: "foo", appSecret: "bar", encryptionKey: "123") // to cloud
		
		// use custom format and set console output to short time, log level & message
//		console.format = "$DHH:mm:ss$d $L $M"
		// or use this for JSON output: console.format = "$J"
		
		// add the destinations to SwiftyBeaver
		log.addDestination(console)
		log.addDestination(file)
//		log.addDestination(cloud)
		
		// Now let’s log!
//		log.verbose("not so important")  // prio 1, VERBOSE in silver
//		log.debug("something to debug")  // prio 2, DEBUG in green
//		log.info("a nice information")   // prio 3, INFO in blue
//		log.warning("oh no, that won’t be good")  // prio 4, WARNING in yellow
//		log.error("ouch, an error did occur!")  // prio 5, ERROR in red
		
		// log anything!
//		log.verbose(123)
//		log.info(-123.45678)
//		log.warning(Date())
//		log.error(["I", "like", "logs!"])
//		log.error(["name": "Mr Beaver", "address": "7 Beaver Lodge"])
//
//		// optionally add context to a log message
//		console.format = "$L: $M $X"
//		log.debug("age", 123)  // "DEBUG: age 123"
//		log.info("my data", context: [1, "a", 2]) // "INFO: my data [1, \"a\", 2]"
	}

	private func createNewWindow() {
		window.title = "My Tookit"
		//		window.isOpaque = false
		window.center()
		window.isMovableByWindowBackground = true
		LayoutConst.windowTitleBarHeight = Int(window.titleBarHeight)

		let	viewController = CrashParserViewController()
		window.contentViewController = viewController
		window.setFrame(NSMakeRect(NSScreen.main!.frame.midX/2, NSScreen.main!.frame.midY/2, NSScreen.main!.frame.midX, NSScreen.main!.frame.midY), display: true)
//		window.setContentSize(NSMakeSize(NSScreen.main!.frame.midX, NSScreen.main!.frame.midY))
		viewController.view.snp.makeConstraints { (make) in
			make.edges.equalTo(NSEdgeInsetsZero)
		}
//		window.backgroundColor = NSColor.red
		//		window.makeKeyAndOrderFront(nil) // 展示
	}
}

extension NSWindow {
	var titleBarHeight: CGFloat {
		let contentHeight = contentRect(forFrameRect: frame).height
		return frame.height - contentHeight
	}
}

