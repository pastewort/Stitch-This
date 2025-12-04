//
//  RootViewController.swift
//
//  Stitch This!
//
//  Started by Martin on 12/05/2016.
//

import Cocoa
import Quartz

class RootViewController: NSViewController,
    NSCollectionViewDelegate, NSCollectionViewDataSource
{

    //-------------------------------------------------//
    //      I N T E R F A C E   O B J E C T S          //
    //-------------------------------------------------//

    //---------------------------
    //        M E N U S
    //---------------------------
    
    // APP (STITCH THIS)
    //------------------
    //Outlets
    @IBOutlet weak var oSTAbout: NSWindow!
    
    // Actions
    @IBAction func aSTAbout(_ sender: AnyObject) {
        oSTAbout.isOpaque = true
        oSTAbout.isMovableByWindowBackground = true
        oSTAbout.makeKeyAndOrderFront(nil)
    }
    @IBAction func aSTPref(_ sender: AnyObject) {
        oPreferences.isOpaque = true
        oPreferences.isMovableByWindowBackground = true
        oPreferences.makeKeyAndOrderFront(nil)
        loadPrefs()
}
    @IBAction func aSTExit(_ sender: AnyObject) {
        exitProg()
    }
    
    
    
    // FILE
    //-----
    // Outlets
    @IBOutlet weak var oMFileOpen: NSMenuItem!
    @IBOutlet weak var oMFileSave: NSMenuItem!
    
    // Actions
    @IBAction func aMFileOpen(_ sender: AnyObject) {
        fileOpen()
        oImageLock.state = 0
        oImageLock.image = NSImage(named: "iconLocked")
    }
    @IBAction func aMFileSave(_ sender: AnyObject) {
        oTabView.selectTabViewItem(at: 1)
        saveImage()
    }
    
    // PROCESS
    //--------
    // Outlets
    @IBOutlet weak var oMProcReduce: NSMenuItem!
    @IBOutlet weak var oMProcMatch: NSMenuItem!
    @IBOutlet weak var oMProcMerge: NSMenuItem!
    @IBOutlet weak var oMProcGenerate: NSMenuItem!

    // Actions
    @IBAction func aMProcReduce(_ sender: AnyObject) {
        oTabView.selectTabViewItem(at: 0)
        doReduce()
        oImageNext.isEnabled = true
        oImageNext.isHighlighted = true
    }
    @IBAction func aMProcMatch(_ sender: AnyObject) {
        oTabView.selectTabViewItem(at: 1)
        matchProcess()
        oMatchNext.isEnabled = true
        oMatchNext.isHighlighted = true
        oMProcMerge.isEnabled = true
        oSymNext.isEnabled = true
        oSymNext.isHighlighted = true
    }
    @IBAction func aMProcMerge(_ sender: Any) {
        oColoursSlide.integerValue = threshold
        oColoursText.integerValue = threshold
        findUnderusedColours(threshold: threshold)
        oColoursCV.reloadData()
        oColours.isOpaque = true
        oColours.isMovableByWindowBackground = true
        oColours.makeKeyAndOrderFront(nil)
        oMatchNext.isEnabled = true
    }
    @IBAction func aMFileGenerate(_ sender: AnyObject) {
        oTabView.selectTabViewItem(at: 3)
        if oGenPrKey.integerValue == 0 &&
            oGenPrThrCd.integerValue == 0 &&
            oGenPrImg.integerValue == 0 &&
            oGenPrShop.integerValue == 0 &&
            oGenPrChart.integerValue == 0 {
            dialogOK("No options selected",text: "What do you want your PDF to contain? \n\nYou need to select at least one page type. \nPlease review.")
            return
        } else {
            _ = savePDF()
        }
    }
    
    // VIEW
    //-----
    // Outlets
    @IBOutlet weak var oViewNext: NSMenuItem!
    // Actions
    @IBAction func aViewSparesMgr(_ sender: AnyObject) {
        oSparesMgr.isOpaque = true
        oSparesMgr.isMovableByWindowBackground = true
        oSparesMgr.makeKeyAndOrderFront(nil)
    }
    @IBAction func aViewNext(_ sender: Any) {
        oTabView.selectNextTabViewItem(nil)
    }
    
    // HELP
    //-----
    @IBOutlet weak var oHelp: NSMenuItem!

    
    //---------------------------
    //   M A I N   W I N D O W
    //---------------------------

    @IBOutlet weak var oWindow: NSWindow!
    
    
    //---------------
    // T O O L B A R
    //---------------
    
    @IBOutlet weak var oToolbar: NSToolbar!
    
    @IBOutlet weak var oTBOpen: NSToolbarItem!
    @IBOutlet weak var oTBSave: NSToolbarItem!
    @IBOutlet weak var oTBSpares: NSToolbarItem!
    @IBOutlet weak var oTBPrefs: NSToolbarItem!
    @IBOutlet weak var oTBExit: NSToolbarItem!
    
    @IBAction func aTBOpen(_ sender: AnyObject) {
        fileOpen()
        oImageLock.state = 0
        oImageLock.image = NSImage(named: "iconLocked")
    }
    @IBAction func aTBSave(_ sender: AnyObject) {
        if saveOK == true {
            saveImage()
        }
   }
    @IBAction func aTBSpares(_ sender: AnyObject) {
        oSparesMgr.isOpaque = true
        oSparesMgr.isMovableByWindowBackground = true
        oSparesMgr.makeKeyAndOrderFront(nil)
    }
    @IBAction func aTBPrefs(_ sender: AnyObject) {
        oPreferences.isOpaque = true
        oPreferences.isMovableByWindowBackground = true
        oPreferences.makeKeyAndOrderFront(nil)
        loadPrefs()
   }
    @IBAction func aTBExit(_ sender: AnyObject) {
        dialogOKCancel("Exit Stitch This!?", text: "Are you sure?")
    }

    //------------------
    // T A B   V I E W
    //------------------
    
    // Tab View itself
    @IBOutlet weak var oTabView: NSTabView!
    // Tabs
    @IBOutlet weak var oTvImage: NSTabViewItem!
    @IBOutlet weak var oTvMatch: NSTabViewItem!
    @IBOutlet weak var oTvSymbols: NSTabViewItem!
    @IBOutlet weak var oTvGenerate: NSTabViewItem!
    
    
    //----------------------------------------
    // T A B   V I E W   C O M P O N E N T S
    //----------------------------------------
    
    // I M A G E
    //----------
    
    //Outlets
    @IBOutlet weak var oImageFname: NSTextFieldCell!
    @IBOutlet weak var oImage: NSImageView!
    @IBOutlet weak var oImageFname2: NSTextField!
    @IBOutlet weak var oImage2: NSImageView!
    @IBOutlet weak var oImageLock: NSButton!
    @IBOutlet weak var oImageW: NSTextField!
    @IBOutlet weak var oImageH: NSTextField!
    @IBOutlet weak var oImageReduce: NSButton!
    @IBOutlet weak var oImageResizeNarr: NSTextField!
    @IBOutlet weak var oImagePalCV: NSCollectionView!
    @IBOutlet weak var oImageNext: NSButton!
    
    // Actions
    @IBAction func aImageLock(_ sender: AnyObject) {
        if oImageLock.state == 0 {
            oImageLock.image = NSImage(named: "iconLocked")
        } else {
            oImageLock.image = NSImage(named: "iconUnlocked")
        }
    }
    @IBAction func aImageW(_ sender: AnyObject) {
        if vImageLoaded == false {return}
        if oImageW.stringValue < "0" || oImageW.stringValue > "9999" {
            dialogOK("Validation error", text: "The width value is either non-numeric or way too large for a viable project. Please re-enter.")
            return
        }
        vImageW = oImageW.integerValue
        if oImageLock.state == 0 {
            vImageH = Int(Float(vImageW) / vAspectRatio)
            oImageH.integerValue = vImageH
            iH = vImageH
        }
        iW = vImageW
        oImageReduce.isEnabled = true
        oMProcReduce.isEnabled = true
    }
    @IBAction func aImageH(_ sender: AnyObject) {
        if vImageLoaded == false {return}
        if oImageH.stringValue < "0" || oImageH.stringValue > "9999" {
            dialogOK("Validation error", text: "The height value is either non-numeric or way too large for a viable project. Please re-enter.")
            return
        }
        vImageH = oImageH.integerValue
        if oImageLock.state == 0 {
            vImageW = Int(Float(vImageH) * vAspectRatio)
            oImageW.integerValue = vImageW
            iW = vImageW
        }
        iH = vImageH
        oImageReduce.isEnabled = true
        oMProcReduce.isEnabled = true
    }
    @IBAction func aImageReduce(_ sender: AnyObject) {
        doReduce()
        oImageNext.isEnabled = true
        oImageNext.isHighlighted = true
    }
    @IBAction func aImageNext(_ sender: Any) {
        oTabView.selectTabViewItem(at: 1)
    }
    
    // M A T C H
    //----------
    
    // Outlets
    @IBOutlet weak var oMatchManuf: NSPopUpButton!
    @IBOutlet weak var oMatchRange: NSPopUpButton!
    @IBOutlet weak var oMatchColoursSlider: NSSlider!
    @IBOutlet weak var oMatchColours: NSTextField!
    @IBOutlet weak var oMatchSC: NSMenuItem!
    @IBOutlet weak var oMatchTW: NSMenuItem!
    @IBOutlet weak var oMatchButton: NSButton!
    @IBOutlet weak var oMatchImage1: NSImageView!
    @IBOutlet weak var oMatchImage2: NSImageView!
    @IBOutlet weak var oMatchOrigNarr: NSTextField!
    @IBOutlet weak var oMatchCtNarr: NSTextField!
    @IBOutlet weak var oMatchMerge: NSButton!
    @IBOutlet weak var oMatchNext: NSButton!
    
    // Actions
    @IBAction func aMatchManuf(_ sender: AnyObject) {
        let prevValue = vMaker
        switch oMatchManuf.title {
        case "Madeira"      : vMaker = "MAD"
        case "DMC"          : vMaker = "DMC"
        case "Lecien Cosmo" : vMaker = "LEC"
        default             : vMaker = "ANC"
        }
        if vMaker == "MAD" || vMaker == "LEC" {
            oMatchRange.selectItem(at: 0)
            oMatchTW.isHidden = true
            oRange.selectItem(at: 0)
            oRangeTW.isHidden = true
            vRange = "SC"
        } else {
            oMatchRange.autoenablesItems = false
            oMatchTW.isHidden = false
            oRange.autoenablesItems = false
            oRangeTW.isHidden = false
        }
        oMaker.selectItem(at: oMatchManuf.indexOfSelectedItem)
        retCt = queryCt(vMaker, r: vRange)
        oCtDisp.stringValue = "No. of threads in range: \(retCt)"
        query(vMaker, r: vRange)
        oTableView.reloadData()
        vPrevSymSet = (0, "", 0)
        if prevValue != vMaker && prevValue != "" {
            oMatchButton.isEnabled = true
            oMProcMatch.isEnabled = true
            oMatchButton.state = NSOnState
        }
    }
    @IBAction func aMatchRange(_ sender: AnyObject) {
        let prevValue = vRange
        if vRange == "TW" && oMatchRange.title == "Stranded cotton" {
            oGenStrands.integerValue = prefStrands
            oGenStrandsDisp.integerValue = prefStrands
        }
        switch oMatchRange.title {
        case "Tapestry wool" : vRange = "TW"
        default              : vRange = "SC"
        }
        if vMaker == "MAD" {
            vRange = "SC"
        }
        if vRange == "TW" {
            oGenStrands.integerValue = 1
            oGenStrandsDisp.integerValue = 1
            oGenFabCt.integerValue = 10
            oGenFabCtDisp.integerValue = 10
            vFabCt = 10
        }
        oRange.selectItem(at: oMatchRange.indexOfSelectedItem)
        retCt = queryCt(vMaker, r: vRange)
        oCtDisp.stringValue = "No. of threads in range: \(retCt)"
        query(vMaker, r: vRange)
        oTableView.reloadData()
        vPrevSymSet = (0, "", 0)
        if vRange != prevValue && prevValue != ""{
            oMatchButton.isEnabled = true
            oMProcMatch.isEnabled = true
            oMatchButton.state = NSOnState
        }
   }
    @IBAction func aMatchSlider(_ sender: AnyObject) {
        oMatchColours.integerValue = oMatchColoursSlider.integerValue
        if matchVal != oMatchColours.integerValue {
            matchVal = oMatchColours.integerValue
            oMatchButton.isEnabled = true
            oMProcMatch.isEnabled = true
        }
        matchVal = oMatchColoursSlider.integerValue
    }
    @IBAction func aMatchColours(_ sender: AnyObject) {
        if oMatchColours.integerValue < 2 || oMatchColours.integerValue > 256 {
            oMatchColours.integerValue = oMatchColoursSlider.integerValue
        } else {
            oMatchColoursSlider.integerValue = oMatchColours.integerValue
            if matchVal != oMatchColoursSlider.integerValue {
                matchVal = oMatchColoursSlider.integerValue
                oMatchButton.isEnabled = true
                oMProcMatch.isEnabled = true
            }
       }
   }
    @IBAction func aMatchButton(_ sender: AnyObject) {
        vPrevSymSet = (0, "", 0)
        matchProcess()
        oMatchMerge.state = NSOnState
        oMProcMerge.isEnabled = true
        oMatchButton.isEnabled = false
        oMProcMatch.isEnabled = false
        oMatchNext.isEnabled = true
        oMatchNext.isHighlighted = true
        oSymNext.isEnabled = true
        oSymNext.isHighlighted = true
    }
    @IBAction func aMatchMerge(_ sender: Any) {
        oColoursSlide.integerValue = threshold
        oColoursText.integerValue = threshold
        findUnderusedColours(threshold: threshold)
        mergeColourCt = replacePal.count
        oColoursToBeMerged.stringValue = "Colours for merging: \(mergeColourCt)"
        oColoursCV.reloadData()
        oColours.isOpaque = true
        oColours.isMovableByWindowBackground = true
        oColours.makeKeyAndOrderFront(nil)
        oMatchNext.isEnabled = true
    }
    @IBAction func aMatchNext(_ sender: Any) {
        oTabView.selectTabViewItem(at: 2)
        oSymNext.isEnabled = true
        oSymNext.isHighlighted = true
    }
    
    // S Y M B O L S
    //--------------
    
    // Outlets
    @IBOutlet weak var oSymDispCV: NSCollectionView!
    @IBOutlet weak var oSymText: NSTextField!
    @IBOutlet weak var oSymUser: NSPopUpButton!
    @IBOutlet weak var oSymNext: NSButton!
    
    // Actions
    @IBOutlet weak var oSymProgress: NSProgressIndicator!
    @IBAction func aSymUser(_ sender: Any) {
        nm = oSymUser.titleOfSelectedItem!
        if oSymUser.stringValue != saveUsr {
            usr = oSymUser.titleOfSelectedItem!
            if nm != "Default" {
                loadUserSymbols(usr)
            } else {
                allocateSymbolsFromDefaultSet()
                loadUserSymbols("Default")
                setBG(self)
            }
            showSymbols()
            oSymDispCV.reloadData()
        }
        oPrefUser.selectItem(withTitle: oSymUser.titleOfSelectedItem!)
        saveUsr = oSymUser.titleOfSelectedItem!
    }
                    
    @IBAction func aSymNext(_ sender: Any) {
        oTabView.selectTabViewItem(at: 3)
    }
    

    // G E N E R A T E
    //----------------

    // Outlets
    @IBOutlet weak var oGenProjName: NSTextField!
    @IBOutlet weak var oGenPgReq: NSTextField!
    @IBOutlet weak var oGenMeas: NSPopUpButton!
    @IBOutlet weak var oGenTurn: NSSlider!
    @IBOutlet weak var oGenTurnUnit: NSTextField!
    @IBOutlet weak var oGenFabCt: NSSlider!
    @IBOutlet weak var oGenFabCtDisp: NSTextField!
    @IBOutlet weak var oGenStrands: NSSlider!
    @IBOutlet weak var oGenStrandsDisp: NSTextField!
    @IBOutlet weak var oGenDtStart: NSButton!
    @IBOutlet weak var oGenChartColour: NSPopUpButton!
    @IBOutlet weak var oGenColourMenu: NSPopUpButtonCell!
    @IBOutlet weak var oGenPrChart: NSButton!
    @IBOutlet weak var oGenPrKey: NSButton!
    @IBOutlet weak var oGenPrThrCd: NSButton!
    @IBOutlet weak var oGenPrImg: NSButton!
    @IBOutlet weak var oGenPrShop: NSButton!
    @IBOutlet weak var oGenPrSelect: NSButton!
    @IBOutlet weak var oGenCardH: NSSlider!
    @IBOutlet weak var oGenHDim: NSTextField!
    @IBOutlet weak var oGenCardReq: NSTextField!
    @IBOutlet weak var oGenPaperNarr: NSTextField!
    @IBOutlet weak var oGenDecrement: NSButtonCell!
    @IBOutlet weak var oGenProgBar: NSProgressIndicator!
    @IBOutlet weak var oGenPDF: NSButtonCell!
    
    // Actions
    @IBAction func aGenMeas(_ sender: AnyObject) {
        measurements()
    }
    @IBAction func aGenTurn(_ sender: AnyObject) {
       switch oGenMeas.title {
        case "inches":
            vOptTurnImp = oGenTurn.integerValue
            vOptTurnMet = Int(round(Float(oGenTurn.integerValue) * 2.54))
            oGenTurn.minValue = 1
            oGenTurn.maxValue = 4
            oGenTurn.integerValue = vOptTurnImp
            oGenTurnUnit.stringValue = "\(vOptTurnImp) in"
        case "centimetres":
            vOptTurnMet = oGenTurn.integerValue
            vOptTurnImp = Int(round(Float(oGenTurn.integerValue) / 2.54))
            oGenTurn.minValue = 3
            oGenTurn.maxValue = 10
            oGenTurn.integerValue = vOptTurnMet
            oGenTurnUnit.stringValue = "\(vOptTurnMet) cm"
        default:
            break
        }
        measurements()
    }
    @IBAction func aGenFabCt(_ sender: AnyObject) {
        if oMatchRange.stringValue == "TW" {
            vFabCt = 10
            oGenFabCt.integerValue = 10
            oGenFabCtDisp.integerValue = 10
        } else {
            vFabCt = oGenFabCt.integerValue
            oGenFabCtDisp.integerValue = vFabCt
        }
    }
    @IBAction func aGenFabCtDisp(_ sender: AnyObject) {
        if oMatchRange.stringValue == "TW" {
            oGenFabCt.integerValue = 10
            oGenFabCtDisp.integerValue = 10
            vFabCt = 10
        } else {
            if oGenFabCtDisp.integerValue < 7 || oGenFabCtDisp.integerValue > 28 {
                dialogOK("Error", text: "Not a valid value for this item. \nShould be between 7-28.")
                oGenFabCtDisp.integerValue = vFabCt
            } else {
                vFabCt = oGenFabCtDisp.integerValue
                oGenFabCt.integerValue = vFabCt
            }
        }
   }
    @IBAction func aGenStrands(_ sender: Any) {
        if oGenStrands.integerValue > 1 && vRange == "TW" {
            oGenStrands.integerValue = 1
            oGenStrandsDisp.integerValue = 1
            dialogOK("Error", text: "You can't have 'strands' of tapestry wool - only stranded cotton.")
        }
        vStrandCt = oGenStrands.integerValue
        oGenStrandsDisp.integerValue = vStrandCt
    }
    @IBAction func aGenStrandsDisp(_ sender: Any) {
        if oGenStrandsDisp.integerValue < 1 || oGenStrandsDisp.integerValue > 6 {
            dialogOK("Error", text: "Not a valid value for this item. \n Should be between 1 and 6.")
            oGenStrandsDisp.integerValue = vStrandCt
        } else {
            vStrandCt = oGenStrandsDisp.integerValue
            oGenStrands.integerValue = vStrandCt
        }
    }
    @IBAction func aGenDtStart(_ sender: Any) {
    }
    @IBAction func aGenChartColour(_ sender: AnyObject) {
        if oGenChartColour.titleOfSelectedItem == "Colour" {
            mapInColour = true
            prefChCol = true
        } else {
            mapInColour = false
            prefChCol = false
        }
    }
    @IBAction func aGenPrChart(_ sender: AnyObject) {
        optionsSelected()
    }
    @IBAction func aGenPrKey(_ sender: AnyObject) {
        optionsSelected()
    }
    @IBAction func aGenPrImg(_ sender: AnyObject) {
        optionsSelected()
    }
    @IBAction func aGenPrThrCd(_ sender: AnyObject) {
        optionsSelected()
    }
    @IBAction func aGenPrShop(_ sender: AnyObject) {
        optionsSelected()
    }
    @IBAction func aGenPrSelect(_ sender: AnyObject) {
        if oGenPrSelect.title == "Select all" {
            oGenPrChart.state = NSOnState
            oGenPrKey.state = NSOnState
            oGenPrImg.state = NSOnState
            oGenPrThrCd.state = NSOnState
            oGenPrShop.state = NSOnState
            oGenPrSelect.state = NSOnState
            oGenPrSelect.title = "Select none"
            oGenPrSelect.state = NSOnState
        } else if oGenPrSelect.title == "Select none" {
            oGenPrChart.state = NSOffState
            oGenPrKey.state = NSOffState
            oGenPrImg.state = NSOffState
            oGenPrThrCd.state = NSOffState
            oGenPrShop.state = NSOffState
            oGenPrSelect.title = "Select all"
            oGenPrSelect.state = NSOffState
        }
    }
    @IBAction func aGenCardH(_ sender: AnyObject) {
        switch oGenMeas.title {
        case "inches":
            vThrCdHImp = oGenCardH.integerValue
            vThrCdHMet = Int(round(Float(oGenCardH.integerValue) * 2.54))
            oGenCardH.minValue = 4
            oGenCardH.maxValue = 11
            oGenCardH.integerValue = vThrCdHImp
            oGenHDim.stringValue = "\(vThrCdHImp) in"
        case "centimetres":
            vThrCdHMet = oGenCardH.integerValue
            vThrCdHImp = Int(round(Float(oGenCardH.integerValue) / 2.54))
            oGenCardH.minValue = 10
            oGenCardH.maxValue = 28
            oGenCardH.integerValue = vThrCdHMet
            oGenHDim.stringValue = "\(vThrCdHMet) cm"
        default:
            break
        }
        measurements()
        if distCol > 0 {
            meas = ""
            switch oGenMeas.title {
            case "inches": meas = "in"
            case "centimetres": meas = "cm"
            default: break
            }
        }
        oGenTurnUnit.stringValue = " \(String(oGenTurn.integerValue)) \(meas)"
        let cardsReq: Int = cardCalc(meas, cardH: oGenCardH.integerValue, cols: distCol)
        oGenCardReq.stringValue = "No. required: \(cardsReq)"
    }
    @IBAction func aGenDecrement(_ sender: Any) {
        if oGenDecrement.integerValue != 0 {
            decrement = true
        } else {
            decrement = false
        }
    }
    @IBAction func aGenPDF(_ sender: AnyObject) {
        if oGenPrKey.integerValue == 0 &&
            oGenPrThrCd.integerValue == 0 &&
            oGenPrImg.integerValue == 0 &&
            oGenPrShop.integerValue == 0 &&
            oGenPrChart.integerValue == 0 {
            dialogOK("No options selected",text: "What do you want your PDF to contain? \n\nYou need to select at least one page type. \nPlease review.")
            return
        } else {
            _ = savePDF()
        }
    }

    
    //--------------------------------
    //    O T H E R   W I N D O W S
    //--------------------------------
    
    
    //----------------------------
    //  M E R G E   C O L O U R S
    //----------------------------

    
    // Outlets
    @IBOutlet weak var oColours: NSWindow!
    @IBOutlet weak var oColoursCV: NSCollectionView!
    @IBOutlet weak var oColoursSlide: NSSlider!
    @IBOutlet weak var oColoursText: NSTextField!
    @IBOutlet weak var oColoursToBeMerged: NSTextField!
    
    // Actions
    @IBAction func aColoursSlide(_ sender: Any) {
        oColoursText.integerValue = oColoursSlide.integerValue
        threshold = oColoursText.integerValue
    }
    @IBAction func aColoursText(_ sender: Any) {
        if oColoursText.integerValue < 100 || oColoursText.integerValue > 1000 {
            oColoursText.integerValue = oColoursSlide.integerValue
        } else {
            oColoursSlide.integerValue = oColoursText.integerValue
        }
        threshold = oColoursText.integerValue
    }
    @IBAction func aColoursApply(_ sender: Any) {
        if oColoursText.integerValue > 1000 {
            dialogOK("Value entered over 1,000", text: "This process is provided to combine insignificant colours with those more significant. Values over 1,000 should be considered significant.")
        } else {
            findUnderusedColours(threshold: threshold)
            oColoursCV.reloadData()
            mergeColourCt = replacePal.count
            oColoursToBeMerged.stringValue = "Colours for merging: \(mergeColourCt)"
        }
    }
    @IBAction func aColoursOK(_ sender: Any) {
        var i: Int = 0
        for i in 0..<replacePal.count {
            var pos1: Int = 0
            var pos2: Int = 0
            var mergeCount: Int = 0
            if replacePal[i].replace == true {
                for j in 0..<matchedPal.count {
                    if replacePal[i].rgb1.rgbRed == matchedPal[j].rgb.rgbRed &&
                       replacePal[i].rgb1.rgbGreen == matchedPal[j].rgb.rgbGreen &&
                       replacePal[i].rgb1.rgbBlue == matchedPal[j].rgb.rgbBlue {
                           pos1 = j
                        mergeCount += 1
                           break
                    }
                }
                for j in 0..<matchedPal.count {
                    if replacePal[i].rgb2.rgbRed == matchedPal[j].rgb.rgbRed &&
                       replacePal[i].rgb2.rgbGreen == matchedPal[j].rgb.rgbGreen &&
                       replacePal[i].rgb2.rgbBlue == matchedPal[j].rgb.rgbBlue &&
                       matchedPal[j].ct >= threshold {
                           pos2 = j
                           overwriteColour(i: pos1, j: pos2, calledBy: "aColoursOK")
                           matchedPal[pos1].src = Int32(pos2)
                           matchedPal[pos1].colourNo = matchedPal[pos2].colourNo
                           matchedPal[pos1].rgb = matchedPal[pos2].rgb
                           matchedPal[pos2].ct += matchedPal[pos1].ct
                           matchedPal[pos1].ct = 0
                           matchedPal[pos1].lum = matchedPal[pos2].lum
                   }
                }
            }
         }
        showSymbols()
        replaceColours()
        writeToTempFile()
        oMatchImage2.image = imageN
        distCol = sortedPal.count
        oMatchCtNarr.stringValue = "\(distCol) distinct colours"
        i = cardCalc(meas, cardH: oGenCardH.integerValue, cols: distCol)
        oGenCardReq.stringValue = "No. required: \(i)"
        oColours.close()
        oMatchMerge.state = NSOffState
        oMProcMerge.isEnabled = false
    }
    @IBAction func aColoursCancel(_ sender: Any) {
        oColours.close()
    }
    
    //-----------------------------
    // S P A R E S   M A N A G E R
    //-----------------------------

    @IBOutlet weak var oSparesMgr: NSWindow!
    // Outlets
    @IBOutlet weak var oMaker: NSPopUpButton!
    @IBOutlet weak var oRange: NSPopUpButton!
    @IBOutlet weak var oRangeSC: NSMenuItem!
    @IBOutlet weak var oRangeTW: NSMenuItem!
    @IBOutlet weak var oCtDisp: NSTextField!
    @IBOutlet weak var oTableView: NSTableView!
    @IBOutlet weak var oUpdate: NSButton!
    // Actions
    @IBAction func aMaker(_ sender: AnyObject) {
        switch oMaker.title {
        case "Lecien Cosmo" : vMaker = "LEC"
        case "Madeira"      : vMaker = "MAD"
        case "DMC"          : vMaker = "DMC"
        default             : vMaker = "ANC"
        }
        if vMaker == "MAD" || vMaker == "LEC" {
            oRange.selectItem(at: 0)
            oRangeTW.isHidden = true
            oMatchRange.selectItem(at: 0)
            oMatchTW.isHidden = true
            vRange = "SC"
        } else {
            oRange.autoenablesItems = false
            oRangeTW.isHidden = false
            oMatchRange.autoenablesItems = false
            oMatchTW.isHidden = false
        }
        oMatchManuf.selectItem(at: oMaker.indexOfSelectedItem)
        retCt = queryCt(vMaker, r: vRange)
        oCtDisp.stringValue = "No. of threads in range: \(retCt)"
        query(vMaker, r: vRange)
        oTableView.reloadData()
    }
    @IBAction func aRange(_ sender: AnyObject) {
        switch oRange.title {
        case "Tapestry wool" : vRange = "TW"
        default              : vRange = "SC"
        }
        if vMaker == "MAD" || vMaker == "LEC" {
            vRange = "SC"
        }
        oMatchRange.selectItem(at: oRange.indexOfSelectedItem)
        retCt = queryCt(vMaker, r: vRange)
        oCtDisp.stringValue = "No. of threads in range: \(retCt)"
        query(vMaker, r: vRange)
        oTableView.reloadData()
    }
    @IBAction func aSparesUpdated(_ sender: NSTextField) {
        if oUpdate.isEnabled == false {
            oUpdate.isEnabled = true
        }
        let row = oTableView.row(for: sender)
        if sender.stringValue != "" {
            let tmp: Float = sender.floatValue
            dataArray[row].spare = Double(nearestQuarter(input: Double(tmp * 100))) / 100
            sender.floatValue = tmp
            dataArray[row].upd = true
        }
    }
    @IBAction func aUpdate(_ sender: NSButton) {
        beginTransaction()
        for i in 0..<dataArray.count {
            if dataArray[i].upd == true {
                let colourNo = dataArray[i].colorNo
                let val: Double = Double(dataArray[i].spare) * 100
                update(val, m: vMaker, r: vRange, n: colourNo)
            }
        }
        oUpdate.isEnabled = false
        commitTransaction()
        oTableView.reloadData()
    }

    //------------------------
    //  P R E F E R E N C E S
    //------------------------
    
    @IBOutlet weak var oPreferences: NSWindow!

    // Outlets
    @IBOutlet weak var oPrefMeas: NSPopUpButton!
    @IBOutlet weak var oPrefPaper: NSPopUpButton!
    @IBOutlet weak var oPrefDate: NSPopUpButtonCell!
    @IBOutlet weak var oPrefManuf: NSPopUpButton!
    @IBOutlet weak var oPrefRange: NSPopUpButton!
    @IBOutlet weak var oPrefRangeSC: NSMenuItem!
    @IBOutlet weak var oPrefRangeTW: NSMenuItem!
    @IBOutlet weak var oPrefFabCtSlider: NSSlider!
    @IBOutlet weak var oPrefFabCtBox: NSTextField!
    @IBOutlet weak var oPrefTurn: NSSlider!
    @IBOutlet weak var oPrefTurnUnit: NSTextField!
    @IBOutlet weak var oPrefStrands: NSSlider!
    @IBOutlet weak var oPrefStrandDisp: NSTextField!
    @IBOutlet weak var oPrefChartColour: NSPopUpButton!
    @IBOutlet weak var oPrefThrCdSlider: NSSlider!
    @IBOutlet weak var oPrefThrCdBox: NSTextField!
    @IBOutlet weak var oPrefTCUnit: NSTextField!
    @IBOutlet weak var oPrefDtStart: NSButton!
    @IBOutlet weak var oPrefOutCharts: NSButton!
    @IBOutlet weak var oPrefOutKeyP: NSButton!
    @IBOutlet weak var oPrefOutThrCd: NSButton!
    @IBOutlet weak var oPrefOutImage: NSButton!
    @IBOutlet weak var oPrefOutShopList: NSButton!
    @IBOutlet weak var oPrefOutSelect: NSButton!
    
    // Actions
    @IBAction func aPrefMeas(_ sender: AnyObject) {
        var scaleChanged: Bool = false
        if (oPrefMeas.title == "centimetres" && prefMeasmt == "cm") ||
            (oPrefMeas.title == "inches" && prefMeasmt == "in") {
            scaleChanged = false
        } else {
            scaleChanged = true
        }
        if scaleChanged == true {
            switch oPrefMeas.title {
            case "centimetres": vThrCdHImp  = prefCrdH
                                vThrCdHMet  = Int(round(Float(prefCrdH) * 2.54))
                                prefCrdH    = vThrCdHMet
                                vOptTurnImp = prefTurn
                                vOptTurnMet = Int(round(Float(prefTurn) * 2.54))
                                prefTurn    = vOptTurnMet
            default:            vThrCdHMet  = prefCrdH
                                vThrCdHImp  = Int(round(Float(prefCrdH) / 2.54))
                                prefCrdH    = vThrCdHImp
                                vOptTurnMet = prefTurn
                                vOptTurnImp = Int(round(Float(prefTurn) / 2.54))
                                prefTurn    = vOptTurnImp
            }
        }
        prefMeas()
        switch oPrefMeas.title {
        case  "centimetres" : prefMeasmt = "cm"
        default:              prefMeasmt = "in"
        }
        oPrefTCUnit.stringValue = prefMeasmt
    }
    @IBAction func aPrefPaper(_ sender: AnyObject) {
        switch oPrefPaper.title {
        case "A4"   : prefPaperSz = "A4"
        default     : prefPaperSz = "Letter"
        }
    }
    @IBAction func aPrefDate(_ sender: AnyObject) {
        switch oPrefDate.title {
        case "D·M·Y": prefDate = "EU"
        default:      prefDate = "US"
        }
    }
    @IBAction func aPrefManuf(_ sender: AnyObject) {
        switch oPrefManuf.title {
        case "Lecien Cosmo" : vMaker = "LEC"
        case "Madeira"      : vMaker = "MAD"
        case "DMC"          : vMaker = "DMC"
        default             : vMaker = "ANC"
        }
        if vMaker == "MAD" || vMaker == "LEC"  {
            oPrefRange.selectItem(at: 0)
            oPrefRangeTW.isHidden = true
            vRange = "SC"
        } else {
            oPrefRange.autoenablesItems = false
            oPrefRangeTW.isHidden = false
        }
        prefManuf = vMaker
    }
    @IBAction func aPrefRange(_ sender: AnyObject) {
        switch oPrefRange.title {
        case "Tapestry wool" : vRange = "TW"
        default              : vRange = "SC"
        }
        if vMaker == "MAD" || vMaker == "LEC" {
            vRange = "SC"
        }
        prefRange = vRange
    }
    @IBAction func aPrefFabCt(_ sender: AnyObject) {
        vFabCt = oPrefFabCtSlider.integerValue
        oPrefFabCtBox.integerValue = vFabCt
        prefFabCt = vFabCt
    }
    @IBAction func aPrefFabCtBox(_ sender: AnyObject) {
        if oPrefFabCtBox.integerValue < 7 || oPrefFabCtBox.integerValue > 28 {
            dialogOK("Error", text: "Not a valid value for this item. \nShould be between 7-28.")
            oPrefFabCtBox.integerValue = vFabCt
        } else {
            vFabCt = oPrefFabCtBox.integerValue
            oPrefFabCtSlider.integerValue = vFabCt
        }
        prefFabCt = vFabCt
    }
    @IBAction func aPrefStrands(_ sender: Any) {
        vStrandCt = oPrefStrands.integerValue
        oPrefStrandDisp.integerValue = vStrandCt
        prefStrands = vStrandCt
    }
   @IBAction func aPrefTurn(_ sender: AnyObject) {
        switch oPrefMeas.title {
            case "centimetres":
                vOptTurnMet = oPrefTurn.integerValue
                vOptTurnImp = Int(round(Float(oPrefTurn.integerValue) / 2.54))
            default:
                vOptTurnImp = oPrefTurn.integerValue
                vOptTurnMet = Int(round(Float(oPrefTurn.integerValue) * 2.54))
        }
        prefMeas()
        switch prefMeasmt {
            case "cm":  prefTurn = vOptTurnMet
                        oPrefTurn.minValue = 3
                        oPrefTurn.maxValue = 10
                        oPrefTurnUnit.stringValue = "\(vOptTurnMet) cm"
            default:    prefTurn = vOptTurnImp
                        oPrefTurn.minValue = 1
                        oPrefTurn.maxValue = 4
                        oPrefTurnUnit.stringValue = "\(vOptTurnImp) in"
        }
        oPrefTurn.integerValue = prefTurn
    }
    
    @IBAction func aPrefChartColour(_ sender: AnyObject) {
        if oPrefChartColour.selectedItem!.title != "Colour" {
            mapInColour = false
            prefChCol = false
        } else {
            mapInColour = true
            prefChCol = true
        }
    }
    @IBAction func aPrefCardH(_ sender: AnyObject) {
        switch prefMeasmt {
        case "cm":
            vThrCdHMet = oPrefThrCdSlider.integerValue
            vThrCdHImp = Int(round(Float(oPrefThrCdSlider.integerValue) / 2.54))
            prefCrdH = vThrCdHMet
            oPrefThrCdSlider.minValue = 10
            oPrefThrCdSlider.maxValue = 28
            oPrefThrCdSlider.integerValue = prefCrdH
            oPrefThrCdBox.integerValue = prefCrdH
        default:
            vThrCdHImp = oPrefThrCdSlider.integerValue
            vThrCdHMet = Int(round(Float(oPrefThrCdSlider.integerValue) * 2.54))
            prefCrdH = vThrCdHImp
            oPrefThrCdSlider.minValue = 4
            oPrefThrCdSlider.maxValue = 11
            oPrefThrCdSlider.integerValue = prefCrdH
            oPrefThrCdBox.integerValue = prefCrdH
        }
        prefMeas()
        if distCol > 0 {
            meas = ""
            switch oPrefMeas.title {
                case "centimetres": meas = "cm"
                default: meas = "in"
            }
        }
        oPrefTCUnit.stringValue = meas
        oGenTurnUnit.stringValue = " \(String(oGenTurn.integerValue)) \(meas)"
    }
    @IBAction func aPrefThrCdBox(_ sender: AnyObject) {
        switch prefMeasmt {
        case "in":
            if oPrefThrCdBox.integerValue < 4 ||
                oPrefThrCdBox.integerValue > 11 {
                dialogOK("Error", text: "Not a valid value for this item. \nShould be between 4-11.")
                oPrefThrCdBox.integerValue = vImageH
            } else {
                vImageH = oPrefThrCdBox.integerValue
                oPrefThrCdSlider.integerValue = vImageH
                prefCrdH = vImageH
            }
        case "cm":
            if oPrefThrCdBox.integerValue < 10 ||
                oPrefThrCdBox.integerValue > 28 {
                dialogOK("Error", text: "Not a valid value for this item. \nShould be between 10-28.")
                oPrefThrCdBox.integerValue = vImageH
            } else {
                vImageH = oPrefThrCdBox.integerValue
                oPrefThrCdSlider.integerValue = vImageH
                prefCrdH = vImageH
            }
        default: break
        }
    }
    @IBAction func aPrefDtStart(_ sender: AnyObject) {
        if oPrefDtStart.state == NSOnState {
            prefDtStart = true
        } else {
            prefDtStart = false
        }
    }
    @IBAction func aPrefOutCharts(_ sender: AnyObject) {
        prefSelected()
        if oPrefOutCharts.state == NSOffState {
            prefOutCh = false
        } else {
            prefOutCh = true
        }
    }
    @IBAction func aPrefOutKeyP(_ sender: AnyObject) {
        prefSelected()
        if oPrefOutKeyP.state == NSOffState {
            prefOutKP = false
        } else {
            prefOutKP = true
        }
    }
    @IBAction func aPrefOutThrCd(_ sender: AnyObject) {
        prefSelected()
        if oPrefOutThrCd.state == NSOffState {
            prefOutTC = false
        } else {
            prefOutTC = true
        }
    }
    @IBAction func aPrefOutImg(_ sender: AnyObject) {
        prefSelected()
        if oPrefOutImage.state == NSOffState {
            prefOutIm = false
        } else {
            prefOutIm = true
        }
    }
    @IBAction func aPrefOutShopList(_ sender: AnyObject) {
        prefSelected()
        if oPrefOutShopList.state == NSOffState {
            prefOutSL = false
        } else {
            prefOutSL = true
        }
    }
    @IBAction func aPrefSelect(_ sender: AnyObject) {
        if oPrefOutSelect.title == "Select all" {
            oPrefOutCharts.state = NSOnState
            oPrefOutKeyP.state = NSOnState
            oPrefOutImage.state = NSOnState
            oPrefOutThrCd.state = NSOnState
            oPrefOutShopList.state = NSOnState
            oPrefOutSelect.state = NSOnState
            oPrefOutSelect.title = "Select none"
            oPrefOutSelect.state = NSOnState
        } else if oPrefOutSelect.title == "Select none" {
            oPrefOutCharts.state = NSOffState
            oPrefOutKeyP.state = NSOffState
            oPrefOutImage.state = NSOffState
            oPrefOutThrCd.state = NSOffState
            oPrefOutShopList.state = NSOffState
            oPrefOutSelect.title = "Select all"
            oPrefOutSelect.state = NSOffState
        }
        switch oPrefOutCharts.state {
            case NSOffState: prefOutCh = false
            default        : prefOutCh = true
        }
        switch oPrefOutKeyP.state {
            case NSOffState: prefOutKP = false
            default        : prefOutKP = true
        }
        switch oPrefOutThrCd.state {
            case NSOffState: prefOutTC = false
            default        : prefOutTC = true
        }
        switch oPrefOutImage.state {
            case NSOffState: prefOutIm = false
            default        : prefOutIm = true
        }
        switch oPrefOutShopList.state {
            case NSOffState: prefOutSL = false
            default        : prefOutSL = true
        }
    }
    @IBAction func aPrefRestore(_ sender: AnyObject) {
        let popUp: NSAlert = NSAlert()
        popUp.messageText = "Are you sure?"
        popUp.informativeText = "This will overwrite all current preferences and set them back to their original values."
        popUp.alertStyle = NSAlertStyle.warning
        popUp.addButton(withTitle: "OK")
        popUp.addButton(withTitle: "Cancel")
        popUp.beginSheetModal(for: self.oPreferences!, completionHandler: { (modalResponse) -> Void in
            if modalResponse == NSAlertFirstButtonReturn {
                prefPaperSz = "A4"
                prefDate = "EU"
                prefMeasmt = "in"
                prefManuf = "DMC"
                prefRange = "SC"
                prefFabCt = 14
                prefTurn = 2
                prefCrdH = 8
                prefChCol = false
                prefDtStart = false
                prefOutCh = true
                prefOutKP = true
                prefOutTC = true
                prefOutIm = false
                prefOutSL = false
                prefStUser = "Default"
                self.loadPrefs()
                self.oPrefUser.selectItem(withTitle: prefStUser)
                self.oSymUser.selectItem(withTitle: prefStUser)
            }
        })
    }
    @IBAction func aPrefSave(_ sender: AnyObject) {
        setDefaults()
        loadPrefs()
        oGenPaperNarr.stringValue = "Paper selected is \(prefPaperSz). See Preferences | Regional to modify."
        oPreferences.close()
    }
    
    //  Preferences: Symbols
    //----------------------
    
    // Outlets
    @IBOutlet weak var oPrefUser: NSPopUpButton!
    @IBOutlet weak var oPrefSymColView: NSCollectionView!
    @IBOutlet weak var oPrefChosenCV: NSCollectionView!
    @IBOutlet weak var oPrefSymProgress: NSProgressIndicator!
    @IBOutlet weak var oPrefSymClear: NSButton!
    
    // Actions
    @IBAction func aPrefUser(_ sender: Any) {
        nm = oPrefUser.titleOfSelectedItem!
        if oPrefUser.stringValue != saveUsr {
            usr = oPrefUser.titleOfSelectedItem!
            prefStUser = usr
            oSymUser.selectItem(withTitle: usr)
            sortedPal.removeAll()
            if usr == "Default" {
                availableSymbolArray.removeAll()
                for i in 0..<symbolNoArray.count {
                    availableSymbolArray.append(symbolNoArray[i].no)
                }
                vPrefSymSet = []
                oPrefSymColView.reloadData()
                oPrefChosenCV.reloadData()
            }
            loadUserSymbols(usr)
            sortPrefSymSet()
            showSymbols()
            oPrefChosenCV.reloadData()
        }
        oSymUser.selectItem(withTitle: nm)
        oSymDispCV.reloadData()
        saveUsr = oPrefUser.titleOfSelectedItem!
        usr = nm
        oPrefUser.selectItem(withTitle: usr)
    }
    @IBAction func aPrefSymClear(_ sender: AnyObject) {
        putBack(Int(getUserID(usr)), char: 0)
        vPrefSymSet = []
        deleteSymbolSet(Int(getUserID(usr)))
        oPrefSymColView.reloadData()
        oPrefChosenCV.reloadData()
        oPrefSymClear.isEnabled = false
    }
    
    // The 'Add User' popup
    
    @IBOutlet weak var oAddUser: NSWindow!
    
    @IBOutlet weak var oAddUserName: NSTextField!
    @IBOutlet weak var oAddUserAdd: NSButton!
    
    @IBAction func aAddUserAdd(_ sender: Any) {
        let nm = oAddUserName.stringValue
        addUser(nm)
        uID = getUserID(nm)
        oPrefUser.addItem(withTitle: nm)
        oSymUser.addItem(withTitle: nm)
        oAddUserName.stringValue = ""
        oPrefUser.selectItem(withTitle: nm)
        oSymUser.selectItem(withTitle: nm)
        prefStUser = nm
        availableSymbolArray.removeAll()
        for i in 0..<symbolNoArray.count {
            availableSymbolArray.append(symbolNoArray[i].no)
        }
        vPrefSymSet = []
        oPrefSymColView.reloadData()
        oPrefChosenCV.reloadData()
        prefStUser = oPrefUser.titleOfSelectedItem!
        oAddUser.close()
    }
    
    
    // Clicking on the '+' key to trigger an Add User event
    
    @IBAction func aPrefAddUser(_ sender: AnyObject) {
        oAddUser.isOpaque = true
        oAddUser.isMovableByWindowBackground = true
        oAddUser.center()
        oAddUser.makeKeyAndOrderFront(nil)
    }
    
    // Clicking on the '-' key to trigger a delete user event
    @IBAction func aDeleteUser(_ sender: Any) {
        let nm = oPrefUser.titleOfSelectedItem!
        if nm == "Default" {
            popUpOK("You can't delete the default user", text: "That's a system-created user, and is there for when other users aren't set up or working correctly.")
        } else {
            deleteOKCancel("Are you sure?", text: "Do you really want to delete user '\(nm)'?", nm: nm)
        }
    }


    // Preference functions...
    //------------------------
    
    // Load initial defaults if they've previously been saved
    func loadPrefs() {
        measurements()
        prefMeas()
        // Set measurements according to the chosen scale
        switch prefPaperSz {
        case "A4"  : oPrefPaper.title = "A4"
        default    : oPrefPaper.title = "Letter"
        }
        switch prefDate {
        case "EU" : oPrefDate.title = "D·M·Y"
        default:    oPrefDate.title = "M·D·Y"
        }
        switch prefMeasmt {
            case "cm": oPrefMeas.title = "centimetres"
                       oGenMeas.title = "centimetres"
                       oGenTurn.minValue = 3
                       oGenTurn.maxValue = 10
                       oGenTurn.integerValue = prefTurn
                       oGenCardH.minValue = 10
                       oGenCardH.maxValue = 28
                       oGenCardH.integerValue = prefCrdH
            default:   oPrefMeas.title = "inches"
                       oGenMeas.title = "inches"
                       oGenTurn.minValue = 1
                       oGenTurn.maxValue = 4
                       oGenTurn.integerValue = prefTurn
                       oGenCardH.minValue = 4
                       oGenCardH.maxValue = 11
                       oGenCardH.integerValue = prefCrdH
        }
        oGenTurnUnit.stringValue = "\(prefTurn)  \(prefMeasmt)"
        oGenHDim.stringValue = "\(prefCrdH) \(prefMeasmt)"
        vMaker = prefManuf
        switch prefManuf {
        case "DMC": oPrefManuf.title = "DMC"
                    oMatchManuf.title = "DMC"
                    oMaker.title = "DMC"
        case "MAD": oPrefManuf.title = "Madeira"
                    oMatchManuf.title = "Madeira"
                    oMaker.title = "Madeira"
        case "LEC": oPrefManuf.title = "Lecien Cosmo"
                    oMatchManuf.title = "Lecien Cosmo"
                    oMaker.title = "Lecien Cosmo"
        default   : oPrefManuf.title = "Anchor"
                    oMatchManuf.title = "Anchor"
                    oMaker.title = "Anchor"
        }
        vRange = prefRange
        switch prefRange {
        case "TW": oPrefRange.title = "Tapestry wool"
                   oMatchRange.title = "Tapestry wool"
                   oRange.title = "Tapestry wool"
        default  : oPrefRange.title = "Stranded cotton"
                   oMatchRange.title = "Stranded cotton"
                   oRange.title = "Stranded cotton"
        }
        retCt = queryCt(vMaker, r: vRange)
        oCtDisp.stringValue = "No. of threads in range: \(retCt)"
        query(vMaker, r: vRange)
        oTableView.reloadData()
        if prefFabCt != 0 {
            oPrefFabCtSlider.integerValue = prefFabCt
            oPrefFabCtBox.integerValue = prefFabCt
            oGenFabCt.integerValue = prefFabCt
            oGenFabCtDisp.integerValue = prefFabCt
        }
        if oMatchRange.stringValue == "TW" {
            oGenFabCt.integerValue = 10
            oGenFabCtDisp.integerValue = 10
        }
        if prefCrdH != 0 {
            oPrefThrCdSlider.integerValue = prefCrdH
            oPrefThrCdBox.integerValue = prefCrdH
            oGenCardH.integerValue = prefCrdH
            oGenHDim.stringValue = "\(prefCrdH) \(prefMeasmt)"
       }
        if prefChCol == true {
            oGenColourMenu.selectItem(withTitle: "Colour")
        } else {
            oGenColourMenu.selectItem(withTitle: "B&W")
        }
        switch prefDtStart {
        case true: oPrefDtStart.state = NSOnState
                   oGenDtStart.state = NSOnState
        default:   oPrefDtStart.state = NSOffState
                   oGenDtStart.state = NSOffState
        }
        switch prefOutCh {
        case true: oPrefOutCharts.state = NSOnState
                   oGenPrChart.state = NSOnState
        default: oPrefOutCharts.state = NSOffState
                 oGenPrChart.state = NSOffState
        }
        switch prefOutKP {
        case true:  oPrefOutKeyP.state = NSOnState
                    oGenPrKey.state = NSOnState
        default: oPrefOutKeyP.state = NSOffState
                 oGenPrKey.state = NSOffState
        }
        switch prefOutTC {
        case true: oPrefOutThrCd.state = NSOnState
                   oGenPrThrCd.state = NSOnState
        default: oPrefOutThrCd.state = NSOffState
                 oGenPrThrCd.state = NSOffState
        }
        switch prefOutIm {
        case true: oPrefOutImage.state = NSOnState
                   oGenPrImg.state = NSOnState
        default: oPrefOutImage.state = NSOffState
                 oGenPrImg.state = NSOffState
        }
        switch prefOutSL {
        case true: oPrefOutShopList.state = NSOnState
                   oGenPrShop.state = NSOnState
        default: oPrefOutShopList.state = NSOffState
                 oGenPrShop.state = NSOffState
        }
        if getUserCt() == 0 {
            prefStUser = "Default"
        }
        oPrefUser.selectItem(withTitle: prefStUser)
        oSymUser.selectItem(withTitle: prefStUser)
        usr = prefStUser
        oGenPaperNarr.stringValue = "Paper selected is \(prefPaperSz). See Preferences | Regional to modify."
    }
    
    // Select all/Select None toggle of print selections
    func prefSelected() {
        if oPrefOutCharts.state == NSOffState &&
            oPrefOutKeyP.state == NSOffState &&
            oPrefOutImage.state == NSOffState &&
            oPrefOutThrCd.state == NSOffState &&
            oPrefOutShopList.state == NSOffState &&
            oPrefOutSelect.state == NSOffState {
            oPrefOutSelect.title = "Select all"
            oPrefOutSelect.state = NSOnState
        } else if oPrefOutCharts.state == NSOnState &&
            oPrefOutKeyP.state == NSOnState &&
            oPrefOutImage.state == NSOnState &&
            oPrefOutThrCd.state == NSOnState &&
            oPrefOutShopList.state == NSOnState {
            oPrefOutSelect.title = "Select none"
            oPrefOutSelect.state = NSOnState
        }
    }
    
    // Set measurements according to choice of units
    func prefMeas() {
        switch oPrefMeas.title {
        case "inches":
            vImp = true
            oPrefThrCdSlider.minValue = 4
            oPrefThrCdSlider.maxValue = 11
            oPrefThrCdSlider.integerValue = prefCrdH
            oPrefThrCdBox.integerValue = prefCrdH
            oPrefTurn.minValue = 1
            oPrefTurn.maxValue = 4
            oPrefTurn.integerValue = prefTurn
            meas = "in"
        case "centimetres":
            vImp = false
            oPrefThrCdSlider.minValue = 10
            oPrefThrCdSlider.maxValue = 28
            oPrefThrCdSlider.integerValue = prefCrdH
            oPrefThrCdBox.integerValue = prefCrdH
            oPrefTurn.minValue = 3
            oPrefTurn.maxValue = 10
            oPrefTurn.integerValue = prefTurn
            meas = "cm"
        default:
            break
        }
        oPrefStrands.integerValue = prefStrands
        oPrefTCUnit.stringValue = meas
        oPrefTurnUnit.stringValue = " \(String(oPrefTurn.integerValue)) \(meas)"
    }


    
    //
    //-----------------------------------------//
    //    D E F I N E D   F U N C T I O N S    //
    //                                         //
    //    (operating upon interface objects)   //
    //-----------------------------------------//
    //
    
    
    //-------------------
    // A P P   L E V E L
    //-------------------

    // Exit the Program
    func exitProg () {
        if bmpOrig != nil {
            FreeImage_Unload(bmpOrig)
        }
        if bmp24 != nil && bmp24 != bmpOrig {
            FreeImage_Unload(bmp24)
        }
        if bmp256 != nil && bmp256 != bmp24 && bmp256 != bmpOrig {
            FreeImage_Unload(bmp256)
        }
        if bmpMatched != nil && bmpMatched != bmp256 && bmpMatched != bmp24 && bmpMatched != bmpOrig {
            FreeImage_Unload(bmpMatched)
        }
        if currImage != nil && currImage != bmpMatched && currImage != bmp256 && currImage != bmp24 && currImage != bmpOrig {
            FreeImage_Unload(currImage)
        }
        FreeImage_DeInitialise()
        clearTempFolder()
        exit(0)
    }
    
    //-----------------------------------
    //   D I A L O G   F U N C T I O N S
    //-----------------------------------

    // Dialog with no choices
    func dialogOK(_ question: String, text: String) {
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
    
    // Dialog with the option to cancel
    func dialogOKCancel(_ question: String, text: String) {
        let popUp: NSAlert = NSAlert()
        popUp.messageText = question
        popUp.informativeText = text
        popUp.alertStyle = NSAlertStyle.warning
        popUp.addButton(withTitle: "OK")
        popUp.addButton(withTitle: "Cancel")
        popUp.beginSheetModal(for: self.view.window!, completionHandler: { (modalResponse) -> Void in
            if modalResponse == NSAlertFirstButtonReturn {
                self.exitProg()
            }
        })
    }

    // Delete dialog with option to cancel
    func deleteOKCancel(_ question: String, text: String, nm: String) {
        let popUp: NSAlert = NSAlert()
        popUp.messageText = question
        popUp.informativeText = text
        popUp.alertStyle = NSAlertStyle.warning
        popUp.addButton(withTitle: "OK")
        popUp.addButton(withTitle: "Cancel")
        if popUp.runModal() == NSAlertFirstButtonReturn {
            deleteUserSymbols(nm)
            deleteUser(nm)
            self.oPrefUser.removeItem(withTitle: nm)
            self.oSymUser.removeItem(withTitle: nm)
            self.oSymUser.selectItem(withTitle: "Default")
            self.oPrefUser.selectItem(withTitle: "Default")
            prefStUser = "Default"
            availableSymbolArray.removeAll()
            for i in 0..<symbolNoArray.count {
                availableSymbolArray.append(symbolNoArray[i].no)
            }
            oPrefSymColView.reloadData()
            oAddUser.close()
            vPrefSymSet = []
            oPrefChosenCV.reloadData()
        }
    }

    // Image file save dialog
    func saveImage() {
        let fileDialog: NSSavePanel = NSSavePanel()
        fileDialog.prompt = "Save"
        fileDialog.worksWhenModal = true
        fileDialog.nameFieldStringValue = projName
        fileDialog.allowedFileTypes = ["bmp"]
        fileDialog.isExtensionHidden = true
        fileDialog.beginSheetModal(for: self.view.window!,completionHandler: { num in
                if num == NSModalResponseOK {
                    let fileDialogURL = fileDialog.url!.absoluteString.replacingOccurrences(of: "file://", with: "").replacingOccurrences(of: "%2520", with: " ").replacingOccurrences(of: "%20", with: " ")
                    if fileDialogURL != "" {
                        let fPtr = (fileDialogURL as NSString).utf8String
                        FreeImage_Save(Int32(0), bmpMatched, fPtr, 0)
                        self.oTBSave.image = NSImage(named: "saveOff")
                        self.oTBSave.isEnabled = false
                        saveOK = false
                        self.oMFileSave.isEnabled = false
                    }
                }
            }
        )
    }
    
    // PDF Save dialog
    func savePDF() -> String {
        var url: String = ""
        let fileDialog: NSSavePanel = NSSavePanel()
        fileDialog.prompt = "Save"
        fileDialog.worksWhenModal = true
        fileDialog.allowedFileTypes = ["pdf"]
        fileDialog.isExtensionHidden = true
        //fileDialog.nameFieldStringValue = projName
        fileDialog.nameFieldStringValue = oGenProjName.stringValue
        fileDialog.hidesOnDeactivate = true
        fileDialog.beginSheetModal(for: self.view.window!,completionHandler: { num in
        if num == NSModalResponseOK {
            let fileDialogURL = fileDialog.url!.absoluteString.replacingOccurrences(of: "file://", with: "").replacingOccurrences(of: "%2520", with: " ").replacingOccurrences(of: "%20", with: " ")
            delay(0.1)
            if fileDialogURL != "" {
                fileDialog.close()
                self.printEngine(fileDialogURL)
                url = fileDialogURL
            }
         }
      })
       return url
    }

    //---------------------------------------------------------
    //   F I L E   M A F I P U L A T I O N   F U N C T I O N S
    //---------------------------------------------------------
    
    // Open a file
    func fileOpen() {
        let fileTypeArray = ["BMP", "ICO", "JPEG", "JPG", "JNG",
                             "KOALA", "LBM", "IFF", "MNG",
                             "PBM", "PBMRAW","PCD", "PCX",
                             "PGM", "PGMRAW", "PNG","PPM",
                             "PPMRAW", "RAS", "TARGA", "TGA",
                             "TIFF","TIF", "WBMP", "PSD", "CUT",
                             "XBM", "XPM", "DDS", "GIF"]
        let fileDialog: NSOpenPanel = NSOpenPanel()
        fileDialog.prompt = "Open"
        fileDialog.worksWhenModal = true
        fileDialog.allowsMultipleSelection = false
        fileDialog.canChooseDirectories = false
        fileDialog.resolvesAliases = true
        fileDialog.allowedFileTypes = fileTypeArray
        fileDialog.beginSheetModal(
            for: self.view.window!,
            completionHandler: { num in
                if num == NSModalResponseOK {
                    fNameURL = fileDialog.url
                    self.setInitialDefaults()
                    self.getImage()
                    if bpp == 8 {
                        self.oGenPDF.isEnabled = true
                        self.oMProcGenerate.isEnabled = true
                    } else {
                        self.oGenPDF.isEnabled = false
                        self.oMProcGenerate.isEnabled = false
                    }
                    self.oMFileSave.isEnabled = true
                }
        } )
    }

    // Get an image file and set any related interface elements
    func getImage() {
        oTabView.selectTabViewItem(at: 0)
        oImage.imageScaling = NSImageScaling.scaleProportionallyUpOrDown
        oMatchImage1.imageScaling = NSImageScaling.scaleProportionallyUpOrDown
        oImage.image = NSImage.init()
        oMatchImage1.image = NSImage.init()
        oMatchImage2.image = NSImage.init()
        oImageFname.stringValue = ""
        paletted = false
        oTBSave.image = NSImage(named: "saveOff")
        oTBSave.isEnabled = false
        saveOK = false
        oMFileSave.isEnabled = false
        pal256.removeAll()
        matchedPal.removeAll()
        sortedPal.removeAll()
        fetchFile()
        if fNameURL != nil {
            oGenProjName.stringValue = projName
            // Set image's dimensions for display etc
            oImageH.integerValue = iH
            oImageW.integerValue = iW
            currImage = bmpOrig
            FreeImage_AdjustBrightness(currImage, 6)
            newTmpFile(currImage,incr: false)
            oImage.image = imageN
            oMatchImage1.image = imageN
            oImageReduce.isEnabled = true
            oMProcReduce.isEnabled = true
            oImageReduce.state = NSOnState
            oMatchColours.isEnabled = true
            oMatchColoursSlider.isEnabled = true
            oMatchButton.isEnabled = true
            oMProcMatch.isEnabled = true
            fileDesc(0)
            oMatchButton.isEnabled = true
            oMatchButton.state = NSOnState
            oMProcMatch.isEnabled = true
        } else {
            oImageReduce.isEnabled = false
            oMProcReduce.isEnabled = false
        }
        setNewFileDefaults()
        if fNameURL != nil {
            resizeWindow()
        }
    }
    
    // Fetch the image - called by getImage
    func fetchFile() {
        if fNameURL == nil {
            return
        }
        let fileTypeLookup: [String:Int32] =
            ["BMP":0, "ICO":1, "JPEG":2, "JPG":2, "JNG":3,
             "KOALA":4, "LBM":5, "IFF":5, "MNG":6, "PBM":7,
             "PBMRAW":8, "PCD":9, "PCX":10, "PGM":11,
             "PGMRAW":12, "PNG":13, "PPM":14, "PPMRAW":15,
             "RAS":16, "TARGA":17, "TGA":17, "TIFF":18,
             "TIF":18, "WBMP":19, "PSD":20, "CUT":21,
             "XBM":22, "XPM":23, "DDS":24, "GIF":25]
        fType = fNameURL.pathExtension.uppercased()
        var fiType: Int32 = 0
        for (extn, type) in fileTypeLookup {
            if extn == fType {
                fiType = type
            }
        }
        rawData = NSData(contentsOf: fNameURL!)
        let fname = fNameURL.absoluteString.replacingOccurrences(of: "file://", with: "").replacingOccurrences(of: "%2520", with: " ").replacingOccurrences(of: "&", with: "+").replacingOccurrences(of: "[", with: "(").replacingOccurrences(of: "]", with: ")").replacingOccurrences(of: "%20", with: " ")
        let fPtr = (fname as NSString).utf8String
        bmpOrig = FreeImage_Load(fiType, fPtr, 0)
        // Check bits per pixel - and depending on the answer,
        // convert to format where it can be set to 8-bit.
        bpp = 1
        bpp = FreeImage_GetBPP(bmpOrig)
        if bpp == 0 {
            dialogOK("Oopsy daisies!", text: "Sorry, that file can't be opened...\n\nThis usually happens when the file, or the folder it's stored in, has accents or other non-standard characters in its name. \nTry renaming it by replacing those with conventional characters and try again (e.g. replace '&' with 'and').")
            fNameURL = nil
            return
        }
        imageN = NSImage(data: rawData! as Data)!
        if let imageC = imageN {
            var imageRect:CGRect = CGRect(x: 0, y: 0,
                                          width: imageC.size.width,
                                          height: imageC.size.height)
            _ = imageC.cgImage(forProposedRect: &imageRect,
                               context: nil,
                               hints: nil)
        }
        currImage = bmpOrig
        newTmpFile(currImage, incr: true)
        let imageSize = NSImageRep(contentsOf: fNameURL!)
        iW = imageSize!.pixelsWide
        iH = imageSize!.pixelsHigh
        fileName = fNameURL!.lastPathComponent
        projName = fNameURL!.lastPathComponent.components(separatedBy: ".")[0]
        vImageW = iW
        vImageH = iH
        vAspectRatio = Float(iW) / Float(iH)
        vImageLoaded = true
        getFileInfo(currImage)
        oImageFname.stringValue = "\(fileName) · \(colTypeNarr) · \(iW)(w) x \(iH)(h)"
    }
    
    // Calculate percentages of stitches per colour
    func getPercentages () {
        let totStCt: Int32 = Int32(iW) * Int32(iH)
        var bigPcts: Int32 = 0
        var noBigPcts: Int32 = 0
        for i in 0..<sortedPal.count {
            if ((sortedPal[i].ct) / Int32(totStCt) * 100) > 15 {
                bigPcts += sortedPal[i].ct
                noBigPcts += 1
            }
        }
        if noBigPcts <= 3 &&
            ((bigPcts / totStCt) * 100) > 40 {
            
        }
    }

    // Resize to dimensions specified
    func resize() {
        if vImageLoaded == false {
            return
        }
        currImage = FreeImage_Rescale(bmpOrig, Int32(vImageW), Int32(vImageH), 0)
        newTmpFile(currImage,incr: true)
        bmpOrig = currImage
        oImage2.image = imageN
        oMatchImage2.imageScaling = NSImageScaling.scaleProportionallyUpOrDown
        vAspectRatio = Float(vImageW) / Float(vImageH)
        if threshold > 1000 {
            threshold = 999
        }
        fileDesc(colCt)
    }
    
    // Quantize down to paletted image
    func makeImage8bit() {
        bmp256 = FreeImage_ColorQuantize(bmpOrig, FREE_IMAGE_QUANTIZE(Float(FIQ_NNQUANT.rawValue)))
        newTmpFile(bmp256, incr: true)
        oImage2.image = imageN
        oMatchImage1.image = nil
        oMatchImage1.image = imageN
        oMatchImage2.image = nil
    }
    
    // Get file information
    func getFileInfo(_ file: UnsafeMutablePointer<FIBITMAP>) {
        fileInfo(file)
        oMatchColours.integerValue = distCol
        oMatchColoursSlider.integerValue = distCol
    }

    // Ascertain and display the description of the file
    func fileDesc(_ cols: Int) {
        let narr = pagesReq()
        if cols == 0 {
            if colUsed > 0 {
                colCt = Int(colUsed)
            } else {
                if distCol > 0 {
                    colCt = distCol
                }
            }
        }
        if colType == 3 {
            colNarr = "\(cols) distinct colours, "
        } else {
            colNarr = " "
        }
        oGenPgReq.stringValue = narr
        oImageResizeNarr.stringValue = narr
        if pagesToPrint > 30 {
            oGenPgReq.textColor = NSColor.red
            oImageResizeNarr.textColor = NSColor.red
            oImageReduce.isEnabled = true
            oMProcReduce.isEnabled = true
        } else {
            oGenPgReq.textColor = NSColor.selectedMenuItemColor
            oImageResizeNarr.textColor = NSColor.selectedMenuItemColor
        }
        fileName = fNameURL!.lastPathComponent
    }

    //---------------------------------
    //   M I S C   F U N C T I O N S
    //---------------------------------
    
    //Reduce colour depth to 8-bit (paletted)
    func doReduce() {
        bpp = FreeImage_GetBPP(bmpOrig)
        if bpp == 0 {
            return
        }
        if bpp == 8 {
            distCol = loadPalette()
            dispPal = origPal
            oImagePalCV.reloadData()
        }
        resize()
        if bpp != 8 {
            // Must convert bmpOrig to 24-bit: QuantizeEx won't work with anything but.
            bmp24 = FreeImage_ConvertTo24Bits(bmpOrig)
            bmpOrig = bmp24
            makeImage8bit()
            currImage = bmp256
            _ = FreeImage_GetColorsUsed(currImage)
            currPal = FreeImage_GetPalette(currImage)
            origPal.removeAll()
            distCol = loadPalette()
            dispPal = origPal
            oImagePalCV.reloadData()
            distCol = origPal.count
        }
        colCt = origPal.count
        _ = displayPalette()
        oImageFname2.stringValue = "\(colCt) colours · \(iW)(w) x \(iH)(h)"
        oMatchColoursSlider.maxValue = Double(colCt)
        oMatchOrigNarr.stringValue = "\(colCt) colours"
        oMatchColours.integerValue = colCt
        oMatchColoursSlider.integerValue = colCt
        if pagesToPrint <= 30 {
            oImageReduce.isEnabled = false
            oMProcReduce.isEnabled = false
        }
    }
    
    // Perform colour match with chosen thread range
    func matchProcess() {
        cNo = 0
        sortedPal.removeAll()
        bmpMatched = FreeImage_ColorQuantizeEx(bmpOrig, 0, Int32(oMatchColours.integerValue), Int32(pal256.count), &pal256)
        newTmpFile(bmpMatched, incr: true)
        _ = loadPalette()
        distCol = origPal.count
        colCt = origPal.count
        matchedPal.removeAll()
        oImageFname2.stringValue = "\(colCt) colours · \(iW)(w) x \(iH)(h)"
        oImageFname2.textColor = NSColor.black
        palNarr = "\(colCt) distinct colours"
        oMatchOrigNarr.stringValue = palNarr
        doMatch()
        oGenPDF.isEnabled = true
        oMProcGenerate.isEnabled = true
        oTBSave.image = NSImage(named: "iconSave")
        oTBSave.isEnabled = true
        saveOK = true
        oMFileSave.isEnabled = true
        oMatchCtNarr.stringValue = "\(distCol) distinct colours"
        oSymDispCV.reloadData()
        oMatchMerge.isEnabled = true
        oMProcMerge.isEnabled = true
    }
    
    // Do a colour match with the current image
    func doMatch() {
        if Int(oMatchColours.integerValue) > Int(pal256.count) {
            oMatchColours.integerValue = Int(pal256.count)
        }
        matchToRange()
        _ = loadPalette()
        findDuplicateColours(bmpMatched)
        oMatchImage2.image = nil
        oMatchImage2.image = imageN
        _ = loadPalette()
        distCol = matchedPal.count
        usr = prefStUser
        showSymbols()
        distCol = sortedPal.count
        oMatchColoursSlider.integerValue = distCol
        oMatchColours.integerValue = distCol
        oMatchColoursSlider.integerValue = distCol
        var cardsReq: Int = 0
        if distCol > 0 {
            meas = ""
            switch oGenMeas.titleOfSelectedItem {
                case "centimetres": meas = "cm"
                default           : meas = "in"
            }
            oGenCardReq.stringValue = "No. required: \(cardsReq)"
        }
        cardsReq = cardCalc(meas, cardH: oGenCardH.integerValue, cols: distCol)
        oGenCardReq.stringValue = "No. required: \(cardsReq)"
        oMatchImage2.image = imageN
        cNo = 0
        oGenPDF.state = NSOnState
        oMProcGenerate.isEnabled = true
    }
    
    // Find colours in the palette which have very low counts in the image, and cross-reference them to the nearest other colour in the palette.
    func findUnderusedColours(threshold: Int) {
        replacePal.removeAll()
        var tmpPal: (rgb1: RGBQUAD, rgb2: RGBQUAD, ct: Int, replace: Bool) = (RGBQUAD(rgbBlue: 0, rgbGreen: 0, rgbRed: 0, rgbReserved: 0), RGBQUAD(rgbBlue: 0, rgbGreen: 0, rgbRed: 0, rgbReserved: 0), ct: 0, false) as (rgb1: RGBQUAD, rgb2: RGBQUAD, ct: Int, replace: Bool)
        for i in 0..<matchedPal.count {
            var diff1: Double = 99999999999
            var k: Int = 0
            if matchedPal[i].src == 999 && matchedPal[i].ct > 0 && matchedPal[i].ct < Int32(threshold) {
                let r1 = matchedPal[i].rgb.rgbRed
                let g1 = matchedPal[i].rgb.rgbGreen
                let b1 = matchedPal[i].rgb.rgbBlue
                tmpPal.rgb1 = matchedPal[i].rgb
                tmpPal.ct = Int(matchedPal[i].ct)
                var xRef: Int = 0
                for j in 0..<matchedPal.count {
                    if i == j || matchedPal[j].ct == 0 {
                        continue
                    }
                    let r2 = matchedPal[j].rgb.rgbRed
                    let g2 = matchedPal[j].rgb.rgbGreen
                    let b2 = matchedPal[j].rgb.rgbBlue
                    let diff2: Double =
                        (Double(abs(Double(r1) - Double(r2))) ** Double(2) +
                            Double(abs(Double(g1) - Double(g2))) ** Double(2) +
                            Double(abs(Double(b1) - Double(b2))) ** Double(2))
                    if diff2 > 0 && diff2 < diff1 && matchedPal[j].ct >= Int32(threshold) {
                        diff1 = diff2
                        xRef = j
                        if matchedPal[j].src != 999 {
                            let iSrc = Int(matchedPal[j].src)
                            xRef = iSrc
                        }
                    }
                }
                tmpPal.rgb2 = matchedPal[Int(xRef)].rgb
                tmpPal.replace = true
                replacePal.append(tmpPal as (rgb1: RGBQUAD, rgb2: RGBQUAD, ct: Int, replace: Bool))
                k += 1
            }
        }
    }

    // Decrement the spares counts
    func decrementCounts() {
        for i in 0..<activeSpares.count {
            if activeSpares[i].spares > 0 {
                let colourNo = activeSpares[i].no
                var spares = activeSpares[i].spares
                var skeins = activeSpares[i].skeinCt
                if skeins == 0 {
                    continue
                }
                if spares > skeins {
                    skeins = Int32(nearestQuarter(input: Double(skeins)))
                    spares -= skeins
                } else {
                    spares = 0
                }
                update(Double(spares), m: vMaker, r: vRange, n: colourNo)
            }
        }
        oTableView.reloadData()
    }
    
    // Resize the main window to the largest the screen will allow
    func resizeWindow() {
        let screenSize: CGRect = (NSScreen.main()?.frame)!
        let screenWidth = screenSize.width
        let screenHeight = screenSize.height
        self.view.window?.setFrameTopLeftPoint(NSPoint(x: 1, y: 1))
        if iH > iW {
            let imgH = (screenHeight - 230)
            let imgW = Int(Float(imgH) * Float(vAspectRatio)) + 40
            var oWidth = (imgW + 35) * 2
            var imgWPos = Int(Float(screenWidth) - Float(oWidth)) / 2
            if oWidth > Int(Float(screenWidth)) {
                oWidth = Int(Float(screenWidth))
                imgWPos = 1
            }
            self.view.window?.setFrame(NSMakeRect(CGFloat(imgWPos), 0, CGFloat(oWidth), CGFloat(screenHeight)), display: true)
        }
        if iH <= iW {
            self.view.window?.setFrameTopLeftPoint(NSPoint(x: 1, y: 1))
            let imgW = (screenWidth - 35) / 2
            let imgH = Int(Float(imgW) / Float(vAspectRatio)) + 20
            var oHeight = imgH + 185
            var imgHPos = Int(Float(screenHeight) - Float(oHeight))
            if oHeight > Int(Float(screenHeight)) {
                oHeight = Int(Float(screenHeight))
                imgHPos = 1
            }
            self.view.window?.setFrame(NSMakeRect(0, CGFloat(imgHPos), CGFloat(screenWidth), CGFloat(oHeight)), display: true)
        }
    }

    // Set initial defaults on opening a new file or the program...
    func setInitialDefaults() {
        bmpOrig = nil
        bmp24 = nil
        bmp256 = nil
        bmpMatched = nil
        currImage = nil
        oImageW.isEnabled = false
        oImageH.isEnabled = false
        oImageLock.isEnabled = false
        oImageReduce.isEnabled = false
        oImage.image = nil
        oImage2.image = nil
        oImageW.stringValue = ""
        oImageH.stringValue = ""
        oImageFname.stringValue = ""
        oImageFname2.stringValue = ""
        oImageResizeNarr.stringValue = ""
        oMatchImage1.image = nil
        oMatchImage2.image = nil
        oMatchColours.integerValue = 0
        oMatchColoursSlider.integerValue = 0
        oMatchButton.isEnabled = false
        oMProcMatch.isEnabled = false
        oMProcReduce.isEnabled = false
        oMatchMerge.isEnabled = false
        oMProcMerge.isEnabled = false
        oTBSave.image = NSImage(named: "saveOff")
        oTBSave.isEnabled = false
        saveOK = false
        oMFileSave.isEnabled = false
        oMProcMatch.isEnabled = false
        oMFileSave.isEnabled = false
        oMatchOrigNarr.stringValue = ""
        oMatchCtNarr.stringValue = ""
        sortedArray.removeAll()
        origPal.removeAll()
        dispPal.removeAll()
        oImagePalCV.reloadData()
        sortedPal.removeAll()
        oSymDispCV.reloadData()
        replacePal.removeAll()
        oColoursCV.reloadData()
        oSymText.stringValue = ""
        oSymUser.selectItem(withTitle: prefStUser)
        oPrefUser.selectItem(withTitle: prefStUser)
        usr = prefStUser
        oPrefSymProgress.isHidden = true
        oSymProgress.isHidden = true
        _ = getUsers()
        for i in 0..<userSet.count {
            oPrefUser.addItem(withTitle: userSet[i])
        }
        oGenPDF.state = NSOffState
        oMProcGenerate.isEnabled = false
        oImageReduce.state = NSOffState
        oMatchButton.state = NSOffState
        oMProcMatch.isEnabled = false
        if prefOutCh == true {
            oGenPrChart.state = NSOnState
        } else {
            oGenPrChart.state = NSOffState
        }
        if prefOutKP == true {
            oGenPrKey.state = NSOnState
        } else {
            oGenPrKey.state = NSOffState
        }
        if prefOutTC == true {
            oGenPrThrCd.state = NSOnState
        } else {
            oGenPrThrCd.state = NSOffState
        }
        oGenDecrement.state = NSOffState
        if prefOutIm == true {
            oGenPrImg.state = NSOnState
        } else {
            oGenPrImg.state = NSOffState
        }
        if prefOutSL == true {
            oGenPrShop.state = NSOnState
        } else {
            oGenPrShop.state = NSOffState
        }
        if prefOutCh == true &&
            prefOutKP == true &&
            prefOutTC == true &&
            prefOutIm == true &&
            prefOutSL == true {
                oGenPrSelect.title = "Select none"
                oGenPrSelect.state = NSOnState
        } else {
            oGenPrSelect.title = "Select all"
            oGenPrSelect.state = NSOffState
        }
        if prefChCol == true {
            oGenColourMenu.selectItem(withTitle: "Colour")
        } else {
            oGenColourMenu.selectItem(withTitle: "B&W")
        }
        if prefRange == "SC" {
            oRange.select(oRangeSC)
        } else {
            oRange.select(oRangeTW)
        }
        oMatchColours.integerValue = oMatchColoursSlider.integerValue
        oUpdate.isEnabled = false
        oGenProjName.stringValue = ""
        oGenPDF.isEnabled = false
        oMProcGenerate.isEnabled = false
        tmpF = 0
        tmpFn = ""
        palNarr = ""
        bgSet = ""
        blankSymbol = 0
        nm = ""
        bgSet = ""
        fType = ""
        vImageLoaded = false
        paletted = false
        halfW = false
        justBroken = false
        mapInColour = false
        saveOK = false
        decrement = false
        bgWasSet = false
        symAlloc = false
        symbol = ""
        meas = ""
        palNarr = ""
        saveUsr = ""
        tmpFn = ""
        tmpF = -1
        iW = 0
        iH = 0
        wDim = 0
        hDim = 0
        matchVal = 0
        cNo = 0
        threshold = 0
        colourCount = 0
        mergeColourCt = 0
        blankSymbol = 0
        vImageH = 0
        vImageW = 0
        vAspectRatio = 0.0
        fileName = ""
        vImageLoaded = false
        paletted = false
        halfW = false
        justBroken = false
        oGenChartColour.selectItem(withTitle: "B&W")
        mapInColour = false
        saveOK = false
        decrement = false
        bgWasSet = false
        symAlloc = false
        symbol = ""
        meas = ""
        colDispKP = 0
        colDispTC = 0
        iStoreKP = 0
        iStoreTC = 0
        pageNoKP = 0
        pageNoTC = 0
        halfWayKP = 0
        halfWayTC = 0
        distCol = 0
        keyPages = 0
        threadCards = 0
        holesPerCol = 0
        holesPerCard = 0
        nm = prefStUser
        gap = 0
        colCt = 0
        colUsed = 0
        colType = 0
        colTypeNarr = ""
        sizeNarr = ""
        colNarr = ""
        bpp = 0
        intFromString = 0
        vPrevSymSet = (0, "", 0)
        if vFabCt == 0 {
            vFabCt = 14
        }
        oImageNext.isEnabled = false
        oImageNext.isHighlighted = false
        oMatchNext.isEnabled = false
        oMatchNext.isHighlighted = false
        oSymNext.isEnabled = false
        oSymNext.isHighlighted = false
        saveUsr = usr
        oSymUser.stringValue = usr
        oPrefUser.stringValue = usr
        if bmpOrig != nil {
            FreeImage_Unload(bmpOrig)
        }
        if bmp24 != nil && bmp24 != bmpOrig {
            FreeImage_Unload(bmp24)
        }
        if bmp256 != nil && bmp256 != bmp24 && bmp256 != bmpOrig {
            FreeImage_Unload(bmp256)
        }
        if bmpMatched != nil && bmpMatched != bmp256 && bmpMatched != bmp24 && bmpMatched != bmpOrig {
            FreeImage_Unload(bmpMatched)
        }
        if currImage != nil && currImage != bmpMatched && currImage != bmp256 && currImage != bmp24 && currImage != bmpOrig {
            FreeImage_Unload(currImage)
        }
        oGenPaperNarr.stringValue = "Paper selected is \(prefPaperSz). See Preferences | Regional to modify."
    }
    
    // Switch measurements between in/cm
    func measurements() {
        switch oGenMeas.title {
        case "inches":
            vImp = true
            oGenCardH.minValue = 4
            oGenCardH.maxValue = 11
            oGenCardH.integerValue = vThrCdHImp
            oGenTurn.minValue = 1
            oGenTurn.maxValue = 4
            oGenTurn.integerValue = vOptTurnImp
            meas = "in"
        case "centimetres":
            vImp = false
            oGenCardH.minValue = 10
            oGenCardH.maxValue = 28
            oGenCardH.integerValue = vThrCdHMet
            oGenTurn.minValue = 3
            oGenTurn.maxValue = 10
            oGenTurn.integerValue = vOptTurnMet
            meas = "cm"
        default:
            break
        }
        oGenTurnUnit.stringValue = " \(String(oGenTurn.integerValue)) \(meas)"
        if oGenMeas.title == "inches" {
            oGenHDim.stringValue = "\(vThrCdHImp) \(meas)"
        } else {
            oGenHDim.stringValue = "\(vThrCdHMet) \(meas)"
        }
    }
    
    // Toggle on/off selections for printing
    func optionsSelected() {
        if oGenPrChart.state == NSOffState &&
            oGenPrKey.state == NSOffState &&
            oGenPrImg.state == NSOffState &&
            oGenPrThrCd.state == NSOffState &&
            oGenPrShop.state == NSOffState {
            oGenPrSelect.title = "Select all"
            oGenPrSelect.state = NSOffState
        } else if oGenPrChart.state == NSOnState &&
            oGenPrKey.state == NSOnState &&
            oGenPrImg.state == NSOnState &&
            oGenPrThrCd.state == NSOnState &&
            oGenPrShop.state == NSOnState {
            oGenPrSelect.title = "Select none"
            oGenPrSelect.state = NSOnState
        }
    }
    
    // Set new file defaults...
    func setNewFileDefaults() {
        // Enable image modifying controls
        oImageW.isEnabled = true
        oImageH.isEnabled = true
        oImageLock.isEnabled = true
        oImageReduce.isEnabled = true
        oMProcReduce.isEnabled = true
    }

    //----------------------------
    //   P R I N T   E N G I N E
    //----------------------------
    
    func printEngine(_ fname: String) {
        let aPDFDocument = PDFDocument()
        let dateStart: Bool
        var longDim: CGFloat = 1754.0
        var shortDim: CGFloat = 1240.0
        footerText = oGenProjName.stringValue
        if prefPaperSz != "A4" {
            longDim = CGFloat(1650.0)
            shortDim = CGFloat(1275.0)
        }
        if oGenDtStart.state == NSOnState {
            dateStart = true
        } else {
            dateStart = false
        }
        switch vMaker {
            case "ANC": threadNarr = "Anchor "
            case "DMC": threadNarr = "DMC "
            case "LEC": threadNarr = "Lecien Cosmo "
            default: threadNarr = "Madeira "
        }
        switch vRange {
            case "TW": threadNarr = threadNarr + "tapestry wool"
            default: threadNarr = threadNarr + "stranded cotton"
        }
        if oGenChartColour.selectedItem!.title == "Colour" {
            mapInColour = true
        } else {
            mapInColour = false
        }
        if !symAlloc {
            showSymbols()
            reassignSymbols()
        }
        // Transfer symbol nos from sortedPal [where they're allocated] to matchedPal [which is used for printing]
        for i in 0..<sortedPal.count {
            for j in 0..<matchedPal.count {
                if matchedPal[j].colourNo == sortedPal[i].colourNo {
                    matchedPal[j].symbolNo = sortedPal[i].symbolNo
                }
            }
        }
        // Set background colour for printing
        for i in 0..<sortedPal.count {
            if sortedPal[i].colourNo == bgSet {
                sortedPal[i].symbolNo = 160
                continue
            }
        }
        for i in 0..<matchedPal.count {
            if matchedPal[i].colourNo == bgSet {
                matchedPal[i].symbolNo = 160
                continue
            }
        }
        //
        // K E Y   P A G E ( S )
        //
        var pdfPageCt = 0
        colDispKP = 0
        // Get halfway point
        var colSzKP: Int = 0
        if prefPaperSz == "A4" {
            colSzKP = 56
        } else {
            colSzKP = 52
        }
        
       // Determine half-way point on last Key Page, and no of pages to print
        colourCount = sortedPal.count
        for i in 0..<sortedPal.count {
            if sortedPal[i].src != 999 ||
                sortedPal[i].ct == 0 {
                colourCount -= 1
            }
        }
        if Int(colourCount) > colSzKP {
            keyPages = Int(colourCount / colSzKP)
            if (colourCount % colSzKP) > 0 {
                halfWayKP = (colourCount - (keyPages * colSzKP)) / 2
                if ((colourCount - (keyPages * colSzKP)) % 2) > 0 {
                    halfWayKP += 1
                }
                keyPages += 1
            }
        } else {
            keyPages = 1
            halfWayKP = colourCount / 2
            if (colourCount % 2) > 0 {
                halfWayKP += 1
            }
        }
        iStoreKP = 0
        colDispKP = 0
        pageNoKP = 1
        justBroken = false
        pageHeight = longDim
        pageWidth = shortDim
        if oGenPrKey.integerValue == 1 {
            for i in 0..<keyPages {
                let keyPage = KeyPage(
                    footerText: oGenProjName.stringValue,
                    rangeText: threadNarr,
                    dateStart: dateStart,
                    totalPages: pagesToPrint,
                    pageWidth: pageWidth,
                    pageHeight: pageHeight,
                    hasPageNumber: false,
                    pgNo: i)
                aPDFDocument.insert(keyPage, at: i)
                pdfPageCt = pdfPageCt + 1
            }
        }
        //
        // T H R E A D   C A R D ( S )
        //
        if oGenPrThrCd.integerValue == 1 {
            holesPerCol = Int((Float(vThrCdHImp) * Float(25.4)) - 28)
            holesPerCol = holesPerCol + 10
            holesPerCol = (holesPerCol / 10)
            if prefPaperSz != "A4" {
                holesPerCol -= 1
            }
            // Get halfway point
            holesPerCard = holesPerCol * 2
            threadCards = (colourCount / holesPerCard)
            halfWayTC = (colourCount - (threadCards * holesPerCard)) / 2
            if (colourCount % 2) > 0 {
                halfWayTC += 1
            }
            if (colourCount % holesPerCard) > 0 {
                threadCards = threadCards + 1
            }
            iStoreTC = 0
            colDispTC = 0
            pageNoTC = 1
            pageHeight = longDim
            pageWidth = shortDim
            justBroken = false
            for i in (pdfPageCt)..<(threadCards + pdfPageCt) {
                // Print Thread Card
                let threadCard = ThreadCard(
                    footerText: oGenProjName.stringValue,
                    rangeText: threadNarr,
                    dateStart: dateStart,
                    totalPages: pagesToPrint,
                    pageWidth: pageWidth,
                    pageHeight: pageHeight,
                    hasPageNumber: false,
                    pgNo: i)
                aPDFDocument.insert(threadCard, at: i)
                pdfPageCt = pdfPageCt + 1
            }
        }
        //
        // I M A G E
        //
        if oGenPrImg.integerValue == 1 {
            if iH > iW {
                pageHeight = longDim
                pageWidth = shortDim
            } else {
                pageHeight = shortDim
                pageWidth = longDim
            }
            for i in pdfPageCt...pdfPageCt {
                let printImage = Image(
                    footerText: oGenProjName.stringValue,
                    rangeText: threadNarr,
                    dateStart: dateStart,
                    totalPages: pagesToPrint,
                    pageWidth: pageWidth,
                    pageHeight: pageHeight,
                    hasPageNumber: false,
                    pgNo: i)
                aPDFDocument.insert(printImage, at: i)
            }
            pdfPageCt += 1
        }
        //
        // S H O P P I N G   L I S T
        //
        if oGenPrShop.integerValue == 1 {
            pageHeight = longDim
            pageWidth = shortDim
            for i in pdfPageCt...pdfPageCt {
                let printImage = ShoppingList(
                    footerText: oGenProjName.stringValue,
                    rangeText: threadNarr,
                    dateStart: dateStart,
                    totalPages: pagesToPrint,
                    pageWidth: pageWidth,
                    pageHeight: pageHeight,
                    hasPageNumber: false,
                    pgNo: i)
                aPDFDocument.insert(printImage, at: i)
            }
            pdfPageCt += 1
        }
        //
        // C H A R T S
        //
        if oGenPrChart.integerValue == 1 {
            var pgNum = 1
            vCurrPage = 0
            pageWidth = longDim
            pageHeight = shortDim
            oGenProgBar.isHidden = false
            oGenProgBar.doubleValue = 0
            oGenProgBar.startAnimation(self)
            oGenProgBar.minValue = 0
            oGenProgBar.maxValue = Double(pagesToPrint)
            for i in (pdfPageCt)..<(pagesToPrint + pdfPageCt) {
                var endIndex = (i * 70) + 70
                if endIndex > pagesToPrint{
                    endIndex = pagesToPrint
                }
                let printCharts = Charts(
                    footerText:    oGenProjName.stringValue,
                    rangeText:     threadNarr,
                    dateStart:     dateStart,
                    totalPages:    pagesToPrint,
                    pageWidth:     pageWidth,
                    pageHeight:    pageHeight,
                    hasPageNumber: true,
                    pgNo:          pgNum)
                if oGenPrChart.integerValue == 1 {
                    aPDFDocument.insert(printCharts, at: i)
                }
                pgNum += 1
            }
        }
        // Only throw a background process if printing charts
        if oGenPrChart.integerValue == 1 {
            DispatchQueue.global(qos: .background).async {
                aPDFDocument.write(toFile: fname)
            }
            while vCurrPage < pagesToPrint {
                self.oGenProgBar.doubleValue = Double(vCurrPage)
                delay(0.01)
            }
            oGenProgBar.stopAnimation(self)
            oGenProgBar.isHidden = true
        } else {
            aPDFDocument.write(toFile: fname)
        }
        if decrement == true {
            decrementCounts()
        }
        dialogOK("All done!", text: "Finished generating output.")
    }


    //-----------------------------------------------
    // S Y M B O L   L A Y O U T   F U N C T I O N S
    //-----------------------------------------------
    
    // Load an individual user's predefined symbol set
    
    func loadUserSymbols(_ u: String) {
        // Complete reload of available symbols array
        availableSymbolArray.removeAll()
        for i in 0..<symbolNoArray.count {
            availableSymbolArray.append(symbolNoArray[i].no)
        }
        // Initialise progress bar
        let userSymbolCt = ctSymbolSet(oPrefUser.stringValue)
        if userSymbolCt > 0 {
            oPrefSymProgress.isHidden = false
            oPrefSymProgress.doubleValue = 0
            oPrefSymProgress.startAnimation(self)
            oPrefSymProgress.minValue = 0
            oPrefSymProgress.maxValue = Double(userSymbolCt)
            oSymProgress.isHidden = false
            oSymProgress.doubleValue = 0
            oSymProgress.startAnimation(self)
            oSymProgress.minValue = 0
            oSymProgress.maxValue = Double(userSymbolCt)
        }
        querySymbols(nm)
        if symbolSet.count == 0 {
            oPrefSymClear.isEnabled = false
        } else {
            vPrefSymSet = []
            for i in 0..<symbolSet.count {
                vPrefSymSet.append(symbolSet[i].sym)
                removeVisuallySimilar(symbolSet[i].sym)
                delay(0.01)
                self.oPrefSymProgress.doubleValue += Double(i)
                if self.oPrefSymProgress.doubleValue > Double(userSymbolCt) {
                    self.oPrefSymProgress.doubleValue = Double(userSymbolCt)
                }
                self.oSymProgress.doubleValue += Double(i)
                if self.oSymProgress.doubleValue > Double(userSymbolCt) {
                    self.oSymProgress.doubleValue = Double(userSymbolCt)
                }
            }
            oPrefSymClear.isEnabled = true
        }
        oPrefChosenCV.reloadData()
        oPrefSymColView.reloadData()
        oPrefSymProgress.stopAnimation(self)
        oPrefSymProgress.isHidden = true
        oPrefSymClear.isEnabled = true
        oSymProgress.stopAnimation(self)
        oSymProgress.isHidden = true
    }

    
    // Load symbols for symbol CV
    
    func showSymbols() {
        // Sort palette by luminance
        if saveUsr == "Default" || usr != "Default" {
            sortedPal = matchedPal.sorted {
                    (element1,element2) -> Bool in
                    return (element1.lum < element2.lum)
            }
            for i in (0..<sortedPal.count).reversed() {
                if sortedPal[i].ct == 0 {
                    for j in 0..<symbolSet.count {
                        if sortedPal[i].symbolNo != 0 {
                            if sortedPal[i].symbolNo == symbolSet[j].sym {
                                symbolSet.remove(at: j)
                                continue
                            }
                        }
                    }
                    sortedPal.remove(at: i)
                }
            }
         }
        allocateSymbolsForUser()
        if blankSymbol != 0 && blankSymbol != 999 {
            sortedPal[blankSymbol].symbolNo = 160
        }
        symAlloc = true
        calculateThreshold()
   }

    
    // Sort quantized palette by luminance and de-duplicate, ready for display
    
    func displayPalette() -> Int {
        sortedArray = pal256.sorted {
            (element1,element2) -> Bool in
            return ((element1.rgbRed < element2.rgbRed) ||
                    (element1.rgbGreen < element2.rgbGreen) ||
                    (element1.rgbBlue < element2.rgbBlue)   )
        }
        for i in (0..<sortedArray.count).reversed() {
            for j in (i..<sortedArray.count).reversed() {
                if j > i &&
                    (sortedArray[i].rgbRed == sortedArray[j].rgbRed) &&
                    (sortedArray[i].rgbGreen == sortedArray[j].rgbGreen) &&
                    (sortedArray[i].rgbBlue == sortedArray[j].rgbBlue) {
                        sortedArray.remove(at: j)
                }
            }
        }
        return sortedArray.count
    }
    
    
    // Remove any symbols that are in the list of the visually similar
    
    func removeVisuallySimilar(_ symbol: Int32) {
        var anythingRemoved = false
        for i in 0..<dupTup.count {
            var indices: [Int] = []
            if symbol == Int32(dupTup[i].0) ||
               symbol == Int32(dupTup[i].1) ||
               symbol == Int32(dupTup[i].2) ||
               symbol == Int32(dupTup[i].3) ||
               symbol == Int32(dupTup[i].4) ||
               symbol == Int32(dupTup[i].5) ||
               symbol == Int32(dupTup[i].6) ||
               symbol == Int32(dupTup[i].7) ||
               symbol == Int32(dupTup[i].8) ||
               symbol == Int32(dupTup[i].9) {
               for j in 0..<availableSymbolArray.count {
                   anythingRemoved = false
                   if availableSymbolArray[j] == Int32(dupTup[i].0) ||
                       availableSymbolArray[j] == Int32(dupTup[i].1) ||
                       availableSymbolArray[j] == Int32(dupTup[i].2) ||
                       availableSymbolArray[j] == Int32(dupTup[i].3) ||
                       availableSymbolArray[j] == Int32(dupTup[i].4) ||
                       availableSymbolArray[j] == Int32(dupTup[i].5) ||
                       availableSymbolArray[j] == Int32(dupTup[i].6) ||
                       availableSymbolArray[j] == Int32(dupTup[i].7) ||
                       availableSymbolArray[j] == Int32(dupTup[i].8) ||
                       availableSymbolArray[j] == Int32(dupTup[i].9) {
                       indices.append(Int(j))
                   }
               }
               for k in (0..<indices.count).reversed() {
                   let m = indices[k]
                   availableSymbolArray.remove(at: m)
                   anythingRemoved = true
               }
               break
            }
        }
        if anythingRemoved == false {
            for n in 0..<availableSymbolArray.count {
                if availableSymbolArray[n] == symbol {
                    availableSymbolArray.remove(at: n)
                    break
                }
            }
        }
        removeLoneWolves()
    }
    
    // Remove any that aren't in the tuple - i.e. 'lone wolves'
    func removeLoneWolves() {
        for i in 0..<vPrefSymSet.count {
            for j in (0..<availableSymbolArray.count).reversed() {
                if vPrefSymSet[i] == availableSymbolArray[j] {
                    availableSymbolArray.remove(at: j)
                }
            }
        }
    }
    
    // Save the symbol set defined thus far
    func saveSymbolSet(_ user: String) {
        uID = getUserID(user)
        for i in 0..<vPrefSymSet.count {
            let symNo = String(vPrefSymSet[Int(i)])
            if symbolExists(uID, s: symNo) == 0 {
                let seq = getLatestSymbolSeq(uID)
                if user != "Default" {
                    insertSymbols(uID, seq: Int(seq),  symno: symNo)
                }
            }
        }
        return
    }
    
    // Calculate threshold (excluding 'major players')
    func calculateThreshold () {
        var symFreq: [(colourNo: String, ct: Int32, pct: Float)] = []
        var symFreqRow: (colourNo: String, ct: Int32, pct: Float)
        let tmpSz: Int32 = Int32(iW * iH)
        for i in 0..<sortedPal.count {
            symFreqRow.colourNo = sortedPal[i].colourNo
            symFreqRow.ct = sortedPal[i].ct
            let tmp1 = Float(sortedPal[i].ct) / Float(tmpSz)
            let tmp2 = tmp1 * 100
            symFreqRow.pct = tmp2
            symFreq.append(symFreqRow)
        }
        symFreq = symFreq.sorted {
            (element1,element2) -> Bool in
            return (element1.ct > element2.ct)
        }
        var stCt: Int32 = 0
        for i in 0..<symFreq.count {
            if symFreq[i].pct < 20 {
                stCt += symFreq[i].ct
            }
        }
        threshold = Int((Double(stCt) / 100) * 0.5)
    }
    
    // Put back into available symbols those cleared or undone
    func putBack(_ set: Int, char: Int) {
        var i: Int = 0
        var foundInTuple = false
        // Is it one specific character to put back?
        // Look for an instance of it in the dupTup list of 'symiles'.
        if char > 0 {
            for j in 0..<dupTup.count {
                if dupTup[j].0 == char || dupTup[j].1 == char || dupTup[j].2 == char ||
                   dupTup[j].3 == char || dupTup[j].4 == char {
                       foundInTuple = true
                       availableSymbolArray.append(Int32(dupTup[j].0))
                       availableSymbolArray.append(Int32(dupTup[j].1))
                       if dupTup[j].2 != 0 {
                          availableSymbolArray.append(Int32(dupTup[j].2))
                       }
                       if dupTup[j].3 != 0 {
                           availableSymbolArray.append(Int32(dupTup[j].3))
                       }
                       if dupTup[j].4 != 0 {
                           availableSymbolArray.append(Int32(dupTup[j].4))
                       }
                       if dupTup[j].5 != 0 {
                           availableSymbolArray.append(Int32(dupTup[j].5))
                       }
                       if dupTup[j].6 != 0 {
                           availableSymbolArray.append(Int32(dupTup[j].6))
                       }
                       if dupTup[j].7 != 0 {
                           availableSymbolArray.append(Int32(dupTup[j].7))
                       }
                       if dupTup[j].8 != 0 {
                           availableSymbolArray.append(Int32(dupTup[j].8))
                       }
                       if dupTup[j].9 != 0 {
                           availableSymbolArray.append(Int32(dupTup[j].9))
                       }
                }
            }
            // Wasn't found in the 'symiles' - put it back by itself
            if foundInTuple == false {
                availableSymbolArray.append(Int32(char))
            }
            // Remove it from the User symbol set
            for i in (0..<vPrefSymSet.count).reversed() {
                if vPrefSymSet[i] == Int32(char) {
                    vPrefSymSet.remove(at: i)
                    deleteSymbol(nm, sym: char)
                }
            }
            sortPrefSymSet()
            deleteSymbol(nm, sym: char)
            reseqPrefSymSet()
            oPrefChosenCV.reloadData()
        } else {
            // The whole chosen symbol set is being put back...
            // Read through the whole chosen symbol set...
            for i in 0..<vPrefSymSet.count {
                // Look for an instance of the current symbol in the dupTup list of 'symiles'.
                for j in 0..<dupTup.count {
                    if Int32(dupTup[j].0) == vPrefSymSet[i] || Int32(dupTup[j].1) == vPrefSymSet[i] ||
                       Int32(dupTup[j].2) == vPrefSymSet[i] || Int32(dupTup[j].3) == vPrefSymSet[i] ||
                       Int32(dupTup[j].4) == vPrefSymSet[i] || Int32(dupTup[j].5) == vPrefSymSet[i] ||
                       Int32(dupTup[j].6) == vPrefSymSet[i] || Int32(dupTup[j].7) == vPrefSymSet[i] ||
                       Int32(dupTup[j].8) == vPrefSymSet[i] || Int32(dupTup[j].9) == vPrefSymSet[i] {
                           foundInTuple = true
                           availableSymbolArray.append(Int32(dupTup[j].0))
                           availableSymbolArray.append(Int32(dupTup[j].1))
                           if dupTup[j].2 != 0 {
                               availableSymbolArray.append(Int32(dupTup[j].2))
                           }
                           if dupTup[j].3 != 0 {
                               availableSymbolArray.append(Int32(dupTup[j].3))
                           }
                           if dupTup[j].4 != 0 {
                               availableSymbolArray.append(Int32(dupTup[j].4))
                           }
                           if dupTup[j].5 != 0 {
                               availableSymbolArray.append(Int32(dupTup[j].5))
                           }
                           if dupTup[j].6 != 0 {
                               availableSymbolArray.append(Int32(dupTup[j].6))
                           }
                           if dupTup[j].7 != 0 {
                               availableSymbolArray.append(Int32(dupTup[j].7))
                           }
                           if dupTup[j].8 != 0 {
                               availableSymbolArray.append(Int32(dupTup[j].8))
                           }
                           if dupTup[j].9 != 0 {
                               availableSymbolArray.append(Int32(dupTup[j].9))
                           }
                    }
                }
            }
            // Wasn't found in the 'symiles' - put it back by itself
            if foundInTuple == false {
                availableSymbolArray.append(vPrefSymSet[i])
            }
        }
        // sort availableSymbolArray according to sequence in symbolNoArray...
        sortAvailableSymbols()
        oPrefSymColView.reloadData()
    }
    
    // Sort vPrefSymSet according to order of appearance in symbolNoArray
    func sortPrefSymSet() {
        var localPrefSymSet: [(seq: Int32, no: Int32)] = []
        for i in 0..<vPrefSymSet.count {
            for j in 0..<symbolNoArray.count {
                if vPrefSymSet[i] == symbolNoArray[j].no {
                    localPrefSymSet.append(symbolNoArray[j])
                }
            }
        }
        localPrefSymSet = localPrefSymSet.sorted {
            (element1, element2) -> Bool in
            return (element1 < element2)
        }
        vPrefSymSet.removeAll()
        for i in 0..<localPrefSymSet.count {
            vPrefSymSet.append(localPrefSymSet[i].no)
        }
    }
    
    // Sort User Symbol set
    func reseqPrefSymSet() {
        deleteUserSymbols(nm)
        for i in 0..<vPrefSymSet.count {
            insertSymbols(uID, seq: i, symno: String(vPrefSymSet[i]))
        }        
    }
    
    // Order available symbols
    func sortAvailableSymbols() {
        var orderedSymbols: [(seq: Int32, no: Int32)] = []
        for i in 0..<availableSymbolArray.count {
            for j in 0..<symbolNoArray.count{
                if symbolNoArray[j].no == availableSymbolArray[i] {
                    let thisInstance: (seq: Int32, no: Int32)
                    thisInstance.seq = symbolNoArray[j].seq
                    thisInstance.no  = availableSymbolArray[i]
                    orderedSymbols.append(thisInstance)
                }
            }
        }
        orderedSymbols = orderedSymbols.sorted {
            (element1,element2) -> Bool in
            return (element1 < element2)
        }
        availableSymbolArray = []
        for i in 0..<orderedSymbols.count {
            availableSymbolArray.append(orderedSymbols[i].no)
        }
        // Deduplicate - in case there are any in the tuple more than once
        for i in (0..<availableSymbolArray.count).reversed() {
            for j in (0..<availableSymbolArray.count).reversed() {
                if availableSymbolArray[i] == availableSymbolArray[j] && i < j {
                    availableSymbolArray.remove(at: j)
                    break
                }
            }
        }
   }
    
    // Allocate a user's symbol set
    func allocateSymbolsForUser() {
        var tmpColCt: Int = 0
        tmpColCt = matchedPal.count
        if vPrefSymSet.count == 0 || usr == "Default" {
            allocateSymbolsFromDefaultSet()
        } else {
            var ct = tmpColCt
            var symbolSet: [(Int32)] = []
            // Do we need to augment the user's symbol set with 'kids from the pool'?
            if tmpColCt >= vPrefSymSet.count {
                symbolSet = vPrefSymSet
                ct -= vPrefSymSet.count
            }
            var diff: Double = 0
            // Work out distribution of symbols across the user's set, since it's less than 50
            if vPrefSymSet.count >= tmpColCt && ct > 0 {
                ct = tmpColCt
                diff = Double(vPrefSymSet.count) / Double(tmpColCt)
                for i in stride(from: 0, to: ((tmpColCt * Int(diff) / 2) + 1), by: Int(diff)) {
                    symbolSet.append(vPrefSymSet[i])
                    ct -= 1
                    if ct == 0 {
                        break
                    }
                }
                for i in stride(from: (vPrefSymSet.count - 1), to: Int(tmpColCt / 2), by: Int(0 - diff)) {
                    symbolSet.append(vPrefSymSet[i])
                    ct -= 1
                    if ct == 0 {
                        break
                    }
                }
            }
            // Any remaining colours unallocated a symbol get one allocated from the pool
            if ct > 0 {
                diff = round(Double(availableSymbolArray.count / ct))
                let startPt = Int(Int(availableSymbolArray.count - (Int(diff) * ct)) / 2)
                var i = startPt
                while symbolSet.count < sortedPal.count {
                    if ct >= 0 {
                        symbolSet.append(availableSymbolArray[i])
                        ct -= 1
                        i += Int(diff)
                    }
                }
            }
            // Sort the resulting symbol set
            var orderedSymbols: [(seq: Int32, no: Int32)] = []
            for i in 0..<symbolSet.count {
                for j in 0..<symbolNoArray.count{
                    if symbolNoArray[j].no == symbolSet[i] {
                        let thisInstance: (seq: Int32, no: Int32)
                        thisInstance.seq = symbolNoArray[j].seq
                        thisInstance.no  = symbolSet[i]
                        orderedSymbols.append(thisInstance)
                    }
                }
            }
            orderedSymbols = orderedSymbols.sorted {
                (element1,element2) -> Bool in
                return (element1 < element2)
            }
            // Allocate symbols to colours
            tmpColCt = sortedPal.count
            // var j: Int = distCol - 1
            var j: Int = orderedSymbols.count - 1
            ifor: for i in (0..<sortedPal.count).reversed() {
                if (sortedPal[i].src == 999 && sortedPal[i].ct > 0) {
                    sortedPal[i].symbolNo = orderedSymbols[j].no
                    j -= 1
                } else {
                    kfor: for k in 0..<sortedPal.count {
                        if sortedPal[i].colourNo == sortedPal[k].colourNo &&
                            sortedPal[k].src == 999 &&
                            sortedPal[k].ct > 0 &&
                            sortedPal[k].colourNo != "0" &&
                            i != k {
                            sortedPal[i].symbolNo = orderedSymbols[k].no
                            continue ifor
                        }
                    }
                }
            }
            oSymText.stringValue = "\(tmpColCt) colours"
            symAlloc = true
        }
    }

    // Allocate symbols using default (full) symbol set
    func allocateSymbolsFromDefaultSet() {
        if oImageFname.stringValue == "" {
            return
        }
        gap = Int(round(Double(symbolNoArray.count / sortedPal.count)))
        var lastSym =  Int(arc4random_uniform(UInt32(gap)))
        for i in (0..<sortedPal.count).reversed() {
            if (sortedPal[i].src != 999 || sortedPal[i].ct == 0) {
                sortedPal.remove(at: i)
            }
        }
        for i in 0..<(sortedPal.count) {
            if (sortedPal[i].src == 999 && sortedPal[i].ct > 0) {
                    sortedPal[i].symbolNo = symbolNoArray[lastSym].no
                    for j in 0..<matchedPal.count {
                        if matchedPal[j].colourNo == sortedPal[i].colourNo {
                            if i == blankSymbol && i > 0 {
                                matchedPal[j].symbolNo = 160
                            } else {
                            matchedPal[j].symbolNo = symbolNoArray[lastSym].no
                            break
                            }
                        }
                    }
                    lastSym += gap
                }
        }
        oSymText.stringValue = "\(sortedPal.count) colours"
        symAlloc = true
    }

    //-------------------------------------------
    // C O L L E C T I O N   V I E W   S T U F F
    //-------------------------------------------
    
    func collectionView(_ collectionView: NSCollectionView, numberOfItemsInSection section: Int) -> Int {
        switch collectionView {
        case self.oImagePalCV     : return dispPal.count
        case self.oSymDispCV      : return sortedPal.count
        case self.oColoursCV      : return replacePal.count
        case self.oPrefSymColView : return availableSymbolArray.count
             default              : return vPrefSymSet.count
        }
    }
    
    func collectionView(_ collectionView: NSCollectionView, itemForRepresentedObjectAt indexPath: IndexPath) -> NSCollectionViewItem {
        switch collectionView {
                                    // Image tab - palette display
        case self.oImagePalCV     : let item = oImagePalCV.makeItem(withIdentifier: "PaletteViewCVItem", for: indexPath) as! PaletteViewCVItem
                                    let r = CGFloat(dispPal[indexPath.item].r) / 255
                                    let g = CGFloat(dispPal[indexPath.item].g) / 255
                                    let b = CGFloat(dispPal[indexPath.item].b) / 255
                                    item.palViewCVItem.color = NSColor(red: r, green: g, blue: b, alpha: 1)
                                    return item
                                    // Symbols tab - main display
        case self.oSymDispCV      : let item = oSymDispCV.makeItem(withIdentifier: "symbolDispCV", for: indexPath) as! symbolDispCV
                                    let r = CGFloat(sortedPal[indexPath.item].rgb.rgbRed) / 255
                                    let g = CGFloat(sortedPal[indexPath.item].rgb.rgbGreen) / 255
                                    let b = CGFloat(sortedPal[indexPath.item].rgb.rgbBlue) / 255
                                    item.symDispColour.color = NSColor(red: r, green: g, blue: b, alpha: 1)
                                    var thrNo = leftAlign(sortedPal[indexPath.item].colourNo)
                                    if vMaker == "LEC" {
                                        for i in 0..<cosmoA.count {
                                            if Int(cosmoA[i]) == Int(thrNo) {
                                                thrNo = thrNo + "A"
                                            }
                                        }
                                    }
                                    item.symDispNo.stringValue = leftAlign(thrNo)
                                    var cNo = Int(sortedPal[indexPath.item].symbolNo)
                                    item.symDispSymbol.stringValue = String(NSString(bytes: &cNo, length: 4, encoding: String.Encoding.utf32LittleEndian.rawValue)!)
                                    return item
                                    // Preferences - symbol well
        case self.oPrefSymColView : let item = oPrefSymColView.makeItem(withIdentifier: "ColViewItem", for: indexPath) as! ColViewItem
                                    view.wantsLayer = true
                                    item.colViewChar.stringValue = "A"
                                    var cSym: Int32 = availableSymbolArray[indexPath.item]
                                    let str = NSString(bytes: &cSym, length: 4, encoding: String.Encoding.utf32LittleEndian.rawValue)! as String
                                    item.colViewChar.stringValue = str as String
                                    return item
                                    // Colour Replace dialog
        case self.oColoursCV     :  let item = oColoursCV.makeItem(withIdentifier: "ColoursCV", for: indexPath) as! ColoursCV
                                    item.colourCt?.stringValue = String(replacePal[indexPath.item].ct).leftPad(length: 4)
                                    let r1 = CGFloat(replacePal[indexPath.item].rgb1.rgbRed) / 255
                                    let g1 = CGFloat(replacePal[indexPath.item].rgb1.rgbGreen) / 255
                                    let b1 = CGFloat(replacePal[indexPath.item].rgb1.rgbBlue) / 255
                                    item.colour1.color = NSColor(red: r1, green: g1, blue: b1, alpha: 1)
                                    let r2 = CGFloat(replacePal[indexPath.item].rgb2.rgbRed) / 255
                                    let g2 = CGFloat(replacePal[indexPath.item].rgb2.rgbGreen) / 255
                                    let b2 = CGFloat(replacePal[indexPath.item].rgb2.rgbBlue) / 255
                                    item.colour2.color = NSColor(red: r2, green: g2, blue: b2, alpha: 1)
                                    if replacePal[indexPath.item].replace == true {
                                        item.arrow.stringValue = "→"
                                    } else {
                                        item.arrow.stringValue = "╳"
                                    }
                                    return item
                                    // Preferences - symbols picked
        default                   : let item = oPrefChosenCV.makeItem(withIdentifier: "ChosenCVItem", for: indexPath) as! ChosenCVItem
                                    var cSym: Int32 = 0
                                    cSym = vPrefSymSet[indexPath.item]
                                    let str = NSString(bytes: &cSym, length: 5, encoding: String.Encoding.utf32LittleEndian.rawValue)! as String?
                                    item.chosenCVItem.stringValue = str!
                                    return item
        }
    }

    // set the background colour's symbol to blank
    func setBG(_ sender: AnyObject) {
        // If this isn't the first time the background colour was changed, set the previous (blanked) symbol back to what it was before...
        if vPrevSymSet.colourNo != "" {
            sortedPal[vPrevSymSet.place].symbolNo = vPrevSymSet.symbolNo
        }
        // ...and then, set the symbol for the currently-selected background colour to blank
        if bgSet == "" || bgSet.isAlphanumeric {
        } else {
            bgSet = leadingZeros(bgSet)
        }
        for i in 0..<sortedPal.count {
            if leftAlign(sortedPal[i].colourNo) == bgSet {
                vPrevSymSet.colourNo = bgSet
                vPrevSymSet.place = i
                vPrevSymSet.symbolNo = sortedPal[i].symbolNo
                sortedPal[i].symbolNo = 160
                blankSymbol = i
                oSymDispCV.reloadData()
                continue
            }
        }
        for i in 0..<sortedPal.count {
            if sortedPal[i].symbolNo == 160 {
                blankSymbol = i
            }
        }
        for i in 0..<matchedPal.count {
            if matchedPal[i].colourNo == sortedPal[blankSymbol].colourNo &&
                matchedPal[i].symbolNo != 160 {
                    matchedPal[i].symbolNo = 160
            }
        }
        oMatchButton.isEnabled = false
        oMatchMerge.isEnabled = false
    }

    // Adds a selected symbol from the pool into the user's symbol set
    func editItem(_ sender: AnyObject) {
        nm = oPrefUser.titleOfSelectedItem!
        uID = getUserID(nm)
        if vPrefSymSet.count == 50 {
            popUpOK("Maximum reached", text: "There's provision only for 50 symbols. No more can be stored.")
            return
        } else {
            vPrefSymSet.append(intFromString)
            vSymSet = getSymbolSet(nm)
        }
        if nm != "Default" {
            saveSymbolSet(nm)
        }
        removeVisuallySimilar(intFromString)
        oPrefSymColView.reloadData()
        oPrefChosenCV.reloadData()
        oPrefSymClear.isEnabled = true
    }

    //----------------------------------------------
    // O V E R R I D E   F U N C T I O N S
    //----------------------------------------------

    override func viewDidLoad() {
        super.viewDidLoad()
       // View setup code
        FreeImage_Initialise(0)
        availableSymbolArray = []
        for i in 0..<symbolNoArray.count {
            availableSymbolArray.append(symbolNoArray[i].no)
        }
        _ = openDatabase()
        query(vMaker, r: vRange)
        oCtDisp.stringValue = "No. of threads in range: \(retCt)"
        oTableView.dataSource = self
        oTableView.delegate = self
        oPrefSymColView.dataSource = self
        oPrefSymColView.delegate = self
        oPrefChosenCV.dataSource = self
        oPrefChosenCV.delegate = self
        oSymDispCV.dataSource = self
        oSymDispCV.delegate = self
        oImagePalCV.dataSource = self
        oImagePalCV.delegate = self
        oColoursCV.dataSource = self
        oColoursCV.delegate = self
        let nib = NSNib(nibNamed: "ColViewItem", bundle: nil)
        oPrefSymColView.register(nib, forItemWithIdentifier: "ColViewItem")
        oPrefSymColView.isSelectable = true
        oPrefSymColView.maxNumberOfRows = 99
        oPrefSymColView.allowsEmptySelection = false
        oPrefSymColView.allowsMultipleSelection = false
        oPrefSymColView.reloadData()
        let chNib = NSNib(nibNamed: "ChosenCVItem", bundle: nil)
        oPrefChosenCV.register(chNib, forItemWithIdentifier: "ChosenCVItem")
        oPrefChosenCV.isSelectable = true
        oPrefChosenCV.maxNumberOfRows = 10
        oPrefChosenCV.allowsEmptySelection = false
        oPrefChosenCV.allowsMultipleSelection = false
        oPrefChosenCV.reloadData()
        let symNib = NSNib(nibNamed: "symbolDispCV", bundle: nil)
        oSymDispCV.register(symNib, forItemWithIdentifier: "symbolDispCV")
        oSymDispCV.isSelectable = true
        oSymDispCV.maxNumberOfRows = 15
        oSymDispCV.allowsEmptySelection = false
        oSymDispCV.allowsMultipleSelection = false
        oSymDispCV.reloadData()
        let palNib = NSNib(nibNamed: "PaletteViewCVItem", bundle: nil)
        oImagePalCV.register(palNib, forItemWithIdentifier: "PaletteViewCVItem")
        oImagePalCV.isSelectable = true
        oImagePalCV.maxNumberOfRows = 99
        oImagePalCV.allowsEmptySelection = false
        oImagePalCV.allowsMultipleSelection = false
        let colNib = NSNib(nibNamed: "ColoursCV", bundle: nil)
        oColoursCV.register(colNib, forItemWithIdentifier: "ColoursCV")
        oColoursCV.isSelectable = true
        oColoursCV.maxNumberOfRows = 99
        oColoursCV.allowsEmptySelection = false
        oColoursCV.allowsMultipleSelection = false
        replacePal.removeAll()
        oImageW.nextKeyView = oImageH
        _ = getUsers()
        for i in 0..<userSet.count {
            let str: String = "\(userSet[i])"
            oPrefUser.addItem(withTitle: str)
            oSymUser.addItem(withTitle: str)
        }
        oPrefUser.addItem(withTitle: "Default")
        oSymUser.addItem(withTitle: "Default")
        oPrefUser.selectItem(withTitle: prefStUser)
        oSymUser.selectItem(withTitle: prefStUser)
        nm = prefStUser
        getDefaults()
        oPrefSymClear.isEnabled = false
        querySymbols(prefStUser)
        for i in 0..<symbolSet.count {
            vPrefSymSet.append(symbolSet[i].sym)
            removeVisuallySimilar(symbolSet[i].sym)
        }
        if symbolSet.count > 0 {
            oPrefSymClear.isEnabled = true
        }
        loadPrefs()
        setInitialDefaults()
    }

    
    override func awakeFromNib() {
        // Set initial defaults
    }
}

//-----------------------------------------------------
// V I E W   C O N T R O L L E R   E X T E N S I O N S
//-----------------------------------------------------


extension RootViewController: NSTableViewDataSource {
    func numberOfRows(in aTableView: NSTableView) -> Int {
        return dataArray.count
    }
}

extension RootViewController: NSTableViewDelegate {

    func tableView(_ tableView: NSTableView,
                   viewFor tableColumn: NSTableColumn?,
                   row: Int) -> NSView? {
        // Populate spares manager
        if let column = tableColumn {
            if let cellView = tableView.make(withIdentifier: column.identifier, owner: self) as? NSTableCellView {
                let thread = dataArray[row]
                if column.identifier == "colourNo" {
                    if vMaker == "LEC" {
                        var thrNo = leftAlign(thread.colorNo)
                        for i in 0..<cosmoA.count {
                            if Int(cosmoA[i]) == Int(thrNo) {
                                thrNo = thrNo + "A"
                            }
                        }
                        cellView.textField?.stringValue = "\(thrNo)"
                    } else {
                        cellView.textField?.stringValue = "\(rightAlign(thread.colorNo))"
                    }
                    return cellView
                }
                if column.identifier == "colour" {
                    cellView.textField?.backgroundColor = thread.color
                    return cellView
                }
                if column.identifier == "spares" {
                    let formatter = NumberFormatter()
                    formatter.usesGroupingSeparator = true
                    formatter.minimumFractionDigits = 0
                    formatter.maximumFractionDigits = 2
                    cellView.textField?.stringValue = formatter.string(from: NSNumber(value: thread.spare))!
                }
                return cellView
            }
        }
        return nil
    }
}


extension NSAlert {
    func runModalSheetForWindow( _ aWindow: NSWindow ) -> Int {
        self.beginSheetModal(for: aWindow, completionHandler: { returnCode in
            NSApp.stopModal(withCode: returnCode)
        }) 
        let modalCode = NSApp.runModal(for: self.window)
        return modalCode
    }
    
    func runModalSheet() -> Int {
        return runModalSheetForWindow(NSApp.mainWindow!)
    }
}
