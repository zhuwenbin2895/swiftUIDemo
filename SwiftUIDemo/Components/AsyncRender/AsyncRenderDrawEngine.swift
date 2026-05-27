import Foundation
import UIKit

// MARK: - Draw Command

enum AsyncDrawCommand {
    case text(NSAttributedString, CGRect)
    case image(UIImage, CGRect, CGFloat)
    case roundedRect(CGRect, CGFloat, UIColor)
    case line(CGPoint, CGPoint, UIColor, CGFloat)
    case gradient([UIColor], CGRect, CGPoint, CGPoint)
}

// MARK: - Async Draw Layer

final class AsyncDrawLayer: CALayer {
    var drawCommands: [AsyncDrawCommand] = []
    var asyncRenderedImage: CGImage?
    private var isRendering = false

    override func display() {
        guard !isRendering else { return }
        if let rendered = asyncRenderedImage {
            contents = rendered
            return
        }
        renderAsync()
    }

    func renderAsync() {
        guard !drawCommands.isEmpty else { return }
        isRendering = true

        let commands = drawCommands
        let size = bounds.size
        let scale = UIScreen.main.scale

        AsyncRenderScheduler.shared.performRender {
            AsyncDrawEngine.render(commands: commands, size: size, scale: scale)
        } completion: { [weak self] image in
            self?.asyncRenderedImage = image
            self?.contents = image
            self?.isRendering = false
        }
    }

    func invalidateRender() {
        asyncRenderedImage = nil
        setNeedsDisplay()
    }
}

// MARK: - Draw Engine

final class AsyncDrawEngine {
    static func render(commands: [AsyncDrawCommand], size: CGSize, scale: CGFloat) -> CGImage? {
        guard size.width > 0, size.height > 0 else { return nil }

        let colorSpace = CGColorSpaceCreateDeviceRGB()
        let bitmapInfo = CGBitmapInfo(rawValue: CGImageAlphaInfo.premultipliedFirst.rawValue | CGBitmapInfo.byteOrder32Little.rawValue)

        guard let context = CGContext(
            data: nil,
            width: Int(size.width * scale),
            height: Int(size.height * scale),
            bitsPerComponent: 8,
            bytesPerRow: 0,
            space: colorSpace,
            bitmapInfo: bitmapInfo.rawValue
        ) else { return nil }

        context.scaleBy(x: scale, y: scale)
        context.translateBy(x: 0, y: size.height)
        context.scaleBy(x: 1, y: -1)

        for command in commands {
            draw(command: command, in: context)
        }

        return context.makeImage()
    }

    private static func draw(command: AsyncDrawCommand, in context: CGContext) {
        switch command {
        case .text(let attrString, let rect):
            drawText(attrString, in: rect, context: context)
        case .image(let image, let rect, let cornerRadius):
            drawImage(image, in: rect, cornerRadius: cornerRadius, context: context)
        case .roundedRect(let rect, let cornerRadius, let color):
            drawRoundedRect(rect, cornerRadius: cornerRadius, color: color, context: context)
        case .line(let from, let to, let color, let width):
            drawLine(from: from, to: to, color: color, width: width, context: context)
        case .gradient(let colors, let rect, let start, let end):
            drawGradient(colors: colors, in: rect, start: start, end: end, context: context)
        }
    }

    private static func drawText(_ attrString: NSAttributedString, in rect: CGRect, context: CGContext) {
        context.saveGState()
        context.translateBy(x: 0, y: rect.origin.y + rect.height)
        context.scaleBy(x: 1, y: -1)
        let adjustedRect = CGRect(x: rect.origin.x, y: 0, width: rect.width, height: rect.height)
        let framesetter = CTFramesetterCreateWithAttributedString(attrString)
        let path = CGPath(rect: adjustedRect, transform: nil)
        let frame = CTFramesetterCreateFrame(framesetter, CFRange(location: 0, length: 0), path, nil)
        CTFrameDraw(frame, context)
        context.restoreGState()
    }

    private static func drawImage(_ image: UIImage, in rect: CGRect, cornerRadius: CGFloat, context: CGContext) {
        guard let cgImage = image.cgImage else { return }
        context.saveGState()
        if cornerRadius > 0 {
            let path = UIBezierPath(roundedRect: rect, cornerRadius: cornerRadius)
            context.addPath(path.cgPath)
            context.clip()
        }
        context.draw(cgImage, in: rect)
        context.restoreGState()
    }

