//
//  PaletteViewCVItem.swift
//  Stitch This!
//
//  Created by Martin on 30/05/2020.
//  Copyright © 2020 Broskersoft. All rights reserved.
//
// The collection view which displays the Reduced image's palette.
//

import Cocoa

class PaletteViewCVItem: NSCollectionViewItem {
    
    var delegate: AnyObject?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do view setup here.
    }
    
    @IBOutlet weak var palViewCVItem: NSColorWell!

}
