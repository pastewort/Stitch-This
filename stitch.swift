//
//  stitch.swift
//
//  N A T I V E   F U N C T I O N A L I T Y
//
//  Started by Martin on 13/05/2016.
//

import Foundation
import Cocoa
import Quartz
import Accelerate

//----------------------------------------------------
//  G L O B A L   S C O P E   D E C L A R A T I O N S
//----------------------------------------------------

// Create exponentiation operator

precedencegroup ExponentiationPrecedence {
    associativity: right
    higherThan: MultiplicationPrecedence
}
infix operator ** : ExponentiationPrecedence

func ** (_ base: Double, _ exp: Double) -> Double {
    return pow(base, exp)
}


// Round to nearest 0.25

func nearestQuarter(input : Double) -> Int {
    return 25 * Int(round(input / 25.0))
}


// Extensions

extension CGFloat {
    var string2: String {
        return String(format: "%.2f", self)
    }
}
extension String {
    func leftPad(length newLength : Int) -> String {
        let length = self.count
        if length < newLength {
            return String(repeating: " ", count: newLength - length) + self
        } else {
            return self.substring(from: self.index(endIndex, offsetBy: -newLength))
        }
    }
}
extension String {
    var isAlphanumeric: Bool {
        return !isEmpty && range(of: "[^a-zA-Z0-9]", options: .regularExpression) == nil
    }
}


// Structs

struct rgbType {
    var r: Int
    var g: Int
    var b: Int
}


// Type Alias

public typealias Byte = UInt8


// Public Vars

public var dib:          FIBITMAP!
public var db:           OpaquePointer? = nil
public var retCt:        Int32 = 422
public var activeSpares: [(no: String, spares: Int32, skeinCt: Int32)] = []
public var symbolSet:    [(no: String, sym: Int32)] = []


// Data

var rawData:      NSData!


// Pointers

var bmpOrig:      UnsafeMutablePointer<FIBITMAP>! = nil
var bmp24:        UnsafeMutablePointer<FIBITMAP>! = nil
var bmp256:       UnsafeMutablePointer<FIBITMAP>! = nil
var bmpMatched:   UnsafeMutablePointer<FIBITMAP>! = nil
var currImage:    UnsafeMutablePointer<FIBITMAP>! = nil
var currPal:      UnsafeMutablePointer<RGBQUAD>! = nil


// Arrays

var dataArray:   [(colorNo: String, color: NSColor, spare: Double, upd: Bool)] = []
var origPal    = Array<(r: Int, g: Int, b: Int, a: Int, nsc: NSColor)>()
                  // palette from the original image
var dispPal    = Array<(r: Int, g: Int, b: Int, a: Int, nsc: NSColor)>()
                  // display palette for the original image
var pal256:       [RGBQUAD] = []   // palette from quantizing the image
var sortedArray:  [RGBQUAD] = []   // sorted in luminance sequence
var threadPal:   [(rgb: RGBQUAD, colourNo: String, symbolNo: Int32, ct: Int32, src: Int32, lum: Int32)] = []
                  // selected thread range's palette
var matchedPal:  [(rgb: RGBQUAD, colourNo: String, symbolNo: Int32, ct: Int32, src: Int32, lum: Int32)] = []
                  // image's palette matched to thread range
var sortedPal:   [(rgb: RGBQUAD, colourNo: String, symbolNo: Int32, ct: Int32, src: Int32, lum: Int32)] = []
                  // matched palette in luminance sequence
var replacePal:  [(rgb1: RGBQUAD, rgb2: RGBQUAD, ct: Int, replace: Bool)] = []
                  // palette of colours to be merged
var userSet:     [String] = []
                  // stores the list of users retrieved from the database


// Stored user choices

var vThrCdHImp  = 10                  // Thread card height (imperial)
var vThrCdHMet  = 15                  // Thread card height (metric)
var vOptTurnImp = 2                   // Allowance for turnings (imperial)
var vOptTurnMet = 5                   // Allowance for turnings (metric)
var vImp:          Bool!              // Imperial/Metric?
var vImageH:       Int = 0            // Image height
var vImageW:       Int = 0            // Image width
var vFabCt:        Int = 0            // Fabric count
var vStrandCt:     Int = 0            // Strand count
var vCurrPage:     Int = 0            // Current page
var vAspectRatio:  Float = 0          // Aspect ratio
var vPageW:        CGFloat = 0.0      // Page width
var vPageH:        CGFloat = 0.0      // Page height
var vSymSet:       Int = 0            // Selected symbol set


// Misc global variables

var nm:            String = ""        // Selected User name
var bgSet:         String = ""        // Stores the colour no of the background colour in vPrefSymSet
var fNameURL:      URL!               // Filename expressed as a URL
var fileName:      String = ""        // Filename
var fType:         String = ""        // File extension of the file opened
var vImageLoaded:  Bool = false       // Is there an image loaded?
var paletted:      Bool = false       // Is the image paletted?
var halfW:         Bool = false       // Half the width (calculate centre point)
var justBroken:    Bool = false       // Indicates whether a column break has just happened
var mapInColour:   Bool = false       // Are we printing the grid in colour?
var saveOK:        Bool = false       // Has the image been saved?
var decrement:     Bool = false       // Decrement database counts?
var bgWasSet:      Bool = false       // Has a background colour been set?
var symAlloc:      Bool = false       // Have the symbols been allocated for this image?
var symbol:        String = ""        // Current symbol
var meas:          String = ""        // Measurements
var palNarr:       String = ""        // Palette description
var saveUsr:       String = ""        // Previously-selected user name
var tmpFn:         String = ""        // The name of the current temp.file
var tmpF:          Int = -1           // Temp.files are named with sequential numeric suffixes. This is it.
var iW:            Int = 0            // Image width
var iH:            Int = 0            // Image heigth
var wDim:          Int = 0            // Width dimension for printing
var hDim:          Int = 0            // Height dimension for printing
var matchVal:      Int = 0            // Integer of how many colours the match was intended for
var cNo:           Int = 0            // Colour no
var threshold:     Int = 0            // Threshold below which colours are considered for merging
var colourCount:   Int = 0            // Number of distinct colours - for printing
var mergeColourCt: Int = 0            // Count of colours for merging
var blankSymbol:   Int = 0            // Index of symbol selected for blanking
var colDispKP:     Int = 0            // Colours displayed on Key Page
var colDispTC:     Int = 0            // Colours displayed on Thread Card
var iStoreKP:      Int = 0            // Store key page
var iStoreTC:      Int = 0            // Store thread card
var pageNoKP:      Int = 0            // Key page('s) page no
var pageNoTC:      Int = 0            // Thread card('s) page no
var halfWayKP:     Int = 0            // Key page half-way point
var halfWayTC:     Int = 0            // Thread card half-way point
var distCol:       Int = 0            // No. of distinct colours in this image
var keyPages:      Int = 0            // Key pages
var threadCards:   Int = 0            // Thread cards
var holesPerCol:   Int = 0            // Holes per column (thread card)
var holesPerCard:  Int = 0            // Holes per card (thread card)
var gap:           Int = 0            // Used to calculate the gap between symbols selected from the chosen set
var colCt:         Int = 0            // Colour count
var colUsed:       Int32 = 0          // Colour used
var colType:       Int32 = 0          // Colour type
var colTypeNarr:   String = ""        // Colour type description
var sizeNarr:      String = ""        // Size description
var colNarr:       String = ""        // Colour description
var usr:           String = "Default" // User no
var uID:           Int32 = 0          // User ID
var bpp:           UInt32 = 0         // Bits per pixel of the current image
var intFromString: Int32 = 999        // Used to hold an integer converted from a string

var imageN:       NSImage!            // NSImage version of the current image
var projName:     String = ""         // Project name (displayed on output)
var vMaker:       String = "ANC"      // Thread manufacturer
var vRange:       String = "SC"       // Thread type: SC: Stranded Cotton, TW: Tapestry Wools
var pagesToPrint: Int = 0

var vPrevSymSet:  (place: Int, colourNo: String, symbolNo: Int32) = (0, "", 0)


// User Defaults [i.e. Preferences]

let userDefaults = UserDefaults.init()
var prefPaperSz:   String = " "       // Paper size
var prefDate:      String = " "       // Date format
var prefMeasmt:    String = " "       // Measurement set (Imperial/Metric)
var prefManuf:     String = " "       // Thread manufacturer
var prefRange:     String = " "       // Thread range
var prefFabCt:     Int = 0            // Fabric count
var prefTurn:      Int = 0            // Turnings allowance
var prefStrands:   Int = 0            // Strands being used
var prefChCol:     Bool = false       // Charts to be printed in colour?
var prefCrdH:      Int = 0            // Thread card height
var prefDtStart:   Bool = false       // Output 'Date Started' prompt?
var prefOutCh:     Bool = false       // Output Charts?
var prefOutKP:     Bool = false       // Output Key page?
var prefOutTC:     Bool = false       // Output Thread Card?
var prefOutIm:     Bool = false       // Output Image?
var prefOutSL:     Bool = false       // Output Shopping List?
var prefStUser:    String = " "       // Start User
var vPrefSymSet:   [(Int32)] = []     // Once read from the database, holds the chosen User's Symbol Set

// Printing constants

let defaultRowHeight  = CGFloat(16.0)
let defaultColumnWidth = CGFloat(16.0)
var pageWidth: CGFloat = 0
var pageHeight: CGFloat = 0
var footerText: String = ""
var threadNarr: String = ""
var dateStart: Bool = false
var hasPageNumber: Bool = false


// Arrays / Tuples

var bmpArray = [Byte](repeating: 0, count: cnt)
let cnt = rawData.length / MemoryLayout<Byte>.size

// Lecien Cosmo numbers suffixed by an A
let cosmoA = [103, 115, 126, 144, 152, 153, 162, 165, 171, 172, 185, 205, 241, 287, 316, 325, 410, 414, 415, 432, 444, 445, 480, 481, 484, 485, 505, 521, 533, 534, 536, 575, 577, 630, 635, 664, 667, 669, 675, 705, 750, 775, 816, 834, 981, 2536]

/*
   Symbol No array: symbols are stored in arbitrary intensity sequence (darkest first)...
   the first of each tuple is their absolute position in the list; the second value is
   the character's integer value
*/

let symbolNoArray: [(seq: Int32, no: Int32)] = [(001,9698),(002,9650),(003,9660),(004,9654),(005,9664),(006,11015),(007,9673),(008,9680),(009,9682),(010,9827),(011,9824),(012,7838),(013,10006),(014,9733),(015,9851),(016,9635),(017,9167),(018,10033),(019,10081),(020,9166),(021,8512),(022,182),(023,10026),(024,9672),(025,9775),(026,8711),(027,10012),(028,7164),(029,10070),(030,9096),(031,3647),(032,385),(033,5844),(034,8999),(035,8984),(036,8694),(037,664),(038,9617),(039,10021),(040,1046),(041,1070),(042,8370),(043,8371),(044,1044),(045,936),(046,1067),(047,198),(048,1034),(049,294),(050,208),(051,1026),(052,330),(053,404),(054,418),(055,2039),(056,422),(057,8366),(058,9778),(059,9836),(060,4322),(061,216),(062,8485),(063,56),(064,38),(065,8523),(066,8362),(067,4333),(068,485),(069,622),(070,946),(071,443),(072,580),(073,254),(074,440),(075,437),(076,36),(077,54),(078,57),(079,165),(080,167),(081,163),(082,1219),(083,1172),(084,1039),(085,223),(086,395),(087,7103),(088,7051),(089,7166),(090,9003),(091,11266),(092,415),(093,632),(094,77),(095,87),(096,66),(097,82),(098,83),(099,75),(100,65),(101,69),(102,80),(103,70),(104,81),(105,71),(106,1069),(107,4337),(108,230),(109,339),(110,9835),(111,681),(112,502),(113,546),(114,586),(115,89),(116,90),(117,78),(118,72),(119,9992),(120,88),(121,916),(122,4307),(123,4324),(124,611),(125,4315),(126,434),(127,673),(128,4328),(129,11490),(130,11621),(131,11570),(132,11303),(133,11611),(134,9730),(135,11310),(136,5621),(137,5622),(138,1190),(139,10762),(140,8473),(141,7165),(142,8364),(143,5098),(144,3517),(145,3424),(146,679),(147,5819),(148,5847),(149,8633),(150,11581),(151,11591),(152,11571),(153,11580),(154,1283),(155,405),(156,4259),(157,948),(158,569),(159,64),(160,1022),(161,10705),(162,5861),(163,5853),(164,1385),(165,1414),(166,1345),(167,10051),(168,10042),(169,400),(170,240),(171,624),(172,425),(173,1294),(174,416),(175,68),(176,67),(177,5773),(178,5459),(179,5483),(180,5484),(181,5488),(182,5491),(183,2768),(184,9665),(185,993),(186,1126),(187,5592),(188,5584),(189,572),(190,984),(191,937),(192,433),(193,5797),(194,7360),(195,5816),(196,928),(197,85),(198,358),(199,84),(200,86),(201,581),(202,955),(203,74),(204,321),(205,76),(206,53),(207,52),(208,4309),(209,4327),(210,55),(211,983),(212,3675),(213,10224),(214,8492),(215,8459),(216,3109),(217,4319),(218,576),(219,7043),(220,5084),(221,4314),(222,4293),(223,4311),(224,10058),(225,9099),(226,8240),(227,8540),(228,190),(229,8532),(230,8538),(231,8536),(232,189),(233,188),(234,37),(235,8453),(236,5356),(237,5458),(238,991),(239,8224),(240,915),(241,8730),(242,63),(243,3844),(244,9187),(245,50),(246,2309),(247,2325),(248,6816),(249,6817),(250,6820),(251,1300),(252,1411),(253,969),(254,8251),(255,8284),(256,6821),(257,6819),(258,9319),(259,9314),(260,5027),(261,5062),(262,5080),(263,4341),(264,4268),(265,8225),(266,8530),(267,8585),(268,8529),(269,950),(270,963),(271,4338),(272,1351),(273,10016),(274,9768),(275,9785),(276,9786),(277,174),(278,8471),(279,169),(280,8804),(281,8805),(282,450),(283,35),(284,5175),(285,5204),(286,956),(287,162),(288,1154),(289,402),(290,45),(291,9284),(292,7542),(293,9767),(294,7231),(295,8252),(296,960),(297,1769),(298,7461),(299,9773),(300,8997),(301,8747),(302,9840),(303,4277),(304,9674),(305,449),(306,8749),(307,8617),(308,685),(309,10019),(310,8965),(311,9720),(312,9721),(313,9794),(314,9792),(315,4256),(316,11040),(317,10561),(318,9108),(319,8263),(320,8627),(321,684),(322,926),(323,6272),(324,6417),(325,5964),(326,3198),(327,60),(328,62),(329,8598),(330,8600),(331,177),(332,215),(333,43),(334,9998),(335,8593),(336,8595),(337,9986),(338,94),(339,8482),(340,247),(341,8648),(342,8649),(343,8644),(344,9834),(345,61),(346,9813),(347,9814),(348,9815),(349,9832),(350,9839),(351,9888),(352,9812),(353,10160),(354,10023),(355,9877),(356,9791),(357,9793),(358,10017),(359,5968),(360,10193),(361,10830),(362,10835),(363,10836),(364,10697),(365,10734),(366,9746),(367,9745),(368,9734),(369,8645),(370,10684),(371,9018),(372,9020),(373,9017),(374,9019),(375,9712),(376,9714),(377,10803),(378,8983),(379,9178),(380,3209),(381,2947),(382,10797),(383,10798),(384,6576),(385,8859),(386,8853),(387,8855),(388,8860),(389,8854),(390,8858),(391,8856),(392,8857),(393,8838),(394,8839),(395,8779),(396,10970),(397,10194),(398,8750),(399,4113),(400,3365),(401,3441),(402,5393),(403,5565),(404,10035),(405,10000),(406,9842),(407,9758),(408,10710),(409,5992),(410,8596),(411,607),(412,383),(413,407),(414,33),(415,10916),(416,10740),(417,47),(418,3632),(419,8697),(420,9685),(421,10652),(422,3314),(423,9833),(424,2952),(425,8912),(426,8913),(427,8828),(428,8829),(429,8690),(430,3904),(431,9105),(432,9104),(433,9094),(434,9086),(435,9684),(436,8731),(437,4177),(438,4043),(439,8258),(440,8273),(441,4968),(442,4960),(443,11582),(444,8978),(445,4962),(446,4961),(447,720),(448,8281),(449,2847),(450,2855),(451,8623),(452,126),(453,9743),(454,9816),(455,3858),(456,10177),(457,10192),(458,5827),(459,8980),(460,9837),(461,9838),(462,9750),(463,9651),(464,9661),(465,9655),(466,9634),(467,9789),(468,9769),(469,8634),(470,8624),(471,8651),(472,9765),(473,9826),(474,9825),(475,9587),(476,9671),(477,9788),(478,9675),(479,8979),(480,9738),(481,9741),(482,3859),(483,3894),(484,9736),(485,8982),(486,8944),(487,8757),(488,11034),(489,160)]

