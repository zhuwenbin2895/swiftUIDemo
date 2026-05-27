import UIKit
import CoreImage
import CoreImage.CIFilterBuiltins
import ImageIO
import UniformTypeIdentifiers

// MARK: - QR Code Generator

final class QRCodeGenerator {

    static let shared = QRCodeGenerator()
    private let context = CIContext()
    private var cache = NSCache<NSString, UIImage>()

    private init() {
        cache.countLimit = 50
        cache.totalCostLimit = 50 * 1024 * 1024
    }

    func clearCache() {
        cache.removeAllObjects()
    }

    // MARK: - Basic Generation

    func generate(config: QRGenerationConfig) -> UIImage? {
        let cacheKey = "\(config.content)_\(config.size)_\(config.correctionLevel.rawValue)" as NSString
        if let cached = cache.object(forKey: cacheKey), !config.useGradient && config.logoImage == nil && config.backgroundImage == nil {
            return cached
        }

        guard let qrImage = generateBasicQR(content: config.content, correctionLevel: config.correctionLevel) else {
            return nil
        }

        let size = CGSize(width: config.size, height: config.size)
        var result: UIImage

        if config.dotStyle != .square {
            result = applyDotStyle(to: qrImage, style: config.dotStyle, size: size, config: config)
        } else {
            result = renderBasic(ciImage: qrImage, size: size, config: config)
        }

        if config.useGradient {
            result = applyGradient(to: result, config: config)
        }

        if let bgImage = config.backgroundImage {
            result = fuseWithBackground(qrImage: result, background: bgImage, alpha: config.backgroundImageAlpha)
        }

        if let watermark = config.watermarkImage {
            result = overlayWatermark(on: result, watermark: watermark)
        }

        if let logo = config.logoImage {
            result = embedLogo(in: result, logo: logo, cornerRadius: config.logoCornerRadius, sizeRatio: config.logoSizeRatio)
        }

        if config.applyBlur {
            result = applyBlurEffect(to: result, radius: config.blurRadius)
        }

        if config.rotation != 0 {
            result = rotateImage(result, degrees: config.rotation)
        }

        if !config.useGradient && config.logoImage == nil && config.backgroundImage == nil {
            cache.setObject(result, forKey: cacheKey)
        }

        return result
    }

    // MARK: - Async Generation

    func generateAsync(config: QRGenerationConfig, completion: @escaping (UIImage?) -> Void) {
        DispatchQueue.global(qos: .userInitiated).async { [weak self] in
            let image = self?.generate(config: config)
            DispatchQueue.main.async {
                completion(image)
            }
        }
    }

    func generateAsync(config: QRGenerationConfig) async -> UIImage? {
        await withCheckedContinuation { continuation in
            generateAsync(config: config) { image in
                continuation.resume(returning: image)
            }
        }
    }

    // MARK: - GIF Generation

    func generateGIF(configs: [QRGenerationConfig], frameDuration: TimeInterval = 0.3) -> Data? {
        let images = configs.compactMap { generate(config: $0) }
        guard !images.isEmpty else { return nil }

        let data = NSMutableData()
        guard let destination = CGImageDestinationCreateWithData(
            data as CFMutableData,
            UTType.gif.identifier as CFString,
            images.count,
            nil
        ) else { return nil }

        let gifProperties: [String: Any] = [
            kCGImagePropertyGIFDictionary as String: [
                kCGImagePropertyGIFLoopCount as String: 0
            ]
        ]
        CGImageDestinationSetProperties(destination, gifProperties as CFDictionary)

        let frameProperties: [String: Any] = [
            kCGImagePropertyGIFDictionary as String: [
                kCGImagePropertyGIFDelayTime as String: frameDuration
            ]
        ]

        for image in images {
            if let cgImage = image.cgImage {
                CGImageDestinationAddImage(destination, cgImage, frameProperties as CFDictionary)
            }
        }

        guard CGImageDestinationFinalize(destination) else { return nil }
        return data as Data
    }

    // MARK: - Private Methods

    private func generateBasicQR(content: String, correctionLevel: QRCorrectionLevel) -> CIImage? {
        guard let data = content.data(using: .utf8) else { return nil }
        let filter = CIFilter.qrCodeGenerator()
        filter.message = data
        filter.correctionLevel = correctionLevel.ciValue
        return filter.outputImage
    }

    private func renderBasic(ciImage: CIImage, size: CGSize, config: QRGenerationConfig) -> UIImage {
        let scaleX = size.width / ciImage.extent.width
        let scaleY = size.height / ciImage.extent.height
        let scaled = ciImage.transformed(by: CGAffineTransform(scaleX: scaleX, y: scaleY))

        let colorFilter = CIFilter.falseColor()
        colorFilter.inputImage = scaled
        colorFilter.color0 = CIColor(color: UIColor(config.foregroundColor))
        colorFilter.color1 = CIColor(color: UIColor(config.backgroundColor))

        guard let outputImage = colorFilter.outputImage,
              let cgImage = context.createCGImage(outputImage, from: outputImage.extent) else {
            return UIImage()
        }

        return UIImage(cgImage: cgImage)
    }

