//
//  AppDelegate.swift
//  Stitch This
//
//  Created by Martin on 12/05/2016.
//  Copyright © 2016 Broskersoft. All rights reserved.
//

import Cocoa
import Quartz
import QuartzCore

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate, NSTableViewDataSource, NSTableViewDelegate {

    @IBOutlet weak var window: NSWindow!
    @IBOutlet weak var showHelp: NSMenuItem!
    @IBAction func showHelp(_ sender: AnyObject) {

    }

    func applicationDidFinishLaunching(_ aNotification: Notification) {
        // Insert code here to initialize your application
        
    }
    func applicationWillTerminate(_ aNotification: Notification) {
        // Insert code here to tear down your application
        sqlite3_close(db)
    }
    
    func applicationShouldTerminateAfterLastWindowClosed(_ sender: NSApplication) -> Bool {
        return true
    }
}

