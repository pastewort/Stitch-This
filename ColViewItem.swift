//
//  ColViewItem.swift
//  Stitch This!
//
//  Created by Martin on 21/05/2020.
//  Copyright © 2020 Broskersoft. All rights reserved.
//
// The collection view that displays the 'pool' from which to select your chosen symbols
//

import Cocoa

extension Character
{
    func unicodeScalarCodePoint() -> UInt32
    {
        let characterString = String(self)
        let scalars = characterString.unicodeScalars
        
        return scalars[scalars.startIndex].value
    }
}

class ColViewItem: NSCollectionViewItem {
    
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

    override var isSelected: Bool {
        didSet {
        }
    }
    
    override func mouseDown(with theEvent: NSEvent) {
        super.mouseDown(with: theEvent)
        if theEvent.clickCount == 2 {
            if self.isSelected == true {
                if prefStUser == "Default" {
                    dialogOK("You can't do that...", text: "The Default symbol set is allocated by the system, and can't be altered. Add a user (click '+'), and you can allocate symbols to that.")
                    return
                } else {
                    intFromString = Int32(Character(self.colViewChar.stringValue).unicodeScalarCodePoint())
                    (self.collectionView?.delegate as! RootViewController).editItem(self)
                }
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do view setup here.
        
    }
    
    @IBOutlet weak var colViewChar: NSTextField!
        
}