    private func applyDotStyle(to ciImage: CIImage, style: QRDotStyle, size: CGSize, config: QRGenerationConfig) -> UIImage {
        let moduleCount = Int(ciImage.extent.width)
        let moduleSize = size.width / CGFloat(moduleCount)

        let renderer = UIGraphicsImageRenderer(size: size)
        return renderer.image { ctx in
            UIColor(config.backgroundColor).setFill()
            ctx.fill(CGRect(origin: .zero, size: size))

            guard let cgImage = context.createCGImage(ciImage, from: ciImage.extent) else { return }
            let bitmap = UIImage(cgImage: cgImage)

            UIColor(config.foregroundColor).setFill()

            for y in 0..<moduleCount {
                for x in 0..<moduleCount {
                    let pixel = getPixelColor(from: bitmap, x: x, y: y)
                    guard pixel else { continue }

                    let rect = CGRect(
                        x: CGFloat(x) * moduleSize,
                        y: CGFloat(y) * moduleSize,
                        width: moduleSize,
                        height: moduleSize
                    )

                    drawDot(in: rect, style: style, context: ctx.cgContext)
                }
            }
        }
    }

    private func drawDot(in rect: CGRect, style: QRDotStyle, context: CGContext) {
        let inset = rect.insetBy(dx: rect.width * 0.05, dy: rect.height * 0.05)

        switch style {
        case .square:
            context.fill(inset)

        case .roundedRect:
            let path = UIBezierPath(roundedRect: inset, cornerRadius: inset.width * 0.3)
            path.fill()

        case .circle:
            let path = UIBezierPath(ovalIn: inset)
            path.fill()

        case .star:
            drawStar(in: inset, context: context)

        case .heart:
            drawHeart(in: inset, context: context)

        case .diamond:
            let path = UIBezierPath()
            path.move(to: CGPoint(x: inset.midX, y: inset.minY))
            path.addLine(to: CGPoint(x: inset.maxX, y: inset.midY))
            path.addLine(to: CGPoint(x: inset.midX, y: inset.maxY))
            path.addLine(to: CGPoint(x: inset.minX, y: inset.midY))
            path.close()
            path.fill()
        }
    }

    private func drawStar(in rect: CGRect, context: CGContext) {
        let center = CGPoint(x: rect.midX, y: rect.midY)
        let outerRadius = min(rect.width, rect.height) / 2
        let innerRadius = outerRadius * 0.4
        let points = 5

        let path = UIBezierPath()
        for i in 0..<(points * 2) {
            let radius = i % 2 == 0 ? outerRadius : innerRadius
            let angle = CGFloat(i) * .pi / CGFloat(points) - .pi / 2
            let point = CGPoint(
                x: center.x + radius * cos(angle),
                y: center.y + radius * sin(angle)
            )
            if i == 0 { path.move(to: point) }
            else { path.addLine(to: point) }
        }
        path.close()
        path.fill()
    }

    private func drawHeart(in rect: CGRect, context: CGContext) {
        let path = UIBezierPath()
        let w = rect.width
        let h = rect.height

        path.move(to: CGPoint(x: rect.minX + w * 0.5, y: rect.minY + h * 0.85))
        path.addCurve(
            to: CGPoint(x: rect.minX, y: rect.minY + h * 0.3),
            controlPoint1: CGPoint(x: rect.minX + w * 0.1, y: rect.minY + h * 0.7),
            controlPoint2: CGPoint(x: rect.minX, y: rect.minY + h * 0.5)
        )
        path.addArc(
            withCenter: CGPoint(x: rect.minX + w * 0.25, y: rect.minY + h * 0.25),
            radius: w * 0.25,
            startAngle: .pi,
            endAngle: 0,
            clockwise: true
        )
        path.addArc(
            withCenter: CGPoint(x: rect.minX + w * 0.75, y: rect.minY + h * 0.25),
            radius: w * 0.25,
            startAngle: .pi,
            endAngle: 0,
            clockwise: true
        )
        path.addCurve(
            to: CGPoint(x: rect.minX + w * 0.5, y: rect.minY + h * 0.85),
            controlPoint1: CGPoint(x: rect.minX + w, y: rect.minY + h * 0.5),
            controlPoint2: CGPoint(x: rect.minX + w * 0.9, y: rect.minY + h * 0.7)
        )
        path.close()
        path.fill()
    }

    private func getPixelColor(from image: UIImage, x: Int, y: Int) -> Bool {
        guard let cgImage = image.cgImage else { return false }
        let width = cgImage.width
        let height = cgImage.height
        guard x >= 0, x < width, y >= 0, y < height else { return false }

        guard let dataProvider = cgImage.dataProvider,
              let data = dataProvider.data,
              let bytes = CFDataGetBytePtr(data) else { return false }

        let bytesPerPixel = cgImage.bitsPerPixel / 8
        let bytesPerRow = cgImage.bytesPerRow
        let offset = y * bytesPerRow + x * bytesPerPixel

        return bytes[offset] == 0
    }