var availableSymbolArray: [Int32] = []


// Tuple containing duplicate equivalents ("symile"s)

let dupTup:[(Int,Int,Int,Int,Int,Int,Int,Int,Int,Int)] = [(9698,9650,9660,9654,9664,0,0,0,0,0),
     (9680,9682,9775,4043,0,0,0,0,0,0),
     (9851,9842,0,0,0,0,0,0,0,0),
     (9733,9734,0,0,0,0,0,0,0,0),
     (7164,9096,0,0,0,0,0,0,0,0),
     (9672,10070,10021,0,0,0,0,0,0,0),
     (10081,182,0,0,0,0,0,0,0,0),
     (8711,916,0,0,0,0,0,0,0,0),
     (8370,71,0,0,0,0,0,0,0,0),
     (1046,936,10970,10194,0,0,0,0,0,0),
     (8371,65,1126,10193,10835,0,0,0,0,0),
     (208,1283,68,0,0,0,0,0,0,0),
     (3647,385,5844,66,0,0,0,0,0,0),
     (1026,1219,1172,11490,1190,0,0,0,0,0),
     (78,330,5819,8362,681,5797,3209,5565,928,956),
     (404,611,0,0,0,0,0,0,0,0),
     (2039,2947,0,0,0,0,0,0,0,0),
     (422,82,0,0,0,0,0,0,0,0),
     (8366,1294,358,84,5992,0,0,0,0,0),
     (9836,9835,9834,9833,0,0,0,0,0,0),
     (216,415,632,0,0,0,0,0,0,0),
     (38,8523,0,0,0,0,0,0,0,0),
     (946,223,0,0,0,0,0,0,0,0),
     (437,90,576,7542,0,0,0,0,0,0),
     (36,83,1414,0,0,0,0,0,0,0),
     (10006,10033,10035,10916,0,0,0,0,0,0),
     (11015,9166,8633,8634,8617,8627,0,0,0,0),
     (65,1126,581,10193,955,198,5565,10835,0,0),
     (230,945,586,64,0,0,0,0,0,0),
     (10836,86,5584,8711,611,0,0,0,0,0),
     (3647,1067,946,254,8492,3365,4113,3314,0,0),
     (208,4259,948,4315,963,9788,0,0,0,0),
     (9813,9812,0,0,0,0,0,0,0,0),
     (71,8370,485,2847,9773,0,0,0,0,0),
     (72,502,405,8459,4268,8983,1034,1190,11580,0),
     (80,8473,1385,8471,9767,4293,0,0,0,0),
     (7838,5080,2855,0,0,0,0,0,0,0),
     (9769,10019,9992,450,5062,0,0,0,0,0),
     (9587,1046,11571,0,0,0,0,0,0,0),
     (9788,9675,8979,9684,9685,8856,8860,8854,8858,8857),
     (8859,8853,8855,6816,6817,0,0,0,0,0),
     (9018,9020,9017,9019,9712,9714,9746,9745,10697,0),
     (62,5592,9654,5458,8805,5175,8829,9094,9655,0),
     (8999,9003,11570,5847,10705,5816,6817,10798,8853,0),
     (5847,11571,5861,5853,0,0,0,0,0,0),
     (10830,960,685,0,0,0,0,0,0,0),
     (61,926,9178,0,0,0,0,0,0,0),
     (8779,6576,3198,0,0,0,0,0,0,0),
     (8370,71,0,0,0,0,0,0,0,0),
     (7166,8749,8779,0,0,0,0,0,0,0),
     (546,4259,4338,6417,0,0,0,0,0,0),
     (9813,9812,0,0,0,0,0,0,0,0),
     (81,586,416,984,0,0,0,0,0,0),
     (72,502,1034,405,294,0,0,0,0,0),
     (4315,4328,42459,948,0,0,0,0,0,0),
     (11621,11303,0,0,0,0,0,0,0,0),
     (5621,5622,0,0,0,0,0,0,0,0),
     (11581,11591,0,0,0,0,0,0,0,0),
     (35,9839,0,0,0,0,0,0,0,0),
     (11571,10705,5861,10710,5853,0,0,0,0,0),
     (1022,67,0,0,0,0,0,0,0,0),
     (1385,4293,0,0,0,0,0,0,0,0),
     (8240,37,8453,0,0,0,0,0,0,0),
     (7103,7051,0,0,0,0,0,0,0,0),
     (5483,5484,5797,0,0,0,0,0,0,0),
     (937,433,4338,0,0,0,0,0,0,0),
     (86,581,955,94,0,0,0,0,0,0),
     (321,76,0,0,0,0,0,0,0,0),
     (10058,10035,0,0,0,0,0,0,0,0),
     (8512,10762,425,5356,5458,0,0,0,0,0),
     (8224,9768,9840,4277,407,0,0,0,0,0),
     (9785,9786,0,0,0,0,0,0,0,0),
     (174,8471,0,0,0,0,0,0,0,0),
     (8804,8805,0,0,0,0,0,0,0,0),
     (8225,450,1154,0,0,0,0,0,0,0),
     (2309,2325,0,0,0,0,0,0,0,0),
     (6816,6817,0,0,0,0,0,0,0,0),
     (8251,8284,6821,6819,10058,7360,10042,10051,10033,0),
     (7361,10684,8859,8853,8855,0,0,0,0,0),
     (9319,9314,0,0,0,0,0,0,0,0),
     (5062,9284,0,0,0,0,0,0,0,0),
     (402,8747,8749,8750,0,0,0,0,0,0),
     (9674,10192,9826,9671,0,0,0,0,0,0),
     (9720,9721,0,0,0,0,0,0,0,0),
     (9794,9792,9791,9793,0,0,0,0,0,0),
     (673,8263,0,0,0,0,0,0,0,0),
     (60,62,0,0,0,0,0,0,0,0),
     (8593,8598,8600,8624,8645,8648,0,0,0,0),
     (177,43,247,9769,10797,10798,407,3858,0,0),
     (8648,8649,8644,0,0,0,0,0,0,0),
     (10835,10836,0,0,0,0,0,0,0,0),
     (9020,9019,0,0,0,0,0,0,0,0),
     (9712,9714,0,0,0,0,0,0,0,0),
     (9839,10803,8983,0,0,0,0,0,0,0),
     (10797,10798,0,0,0,0,0,0,0,0),
     (8858,8857,4177,0,0,0,0,0,0,0),
     (10042,10058,8251,6821,10035,0,0,0,0,0),
     (8838,8839,0,0,0,0,0,0,0,0),
     (4113,3441,0,0,0,0,0,0,0,0),
     (8912,8913,0,0,0,0,0,0,0,0),
     (8828,8829,0,0,0,0,0,0,0,0),
     (88,215,9017,9746,9587,10016,10710,0,0,0),
     (9105,9104,0,0,0,0,0,0,0,0),
     (9685,9684,0,0,0,0,0,0,0,0),
     (8273,4961,720,0,0,0,0,0,0,0),
     (4960,3894,0,0,0,0,0,0,0,0),
     (4962,8281,0,0,0,0,0,0,0,0),
     (607,383,8750,0,0,0,0,0,0,0),
     (9634,11034,0,0,0,0,0,0,0,0),
     (9888,10177,9651,9661,9655,0,0,0,0,0),
     (11570,6816,8853,0,0,0,0,0,0,0),
     (8984,4341,402,679,681,8747,0,0,0,0),
     (9788,9675,3859,8982,0,0,0,0,0,0),
     (9665,9655,0,0,0,0,0,0,0,0),
     (9094,9736,8690,8624,8623,8627,8617,9166,0,0),
     (8730,8731,0,0,0,0,0,0,0,0),
     (4327,4319,0,0,0,0,0,0,0,0),
     (10012,10021,7360,8224,9768,10016,9840,4277,10019,9769),
     (11015,8600,8598,8593,8595,10740,0,0,0,0),
     (8633,8644,8645,8651,0,0,0,0,0,0),
     (4968,4960,11582,4962,4961,720,8281,0,0,0),
     (9017,9018,9019,9020,0,0,0,0,0,0)]


//
//--------------------------------------
//   G E N E R A L   F U N C T I O N S
//--------------------------------------
//

// Exit the Program
func exitProg () {
    FreeImage_DeInitialise()
    exit(0)
}

// Message popup
func popUpOK(_ question: String, text: String) {
    let popUp: NSAlert = NSAlert()
    popUp.messageText = question
    popUp.informativeText = text
    popUp.alertStyle = NSAlertStyle.warning
    popUp.addButton(withTitle: "OK")
    popUp.runModal()
}

// Create a new temp file from current image and display its contents
func newTmpFile(_ input: UnsafeMutablePointer<FIBITMAP>, incr: Bool) {
    if incr == true {
        tmpF += 1
        tmpFn = NSTemporaryDirectory() + "stitchtmp00" + String(tmpF) + ".bmp"
    }
    _ = FreeImage_Save(Int32(0), input, tmpFn, 0)
    rawData = NSData(contentsOf: URL(fileURLWithPath: tmpFn))
    imageN = NSImage(data: rawData! as Data)!
}

func writeToTempFile() {
    tmpF += 1
    tmpFn = NSTemporaryDirectory() + "stitchtmp00" + String(tmpF) + ".bmp"
    guard FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).last != nil else {
        return
    }
    let fileURL = URL(fileURLWithPath: tmpFn)
    do {
        try NSData(data: Data(bmpArray)).write(to: fileURL, options: .atomic)
    } catch {
        print("Unable to write to tmp file: \(error)")
        return
    }
    imageN = NSImage(data: Data(bmpArray))
}

// Delete temp files at end of processing
func clearTempFolder() {
    let fileManager = FileManager.default
    let tempFolderPath = NSTemporaryDirectory()
    do {
        let filePaths = try fileManager.contentsOfDirectory(atPath: tempFolderPath)
        for filePath in filePaths {
            try fileManager.removeItem(atPath: tempFolderPath + filePath)
        }
    } catch {
        print("Could not clear temp folder: \(error)")
    }
}

func delay(_ lenght: Double) {
    RunLoop.main.run(until: Date.init(timeIntervalSinceNow: lenght))
}


//---------------------------------------------------------
//   B A S I C   I N F O R M A T I O N   F U N C T I O N S
//---------------------------------------------------------


// Get basic file info

func fileInfo(_ file: UnsafeMutablePointer<FIBITMAP>) {
    bpp = FreeImage_GetBPP(file)
    colType = FreeImage_GetColorType(file)
    iH = Int(FreeImage_GetHeight(file))
    iW = Int(FreeImage_GetWidth(file))
    let size = FreeImage_GetDIBSize(file)
    colUsed = Int32(FreeImage_GetColorsUsed(file))
    if fileName == "" {
        fileName = fNameURL!.lastPathComponent
    }
    switch colType {
    case 2:  colTypeNarr = "Unpaletted (RGB)"
    case 3:  colTypeNarr = "Paletted"
    case 4:  colTypeNarr = "Unpaletted (RGBA)"
    case 5:  colTypeNarr = "Unpaletted (CMYK)"
    default: colTypeNarr = "B+W"
    }
    if (size / 1024) > 1024 {
        sizeNarr = "\((size / 1024) / 1024)Mb"
    } else if size < 1024 {
        sizeNarr = "\(size)bytes"
    } else {
        sizeNarr = "\(size / 1024) Kb"
    }
}


// No of pages required to print at this resolution

func pagesReq () -> String {
    var pagesAcross: Int = iW / 100
    if (iW % 100) > 0 {
        pagesAcross += 1
    }
    var pagesDown: Int = iH / 70
    if (iH % 70) > 0 {
        pagesDown += 1
    }
    pagesToPrint = pagesAcross * pagesDown
    var msg = "Needs \(pagesToPrint) pages to print charts"
    if pagesToPrint > 30 {
        msg = msg + "! Consider resizing."
    }
    return msg
}


// No of thread cards required

func cardCalc(_ unit: String, cardH: Int, cols: Int) -> Int {
    var cardsReq: Int = 0
    var a: Int = 0
    if unit == "cm" {
        switch cardH {
        case 10: a = 16
        case 11: a = 16
        case 12: a = 20
        case 13: a = 20
        case 14: a = 26
        case 15: a = 26
        case 16: a = 26
        case 17: a = 30
        case 18: a = 30
        case 19: a = 30
        case 20: a = 36
        case 21: a = 36
        case 22: a = 42
        case 23: a = 42
        case 24: a = 42
        case 25: a = 46
        case 26: a = 46
        default: a = 52
        }
    }
    if unit == "in"{
        switch cardH {
        case 4: a = 16
        case 5: a = 20
        case 6: a = 26
        case 7: a = 30
        case 8: a = 36
        case 9: a = 42
        case 10: a = 46
        default: a = 52
        }
    }
    cardsReq = (cols / a)
    if (cols % a) > 0 {
        cardsReq += 1
    }
    return cardsReq
}


// Formatting funcs

