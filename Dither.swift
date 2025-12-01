
//
//  File:       Dither.swift
//  Project:    FilterPlay

import AppKit
import Foundation


public extension NSImage {
    ///  Convert NSImage to NSBitmapImageRep
    ///  - returns: NSBitmapImageRep
    public func bitmapImageRep() -> NSBitmapImageRep? {
        let width = Int(size.width)
        let height = Int(size.height)
        
        guard let bitmapImageRep = NSBitmapImageRep(
            bitmapDataPlanes: nil,
            pixelsWide: width,
            pixelsHigh: height,
            bitsPerSample: 8,
            samplesPerPixel: 4,
            hasAlpha: true,
            isPlanar: false,
            colorSpaceName: NSNamedColorSpace(NSCalibratedRGBColorSpace),
            //NSColorSpaceName.calibratedRGB,
            bytesPerRow: width * 4,
            bitsPerPixel: 32) else { fatalError("Unable to convert to NSBitmapImageRep") }
        
        let graphicsContext = NSGraphicsContext(bitmapImageRep: bitmapImageRep)
        NSGraphicsContext.saveGraphicsState()
        NSGraphicsContext.current = graphicsContext
        draw(at: NSZeroPoint, from: NSZeroRect, operation: NSCompositingOperation.copy, fraction: CGFloat(1.0))
        graphicsContext?.flushGraphics()
        NSGraphicsContext.restoreGraphicsState()
        return bitmapImageRep
    }
}


public extension NSImage {
    ///  Pixel Components
    public struct Pixel {
        var red: UInt8
        var green: UInt8
        var blue: UInt8
        var alpha: UInt8
        
        private static func toUInt8(value: Double) -> UInt8 {
            return value > 1.0 ? UInt8(255) : value < 0 ? UInt8(0) : UInt8(value * 255.0)
        }
        
        init(red: UInt8, green: UInt8, blue: UInt8, alpha: UInt8) {
            self.red = red
            self.green = green
            self.blue = blue
            self.alpha = alpha
        }
        
        init(red: Double, green: Double, blue: Double, alpha: Double) {
            self.red = Pixel.toUInt8(red)
            self.green = Pixel.toUInt8(green)
            self.blue = Pixel.toUInt8(blue)
            self.alpha = Pixel.toUInt8(alpha)
        }
    }
    
    ///  Converts NSImage to UnsafeMutablePointer<Pixel>
    ///  Used for pixel component access and/or manipulation
    ///  - returns: UnsafeMutablePointer<Pixel>
    public func pixelArray() -> UnsafeMutablePointer<Pixel>? {
        guard let imageRep = self.bitmapImageRep() else { fatalError("Unable to convert to pixelArray") }
        return imageRep.bitmapData.withMemoryRebound(to: Pixel.self, capacity: imageRep.pixelsWide * imageRep.pixelsHigh, UnsafeMutablePointer.init)
    }

}


// MARK: - UnsafeMutablePointer<Pixel> to NSImage -

public extension NSImage {
    ///  Recomposites UnsafeMutablePointer<Pixel> Back To NSImage
    ///  Works in conjunction with pixelArray() functions.
    ///  - parameter pixelData: UnsafeMutablePointer<Pixel>
    ///  - parameter size: NSSize of image data contained in UnsafeMutablePointer<Pixel>
    ///  - returns: NSImage
    public static func recomposite(pixelData: UnsafeMutablePointer<Pixel>, size: NSSize) -> NSImage? {
        let width = Int(size.width)
        let height = Int(size.height)
        let colorSpace = NSColorSpace.genericRGBColorSpace()
        let bytesPerRow = MemoryLayout<Pixel>.size * width
        let bitsPerComponent = 8
        let bitmapInfo = CGBitmapInfo.ByteOrder32Big.rawValue | CGImageAlphaInfo.PremultipliedLast.rawValue
        guard let bitmapContext = CGContext(data: pixelData, width: width, height: height, bitsPerComponent: bitsPerComponent, bytesPerRow: bytesPerRow, space: colorSpace!, bitmapInfo: bitmapInfo) else {
            fatalError("Unable to create bitmap CGcontext")
        }
        guard let cgImage = bitmapContext.makeImage() else { fatalError("Unable to makeImage") }
        let imageSize = NSSize(width: width, height: height)
        return NSImage(cgImage: cgImage, size: imageSize)
    }
}

public extension NSImage {
    
    // MARK: - DitherMethod -
    
    ///  2D Dither Methods
    ///  - Atkinson:
    ///  - FloydSteinberg:
    ///  - Burkes:
    ///  - Sierra:
    ///  - SierraTwoRow:
    ///  - SierraLite:
    ///  - Stucki:
    ///  - JarvisJudiceNinke:
    public enum Dither {
        case atkinson, floydSteinberg, burkes
        case sierra, sierraTwoRow, sierraLite
        case stucki, jarvisJudiceNinke, none
        