    private func applyGradient(to image: UIImage, config: QRGenerationConfig) -> UIImage {
        let size = image.size
        let renderer = UIGraphicsImageRenderer(size: size)

        return renderer.image { ctx in
            let rect = CGRect(origin: .zero, size: size)

            let colors = [UIColor(config.gradientStartColor).cgColor, UIColor(config.gradientEndColor).cgColor]
            let colorSpace = CGColorSpaceCreateDeviceRGB()
            guard let gradient = CGGradient(colorsSpace: colorSpace, colors: colors as CFArray, locations: nil) else {
                image.draw(in: rect)
                return
            }

            switch config.gradientDirection {
            case .topToBottom:
                ctx.cgContext.drawLinearGradient(gradient, start: .zero, end: CGPoint(x: 0, y: size.height), options: [])
            case .leftToRight:
                ctx.cgContext.drawLinearGradient(gradient, start: .zero, end: CGPoint(x: size.width, y: 0), options: [])
            case .topLeftToBottomRight:
                ctx.cgContext.drawLinearGradient(gradient, start: .zero, end: CGPoint(x: size.width, y: size.height), options: [])
            case .radial:
                let center = CGPoint(x: size.width / 2, y: size.height / 2)
                ctx.cgContext.drawRadialGradient(gradient, startCenter: center, startRadius: 0, endCenter: center, endRadius: size.width / 2, options: [])
            }

            image.draw(in: rect, blendMode: .destinationIn, alpha: 1.0)
        }
    }

    private func fuseWithBackground(qrImage: UIImage, background: UIImage, alpha: CGFloat) -> UIImage {
        let size = qrImage.size
        let renderer = UIGraphicsImageRenderer(size: size)
        return renderer.image { _ in
            background.draw(in: CGRect(origin: .zero, size: size))
            qrImage.draw(in: CGRect(origin: .zero, size: size), blendMode: .normal, alpha: 1.0 - alpha)
        }
    }

    private func overlayWatermark(on image: UIImage, watermark: UIImage) -> UIImage {
        let size = image.size
        let renderer = UIGraphicsImageRenderer(size: size)
        return renderer.image { _ in
            image.draw(in: CGRect(origin: .zero, size: size))
            watermark.draw(in: CGRect(origin: .zero, size: size), blendMode: .normal, alpha: 0.15)
        }
    }

    private func embedLogo(in image: UIImage, logo: UIImage, cornerRadius: CGFloat, sizeRatio: CGFloat) -> UIImage {
        let size = image.size
        let logoSize = CGSize(width: size.width * sizeRatio, height: size.height * sizeRatio)
        let logoOrigin = CGPoint(x: (size.width - logoSize.width) / 2, y: (size.height - logoSize.height) / 2)
        let logoRect = CGRect(origin: logoOrigin, size: logoSize)

        let renderer = UIGraphicsImageRenderer(size: size)
        return renderer.image { ctx in
            image.draw(in: CGRect(origin: .zero, size: size))

            let bgRect = logoRect.insetBy(dx: -4, dy: -4)
            let bgPath = UIBezierPath(roundedRect: bgRect, cornerRadius: cornerRadius + 2)
            UIColor.white.setFill()
            bgPath.fill()

            let clipPath = UIBezierPath(roundedRect: logoRect, cornerRadius: cornerRadius)
            ctx.cgContext.saveGState()
            clipPath.addClip()
            logo.draw(in: logoRect)
            ctx.cgContext.restoreGState()
        }
    }

    private func applyBlurEffect(to image: UIImage, radius: CGFloat) -> UIImage {
        guard let ciImage = CIImage(image: image) else { return image }
        let filter = CIFilter.gaussianBlur()
        filter.inputImage = ciImage
        filter.radius = Float(radius)
        guard let output = filter.outputImage,
              let cgImage = context.createCGImage(output, from: ciImage.extent) else { return image }
        return UIImage(cgImage: cgImage)
    }

    private func rotateImage(_ image: UIImage, degrees: Double) -> UIImage {
        let radians = degrees * .pi / 180
        let size = image.size
        let newSize = CGSize(
            width: abs(size.width * cos(radians)) + abs(size.height * sin(radians)),
            height: abs(size.width * sin(radians)) + abs(size.height * cos(radians))
        )

        let renderer = UIGraphicsImageRenderer(size: newSize)
        return renderer.image { ctx in
            ctx.cgContext.translateBy(x: newSize.width / 2, y: newSize.height / 2)
            ctx.cgContext.rotate(by: radians)
            image.draw(in: CGRect(x: -size.width / 2, y: -size.height / 2, width: size.width, height: size.height))
        }
    }
}