func leftAlign (_ input: String) -> String {
    var nonzero: Bool = false
    var output: String = ""
    for char in input {
        if char == "0"  && nonzero == false {
            output += ""
        } else {
            nonzero = true
            output += String(char)
        }
    }
    return output
}

func rightAlign (_ input: String) -> String {
    var nonzero: Bool = false
    var output: String = ""
    for char in input {
        if char == "0"  && nonzero == false {
            output += " "
        } else {
            nonzero = true
            output += String(char)
        }
    }
    return output
}

func stripFirstChar(_ input: String) -> String {
    var firstChar: Bool = true
    var output: String = ""
    for char in input {
        if firstChar && char == " " {
            firstChar = false
        } else {
            output += String(char)
        }
    }
    return output
}

func leadingZeros (_ input: String) -> String {
    var output: String = ""
    if Int(input)! < 10 {
        output = "0000" + input
    } else if Int(input)! < 100 {
        output = "000" + input
    } else if Int(input)! < 1000 {
        output = "00" + input
    } else if Int(input)! < 10000 {
        output = "0" + input
    } else {
        output = input
    }
    return output
}


//-------------------------------------
//   P A L E T T E   F U N C T I O N S
//-------------------------------------


// Load and sort the palette from the current paletted image

func loadPalette() -> Int {
    var blackInc: Bool = false
    var thisPal: (r: Int, g: Int, b: Int, a: Int, nsc: NSColor) =
        (0, 0, 0, 0, NSColor(red: 0, green: 0, blue: 0, alpha: 0))
    var nscol: NSColor!
    var rgbPal = [rgbType]()
    var prevRGB: rgbType!
    var thisRGB: rgbType!
    // Load the palette from the current image file
    origPal.removeAll()
    pal256.removeAll()
    prevRGB = rgbType(r: 0, g: 0, b: 0)
    var i: Int = 54
    var k: Int = 0
    rawData.getBytes(&bmpArray, length: cnt * MemoryLayout<Byte>.size)
    repeat {
        nscol = NSColor.init(red:   CGFloat(Int(bmpArray[i+2]) / 255),
                             green: CGFloat(Int(bmpArray[i+1]) / 255),
                             blue:  CGFloat(Int(bmpArray[i]) / 255),
                             alpha: CGFloat(1) )
        thisRGB = rgbType(r: Int(bmpArray[i+2]), g: Int(bmpArray[i+1]), b: Int(bmpArray[i]))
        if thisRGB.r == 0 && thisRGB.g == 0 && thisRGB.b == 0 {
            blackInc = true
        }
        rgbPal.append(thisRGB)
        thisPal = (r: Int(bmpArray[i+2]), g: Int(bmpArray[i+1]), b: Int(bmpArray[i]), a: Int(255), nsc: nscol)
        // Discount successive greys or all-blacks/whites where previous colour was the same
        if ((Int(bmpArray[i+2]) == k && Int(bmpArray[i+1]) == k && Int(bmpArray[i]) == k && k != 0) ||
             (thisRGB.r == prevRGB.r && thisRGB.g == prevRGB.g && thisRGB.b == prevRGB.b && k != 0) )
        {
        } else {
            prevRGB = thisRGB
            origPal.append(thisPal)
        }
        i += 4
        k += 1
    } while i < 1079 && k < 256

    var r0: Int = -1
    var g0: Int = -1
    var b0: Int = -1
    var j: Int = rgbPal.count
    for i in 0..<rgbPal.count {
        let r1: Int = rgbPal[i].r
        let g1: Int = rgbPal[i].g
        let b1: Int = rgbPal[i].b
        if ((i != 0 || blackInc == true) &&
            ((r0 == r1 && g0 == g1 && b0 == b1) ||
             (r1 == (i) && g1 == (i) && b1 == (i))) ) {
            j -= 1
        }
        r0 = rgbPal[i].r
        g0 = rgbPal[i].g
        b0 = rgbPal[i].b
    }
    
    for i in 0..<origPal.count {
        var tmpPal: RGBQUAD = RGBQUAD(rgbBlue: 0, rgbGreen: 0, rgbRed: 0, rgbReserved: 0)
        tmpPal.rgbRed = UInt8(origPal[i].r)
        tmpPal.rgbGreen = UInt8(origPal[i].g)
        tmpPal.rgbBlue = UInt8(origPal[i].b)
        tmpPal.rgbReserved = 0
        pal256.append(tmpPal)
    }
    paletted = true
    
    return j
}


// Match colours in this palette to the selected colour range

func matchToRange() {
    matchedPal.removeAll()
    var thisPal: (rgb: RGBQUAD, colourNo: String, symbolNo: Int32, ct: Int32, src: Int32, lum: Int32)!
    fori: for var i in 0..<pal256.count {
        var diff1: Double = 99999999999
        let r1 = Int(pal256[i].rgbRed)
        let g1 = Int(pal256[i].rgbGreen)
        let b1 = Int(pal256[i].rgbBlue)
        /*
        Palette equivalents are a sign of an unused value and can be ignored...
        The R,G,B values are the same as the colour position in the palette,
        except 0 and 255, because black in the first position, and white in the last,
        may be valid.
        */
        if (r1 == i && g1 == i && b1 == i) && (i != 0 && i != 255) {
            continue fori
        }
        var jSave: Int = 0
        forj: for var j in 0..<threadPal.count {
            let r2 = Int(threadPal[j].rgb.rgbRed)
            let g2 = Int(threadPal[j].rgb.rgbGreen)
            let b2 = Int(threadPal[j].rgb.rgbBlue)
            let lum = r2 + g2 + b2
            if ( r1 == r2 && g1 == g2 && b1 == b2) {
                thisPal = threadPal[j]
                thisPal.symbolNo = 0
                thisPal.ct = 0
                thisPal.src = 999
                thisPal.lum = Int32(lum)
                matchedPal.append(thisPal)
                i += 1
                continue fori
            }
            let diff2 =
            abs((Double(r1 - r2) ** 2) +
                (Double(g1 - g2) ** 2) +
                (Double(b1 - b2) ** 2))
            if diff2 < diff1 {
                diff1 = diff2
                thisPal = threadPal[j]
                jSave = j
                thisPal.symbolNo = 0
                thisPal.ct = 0
                thisPal.src = 999
                thisPal.lum = Int32(lum)
            }
            j += 1
        }
        if thisPal != nil {
            matchedPal.append(thisPal)
            overwriteColour(i: i, j: jSave, calledBy: "matchToRange")
            i += 1
        }
    }
}


// Find any duplicate colours

func findDuplicateColours(_ dib: UnsafeMutablePointer<FIBITMAP>) {
    bpp = FreeImage_GetBPP(bmpMatched)
    distCol = getColourCounts(bmpMatched, hght: Int32(iH), wdth: Int32(iW))
    for i in 0..<matchedPal.count {

        if matchedPal[i].src == 999 {
            for j in i + 1..<matchedPal.count {
                if matchedPal[i].colourNo == matchedPal[j].colourNo &&
                   matchedPal[j].src == 999 {
                       matchedPal[j].src = Int32(i)
                       matchedPal[i].ct += matchedPal[j].ct
                       matchedPal[j].ct = 0
                }
            }
        } else {
            if matchedPal[i].ct > 0 {
                matchedPal[Int(matchedPal[i].src)].ct += matchedPal[i].ct
                matchedPal[i].ct = 0
            }
        }
    }

}


// Overwrite one colour with another

func overwriteColour(i: Int, j: Int, calledBy: String) {
    var replacementColour: RGBQUAD? = nil
    switch calledBy {
        case "matchToRange" : replacementColour = threadPal[j].rgb
        default             : replacementColour = matchedPal[j].rgb
    }
    let ref: Int = 54 + (i * 4)
    bmpArray[ref+0] = (replacementColour?.rgbBlue)!
    bmpArray[ref+1] = (replacementColour?.rgbGreen)!
    bmpArray[ref+2] = (replacementColour?.rgbRed)!
    bmpArray[ref+3] = (replacementColour?.rgbReserved)!
    rawData.write(toFile: tmpFn, atomically: true)
}


// Replace one colour with another as part of the merge process

func replaceColours() {
    for ref in stride(from: 54, to: 1078, by: 4) {
        let tmp = (ref - 54) / 4
        for i in 0..<replacePal.count {
            if bmpArray[ref+2] == tmp && bmpArray[ref+1] == tmp && bmpArray[ref] == tmp {
                // Palette equivalent
                break
            }
            if  bmpArray[ref+2] == replacePal[i].rgb1.rgbRed &&
                bmpArray[ref+1] == replacePal[i].rgb1.rgbGreen &&
                bmpArray[ref+0] == replacePal[i].rgb1.rgbBlue &&
                replacePal[i].replace == true {

                bmpArray[ref+3] = replacePal[i].rgb2.rgbReserved
                bmpArray[ref+2] = replacePal[i].rgb2.rgbRed
                bmpArray[ref+1] = replacePal[i].rgb2.rgbGreen
                bmpArray[ref+0] = replacePal[i].rgb2.rgbBlue
                rawData.write(toFile: tmpFn, atomically: true)
 
            }
        }
    }
}

func getColourCounts(_ dib: UnsafeMutablePointer<FIBITMAP>, hght: Int32, wdth: Int32) -> Int {
    var curCol: Byte = 0
    var totStits = 0
    
    // Start by zeroising all counts, since this process can be run more than once
    for i in 0..<matchedPal.count {
        matchedPal[i].ct = 0
    }
    iH = Int(hght)
    iW = Int(wdth)

    for i in 0..<iH {
        for j in 0..<iW {
            totStits = totStits + 1
            FreeImage_GetPixelIndex(dib, UInt32(j), UInt32(i), &curCol)
            matchedPal[Int(curCol)].ct += 1
        }
    }

    var inUse: Int = 0
    for i in(0..<matchedPal.count)
    {
        if matchedPal[i].src == 999 || matchedPal[i].ct > 0
            {
                inUse = inUse + 1
            }
    }
    return inUse
}


// Since matchedPal is necessary for all printing, transfer the user's choice of symbols
// from sortedPal [in luminance order] to matchedPal [in palette order]

func reassignSymbols() {
    ifor: for i in 0..<matchedPal.count {
        jfor: for j in 0..<sortedPal.count {
            if matchedPal[i].colourNo == sortedPal[j].colourNo {
                if matchedPal[i].src == 999 {
                    matchedPal[i].symbolNo = sortedPal[j].symbolNo
                    continue ifor

                  }
                  else {
                    for k in 0..<sortedPal.count {
                        if matchedPal[i].colourNo == sortedPal[k].colourNo && matchedPal[i].src == 999 {
                            sortedPal[k].symbolNo = matchedPal[i].symbolNo
                            continue ifor
                        }
                    }
                matchedPal[Int(matchedPal[i].src)].symbolNo = matchedPal[Int(matchedPal[i].src)].symbolNo
                    continue ifor
                }
            }
        }
    }
}

//=======================
// Debug Print functions
//=======================

func printPalette( pal: String ) {
    var tmpPal: [(rgb: RGBQUAD, colourNo: String, symbolNo: Int32, ct: Int32, src: Int32, lum: Int32)] = []
    var tmpPalette: [RGBQUAD] = []
    switch pal {
    case "2" : tmpPalette = pal256
    print("\npal256:\ncount=\(pal256.count)")
    case "A" : tmpPalette = sortedArray
    print("\nsortedArray:\n")
    case "T" : tmpPal = threadPal
    print("\nthreadPal:\n")
    case "S" : tmpPal = sortedPal
    print("\nsortedPal:\n")
    case "M" : tmpPal = matchedPal
    print("\nmatchedPal:\n")
    case "R" : print("\nreplacePal:\n")
    default  : print("\norigPal:\n")
    }
    var stCt = 0
    if pal == "R" {
        for i in 0..<replacePal.count {
            print("\(String(i).leftPad(length: 3)): [rgb1]:  R: \(String(replacePal[i].rgb1.rgbRed).leftPad(length: 3)) | G: \(String(replacePal[i].rgb1.rgbGreen).leftPad(length: 3)) | B: \(String(replacePal[i].rgb1.rgbBlue).leftPad(length: 3))  [rgb2]:  R: \(String(replacePal[i].rgb2.rgbRed).leftPad(length: 3)) | G: \(String(replacePal[i].rgb2.rgbGreen).leftPad(length: 3)) | B: \(String(replacePal[i].rgb2.rgbBlue).leftPad(length: 3))   count=\(String(replacePal[i].ct).leftPad(length: 4))  replace: \(replacePal[i].replace)")
        }
        print("\n\n")
    } else if pal == "O" {
        for i in 0..<origPal.count {
            let line = String(i).leftPad(length: 3)
            let r = String(origPal[i].r).leftPad(length: 3)
            let g = String(origPal[i].g).leftPad(length: 3)
            let b = String(origPal[i].b).leftPad(length: 3)
            print("\(line)   R: \(r) | G: \(g) | B: \(b)")
        }
    } else if pal == "2" || pal == "A" || pal == "O" {
        for i in 0..<tmpPalette.count {
            let line = String(i).leftPad(length: 3)
            let r = String(tmpPalette[i].rgbRed).leftPad(length: 3)
            let g = String(tmpPalette[i].rgbGreen).leftPad(length: 3)
            let b = String(tmpPalette[i].rgbBlue).leftPad(length: 3)
            print("\(line)   R: \(r) | G: \(g) | B: \(b)")
        }
    } else {
        for i in 0..<tmpPal.count {
            stCt += Int(tmpPal[i].ct)
            let line = String(i).leftPad(length: 3)
            let r = String(tmpPal[i].rgb.rgbRed).leftPad(length: 3)
            let g = String(tmpPal[i].rgb.rgbGreen).leftPad(length: 3)
            let b = String(tmpPal[i].rgb.rgbBlue).leftPad(length: 3)
            let col = String(tmpPal[i].colourNo).leftPad(length: 4)
            let sym = String(tmpPal[i].symbolNo).leftPad(length: 5)
            let ct = String(tmpPal[i].ct).leftPad(length: 5)
            let src = String(tmpPal[i].src).leftPad(length: 3)
            let lum = String(tmpPal[i].lum).leftPad(length: 3)
            print("\(line)   R: \(r) | G: \(g) | B: \(b)   colourNo: \(col)   symbolNo: \(sym)   ct: \(ct)   src: \(src)   lum: \(lum)")
        }
        print("\nTotal stitches: \(stCt)\n\n")
    }
}

func printFilePalette() {
    var ct: Int = 0
    print("\n file's palette: \n")
    for ref in stride(from: 54, to: 1078, by: 4) {
        if bmpArray[ref+2] == ct && bmpArray[ref+1] == ct && bmpArray[ref] == ct {
            print("\n\n")
            break
        }
        print("\(String(ct).leftPad(length: 3))  R: \(String(bmpArray[ref+2]).leftPad(length: 3)) | G: \(String(bmpArray[ref+1]).leftPad(length: 3)) | B: \(String(bmpArray[ref+0]).leftPad(length: 3))")
        ct += 1
    }
}


//
//---------------------------------------//
//                                       //
//    P R I N T I N G   C L A S S E S    //
//                                       //
//---------------------------------------//
//