        ///  Divisor to be used with dither offsets
        ///  - returns: Integer divisor
        internal func divisor() -> Int {
            switch self {
            case .atkinson: return 8
            case .floydSteinberg: return 16
            case .burkes: return 32
            case .sierra: return 32
            case .sierraTwoRow: return 16
            case .sierraLite: return 4
            case .stucki: return 42
            case .jarvisJudiceNinke: return 48
            default: return 0
            }
        }
        
        /// Array containing all dither methods, excludes None
        public static var allValues: [Dither] = [
            .atkinson, .floydSteinberg, .burkes,
            .sierra, .sierraTwoRow, .sierraLite,
            .stucki, .jarvisJudiceNinke,
            ]
        
        ///  Matrix to stored dither offsets and the error ratio
        internal struct Matrix {
            let row: Int
            let column: Int
            let ratio: Int
        }
        
        private static let AtkinsonMatrix = [
            Matrix(row: 0, column: 1, ratio: 1),
            Matrix(row: 0, column: 2, ratio: 1),
            Matrix(row: 1, column: -1, ratio: 1),
            Matrix(row: 1, column: 0, ratio: 1),
            Matrix(row: 1, column: 1, ratio: 1),
            Matrix(row: 2, column: 0, ratio: 1),
            ]
        
        private static let FloydSteinbergMatrix = [
            Matrix(row: 0, column: 1, ratio: 7),
            Matrix(row: 1, column: -1, ratio: 3),
            Matrix(row: 1, column: 0, ratio: 5),
            Matrix(row: 1, column: 1, ratio: 1),
            ]
        
        private static let BurkesMatrix = [
            Matrix(row: 0, column: 1, ratio: 8),
            Matrix(row: 0, column: 2, ratio: 4),
            Matrix(row: 1, column: -2, ratio: 2),
            Matrix(row: 1, column: -1, ratio: 4),
            Matrix(row: 1, column: 0, ratio: 8),
            Matrix(row: 1, column: 1, ratio: 4),
            Matrix(row: 1, column: 2, ratio: 2),
            ]
        
        private static let SierraMatrix = [
            Matrix(row: 0, column: 1, ratio: 5),
            Matrix(row: 0, column: 2, ratio: 3),
            Matrix(row: 1, column: -2, ratio: 2),
            Matrix(row: 1, column: -1, ratio: 4),
            Matrix(row: 1, column: 0, ratio: 5),
            Matrix(row: 1, column: 1, ratio: 4),
            Matrix(row: 1, column: 2, ratio: 2),
            Matrix(row: 2, column: -1, ratio: 2),
            Matrix(row: 2, column: 0, ratio: 3),
            Matrix(row: 2, column: 1, ratio: 2),
            ]
        
        private static let SierraTwoRowMatrix = [
            Matrix(row: 0, column: 1, ratio: 4),
            Matrix(row: 0, column: 2, ratio: 3),
            Matrix(row: 1, column: -2, ratio: 1),
            Matrix(row: 1, column: -1, ratio: 2),
            Matrix(row: 1, column: 0, ratio: 3),
            Matrix(row: 1, column: 1, ratio: 2),
            Matrix(row: 1, column: 2, ratio: 1),
            ]
        
        private static let SierraLiteMatrix = [
            Matrix(row: 0, column: 1, ratio: 2),
            Matrix(row: 1, column: -1, ratio: 1),
            Matrix(row: 1, column: 0, ratio: 1),
            ]
        
        private static let StuckiMatrix = [
            Matrix(row: 0, column: 1, ratio: 8),
            Matrix(row: 0, column: 2, ratio: 4),
            Matrix(row: 1, column: -2, ratio: 2),
            Matrix(row: 1, column: -1, ratio: 4),
            Matrix(row: 1, column: 0, ratio: 8),
            Matrix(row: 1, column: 1, ratio: 4),
            Matrix(row: 1, column: 2, ratio: 2),
            Matrix(row: 2, column: -2, ratio: 1),
            Matrix(row: 2, column: -1, ratio: 2),
            Matrix(row: 2, column: 0, ratio: 4),
            Matrix(row: 2, column: 1, ratio: 2),
            Matrix(row: 2, column: 2, ratio: 1),
            ]
        
