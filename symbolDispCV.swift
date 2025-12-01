//
//  symbolDispCV.swift
//  Stitch This!
//
//  Created by Martin on 29/05/2020.
//  Copyright © 2020 Broskersoft. All rights reserved.
//
// The collection view which is used to display the Symbols tab's view of allocated symbols and colours.
//

import Cocoa

class symbolDispCV: NSCollectionViewItem {
    
    var delegate: AnyObject?
        

    override var isSelected: Bool {
        didSet {
        }
    }
    
    override func mouseDown(with theEvent: NSEvent) {
        super.mouseDown(with: theEvent)
        bgWasSet = false
        if theEvent.clickCount == 2 {
            bgWasSet = true
            if self.isSelected == true {
                bgSet = (self.symDispNo.stringValue)
                (self.collectionView?.delegate as! RootViewController).setBG(self)
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do view setup here.

    }
    
    @IBOutlet weak var symDispColour: NSColorWell!
    @IBOutlet weak var symDispSymbol: NSTextField!
    @IBOutlet weak var symDispNo: NSTextField!

}