//
//-------------------//
//  K E Y   P A G E  //
//-------------------//
//
class KeyPage: BasePDFPage{
    override init(footerText:String,
                  rangeText:String,
                  dateStart:Bool,
                  totalPages:Int,
                  pageWidth:CGFloat,
                  pageHeight:CGFloat,
                  hasPageNumber:Bool,
                  pgNo:Int)
    {
        super.init(footerText: footerText,
                   rangeText: rangeText,
                   dateStart: dateStart,
                   totalPages: totalPages,
                   pageWidth: pageWidth,
                   pageHeight: pageHeight,
                   hasPageNumber: hasPageNumber,
                   pgNo: pgNo)
    }
    
    func getDate() -> String {
        let date = Date()
        let dateFormatter = DateFormatter()
        if prefDate == "EU" {
            dateFormatter.dateFormat = "dd/MM/yyyy HH:mm:ss"
        } else {
            dateFormatter.dateFormat = "MM/dd/yyyy HH:mm:ss"
        }
        let output = dateFormatter.string(from: date).capitalized
        return output
    }

    func drawKeyPage() {
        var textX: CGFloat = 0.0
        var textY: CGFloat = 0.0
        var rowsPerCol = 0
        
        var leftMargin: CGFloat = 77.0
        if prefPaperSz != "A4" {
            leftMargin = 80.0
        }
        
        if prefPaperSz == "A4" {
            textY = 1677.0
        } else {
            textY = 1573.0
        }
        
        
        let textYOrig = textY
        plotText("Stitch This!", x: leftMargin, y: textY,
                 w: CGFloat(300.0), h: CGFloat(40.0), font: "Helvetica Bold Oblique",
                 size: CGFloat(32.0), align: "L", bgColour: bgCol, fgColour: fgCol)
        plotText("K E Y", x: (leftMargin + 320.0), y: (textY - 28.0),
                 w: 300.0, h: 80.0, font: "Helvetica Bold",
                 size: 60.0, align: "C", bgColour: bgCol, fgColour: fgCol)
        plotText("\(threadNarr)" as NSString, x: leftMargin, y: (textY - 103.0),
                 w: 500.0, h: 25.0, font: "Helvetica",
                 size: 22.0, align: "L", bgColour: bgCol, fgColour: fgCol)
        let date = getDate()
        plotText("Generated \(date)" as NSString, x: leftMargin, y: (textY - 33.0),
                 w: 350.0, h: 20.0,
                 font: "Helvetica Oblique", size: 16.0, align: "L", bgColour: bgCol, fgColour: fgCol)
        plotText("\(footerText)" as NSString, x: leftMargin, y: (textY - 74.0),
                 w: 750.0, h: 25.0, font: "Helvetica Bold",
                 size: 22.0, align: "L", bgColour: bgCol, fgColour: fgCol)
        if iStoreKP == 0 {
            plotText("Date Project Started:  ___/___/______", x: 800.0, y: (textY + 7.0),
                     w: 350.0, h: 30.0, font: "Helvetica",
                     size: 18.0, align: "R", bgColour: bgCol, fgColour: fgCol)
            plotText("Date Project Completed:  ___/___/______", x: 800.0, y: (textY - 33.0),
                     w: 350.0, h: 30.0, font: "Helvetica",
                     size: 18.0, align: "R", bgColour: bgCol, fgColour: fgCol)
            plotText("Colours used: \(colourCount)" as NSString, x: 365.0, y: (textY - 103.0),
                     w: 350.0, h: 25.0, font: "Helvetica",
                     size: 20.0, align: "C", bgColour: bgCol, fgColour: fgCol)
            wDim = Int((2 * vOptTurnImp) + (iW / vFabCt))
            hDim = Int((2 * vOptTurnImp) + (iH / vFabCt))
            let turn: Int!
            let meas: String!
            if vImp == true {
                turn = vOptTurnImp
                meas = "in."
            } else {
                wDim = Int(round(Double(wDim) * 2.54))
                hDim = Int(round(Double(hDim) * 2.54))
                turn = vOptTurnMet
                meas = "cm."
            }
            plotText("Dimensions: \(iW)(w) x \(iH)(h) stitches.\nCanvas size: \(wDim) x \(hDim) \(meas!) x \(vFabCt) count, \nallowing \(turn!) \(meas!) all round for turnings." as NSString,
                     x: 800.0, y: (textY - 228.0), w: 350.0, h: 180.0, font: "Helvetica",
                     size: 16.0, align: "R", bgColour: bgCol, fgColour: fgCol)
        } else {
            plotText("c o n t .",
                     x: 800.0, y: textY, w: 350.0, h: 38.0, font: "Helvetica",
                     size: 36.0, align: "R", bgColour: bgCol, fgColour: fgCol)
        }
        // Key display
        var xOrig = CGFloat(55.0)
        // Column headings
        plotText("Symbol", x: (xOrig + 27.0), y: (textY - 162.0), w: 80.0, h: 18.0, font: "Helvetica", size: 13.0, align: "L", bgColour: bgCol, fgColour: fgCol)
        var col: Int = 0
        while col < 2 {
            plotText("Symbol", x: (xOrig + 27.0), y: (textY - 162.0),
                     w: 80.0, h: 18.0,
                     font: "Helvetica",
                     size: 13.0, align: "L", bgColour: bgCol, fgColour: fgCol)
            plotText("Colour", x: (xOrig + 85.0), y: (textY - 162.0),
                     w: 80.0, h: 18.0,
                     font: "Helvetica",
                     size: 13.0, align: "L", bgColour: bgCol, fgColour: fgCol)
            plotText("Thread No.", x: (xOrig + 146.0), y: (textY - 162.0),
                     w: 80.0, h: 18.0,
                     font: "Helvetica",
                     size: 13.0, align: "L", bgColour: bgCol, fgColour: fgCol)
            plotText("Stitch count", x: (xOrig + 258.0), y: (textY - 162.0),
                     w: 80.0, h: 18.0,
                     font: "Helvetica",
                     size: 13.0, align: "L", bgColour: bgCol, fgColour: fgCol)
            plotText("Percentage", x: (xOrig + 365.0), y: (textY - 162.0),
                     w: 80.0, h: 18.0,
                     font: "Helvetica",
                     size: 13.0, align: "L", bgColour: bgCol, fgColour: fgCol)
            plotText("Skeins Req.*", x: (xOrig + 446.0), y: (textY - 162.0),
                     w: 80.0, h: 18.0,
                     font: "Helvetica",
                     size: 13.0, align: "L", bgColour: bgCol, fgColour: fgCol)
            xOrig = CGFloat(620.0)
            col += 1
        }
        xOrig = CGFloat(55.0)
        // Individual colour data
        textX = xOrig
        let path = NSBezierPath()
        NSColor.black.set()
        path.lineWidth = 0.5
        var prCol = 0
        querySpares(vMaker, r: vRange)
        for i in iStoreKP..<sortedPal.count {
            if sortedPal[i].src == 999 {
                justBroken = false
                let r = CGFloat(sortedPal[i].rgb.rgbRed) / 255
                let g = CGFloat(sortedPal[i].rgb.rgbGreen) / 255
                let b = CGFloat(sortedPal[i].rgb.rgbBlue) / 255
                let nsc = NSColor(red: r, green: g, blue: b, alpha: 1)
                var cSym = sortedPal[i].symbolNo
                let str = NSString(bytes: &cSym, length: 4, encoding: String.Encoding.utf32LittleEndian.rawValue)! as String
                var sCount: Int32 = 0
                var thrNo = rightAlign(sortedPal[i].colourNo)
                let tmpNo: String
                if thrNo.isAlphanumeric {
                    tmpNo = thrNo
                } else {
                    tmpNo = leftAlign(sortedPal[i].colourNo)
                }
                if vMaker == "LEC" {
                    for i in 0..<cosmoA.count {
                        if String(cosmoA[i]) == tmpNo {
                            thrNo = stripFirstChar(thrNo)
                            thrNo = thrNo + "A"
                        }
                    }
                }
                for j in 0..<sortedPal.count{
                    if j == i || Int(sortedPal[j].src) == Int(i) {
                        sCount += sortedPal[j].ct
                    }
                }
                let pxCount = (iW * iH)
                let res = (Double(sCount) / Double(pxCount)) * 100
                let pctage = String(format: "%.2f",res)
                let skeins = ((Double(sCount) / 2500) * (2 / Double(vStrandCt)) * (Double(vFabCt) / 18))
                let skeinCt = round(skeins * 100) / 100
                for k in 0..<activeSpares.count {
                    if thrNo == String("0" + activeSpares[k].no) {
                        activeSpares[k].skeinCt = Int32(skeinCt * 100)
                        break
                    }
                }
                // Plot box around symbol
                // Top
                path.move(to: NSMakePoint(textX + 27.0, (textY - 176.0)))
                path.line(to: NSMakePoint(textX + 72.0, (textY - 176.0)))
                path.stroke()
                // Left
                path.move(to: NSMakePoint(textX + 27.0, (textY - 221.0)))
                path.line(to: NSMakePoint(textX + 27.0, (textY - 176.0)))
                path.stroke()
                // Bottom
                path.move(to: NSMakePoint(textX + 27.0, (textY - 221.0)))
                path.line(to: NSMakePoint(textX + 72.0, (textY - 221.0)))
                path.stroke()
                // Right
                path.move(to: NSMakePoint(textX + 72.0, (textY - 221.0)))
                path.line(to: NSMakePoint(textX + 72.0, (textY - 176.0)))
                path.stroke()
                //Symbol
                plotText(str as NSString, x: textX + 10.0, y: (textY - 253.0), w: 80.0, h: 80.0,
                         font: "Helvetica", size: 38.0, align: "C", bgColour: bgCol, fgColour: fgCol)
                textX = xOrig + CGFloat(60.0)
                //Colour square
                let rct = CGRect(x: textX + 25, y: textY - 220, width: 45, height: 45)
                nsc.setFill()
                NSBezierPath(rect: rct).fill()
                //Thread No
                plotText(thrNo as NSString, x: textX + 85, y: (textY - 257.0), w: 80.0, h: 80.0,
                         font: "Menlo", size: 24.0, align: "L", bgColour: bgCol, fgColour: fgCol)
                textX = xOrig + CGFloat(210.0)
                //Stitch Count
                plotText(String(sCount) as NSString, x: textX, y: (textY - 257.0), w: 120.0, h: 80.0,
                         font: "Menlo", size: 24.0, align: "R", bgColour: bgCol, fgColour: fgCol)
                textX = xOrig + CGFloat(350.0)
                //Percentage
                plotText(pctage as NSString, x: textX, y: (textY - 257.0), w: 85.0, h: 80.0,
                         font: "Menlo", size: 24.0, align: "R", bgColour: bgCol, fgColour: fgCol)
                textX = xOrig + CGFloat(435.0)
                // No of skeins
                plotText(String(skeinCt) as NSString, x: textX, y: (textY - 257.0), w: 80.0, h: 80.0,
                         font: "Menlo", size: 24.0, align: "R", bgColour: bgCol, fgColour: fgCol)
                textX = xOrig + CGFloat(435.0)
                textY -= 50
                textX = xOrig
                colDispKP += 1
                rowsPerCol += 1
                var brkPt: Int = 0
                if prefPaperSz == "A4" {
                    brkPt = 28
                } else {
                    brkPt = 26
                }
                // Column break?
                if justBroken == false &&
                    ((pageNoKP == keyPages) &&
                        (rowsPerCol == halfWayKP)) ||
                    ((sortedPal.count > colDispKP &&
                        (colDispKP % brkPt) == 0)) {
                    if prCol == 0 {
                        xOrig = CGFloat(620.0)
                        textX = xOrig
                        prCol = 1
                        rowsPerCol = 0
                        textY = textYOrig
                    } else {
                        if (colDispKP % brkPt) != 0 {
                            textX = xOrig
                            textY = textYOrig
                            prCol = 0
                            rowsPerCol = 0
                        }
                    }
                }
                // Page break
                if justBroken == false &&
                    (colDispKP % (brkPt * 2)) == 0 {
                    prCol = 0
                    xOrig = CGFloat(45.0)
                    textX = xOrig
                    textY = textYOrig + 253.0
                    justBroken = true
                    iStoreKP = i + 1
                    pageNoKP += 1
                    break
                }
            }
        }
        // Footer
        plotText("*Skein counts are estimates, and given only as a guide.",
                 x: 80.0, y: 40.0, w: 450.0, h: 24.0,
                 font: "Helvetica", size: 15.0, align: "L", bgColour: bgCol, fgColour: fgCol)
    }
    override func draw(with box: PDFDisplayBox) {
        super.draw(with: box)
        self.drawKeyPage()
    }
}

//
//-------------------------//
//  T H R E A D   C A R D  //
//-------------------------//
//
class ThreadCard: BasePDFPage{
    override init(footerText:String,
                  rangeText:String,
                  dateStart:Bool,
                  totalPages:Int,
                  pageWidth:CGFloat,
                  pageHeight:CGFloat,
                  hasPageNumber:Bool,
                  pgNo:Int)
    {
        super.init(footerText: footerText,
                   rangeText: rangeText,
                   dateStart: dateStart,
                   totalPages: totalPages,
                   pageWidth: pageWidth,
                   pageHeight: pageHeight,
                   hasPageNumber: hasPageNumber,
                   pgNo: pgNo)
    }
    
