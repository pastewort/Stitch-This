//
//  ColoursCV.swift
//  Stitch This!
//
//  Created by Martin on 08/04/2023.
//  Copyright © 2023 Broskersoft. All rights reserved.
//

import Cocoa

class ColoursCV: NSCollectionViewItem {
    
    var delegate: AnyObject?

    
    override func mouseDown(with theEvent: NSEvent) {
        super.mouseDown(with: theEvent)
        if self.isSelected == true {
                for i in 0..<replacePal.count {
                    if Int(colour1.color.redComponent * 255) == replacePal[i].rgb1.rgbRed &&
                        Int(colour1.color.greenComponent * 255) == replacePal[i].rgb1.rgbGreen &&
                        Int(colour1.color.blueComponent * 255) == replacePal[i].rgb1.rgbBlue &&
                        Int(colour2.color.redComponent * 255) == replacePal[i].rgb2.rgbRed &&
                        Int(colour2.color.greenComponent * 255) == replacePal[i].rgb2.rgbGreen &&
                        Int(colour2.color.blueComponent * 255) == replacePal[i].rgb2.rgbBlue {
                        if arrow.stringValue == "╳" {
                            replacePal[i].replace = true
                            arrow.stringValue = "→"
                            mergeColourCt += 1
                            (self.collectionView?.delegate as! RootViewController).oColoursToBeMerged.stringValue = "Colours for merging: \(mergeColourCt)"
                            break
                        } else {
                            replacePal[i].replace = false
                            arrow.stringValue = "╳"
                            mergeColourCt -= 1
                            (self.collectionView?.delegate as! RootViewController).oColoursToBeMerged.stringValue = "Colours for merging: \(mergeColourCt)"
                        }
                    }
                }
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do view setup here.
        
    }
    
    @IBOutlet weak var colourCt: NSTextField!
    @IBOutlet weak var colour1: NSColorWell!
    @IBOutlet weak var arrow: NSTextField!
    @IBOutlet weak var colour2: NSColorWell!
    
}
