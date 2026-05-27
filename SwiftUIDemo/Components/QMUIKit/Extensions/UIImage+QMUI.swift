import UIKit

extension UIImage {

    // MARK: - Generate Image from Color

    static func qmui_image(color: UIColor, size: CGSize = CGSize(width: 1, height: 1)) -> UIImage? {
        let rect = CGRect(origin: .zero, size: size)
        UIGraphicsBeginImageContextWithOptions(size, false, 0)
        defer { UIGraphicsEndImageContext() }
        color.setFill()
        UIRectFill(rect)
        return UIGraphicsGetImageFromCurrentImageContext()
    }

    // MARK: - Async Corner Radius

    func qmui_asyncCornerRadius(_ radius: CGFloat, size: CGSize, completion: @escaping (UIImage?) -> Void) {
        DispatchQueue.global(qos: .userInitiated).async {
            let rect = CGRect(origin: .zero, size: size)
            UIGraphicsBeginImageContextWithOptions(size, false, UIScreen.main.scale)
            defer { UIGraphicsEndImageContext() }

            let path = UIBezierPath(roundedRect: rect, cornerRadius: radius)
            path.addClip()
            self.draw(in: rect)

            let result = UIGraphicsGetImageFromCurrentImageContext()
            DispatchQueue.main.async {
                completion(result)
            }
        }
    }

    // MARK: - Tint Color

    func qmui_tintImage(color: UIColor) -> UIImage? {
        UIGraphicsBeginImageContextWithOptions(size, false, scale)
        defer { UIGraphicsEndImageContext() }

        let rect = CGRect(origin: .zero, size: size)
        color.set()
        UIRectFill(rect)
        draw(in: rect, blendMode: .destinationIn, alpha: 1.0)

        return UIGraphicsGetImageFromCurrentImageContext()
    }

    // MARK: - Compress to Size

    func qmui_compress(toMaxBytes maxBytes: Int) -> Data? {
        var compression: CGFloat = 1.0
        var data = jpegData(compressionQuality: compression)

        while let d = data, d.count > maxBytes, compression > 0.05 {
            compression -= 0.1
            data = jpegData(compressionQuality: compression)
        }

        if let d = data, d.count <= maxBytes {
            return d
        }

        // Scale down if still too large
        var scale: CGFloat = 0.9
        var scaledImage = self
        while let d = scaledImage.jpegData(compressionQuality: 0.5), d.count > maxBytes, scale > 0.1 {
            let newSize = CGSize(width: size.width * scale, height: size.height * scale)
            UIGraphicsBeginImageContextWithOptions(newSize, false, self.scale)
            scaledImage.draw(in: CGRect(origin: .zero, size: newSize))
            scaledImage = UIGraphicsGetImageFromCurrentImageContext() ?? self
            UIGraphicsEndImageContext()
            scale -= 0.1
        }

        return scaledImage.jpegData(compressionQuality: 0.5)
    }

    // MARK: - Stretchable Image

    func qmui_stretchableImage() -> UIImage {
        let centerX = size.width / 2.0
        let centerY = size.height / 2.0
        return stretchableImage(
            withLeftCapWidth: Int(centerX),
            topCapHeight: Int(centerY)
        )
    }

    func qmui_resizableImage(capInsets: UIEdgeInsets) -> UIImage {
        resizableImage(withCapInsets: capInsets, resizingMode: .stretch)
    }
}