    func drawThreadCard() {
        let unitsXPerMM: CGFloat
        let unitsYPerMM: CGFloat
        var xOrig: CGFloat = 0
        var yOrig: CGFloat = 0
        if prefPaperSz == "A4" {
            pageWidth = 1240.0
            pageHeight = 1754.0
            unitsXPerMM = vPageW / 210.0
            unitsYPerMM = vPageH / 297.0
            yOrig = 1658.0
        } else {
            pageWidth = 1275.0
            pageHeight = 1650.0
            unitsXPerMM = vPageW / 215.9
            unitsYPerMM = vPageH / 279.4
            yOrig = 1554.0
        }
        var holesThisCol = 0
        let pageH: CGFloat
        let pageW: CGFloat
        pageH = (vPageH - ((CGFloat(vThrCdHImp) * 25.4) * unitsYPerMM))
        pageW = CGFloat(275.0)
        let path = NSBezierPath()
        // PLOT LINES TO MARK EDGE OF CARD...
        //Right...
        NSColor.black.set()
        path.lineWidth = 0.5
        if prefPaperSz == "A4" {
            path.move(to: NSMakePoint(754.0, pageHeight))
        } else {
            path.move(to: NSMakePoint(754.0, 1750.0))
        }
        path.line(to: NSMakePoint(754.0, pageH))
        path.stroke()
        //Bottom...
        NSColor.black.set()
        path.lineWidth = 0.5
        path.move(to: NSMakePoint(0, pageH))
        path.line(to: NSMakePoint(754.0, pageH))
        path.stroke()
        // Print project details (top & bottom)
        let textStr: String = "Stitch This!  ·  \(footerText)  ·  \(threadNarr)"
        plotText(textStr as NSString, x: 0.0, y: (pageH - 20.0), w: 754.0, h: 60.0,
                 font: "Helvetica Bold Oblique", size: 15.0, align: "C", bgColour: NSColor.white, fgColour: NSColor.gray)
        
        // INDIVIDUAL COLOUR DATA
        var textX = xOrig
        var textY = yOrig
        // Each colour...
        var prCol = 0
        for i in iStoreTC..<sortedPal.count {
            if sortedPal[i].src == 999 {
                justBroken = false
                let r = CGFloat(sortedPal[i].rgb.rgbRed) / 255
                let g = CGFloat(sortedPal[i].rgb.rgbGreen) / 255
                let b = CGFloat(sortedPal[i].rgb.rgbBlue) / 255
                let nsc = NSColor(red: r, green: g, blue: b, alpha: 1)
                var cSym = sortedPal[i].symbolNo
                let str = NSString(bytes: &cSym, length: 4, encoding: String.Encoding.utf32LittleEndian.rawValue)! as String
                var sCount: Int32 = 0
                for j in 0..<sortedPal.count{
                    if j == i || Int(sortedPal[j].src) == Int(i) {
                        sCount += sortedPal[j].ct
                    }
                }
                if prCol == 0 {
                    // Left-hand column
                    // Plot hole line
                    textY -= 3
                    NSColor.black.set()
                    path.lineWidth = 0.5
                    path.move(to: NSMakePoint(xOrig + 2, textY + 42))
                    path.line(to: NSMakePoint(xOrig + 145, textY + 42))
                    path.stroke()
                    // Plot box around symbol
                    // Top
                    path.move(to: NSMakePoint(xOrig + 158, textY + 63))
                    path.line(to: NSMakePoint(xOrig + 198, textY + 63))
                    path.stroke()
                    // Left
                    path.move(to: NSMakePoint(xOrig + 158, textY + 23))
                    path.line(to: NSMakePoint(xOrig + 158, textY + 63))
                    path.stroke()
                    // Bottom
                    path.move(to: NSMakePoint(xOrig + 158, textY + 23))
                    path.line(to: NSMakePoint(xOrig + 198, textY + 23))
                    path.stroke()
                    // Right
                    path.move(to: NSMakePoint(xOrig + 198, textY + 23))
                    path.line(to: NSMakePoint(xOrig + 198, textY + 63))
                    path.stroke()
                    // Symbol
                    textY -= 3
                    textX = xOrig + 148.0
                    plotText(str as NSString, x: textX, y: textY + 6.0, w: 60.0, h: 60.0,
                             font: "Helvetica", size: 32.0, align: "C", bgColour: bgCol, fgColour: fgCol)
                    textY += 3
                    // Colour square
                    textX = xOrig + 185.0
                    let rct = CGRect(x: textX + 22, y: textY + 23, width: 40, height: 40)
                    nsc.setFill()
                    NSBezierPath(rect: rct).fill()
                    // Thread No
                    textX = xOrig + 260.0
                    let tmpNo = Int(sortedPal[i].colourNo)
                    var thrNo = rightAlign(sortedPal[i].colourNo)
                    if vMaker == "LEC" {
                        for i in 0..<cosmoA.count {
                            if Int(cosmoA[i]) == tmpNo {
                                thrNo = stripFirstChar(thrNo)
                                thrNo = thrNo + "A"
                            }
                        }
                    }
                    plotText(thrNo as NSString, x: textX, y: (textY + 24), w: 85.0, h: 40.0,
                             font: "Menlo", size: 25.0, align: "L", bgColour: bgCol, fgColour: fgCol)
                    textY -= (unitsYPerMM * 10) - 1
                    textX = xOrig
                } else {
                    // Right-hand column
                    let xLimit: CGFloat = 754.0
                    textY -= 3
                    // Plot hole line
                    NSColor.black.set()
                    path.lineWidth = 0.5
                    path.move(to: NSMakePoint(xLimit - 2, textY + 42))
                    path.line(to: NSMakePoint(xLimit - 145, textY + 42))
                    path.stroke()
                    // Plot box around symbol
                    // Top
                    path.move(to: NSMakePoint(xLimit - 158, textY + 63))
                    path.line(to: NSMakePoint(xLimit - 198, textY + 63))
                    path.stroke()
                    // Left
                    path.move(to: NSMakePoint(xLimit - 158, textY + 23))
                    path.line(to: NSMakePoint(xLimit - 158, textY + 63))
                    path.stroke()
                    // Bottom
                    path.move(to: NSMakePoint(xLimit - 158, textY + 23))
                    path.line(to: NSMakePoint(xLimit - 198, textY + 23))
                    path.stroke()
                    // Right
                    path.move(to: NSMakePoint(xLimit - 198, textY + 23))
                    path.line(to: NSMakePoint(xLimit - 198, textY + 63))
                    path.stroke()
                    // Symbol
                    textY -= 3
                    textX = xLimit - 209.5
                    plotText(str as NSString, x: textX, y: textY + 6.0, w: 60.0, h: 60.0,
                             font: "Helvetica", size: 32.0, align: "C", bgColour: bgCol, fgColour: fgCol)
                    textY += 3
                    // Colour square
                    textX = xLimit - 273.0
                    let rct = CGRect(x: textX + 26, y: textY + 23, width: 40, height: 40)
                    nsc.setFill()
                    NSBezierPath(rect: rct).fill()
                    // Thread No
                    textX = xLimit - 333.0
                    let tmpNo = Int(sortedPal[i].colourNo)
                    var thrNo = leftAlign(sortedPal[i].colourNo)
                    if vMaker == "LEC" {
                        for i in 0..<cosmoA.count {
                            if Int(cosmoA[i]) == tmpNo {
                                thrNo = thrNo + "A"
                            }
                        }
                    }
                    plotText(thrNo as NSString, x: textX, y: (textY + 24), w: 85.0, h: 40.0,
                             font: "Menlo", size: 25.0, align: "L", bgColour: bgCol, fgColour: fgCol)
                    textY -= (unitsYPerMM * 10) - 1
                    textX = xLimit
                    
                }
                colDispTC = colDispTC + 1
                holesThisCol += 1
                // Column break?
                var lastFullCard = 0
                if (colourCount % holesPerCard) > 0 {
                    lastFullCard = (colourCount / holesPerCard) * holesPerCard
                }
                if (colDispTC % holesPerCol) == 0 ||
                    (colDispTC == (lastFullCard + halfWayTC)) {
                    if prCol == 0 {
                        xOrig = CGFloat(pageW * 11.5) - 220.0
                        textX = xOrig
                        prCol = 1
                        holesThisCol = 0
                        textY = yOrig
                    } else {
                        if (colDispTC % holesPerCol) != 0 {
                            textX = xOrig
                            textY = yOrig
                            prCol = 0
                            holesThisCol = 0
                        }
                    }
                }
                // Page break
                if (colDispTC % (holesPerCard)) == 0 && justBroken == false {
                    prCol = 0
                    xOrig = CGFloat(2.0) * unitsXPerMM
                    textX = xOrig
                    textY = yOrig
                    justBroken = true
                    iStoreTC = i + 1
                    break
                }
            }
        }
    }
    override func draw(with box: PDFDisplayBox) {
        super.draw(with: box)
        self.drawThreadCard()
    }
}

//
//-------------------//
//     I M A G E     //
//-------------------//
//
class Image: BasePDFPage{
    override init(footerText:String,
                  rangeText:String,
                  dateStart:Bool,
                  totalPages:Int,
                  pageWidth:CGFloat,
                  pageHeight:CGFloat,
                  hasPageNumber:Bool,
                  pgNo:Int)
    {
        super.init(footerText: footerText,
                   rangeText: rangeText,
                   dateStart: dateStart,
                   totalPages: totalPages,
                   pageWidth: pageWidth,
                   pageHeight: pageHeight,
                   hasPageNumber: hasPageNumber,
                   pgNo: pgNo)
    }
    func drawImage() {
        var rect:    NSRect
        var fromX:   CGFloat = 0.0
        var fromY:   CGFloat = 0.0
        var iWidth:  CGFloat = 0.0
        var iHeight: CGFloat = 0.0
        if iH > iW {
            pageHeight = 1754.0
            pageWidth = 1240.0
            if prefPaperSz != "A4" {
                pageHeight = 1650.0
                pageWidth = 1275.0
            }
            iHeight = (pageHeight - 120.0)
            iWidth = (iHeight * CGFloat(vAspectRatio))
            fromX = CGFloat((pageWidth - iWidth) / 2)
            fromY = 60.0
            if iWidth > (pageWidth - 120.0) {
                iWidth = (pageWidth - 120.0)
                iHeight = (iWidth / CGFloat(vAspectRatio))
                fromX = 60.0
                fromY = CGFloat((pageHeight - iHeight) / 2)
            }
        } else {   // iW > iH
            pageWidth = 1754.0
            pageHeight = 1240.0
            if prefPaperSz != "A4" {
                pageWidth = 1650.0
                pageHeight = 1275.0
            }
            iWidth = (pageWidth - 120.0)
            iHeight = (iWidth / CGFloat(vAspectRatio))
            fromX = 60.0
            fromY = CGFloat((pageHeight - iHeight) / 2)
            if iHeight > (pageHeight - 120.0) {
                iHeight = (pageHeight - 120.0)
                iWidth = (iHeight * CGFloat(vAspectRatio))
                fromX = CGFloat((pageWidth - iWidth) / 2)
                fromY = 60.0
            }
        }
        rect = NSMakeRect(fromX, fromY, iWidth, iHeight)
        let image = NSImage(data: rawData! as Data)!
        image.draw(in: rect)
    }

    override func draw(with box: PDFDisplayBox) {
        super.draw(with: box)
        self.drawImage()
    }
}

//
//-------------------------------//
//   S H O P P I N G   L I S T   //
//-------------------------------//
//
class ShoppingList: BasePDFPage{
    override init(footerText:String,
                  rangeText:String,
                  dateStart:Bool,
                  totalPages:Int,
                  pageWidth:CGFloat,
                  pageHeight:CGFloat,
                  hasPageNumber:Bool,
                  pgNo:Int)
    {
        super.init(footerText: footerText,
                   rangeText: rangeText,
                   dateStart: dateStart,
                   totalPages: totalPages,
                   pageWidth: pageWidth,
                   pageHeight: pageHeight,
                   hasPageNumber: hasPageNumber,
                   pgNo: pgNo)
    }
    
    func getDate() -> String {
        let date = Date()
        let dateFormatter = DateFormatter()
        if prefDate == "EU" {
            dateFormatter.dateFormat = "dd/MM/yyyy HH:mm:ss"
        } else {
            dateFormatter.dateFormat = "MM/dd/yyyy HH:mm:ss"
        }
        let output = dateFormatter.string(from: date).capitalized
        return output
    }

    func shopList() {
        var leftMargin: CGFloat = 77.0
        var rightMargin: CGFloat = 77.0
        if prefPaperSz != "A4" {
            leftMargin = 90.0
            rightMargin = 70.0
        }
        plotText("Stitch This!", x: leftMargin, y: (pageHeight - 73.0),
                 w: CGFloat(300.0), h: CGFloat(40.0), font: "Helvetica Bold Oblique",
                 size: CGFloat(32.0), align: "L", bgColour: bgCol, fgColour: fgCol)
        plotText("\(footerText)\nShopping List" as NSString, x: 310.0, y: (pageHeight - 150.0),
                 w: 620.0, h: 120.0, font: "Helvetica Bold",
                 size: 30.0, align: "C", bgColour: bgCol, fgColour: fgCol)
        let date = getDate()
        plotText("Generated \(date)" as NSString, x: (pageWidth - rightMargin) - 350.0, y: (pageHeight - 58.0),
                 w: 350.0, h: 20.0,
                 font: "Helvetica Oblique", size: 16.0, align: "R", bgColour: bgCol, fgColour: fgCol)
        // Fabric details
        let fabricType: String!
        if vFabCt < 12 || vRange == "TW" {
            fabricType = "Canvas"
        } else {
            fabricType = "Aida"
        }
        var fabricH = (iH / vFabCt)
        var fabricW = (iW / vFabCt)
        var fabricText: String!
        if vImp == true {
            fabricH = fabricH + (vOptTurnImp * 2)
            fabricW = fabricW + (vOptTurnImp * 2)
            let fabHMet = Int(round(Float(fabricH) * 2.54))
            let fabWMet = Int(round(Float(fabricW) * 2.54))
            fabricText = "\(vFabCt)-count \(fabricType!), \(fabricH) x \(fabricW) in, allowing \(vOptTurnImp) in. all round for turnings (i.e. \(fabHMet) x \(fabWMet) cm.)"
        } else {
            fabricH = Int(round(Float(fabricH) * 2.54)) + (vOptTurnMet * 2)
            fabricW = Int(round(Float(fabricW) * 2.54)) + (vOptTurnMet * 2)
            fabricText = "\(vFabCt)-count \(fabricType!), \(fabricH) x \(fabricW) cm, allowing \(vOptTurnMet) cm. all round for turnings."
        }
        plotText(fabricText! as NSString, x: leftMargin, y: (pageHeight - 200.0),
                 w: 900.0, h: 28.0, font: "Helvetica",
                 size: 22.0, align: "L", bgColour: bgCol, fgColour: fgCol)
        plotText("The following \(rangeText) colours:" as NSString, x: leftMargin, y: (pageHeight - 246.0),
                 w: 600.0, h: 28.0, font: "Helvetica",
                 size: 22.0, align: "L", bgColour: bgCol, fgColour: fgCol)
        // Sort palette by colour no
        var _: (rgb: RGBQUAD, colourNo: String, symbolNo: Int32, ct: Int32, src: Int32, lum: Int32) =
        (RGBQUAD(rgbBlue: 0, rgbGreen: 0, rgbRed: 0, rgbReserved: 0), "", 0, 0, 0, 0)
        var sortedArray: [(rgb: RGBQUAD, colourNo: String, symbolNo: Int32, ct: Int32, src: Int32, lum: Int32)] = sortedPal.sorted {
            (element1,element2) -> Bool in
            return ((element1.colourNo < element2.colourNo))
        }
        let colNo = (colourCount / 5)
        let addCols = (colourCount % 5)
        var nsc: NSColor
        var xOrig: CGFloat = leftMargin
        var yOrig: CGFloat = 0.0
        switch prefPaperSz {
        case "A4" : yOrig = 1460.0
        default   : yOrig = 1360.0
        xOrig += 30.0
        }
        var textX: CGFloat = xOrig
        var textY: CGFloat = yOrig
        if prefPaperSz != "A4" {
            textX -= 20.0
        }
        let path = NSBezierPath()
        var colCt = 0
        var coloursFromSpares: String = ""
        var currCol = 1
        for i in 0..<sortedArray.count {
            // Colour No
            if sortedArray[i].src != 999 {
                continue
            }
            for j in 0..<activeSpares.count {
                if sortedArray[i].colourNo == activeSpares[j].no {
                    coloursFromSpares = coloursFromSpares + activeSpares[j].no + "  "
                }
            }
            var thrNo = rightAlign(sortedArray[i].colourNo)
            let tmpNo = Int(sortedArray[i].colourNo)
            if vMaker == "LEC" {
                for k in 0..<cosmoA.count {
                    if Int(cosmoA[k]) == tmpNo {
                        thrNo = stripFirstChar(thrNo)
                        thrNo = thrNo + "A"
                    }
                }
            }
            plotText("\(thrNo)" as NSString, x: textX, y: textY,
                     w: 350.0, h: 25.0,
                     font: "Helvetica", size: 22.0, align: "L", bgColour: bgCol, fgColour: fgCol)
            // Colour square
            let r = CGFloat(sortedArray[i].rgb.rgbRed) / 255
            let g = CGFloat(sortedArray[i].rgb.rgbGreen) / 255
            let b = CGFloat(sortedArray[i].rgb.rgbBlue) / 255
            nsc = NSColor(red: r, green: g, blue: b, alpha: 1)
            let rct = CGRect(x: textX + 75, y: textY - 2, width: 27, height: 27)
            nsc.setFill()
            NSBezierPath(rect: rct).fill()
            // Plot tick box
            // Top
            path.move(to: NSMakePoint(textX + 117.0, textY + 24.0))
            path.line(to: NSMakePoint(textX + 143.0, textY + 24.0))
            NSColor.black.set()
            path.stroke()
            // Left
            path.move(to: NSMakePoint(textX + 117.0, textY + 24.0))
            path.line(to: NSMakePoint(textX + 117.0, textY - 2.0))
            NSColor.black.set()
            path.stroke()
            // Bottom
            path.move(to: NSMakePoint(textX + 117.0, textY - 2.0))
            path.line(to: NSMakePoint(textX + 143.0, textY - 2.0))
            NSColor.black.set()
            path.stroke()
            // Right
            path.move(to: NSMakePoint(textX + 143.0, textY + 24.0))
            path.line(to: NSMakePoint(textX + 143.0, textY - 2.0))
            NSColor.black.set()
            path.stroke()
            // If the colour is one of the spares, put a cross in the box
            for k in 0..<activeSpares.count {
                if activeSpares[k].no == sortedArray[i].colourNo && activeSpares[k].spares > 0 {
                    path.move(to: NSMakePoint(textX + 123.0, textY + 18.0))
                    path.line(to: NSMakePoint(textX + 137.0, textY + 4.0))
                    NSColor.darkGray.set()
                    path.stroke()
                    path.move(to: NSMakePoint(textX + 137.0, textY + 18.0))
                    path.line(to: NSMakePoint(textX + 123.0, textY + 4.0))
                    NSColor.darkGray.set()
                    path.stroke()
                    break
                }
            }
            textY -= 35.0
            colCt += 1
            if (currCol <= addCols && colCt == (colNo + 1)) || (currCol > addCols && colCt == colNo) {
                textY = yOrig
                textX += 235.0
                colCt = 0
                currCol += 1
            }
        }
    }
    override func draw(with box: PDFDisplayBox) {
        super.draw(with: box)
        self.shopList()
    }
}