    private static func drawRoundedRect(_ rect: CGRect, cornerRadius: CGFloat, color: UIColor, context: CGContext) {
        context.saveGState()
        context.setFillColor(color.cgColor)
        let path = UIBezierPath(roundedRect: rect, cornerRadius: cornerRadius)
        context.addPath(path.cgPath)
        context.fillPath()
        context.restoreGState()
    }

    private static func drawLine(from: CGPoint, to: CGPoint, color: UIColor, width: CGFloat, context: CGContext) {
        context.saveGState()
        context.setStrokeColor(color.cgColor)
        context.setLineWidth(width)
        context.move(to: from)
        context.addLine(to: to)
        context.strokePath()
        context.restoreGState()
    }

    private static func drawGradient(colors: [UIColor], in rect: CGRect, start: CGPoint, end: CGPoint, context: CGContext) {
        context.saveGState()
        context.clip(to: rect)
        let cgColors = colors.map { $0.cgColor } as CFArray
        guard let gradient = CGGradient(colorsSpace: CGColorSpaceCreateDeviceRGB(), colors: cgColors, locations: nil) else {
            context.restoreGState()
            return
        }
        let startPoint = CGPoint(x: rect.origin.x + start.x * rect.width, y: rect.origin.y + start.y * rect.height)
        let endPoint = CGPoint(x: rect.origin.x + end.x * rect.width, y: rect.origin.y + end.y * rect.height)
        context.drawLinearGradient(gradient, start: startPoint, end: endPoint, options: [])
        context.restoreGState()
    }
}

// MARK: - Async Image Decoder

final class AsyncImageDecoder {
    static func decode(data: Data, completion: @escaping (UIImage?) -> Void) {
        AsyncRenderScheduler.shared.performImageProcess {
            guard let image = UIImage(data: data) else { return nil }
            return forceDecodeImage(image)
        } completion: { result in
            completion(result)
        }
    }

    static func decode(image: UIImage, completion: @escaping (UIImage?) -> Void) {
        AsyncRenderScheduler.shared.performImageProcess {
            forceDecodeImage(image)
        } completion: { result in
            completion(result)
        }
    }

    private static func forceDecodeImage(_ image: UIImage) -> UIImage? {
        guard let cgImage = image.cgImage else { return nil }
        let width = cgImage.width
        let height = cgImage.height
        let colorSpace = CGColorSpaceCreateDeviceRGB()
        let bitmapInfo = CGBitmapInfo(rawValue: CGImageAlphaInfo.premultipliedFirst.rawValue | CGBitmapInfo.byteOrder32Little.rawValue)

        guard let context = CGContext(
            data: nil,
            width: width,
            height: height,
            bitsPerComponent: 8,
            bytesPerRow: width * 4,
            space: colorSpace,
            bitmapInfo: bitmapInfo.rawValue
        ) else { return nil }

        context.draw(cgImage, in: CGRect(x: 0, y: 0, width: width, height: height))
        guard let decodedImage = context.makeImage() else { return nil }
        return UIImage(cgImage: decodedImage, scale: image.scale, orientation: image.imageOrientation)
    }
}

// MARK: - Composite Layer Renderer

final class CompositeLayerRenderer {
    struct LayerContent {
        let image: CGImage?
        let frame: CGRect
        let opacity: CGFloat
    }

    static func composeLayers(_ layers: [LayerContent], size: CGSize, scale: CGFloat, completion: @escaping (CGImage?) -> Void) {
        AsyncRenderScheduler.shared.performRender {
            guard size.width > 0, size.height > 0 else { return nil }

            let colorSpace = CGColorSpaceCreateDeviceRGB()
            let bitmapInfo = CGBitmapInfo(rawValue: CGImageAlphaInfo.premultipliedFirst.rawValue | CGBitmapInfo.byteOrder32Little.rawValue)

            guard let context = CGContext(
                data: nil,
                width: Int(size.width * scale),
                height: Int(size.height * scale),
                bitsPerComponent: 8,
                bytesPerRow: 0,
                space: colorSpace,
                bitmapInfo: bitmapInfo.rawValue
            ) else { return nil }

            context.scaleBy(x: scale, y: scale)

            for layer in layers {
                guard let image = layer.image else { continue }
                context.saveGState()
                context.setAlpha(layer.opacity)
                context.draw(image, in: layer.frame)
                context.restoreGState()
            }

            return context.makeImage()
        } completion: { image in
            completion(image)
        }
    }
}
