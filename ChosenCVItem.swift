//
//  ChosenCVItem.swift
//  Stitch This!
//
//  Created by Martin on 25/05/2020.
//  Copyright © 2020 Broskersoft. All rights reserved.
//
// The collection view from which you can view a User's symbol set
//


import Cocoa

class ChosenCVItem: NSCollectionViewItem {

    var delegate: AnyObject?
    
    func dialogOK (_ question: String, text: String) {
        let popUp = NSAlert()
        popUp.messageText = question
        popUp.informativeText = text
        popUp.addButton(withTitle: "OK")
        popUp.alertStyle = NSAlertStyle.warning
        popUp.beginSheetModal(for: self.view.window!, completionHandler: { (modalResponse) -> Void in
            if modalResponse == NSAlertFirstButtonReturn {
                return
            }
        })
    }
    
    func collectionView(collectionView: NSCollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
    }
    
    @IBOutlet weak var chosenCVItem: NSTextField!
    
    override var isSelected: Bool {
        didSet {
            if isSelected {
                self.view.layer?.borderColor = NSColor.red.cgColor
            } else {
                self.view.layer?.borderColor = NSColor.gridColor.cgColor
                (self.collectionView?.delegate as! RootViewController).saveSymbolSet(nm)
            }
        }
    }
    
    override func mouseDown(with theEvent: NSEvent) {
        super.mouseDown(with: theEvent)
        if theEvent.clickCount == 2 {
            if self.isSelected == true {
                intFromString = Int32(Character(self.chosenCVItem.stringValue).unicodeScalarCodePoint())
                (self.collectionView?.delegate as! RootViewController).putBack(Int(getUserID(usr)), char: Int(intFromString))
            }
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do view setup here.

    }
}