        private static let JarvisJudiceNinkeMatrix = [
            Matrix(row: 0, column: 1, ratio: 7),
            Matrix(row: 0, column: 2, ratio: 5),
            Matrix(row: 1, column: -2, ratio: 3),
            Matrix(row: 1, column: -1, ratio: 5),
            Matrix(row: 1, column: 0, ratio: 7),
            Matrix(row: 1, column: 1, ratio: 5),
            Matrix(row: 1, column: 2, ratio: 3),
            Matrix(row: 2, column: -2, ratio: 1),
            Matrix(row: 2, column: -1, ratio: 3),
            Matrix(row: 2, column: 0, ratio: 5),
            Matrix(row: 2, column: 1, ratio: 3),
            Matrix(row: 2, column: 2, ratio: 1),
            ]
        
        internal func matrix() -> [Matrix] {
            switch self {
            case .atkinson: return Dither.AtkinsonMatrix
            case .floydSteinberg: return Dither.FloydSteinbergMatrix
            case .burkes: return Dither.BurkesMatrix
            case .sierra: return Dither.SierraMatrix
            case .sierraTwoRow: return Dither.SierraTwoRowMatrix
            case .sierraLite: return Dither.SierraLiteMatrix
            case .stucki: return Dither.StuckiMatrix
            case .jarvisJudiceNinke: return Dither.JarvisJudiceNinkeMatrix
            default: return []
            }
        }
    }
    
    // MARK: - dither function -
    
    ///  Dither NSImage to improve clarity with low color or low resolution
    ///  - parameter method: optional DitherMethod type
    ///  - returns: new optional NSImage
    public func dither(method: Dither = .jarvisJudiceNinke) -> NSImage? {
        // Retrieve method divisor & matrix
        let divisor = method.divisor()
        let matrix = method.matrix()
        
        // Dimensions
        let width = Int(size.width)
        let height = Int(size.height)
        
        /* Calculate error to add to matrix values & curb UInt8 overflow */
        func addError(component: UInt8, pixelError: UInt8, ratio: Int) -> UInt8 {
            let _component = Int(component)
            let _pixelError = Int(pixelError)
            let apportionedError = _pixelError * ratio / divisor
            return UInt8(_component + apportionedError > 255 ? 255 : _component + apportionedError)
        }
        
        /* Subtract Dither from current component & curb UInt8 underflow */
        func subtractDither(component: UInt8, dither: UInt8) -> UInt8 {
            return Int(component) - Int(dither) < 0 ? 0 : component - dither
        }
        
        /* Distribute error to matrix color components */
        func distributeError(pixel: Pixel, pixelError: Pixel, ratio: Int) -> Pixel {
            return Pixel(
                red: addError(pixel.red, pixelError: pixelError.red, ratio: ratio),
                green: addError(pixel.green, pixelError: pixelError.green, ratio: ratio),
                blue: addError(pixel.blue, pixelError: pixelError.blue, ratio: ratio),
                alpha: pixel.alpha)
        }
        
        /* Calculate the dither for the current pixel */
        func calculateDither(pixel: Pixel) -> Pixel {
            return Pixel(red: pixel.red < 128 ? 0 : 255,
                         green: pixel.green < 128 ? 0 : 255,
                         blue: pixel.blue < 128 ? 0 : 255,
                         alpha: pixel.alpha)
        }
        
        /* Calculate Error by substracting dither from current color components */
        func calculateError(current: Pixel, dither: Pixel) -> Pixel {
            return Pixel(red: subtractDither(current.red, dither: dither.red),
                         green: subtractDither(current.green, dither: dither.green),
                         blue: subtractDither(current.blue, dither: dither.blue),
                         alpha: current.alpha)
        }
        
        // calculate memory offset
        func offset(row: Int, column: Int) -> Int {
            return row * width + column
        }
        
        /* Create a 2D pixel Array for dither pixel processing */
        guard let pixelArray = self.pixelArray() else { return nil }
        
        /* Loop through each pixel and apply dither */
        for y in 0 ..< height {
            for x in 0 ..< width {
                let currentOffset = offset(y, column: x)
                let currentColor = pixelArray[currentOffset]
                let ditherColor = calculateDither(currentColor)
                let errorColor = calculateError(currentColor, dither: ditherColor)
                
                /* Dither Current Pixel */
                pixelArray[currentOffset] = ditherColor
                
                /* Apply Error To Matrix Pixels */
                for neighbor in matrix {
                    let row = y + neighbor.row
                    let column = x + neighbor.column
                    
                    // Bounds check
                    guard row >= 0 && row < height && column >= 0 && column < width else { continue }
                    
                    let neighborOffset = offset(row, column: column)
                    let neighborColor = pixelArray[neighborOffset]
                    pixelArray[neighborOffset] = distributeError(
                        neighborColor,
                        pixelError: errorColor,
                        ratio: neighbor.ratio)
                }
            }
        }
        
        /* Recomposite image from pixelArray */
        return NSImage.recomposite(pixelArray, size: size)
    }
}