//
//---------------//
//  C H A R T S  //
//---------------//
//
class BasePDFPage: PDFPage {
    var pdfTitle: NSString = " "
    var footerText = ""
    var rangeText = ""
    var genText = ""
    var dateStart = false
    var totalPages = 0
    var hasPageNumber = true
    var pgNo = 1
    var pageHeight: CGFloat = 0.0
    var pageWidth: CGFloat = 0.0
    let bgCol = NSColor.clear
    var fgCol: NSColor = NSColor.black

    func plotText (_ input: NSString, x: CGFloat, y: CGFloat, w: CGFloat, h: CGFloat, font: String, size: CGFloat, align: String, bgColour: NSColor, fgColour: NSColor) {
        pdfTitle = input
        let titleFont = NSFont(name: font, size: size)
        let paraStyle = NSMutableParagraphStyle()
        switch align {
        case "R": paraStyle.alignment = NSTextAlignment.right
        case "C": paraStyle.alignment = NSTextAlignment.center
        default:  paraStyle.alignment = NSTextAlignment.left
        }
        let titleFontAttributes = [
            NSFontAttributeName: titleFont ?? NSFont.labelFont(ofSize: 12),
            NSParagraphStyleAttributeName:  paraStyle,
            NSBackgroundColorAttributeName: bgColour,
            NSForegroundColorAttributeName: fgColour
        ]
        let titleRect = NSMakeRect(x, y, w, h)
        self.pdfTitle.draw(in: titleRect, withAttributes: titleFontAttributes)
    }
    
    func mapSymbols() {
        
        var leftMargin: CGFloat = 77.0
        var rightMargin: CGFloat = 77.0
        var topMargin: CGFloat = 60.0
        var bottomMargin: CGFloat = 60.0
        var symbolTextX: CGFloat = 69.0
        var symbolTextY: CGFloat = 1161.75
        if prefPaperSz != "A4" {
            leftMargin = 15.0
            rightMargin = 5.0
            topMargin = 57.5
            bottomMargin = 57.5
            symbolTextX = 20.0
            symbolTextY = 1184.5
        }
        let symbolTextWidth = defaultColumnWidth + 16
        let symbolTextHeight = defaultRowHeight + 5
        
        // Start positions for any symbols' page print
        let symbolParagraphStyle = NSMutableParagraphStyle()
        symbolParagraphStyle.alignment = NSTextAlignment.center
        symbolParagraphStyle.minimumLineHeight = 28.0
        
        var xStart: Int = 0
        var yStart: Int = 0
        var xLimit: Int = 0
        var yLimit: Int = 0
        let fullPagesW = Int(iW / 100)
        let fullPagesH = Int(iH / 70)
        var pagesW = fullPagesW
        var pagesH = fullPagesH
        if (iW % 100) != 0 {
            pagesW += 1
        }
        if (iH % 70) != 0 {
            pagesH += 1
        }
        if ((pgNo % pagesW)) == 1 {
            xStart = 1
        } else {
            xStart = (((pgNo - 1) % pagesW) * 100) + 1
        }
        if (xStart + 100) > iW {
            xLimit = iW
        } else {
            xLimit = xStart + 99
        }
        yStart = (iH - (((pgNo - 1) / pagesW) * 70))
        if yStart < 70 {
            yLimit = 1
        } else {
            yLimit = yStart - 69
        }
        vCurrPage = pgNo
        
        // Centre Line Markers: get centre points, and whether square or line...
        let cLH: Bool!
        let cLW: Bool!
        let centreW = iW / 2
        if (iW % 2) > 0 {
            cLW = false
        } else {
            cLW = true
        }
        let centreH = iH / 2
        if (iH % 2) > 0 {
            cLH = false
        } else {
            cLH = true
        }
        
        var symbolStr = " "
        if yStart < yLimit {
            return
        }
        for y in (yLimit...yStart).reversed() {
            for x in xStart...xLimit {
                var r: CGFloat
                var g: CGFloat
                var b: CGFloat
                var nsc: NSColor
                var cInt: Int
                var cSym: Int32
                var curCol: Byte = 0
                FreeImage_GetPixelIndex(bmpMatched, UInt32(x - 1), UInt32(y - 1), &curCol)
                if matchedPal[Int(curCol)].src == 999 {
                    cInt = Int(curCol)
                } else {
                    cInt = Int(matchedPal[Int(curCol)].src)
                }
                r = CGFloat(matchedPal[cInt].rgb.rgbRed) / 255
                g = CGFloat(matchedPal[cInt].rgb.rgbGreen) / 255
                b = CGFloat(matchedPal[cInt].rgb.rgbBlue) / 255
                nsc = NSColor(red: r, green: g, blue: b, alpha: 1)
                cSym = matchedPal[cInt].symbolNo
                if mapInColour == true {
                    let rct = CGRect(x: symbolTextX + 8.0, y: (symbolTextY + 2.0), width: 16, height: 16.5)
                    nsc.setFill()
                    NSBezierPath(rect: rct).fill()
                    symbolStr = NSString(bytes: &cSym, length: 4, encoding: String.Encoding.utf32LittleEndian.rawValue)! as String
                    if matchedPal[cInt].lum > 450 {
                        fgCol = NSColor.black
                    } else {
                        fgCol = NSColor.white
                    }
                    plotText(symbolStr as NSString, x: symbolTextX, y: symbolTextY - 1.0, w: symbolTextWidth, h: symbolTextHeight, font: "Helvetica", size: 15.0, align: "C", bgColour: NSColor.clear, fgColour: fgCol)
               } else {
                    fgCol = NSColor.black
                    symbolStr = NSString(bytes: &cSym, length: 4, encoding: String.Encoding.utf32LittleEndian.rawValue)! as String
                    plotText(symbolStr as NSString, x: symbolTextX, y: symbolTextY - 1.0, w: symbolTextWidth, h: symbolTextHeight, font: "Helvetica", size: 15.0, align: "C", bgColour: NSColor.clear, fgColour: fgCol)
                }
                // Plot Centre Markers
                if x == centreW && y == yStart {
                    let path = NSBezierPath()
                    path.lineWidth = 1.0
                    var plotPointX: CGFloat
                    var plotPointY: CGFloat
                    if cLW == true {
                        plotPointX = symbolTextX + 21
                    } else {
                        plotPointX = symbolTextX + 28
                    }
                    if (yStart - yLimit) == 69 {
                        plotPointY = bottomMargin
                    } else {
                        plotPointY = (pageHeight - topMargin) - (CGFloat(yStart) * defaultRowHeight)
                    }
                    var yPoint: CGFloat = (pageHeight - topMargin)
                    plotPointX += 4.0
                    if prefPaperSz != "A4" {
                        yPoint = (pageHeight - topMargin) - 14.5
                        plotPointY += 25.5
                    }
                    // Top Marker
                    NSColor.black.set()
                    path.move(to: NSMakePoint(plotPointX, yPoint + 2))
                    path.line(to: NSMakePoint((plotPointX - 5), yPoint + 8))
                    path.stroke()
                    path.move(to: NSMakePoint(plotPointX, yPoint + 2))
                    path.line(to: NSMakePoint((plotPointX + 5), yPoint + 8))
                    path.stroke()
                    path.move(to: NSMakePoint((plotPointX - 5), yPoint + 8))
                    path.line(to: NSMakePoint((plotPointX + 5), yPoint + 8))
                    path.stroke()
                    // Bottom Marker
                    NSColor.black.set()
                    path.move(to: NSMakePoint(plotPointX, plotPointY - 2))
                    path.line(to: NSMakePoint(plotPointX - 5, plotPointY - 8))
                    path.stroke()
                    path.move(to: NSMakePoint(plotPointX, plotPointY - 2))
                    path.line(to: NSMakePoint(plotPointX + 5, plotPointY - 8))
                    path.stroke()
                    path.move(to: NSMakePoint(plotPointX - 5, plotPointY - 8))
                    path.line(to: NSMakePoint(plotPointX + 5, plotPointY - 8))
                    path.stroke()
                }
                if y == centreH && x == xStart {
                    let path = NSBezierPath()
                    path.lineWidth = 1.0
                    var plotPointX: CGFloat
                    var plotPointY: CGFloat
                    if cLH == true {
                        plotPointY = symbolTextY + defaultRowHeight
                    } else {
                        plotPointY = (symbolTextY + defaultRowHeight) - (defaultRowHeight / 2)
                    }
                    if (xLimit - xStart) == 99 {
                        plotPointX = (pageWidth - rightMargin) + 2
                    } else {
                        plotPointX = (leftMargin + (CGFloat((xLimit - xStart) + 1) * defaultColumnWidth)) + 2
                        if prefPaperSz != "A4" {
                            plotPointX += 30.0
                        }
                    }
                    var xOrigin: CGFloat = (leftMargin - 2)
                    plotPointY += 1.5
                    if prefPaperSz != "A4" {
                        xOrigin += 13.0
                        plotPointX -= 17.0
                    }
                    // Left Marker
                    NSColor.black.set()
                    path.move(to: NSMakePoint(xOrigin, plotPointY))
                    path.line(to: NSMakePoint(xOrigin - 8, plotPointY + 5))
                    path.stroke()
                    path.move(to: NSMakePoint(xOrigin, plotPointY))
                    path.line(to: NSMakePoint(xOrigin - 8, plotPointY - 5))
                    path.stroke()
                    path.move(to: NSMakePoint(xOrigin - 8, plotPointY - 5))
                    path.line(to: NSMakePoint(xOrigin - 8, plotPointY + 5))
                    path.stroke()
                    // Right Marker
                    NSColor.black.set()
                    path.move(to: NSMakePoint(plotPointX, plotPointY))
                    path.line(to: NSMakePoint(plotPointX + 8, plotPointY + 5))
                    path.stroke()
                    path.move(to: NSMakePoint(plotPointX, plotPointY))
                    path.line(to: NSMakePoint(plotPointX + 8, plotPointY - 5))
                    path.stroke()
                    path.move(to: NSMakePoint(plotPointX + 8, plotPointY - 5))
                    path.line(to: NSMakePoint(plotPointX + 8, plotPointY + 5))
                    path.stroke()
                }
                symbolTextX += defaultColumnWidth
            }
            symbolTextY -= defaultRowHeight
            if prefPaperSz == "A4" {
                symbolTextX = leftMargin - 8
            } else {
                symbolTextX = leftMargin + 5
            }
        }
   }
    
    func drawChartHeaders() {
        var leftMargin: CGFloat = 77.0
        var rightMargin: CGFloat = 77.0
        var rightEdge: CGFloat = 1327.0
        var topEdge: CGFloat = 1175.0
        var bottomEdge: CGFloat = 35.0
        if prefPaperSz != "A4" {
            leftMargin = 28.0
            rightMargin = 28.0
            rightEdge = 1268.0
            topEdge = 1200.0
            bottomEdge = 45.0
        }
        plotText("Stitch This!", x: leftMargin, y: topEdge, w: 120.0, h: 35.0,
                 font: "Helvetica Bold Oblique", size: 20.0, align: "L", bgColour: bgCol, fgColour: fgCol)
        if dateStart {
            plotText("Page started on ____/____/ ____", x: rightEdge, y: (topEdge + 10.0),
                    w: 350.0, h: 20.0,
                    font: "Helvetica Oblique", size: 16.0, align: "R", bgColour: bgCol, fgColour: fgCol)
        }
        plotText(footerText as NSString, x: leftMargin, y: bottomEdge, w: 500.0, h: 20.0,
                 font: "Helvetica Oblique", size: 16.0, align: "L", bgColour: bgCol, fgColour: fgCol)
        let pgNoStr = "Page \(self.pgNo) of \(totalPages)"
        plotText(pgNoStr as NSString, x: leftMargin, y: (bottomEdge - 10.0), w: (pageWidth - leftMargin - rightMargin), h: 30.0,
                 font: "Helvetica", size: 16.0, align: "C", bgColour: bgCol, fgColour: fgCol)
        plotText(rangeText as NSString, x: rightEdge, y: bottomEdge,
                 w: 350.0, h: 20.0,
                 font: "Helvetica Oblique", size: 16.0, align: "R", bgColour: bgCol, fgColour: fgCol)
    }
    
    override func bounds(for box: PDFDisplayBox) -> NSRect {
        return NSMakeRect(0, 0, pageWidth, pageHeight)
    }
    
    override func draw(with box: PDFDisplayBox) {
        if self.hasPageNumber == true {
            drawChartHeaders()
            self.mapSymbols()
        }
    }
    
    init(footerText:String,
         rangeText:String,
         dateStart:Bool,
         totalPages:Int,
         pageWidth:CGFloat,
         pageHeight:CGFloat,
         hasPageNumber:Bool,
         pgNo:Int)
    {
        super.init()
        self.footerText = footerText
        self.rangeText = rangeText
        self.dateStart = dateStart
        self.totalPages = totalPages
        self.pageWidth = pageWidth
        self.pageHeight = pageHeight
        self.hasPageNumber = hasPageNumber
        self.pgNo = pgNo
    }

}

class Charts: BasePDFPage{
    override init(footerText:String,
                  rangeText:String,
                  dateStart:Bool,
                  totalPages:Int,
                  pageWidth:CGFloat,
                  pageHeight:CGFloat,
                  hasPageNumber:Bool,
                  pgNo:Int)
    {
        super.init(footerText: footerText,
                   rangeText: rangeText,
                   dateStart: dateStart,
                   totalPages: totalPages,
                   pageWidth: pageWidth,
                   pageHeight: pageHeight,
                   hasPageNumber: hasPageNumber,
                   pgNo: pgNo
        )
    }
    func drawGrid(){
        var leftMargin: CGFloat = 77.0
        var topMargin: CGFloat = 60.0
        if prefPaperSz != "A4" {
            leftMargin = 28.0
            topMargin = 72.5
        }
        var pgAcross = iW / 100
        var pgDown = iH / 70
        if (iW % 100) > 0 {
            pgAcross += 1
        }
        if (iH % 70) > 0 {
            pgDown += 1
        }
        var noCols: Int = 0
        var noRows: Int = 0
        let fullPagesW = Int(iW / 100)
        let fullPagesH = Int(iH / 70)
        var pagesW = fullPagesW
        var pagesH = fullPagesH
        if (iW % 100) != 0 {
            pagesW += 1
        }
        if (iH % 70) != 0 {
            pagesH += 1
        }
        
        if pgNo > fullPagesW && (pgNo % pagesW) == 0 && (iW % 100) > 0 {
            noCols = (iW % 100)
        } else {
            noCols = 100
        }
        if pgNo > (fullPagesH * pagesW) {
            noRows = (iH % 70)
        } else {
            noRows = 70
        }
        
        // Vertical
        for i in (0...noCols).reversed() {
            //draw the vertical lines
            let fromX = (leftMargin + (CGFloat(i) * defaultColumnWidth))
            let fromY = pageHeight - topMargin
            let toX = (leftMargin + (CGFloat(i) * defaultColumnWidth))
            let toY = (pageHeight - topMargin) - (defaultRowHeight * CGFloat(noRows))
            let fromPoint = NSMakePoint(fromX, fromY)
            let toPoint = NSMakePoint(toX, toY)
            let path = NSBezierPath()
            if (i % 10) == 0 || i == noCols {
                NSColor.black.set()
                path.lineWidth = 1.5
            } else if (i % 5) == 0 {
                NSColor.black.set()
                path.lineWidth = 0.5
            } else {
                NSColor.gray.set()
                path.lineWidth = 0.5
            }
            if i == 0 || i == 100 {
                NSColor.black.set()
                path.lineWidth = 1.5
            }
            path.move(to: fromPoint)
            path.line(to: toPoint)
            path.stroke()
        }
        // Horizontal
        for i in (0...noRows).reversed() {
            let fromX = leftMargin
            let fromY = (pageHeight - topMargin) - (defaultColumnWidth * CGFloat(i))
            let toX = leftMargin + (defaultColumnWidth * CGFloat(noCols))
            let toY = (pageHeight - topMargin) - (defaultColumnWidth * CGFloat(i))
            let fromPoint = NSMakePoint(fromX, fromY)
            let toPoint = NSMakePoint(toX, toY)
            let path = NSBezierPath()
            if (i % 10) == 0 || i == noRows {
                NSColor.black.set()
                path.lineWidth = 1.5
            } else if (i % 5) == 0 {
                NSColor.black.set()
                path.lineWidth = 0.5
            } else {
                NSColor.gray.set()
                path.lineWidth = 0.5
            }
            if i == 0 || i == 70 {
                NSColor.black.set()
                path.lineWidth = 1.5
            }
            path.move(to: fromPoint)
            path.line(to: toPoint)
            path.stroke()
        }
    }
    override func draw(with box: PDFDisplayBox) {
        super.draw(with: box)
        self.drawGrid()
    }
}


//
//-------------------------//
//  P R E F E R E N C E S  //
//-------------------------//
//

func setDefaults() {
        userDefaults.set(prefPaperSz, forKey: "prefPaperSz")
        userDefaults.set(prefDate, forKey: "prefDate")
        userDefaults.set(prefMeasmt, forKey: "prefMeasmt")
        userDefaults.set(prefManuf, forKey: "prefManuf")
        userDefaults.set(prefRange, forKey: "prefRange")
        userDefaults.set(prefFabCt, forKey: "prefFabCt")
        userDefaults.set(prefTurn, forKey: "prefTurn")
        userDefaults.set(prefStrands, forKey: "prefStrands")
        userDefaults.set(prefChCol, forKey: "prefChCol")
        userDefaults.set(prefCrdH, forKey: "prefCrdH")
        userDefaults.set(prefDtStart, forKey: "prefDtStart")
        userDefaults.set(prefOutCh, forKey: "prefOutCh")
        userDefaults.set(prefOutKP, forKey: "prefOutKP")
        userDefaults.set(prefOutTC, forKey: "prefOutTC")
        userDefaults.set(prefOutIm, forKey: "prefOutIm")
        userDefaults.set(prefOutSL, forKey: "prefOutSL")
        userDefaults.set(prefStUser, forKey: "prefStUser")
}

func getDefaults() {
    // Set to 'shipped defaults' if unset or Restore chosen
    if userDefaults.string(forKey: "prefPaperSz") == nil {
        prefPaperSz = "A4"
    } else {
        prefPaperSz = userDefaults.string(forKey: "prefPaperSz")!
    }
    if userDefaults.string(forKey: "prefDate") == nil {
        prefDate = "EU"
    } else {
        prefDate = userDefaults.string(forKey: "prefDate")!
    }
    if userDefaults.string(forKey: "prefMeasmt") == nil {
        prefMeasmt = "in"
    } else {
        prefMeasmt = userDefaults.string(forKey: "prefMeasmt")!
    }
    if userDefaults.string(forKey: "prefManuf") == nil {
        prefManuf = "ANC"
    } else {
        prefManuf = userDefaults.string(forKey: "prefManuf")!
    }
    if userDefaults.string(forKey: "prefRange") == nil {
        prefRange = "SC"
    } else {
        prefRange = userDefaults.string(forKey: "prefRange")!
    }
    if userDefaults.string(forKey: "prefStUser") == nil {
        prefStUser = "Default"
    } else {
        prefStUser = userDefaults.string(forKey: "prefStUser")!
    }
    if userDefaults.integer(forKey: "prefFabCt") == 0 {
        prefFabCt = 14
    } else {
        prefFabCt = userDefaults.integer(forKey: "prefFabCt")
    }
    if userDefaults.integer(forKey: "prefTurn") == 0 {
        prefTurn = 2
    } else {
        prefTurn = userDefaults.integer(forKey: "prefTurn")
    }
    if userDefaults.integer(forKey: "prefStrands") == 0 {
        prefStrands = 2
    } else {
        prefStrands = userDefaults.integer(forKey: "prefStrands")
    }
    if userDefaults.integer(forKey: "prefCrdH") == 0 {
        prefCrdH = 8
    } else {
        prefCrdH = userDefaults.integer(forKey: "prefCrdH")
    }
    prefChCol   = false
    prefOutCh   = true
    prefDtStart = false
    prefOutKP   = true
    prefOutTC   = true
    prefOutIm   = false
    prefOutSL   = false
    prefChCol   = userDefaults.bool(forKey: "prefChCol")
    prefOutCh   = userDefaults.bool(forKey: "prefOutCh")
    prefDtStart = userDefaults.bool(forKey: "prefDtStart")
    prefOutKP   = userDefaults.bool(forKey: "prefOutKP")
    prefOutTC   = userDefaults.bool(forKey: "prefOutTC")
    prefOutIm   = userDefaults.bool(forKey: "prefOutIm")
    prefOutSL   = userDefaults.bool(forKey: "prefOutSL")
    switch prefMeasmt {
        case "cm": vThrCdHMet = prefCrdH
                   vThrCdHImp = Int(round(Float(prefCrdH) / 2.54))
                   vOptTurnMet = prefTurn
                   vOptTurnImp = Int(round(Float(prefTurn) / 2.54))
        default:   vThrCdHImp = prefCrdH
                   vThrCdHMet = Int(round(Float(prefCrdH) * 2.54))
                   vOptTurnImp = prefTurn
                   vOptTurnMet = Int(round(Float(prefTurn) * 2.54))
    }
    switch prefPaperSz {
        case "A4": vPageH = 1754.0
                   vPageW = 1240.0
        default  : vPageH = 1650.0
                   vPageW = 1275.0
    }
    vFabCt = prefFabCt
    vStrandCt = prefStrands
}


//-------------------------------------
// D A T A B A S E   F U N C T I O N S
//-------------------------------------

open class SQLiteDatabase {
    fileprivate let dbPointer: OpaquePointer
    // ->
    fileprivate let dbVersion: Int = 2
    // <-
    fileprivate init(dbPointer: OpaquePointer) {
        self.dbPointer = dbPointer
    }
    deinit {
        sqlite3_close(dbPointer)
    }
    fileprivate var errorMessage: String {
        if let errorMessage = String(validatingUTF8: sqlite3_errmsg(dbPointer)) {
            return errorMessage
        } else {
            return "No error message provided from SQLite."
        }
    }
}

extension SQLiteDatabase {
    func prepareStatement(_ sql: String) throws -> OpaquePointer {
        var statement: OpaquePointer? = nil
        guard sqlite3_prepare_v2(dbPointer, sql, -1, &statement, nil) == SQLITE_OK else {
            exit(999)
        }
        return statement!
    }
}

public func openDatabase() -> OpaquePointer {
    let dbName: String = "/Applications/Stitch This!.app/Contents/Resources/stitch.sqlite"
    let result: Int32 = sqlite3_open(dbName, &db)
    if result  == SQLITE_OK {
        return db!
    } else {
        popUpOK("Error \(result) connecting to Stitch DB...", text: "Path being searched was '\(dbName)'")
        sqlite3_close(db)
        return db!
    }
}

public func query(_ m: String, r: String) {
    let queryStatementString = "select substr('00000' || no, -5, 5) as no, makerid, rangeid, r, g, b, spares from thread where substr(no,1,1) <= '9' and makerid = '" + m + "' and rangeid = '" + r + "' union select no, makerid, rangeid, r, g, b, spares from thread where substr(no,1,1) > '9' and makerid = '" + m + "' and rangeid = '" + r + "';"
    dataArray.removeAll()
    threadPal.removeAll()
    var queryStatement: OpaquePointer? = nil
    let result: Int32 = sqlite3_prepare_v2(db, queryStatementString, -1, &queryStatement, nil)
    var spares: Double = 0
    let i: Int = 0
    var colour: NSColor
    if  result == SQLITE_OK {
        while (sqlite3_step(queryStatement) == SQLITE_ROW && i < Int(retCt)) {
            let upd: Bool = false
            let colNo = String(cString: sqlite3_column_text(queryStatement, 0))
            let pr = sqlite3_column_int(queryStatement, 3)
            let pg = sqlite3_column_int(queryStatement, 4)
            let pb = sqlite3_column_int(queryStatement, 5)
            let curRGB: RGBQUAD = RGBQUAD(rgbBlue: Byte(pb), rgbGreen: Byte(pg), rgbRed: Byte(pr), rgbReserved: Byte(255))
            let thisRGB: (rgb: RGBQUAD, colourNo: String, symbolNo: Int32, ct: Int32, src: Int32, lum: Int32)
            let r = CGFloat(pr) / 255
            let g = CGFloat(pg) / 255
            let b = CGFloat(pb) / 255
            colour = NSColor.init(red: r, green: g, blue: b, alpha: 1)
            spares = Double(sqlite3_column_int(queryStatement, 6)) / Double(100)
            let thisData: (colorNo: String, color: NSColor, spare: Double, upd: Bool)
            thisData.colorNo = colNo
            thisData.color = colour
            thisData.spare = spares
            thisData.upd = upd
            dataArray.append(thisData)
            thisRGB.rgb = curRGB
            thisRGB.colourNo = colNo
            thisRGB.symbolNo = 0
            thisRGB.ct = 0
            thisRGB.src = 0
            thisRGB.lum = (pr + pg + pb)
            threadPal.append(thisRGB)
        }
    } else {
    }
    sqlite3_finalize(queryStatement)
}

public func queryCt(_ m: String, r: String) -> Int32 {
    let queryStatementString = "select count(*) from thread where makerid = '" + m + "' and rangeid = '" + r + "';"
    var ctNo: Int32 = 0
    var queryStatement: OpaquePointer? = nil
    let result: Int32 = sqlite3_prepare_v2(db, queryStatementString, -1, &queryStatement, nil)
    if  result == SQLITE_OK && sqlite3_step(queryStatement) == SQLITE_ROW {
        ctNo = sqlite3_column_int(queryStatement, 0)
    } else {
        print("SELECT statement '\(queryStatementString)' could not be prepared: Error \(result)")
    }
    sqlite3_finalize(queryStatement)
    return ctNo
}

public func querySpares(_ m: String, r: String) {
    let queryStatementString = "select no, spares from thread where makerid = '" + m + "' and rangeid = '" + r + "' and spares > 0 order by 1;"
    var queryStatement: OpaquePointer? = nil
    let result: Int32 = sqlite3_prepare_v2(db, queryStatementString, -1, &queryStatement, nil)
    let i: Int = 0
    var thisSpare: (no: String, spares: Int32, skeinCt: Int32)
   if  result == SQLITE_OK {
        while (sqlite3_step(queryStatement) == SQLITE_ROW && i < Int(retCt)) {
            thisSpare.no = String(format: "%05d", sqlite3_column_int(queryStatement, 0))
            thisSpare.spares = sqlite3_column_int(queryStatement, 1)
            thisSpare.skeinCt = 0
            activeSpares.append(thisSpare)
        }
    } else {
        print("SELECT statement '\(queryStatementString)' could not be prepared: Error \(result)")
    }
    sqlite3_finalize(queryStatement)
}

public func update(_ s: Double, m: String, r: String, n: String) {
    var updateStatementString = "update thread set spares = " + String(format: "%.2f", s)
    updateStatementString += " where makerid = '" + m + "' and rangeid = '" + r + "' and no = '" + n + "';"
    var updateStatement: OpaquePointer? = nil
    if sqlite3_prepare_v2(db, updateStatementString, -1, &updateStatement, nil) == SQLITE_OK {
        if sqlite3_step(updateStatement) == SQLITE_DONE {
        } else {
            print("Could not update row.")
        }
    } else {
        print("UPDATE statement could not be prepared")
    }
    sqlite3_finalize(updateStatement)
}

//
// User table
//

public func getUserCt() -> Int32 {
    let queryStatementString = "select count(*) from user;"
    var ctNo: Int32 = 0
    var queryStatement: OpaquePointer? = nil
    let result: Int32 = sqlite3_prepare_v2(db, queryStatementString, -1, &queryStatement, nil)
    if  result == SQLITE_OK && sqlite3_step(queryStatement) == SQLITE_ROW {
        ctNo = sqlite3_column_int(queryStatement, 0)
    } else {
        print("SELECT statement '\(queryStatementString)' could not be prepared: Error \(result), ctNo=\(ctNo)")
    }
    sqlite3_finalize(queryStatement)
    return ctNo
}

public func getUsers() -> Int32  {
    let i: Int = 0
    let userCt = getUserCt()
    let queryStatementString = "select name from user order by userid;"
    var queryStatement: OpaquePointer? = nil
    let result: Int32 = sqlite3_prepare_v2(db, queryStatementString, -1, &queryStatement, nil)
    if result == SQLITE_OK  {
        while (sqlite3_step(queryStatement) == SQLITE_ROW && i <= userCt) {
            let queryResult = sqlite3_column_text(queryStatement, 0)
            let thisUser = String(cString: queryResult!)
            userSet.append(thisUser)
        }
    } else {
        print("SELECT statement '\(queryStatementString)' could not be prepared: Error \(result)")
    }
    sqlite3_finalize(queryStatement)
    return result
}

public func getUserID(_ r: String) -> Int32  {
    var queryResult: Int32 = 0
    let queryStatementString = "select userid from user where name = '\(r)';"
    var queryStatement: OpaquePointer? = nil
    let result: Int32 = sqlite3_prepare_v2(db, queryStatementString, -1, &queryStatement, nil)
    if result == SQLITE_OK  {
        while (sqlite3_step(queryStatement) == SQLITE_ROW) {
            queryResult = sqlite3_column_int(queryStatement, 0)
        }
    } else {
        print("SELECT statement '\(queryStatementString)' could not be prepared: Error \(result)")
    }
    sqlite3_finalize(queryStatement)
    return queryResult
}

public func addUser(_ r: String) {
    beginTransaction()
    let sqlStatement = "insert into user (name) values ('\(r)');"
    var insertStatement: OpaquePointer? = nil
    if sqlite3_prepare_v2(db, sqlStatement, -1, &insertStatement, nil) == SQLITE_OK {
        if sqlite3_step(insertStatement) != SQLITE_DONE {
            popUpOK("Database error", text: "UNABLE TO PROCESS DATA. \n SQL being processed: <\(sqlStatement)>")
        }
    } else {
        popUpOK("Error updating database:", text: "STATEMENT \(sqlStatement) FAILED: ERROR \(sqlite3_step(insertStatement))")
    }
    sqlite3_finalize(insertStatement)
    commitTransaction()
    prefStUser = "\(r)"
}

public func deleteUser(_ r: String) {
    beginTransaction()
    let sqlStatement = "delete from user where name = '\(r)';"
    var deleteStatement: OpaquePointer? = nil
    if sqlite3_prepare_v2(db, sqlStatement, -1, &deleteStatement, nil) == SQLITE_OK {
        if sqlite3_step(deleteStatement) != SQLITE_DONE {
            popUpOK("Database error", text: "UNABLE TO PROCESS DATA. \n SQL being processed: <\(sqlStatement)>")
        }
    } else {
        popUpOK("Error updating database:", text: "STATEMENT \(sqlStatement) FAILED: ERROR \(sqlite3_step(deleteStatement))")
    }
    sqlite3_finalize(deleteStatement)
    commitTransaction()
    resetUserSeq()
}

public func deleteUserSymbols(_ r: String) {
    beginTransaction()
    let sqlStatement = "delete from symbols where substr(key,1,1) in(select userid from user where name = '\(r)');"
    var deleteStatement: OpaquePointer? = nil
    if sqlite3_prepare_v2(db, sqlStatement, -1, &deleteStatement, nil) == SQLITE_OK {
        if sqlite3_step(deleteStatement) != SQLITE_DONE {
            popUpOK("Database error", text: "UNABLE TO PROCESS DATA. \n SQL being processed: <\(sqlStatement)>")
        }
    } else {
        popUpOK("Error updating database:", text: "STATEMENT \(sqlStatement) FAILED: ERROR \(sqlite3_step(deleteStatement))")
    }
    sqlite3_finalize(deleteStatement)
    commitTransaction()
    resetUserSeq()
}

public func resetUserSeq() {
    let updateStatementString = "update sqlite_sequence set seq = (select max(userid) from user) where name='user';"
    var updateStatement: OpaquePointer? = nil
    if sqlite3_prepare_v2(db, updateStatementString, -1, &updateStatement, nil) == SQLITE_OK {
        if sqlite3_step(updateStatement) == SQLITE_DONE {
        } else {
            print("Could not reset sequence.")
        }
    } else {
        print("UPDATE statement could not be prepared: >>\(updateStatementString)<<")
    }
    sqlite3_finalize(updateStatement)
}


//
// Preferences Symbol tables
//

public func getSymbolSet(_ r: String) -> Int  {
    let queryStatementString = "select userid from user where name = '" + r + "';"
    var ctNo: Int32 = 0
    var queryStatement: OpaquePointer? = nil
    let result: Int32 = sqlite3_prepare_v2(db, queryStatementString, -1, &queryStatement, nil)
    if  result == SQLITE_OK && sqlite3_step(queryStatement) == SQLITE_ROW {
        ctNo = sqlite3_column_int(queryStatement, 0)
    } else {
        print("SELECT statement '\(queryStatementString)' could not be prepared: Error \(result), ctNo=\(ctNo)")
    }
    sqlite3_finalize(queryStatement)
    return Int(result)
}

public func symbolExists(_ u: Int32, s: String) -> Int32  {
    let queryStatementString = "select 1 from symbols where substr(key,1,1) = '\(u)' and symno = '\(s)';"
    var ctNo: Int32 = 0
    var queryStatement: OpaquePointer? = nil
    let result: Int32 = sqlite3_prepare_v2(db, queryStatementString, -1, &queryStatement, nil)
    if  result == SQLITE_OK && sqlite3_step(queryStatement) == SQLITE_ROW {
        ctNo = sqlite3_column_int(queryStatement, 0)
    }
    sqlite3_finalize(queryStatement)
    return ctNo
}

public func querySymbols(_ u: String)  {
    let queryStatementString = "select substr(key,2,2) as symbol, symno from symbols where substr(key,1,1) in(select userid from user where name = '\(u)') order by 1;"
    symbolSet = []
    var queryStatement: OpaquePointer? = nil
    let result: Int32 = sqlite3_prepare_v2(db, queryStatementString, -1, &queryStatement, nil)
    let i: Int = 0
    var thisSym: (no: String, sym: Int32)
    if  result == SQLITE_OK {
        while (sqlite3_step(queryStatement) == SQLITE_ROW && i < 50) {
            thisSym.no = String(format: "%02d", sqlite3_column_int(queryStatement, 0))
            thisSym.sym = sqlite3_column_int(queryStatement, 1)
            symbolSet.append(thisSym)
        }
    } else {
        print("SELECT statement '\(queryStatementString)' could not be prepared: Error \(result)")
    }
    sqlite3_finalize(queryStatement)
}

public func ctSymbolSet(_ u: String) -> Int32 {
    let queryStatementString = "select count(*) from symbols where substr(key,1,1) = '\(u)';"
    var ctNo: Int32 = 0
    var queryStatement: OpaquePointer? = nil
    let result: Int32 = sqlite3_prepare_v2(db, queryStatementString, -1, &queryStatement, nil)
    if  result == SQLITE_OK && sqlite3_step(queryStatement) == SQLITE_ROW {
        ctNo = sqlite3_column_int(queryStatement, 0)
    } else {
        print("SELECT statement '\(queryStatementString)' could not be prepared: Error \(result)")
    }
    sqlite3_finalize(queryStatement)
    return ctNo
}

public func getLatestSymbolSeq(_ s: Int32) -> Int32  {
    let queryStatementString = "select max(substr(key,2,2)) from symbols where substr(key,1,1) = '\(s)';"
    var ctNo: Int32 = 0
    var queryStatement: OpaquePointer? = nil
    let result: Int32 = sqlite3_prepare_v2(db, queryStatementString, -1, &queryStatement, nil)
    if  result == SQLITE_OK && sqlite3_step(queryStatement) == SQLITE_ROW {
        ctNo = sqlite3_column_int(queryStatement, 0)
    } else {
        print("SELECT statement '\(queryStatementString)' could not be prepared: Error \(result), ctNo=\(ctNo)")
    }
    sqlite3_finalize(queryStatement)
    return ctNo
}

public func insertSymbols(_ user: Int32, seq: Int, symno: String) {
    var seqNo: String = ""
    if seq < 9 {
        seqNo = "0" + String(seq + 1)
    } else {
        seqNo = String(seq + 1)
    }
    let key = String(user) + String(seqNo)
    beginTransaction()
    let sqlStatement = "insert into symbols (key, symno) values('" + key + "', '" + symno + "');"
    var insertStatement: OpaquePointer? = nil
    if sqlite3_prepare_v2(db, sqlStatement, -1, &insertStatement, nil) == SQLITE_OK {
        if sqlite3_step(insertStatement) != SQLITE_DONE {
            popUpOK("Database error", text: "UNABLE TO PROCESS DATA. \n SQL being processed: <\(sqlStatement)>")
        }
    } else {
        popUpOK("Error updating database:", text: "STATEMENT \(sqlStatement) FAILED: ERROR \(sqlite3_step(insertStatement))")
    }
    sqlite3_finalize(insertStatement)
    commitTransaction()
}

public func deleteSymbol(_ user: String, sym: Int) {
    let updateStatementString = "delete from symbols where substr(key,1,1) in(select userid from user where name = '\(user)') and symno = '\(sym)';"
    var updateStatement: OpaquePointer? = nil
    if sqlite3_prepare_v2(db, updateStatementString, -1, &updateStatement, nil) == SQLITE_OK {
        if sqlite3_step(updateStatement) == SQLITE_DONE {
        } else {
            print("Could not update row.")
        }
    } else {
        print("UPDATE statement could not be prepared: >>\(updateStatementString)<<")
    }
    sqlite3_finalize(updateStatement)
}

public func deleteSymbolSet(_ user: Int) {
    let updateStatementString = "delete from symbols where substr(key,1,1) = '\(user)';"
    beginTransaction()
    var updateStatement: OpaquePointer? = nil
    if sqlite3_prepare_v2(db, updateStatementString, -1, &updateStatement, nil) == SQLITE_OK {
        if sqlite3_step(updateStatement) == SQLITE_DONE {
        } else {
            print("Could not update row.")
        }
    } else {
        print("UPDATE statement could not be prepared: >>\(updateStatementString)<<")
    }
    commitTransaction()
    sqlite3_finalize(updateStatement)
}


//
// Transactional
//

public func beginTransaction() {
    let sql = "begin transaction;"
    var sqlStatement: OpaquePointer? = nil
    if sqlite3_prepare_v2(db, sql, -1, &sqlStatement, nil) == SQLITE_OK {
        if sqlite3_step(sqlStatement) == SQLITE_DONE {
        } else {
            popUpOK("Database error", text: "UNABLE TO BEGIN TRANSACTION.")
        }
    } else {
        popUpOK("Database error", text: "BEGIN STATEMENT \(sql) COULD NOT BE PREPARED: ERROR \(sqlite3_step(sqlStatement))")
    }
    sqlite3_finalize(sqlStatement)
}
public func commitTransaction() {
    let sql = "commit transaction;"
    var sqlStatement: OpaquePointer? = nil
    if sqlite3_prepare_v2(db, sql, -1, &sqlStatement, nil) == SQLITE_OK {
        if sqlite3_step(sqlStatement) == SQLITE_DONE {
        } else {
            popUpOK("Database error", text: "UNABLE TO COMMIT TRANSACTION.")
        }
    } else {
        popUpOK("Database error", text: "COMMIT STATEMENT \(sql) COULD NOT BE PREPARED: ERROR \(sqlite3_step(sqlStatement))")
    }
    sqlite3_finalize(sqlStatement)
}


//
// Table View layout functions
//

public func columnView(_ name: String, useHeaderStyle: Bool = false) -> NSView {
    let label = NSTextField(frame: CGRect(x: 0, y: 0, width: 1, height: 1))
    if useHeaderStyle == true {
        label.backgroundColor = NSColor.lightGray
    }
    label.layer!.borderWidth = 0.5
    label.layer!.borderColor = NSColor.black.cgColor
    label.sizeToFit()
    return label
}

public func rowView(_ row: Row, useHeaderStyle: Bool = false) -> NSView {
    let stackView = NSStackView(frame: CGRect(x: 0, y: 0, width: 1, height: 1))
    stackView.distribution = .fillEqually
    stackView.spacing = 0
    var columnViews = [NSView]()
    for name in row.names {
        let c = columnView(name, useHeaderStyle: useHeaderStyle)
        columnViews.append(c)
        stackView.addArrangedSubview(c)
    }
    stackView.frame = CGRect(x: 0, y: 0, width: row.names.count*100, height: 30)
    return stackView
}

public struct Row {
    let names: [String]
    public init(names: [String]) {
        self.names = names
    }
}

public func tableView(_ rows: [Row]) -> NSView {
    guard rows.count > 0 else {
        return columnView("No Rows")
    }
    let firstRow = rows[0]
    let stackView = NSStackView(frame: CGRect(x: 0, y: 0, width: 1, height: 1))
    stackView.distribution = .fillEqually
    stackView.spacing = 0
    for row in rows {
        let isHeaderRow = stackView.arrangedSubviews.count == 0
        stackView.addArrangedSubview(rowView(row, useHeaderStyle: isHeaderRow))
    }
    stackView.frame = CGRect(x: 0, y: 0, width: firstRow.names.count * 100, height: rows.count * 25)
    return stackView
}

public func palView(_ rows: [Row]) -> NSView {
    guard rows.count > 0 else {
        return columnView("No rows")
    }
    let firstRow = rows[0]
    let stackView = NSStackView(frame: CGRect(x: 0, y: 0, width: 1, height: 1))
    stackView.distribution = .fillEqually
    stackView.spacing = 0
    for row in rows {
        stackView.addArrangedSubview(rowView(row, useHeaderStyle: false)
        )
    }
    stackView.frame = CGRect(x: 0, y: 0, width: firstRow.names.count * 100, height: rows.count * 25)
    return stackView
}
