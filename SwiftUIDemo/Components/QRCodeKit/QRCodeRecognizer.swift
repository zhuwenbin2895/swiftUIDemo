import UIKit
import AVFoundation
import Vision
import Combine

// MARK: - QR Code Recognizer

final class QRCodeRecognizer: NSObject {

    // MARK: - Static Image Recognition

    static func recognize(from image: UIImage, region: CGRect? = nil) -> [QRRecognitionResult] {
        guard let ciImage = CIImage(image: image) else { return [] }

        let detector = CIDetector(
            ofType: CIDetectorTypeQRCode,
            context: nil,
            options: [CIDetectorAccuracy: CIDetectorAccuracyHigh]
        )

        var features = detector?.features(in: ciImage) ?? []

        if let region = region {
            let imageSize = ciImage.extent.size
            let cropRect = CGRect(
                x: region.origin.x * imageSize.width,
                y: region.origin.y * imageSize.height,
                width: region.size.width * imageSize.width,
                height: region.size.height * imageSize.height
            )
            features = features.filter { cropRect.intersects($0.bounds) }
        }

        return features.compactMap { feature -> QRRecognitionResult? in
            guard let qrFeature = feature as? CIQRCodeFeature,
                  let message = qrFeature.messageString else { return nil }

            let imageSize = ciImage.extent.size
            let normalizedBounds = CGRect(
                x: qrFeature.bounds.origin.x / imageSize.width,
                y: qrFeature.bounds.origin.y / imageSize.height,
                width: qrFeature.bounds.width / imageSize.width,
                height: qrFeature.bounds.height / imageSize.height
            )

            let corners = [
                qrFeature.topLeft,
                qrFeature.topRight,
                qrFeature.bottomRight,
                qrFeature.bottomLeft
            ].map { CGPoint(x: $0.x / imageSize.width, y: $0.y / imageSize.height) }

            return QRRecognitionResult(content: message, bounds: normalizedBounds, corners: corners)
        }
    }

    // MARK: - Batch Recognition

    static func batchRecognize(images: [UIImage]) async -> [[QRRecognitionResult]] {
        await withTaskGroup(of: (Int, [QRRecognitionResult]).self) { group in
            for (index, image) in images.enumerated() {
                group.addTask {
                    let results = recognize(from: image)
                    return (index, results)
                }
            }

            var allResults = Array(repeating: [QRRecognitionResult](), count: images.count)
            for await (index, results) in group {
                allResults[index] = results
            }
            return allResults
        }
    }
}

// MARK: - Camera Scanner Delegate

protocol QRCameraScannerDelegate: AnyObject {
    func didDetectQRCodes(_ results: [QRRecognitionResult])
}

// MARK: - Camera Scanner

final class QRCameraScanner: ObservableObject {
    let objectWillChange = ObservableObjectPublisher()

    var scannedResults: [QRRecognitionResult] = [] {
        willSet { objectWillChange.send() }
    }
    var isScanning = false {
        willSet { objectWillChange.send() }
    }

    let captureSession = AVCaptureSession()
    private let metadataOutput = AVCaptureMetadataOutput()
    private var metadataDelegate: MetadataDelegate?
    weak var delegate: QRCameraScannerDelegate?
    var scanRegion: CGRect?

    func setupSession() {
        guard let device = AVCaptureDevice.default(for: .video),
              let input = try? AVCaptureDeviceInput(device: device) else { return }

        if captureSession.canAddInput(input) {
            captureSession.addInput(input)
        }

        if captureSession.canAddOutput(metadataOutput) {
            captureSession.addOutput(metadataOutput)
            let metadataDelegate = MetadataDelegate { [weak self] results in
                self?.scannedResults = results
                self?.delegate?.didDetectQRCodes(results)
            }
            self.metadataDelegate = metadataDelegate
            metadataOutput.setMetadataObjectsDelegate(metadataDelegate, queue: DispatchQueue.main)
            metadataOutput.metadataObjectTypes = [.qr]
        }

        if let region = scanRegion {
            metadataOutput.rectOfInterest = region
        }
    }

    func startScanning() {
        DispatchQueue.global(qos: .userInitiated).async { [weak self] in
            self?.captureSession.startRunning()
            DispatchQueue.main.async {
                self?.isScanning = true
            }
        }
    }

    func stopScanning() {
        captureSession.stopRunning()
        isScanning = false
    }

    func setScanRegion(_ rect: CGRect) {
        scanRegion = rect
        metadataOutput.rectOfInterest = rect
    }
}

// MARK: - Metadata Delegate

private class MetadataDelegate: NSObject, AVCaptureMetadataOutputObjectsDelegate {
    let onResults: ([QRRecognitionResult]) -> Void

    init(onResults: @escaping ([QRRecognitionResult]) -> Void) {
        self.onResults = onResults
    }

    func metadataOutput(_ output: AVCaptureMetadataOutput, didOutput metadataObjects: [AVMetadataObject], from connection: AVCaptureConnection) {
        let results = metadataObjects.compactMap { object -> QRRecognitionResult? in
            guard let readable = object as? AVMetadataMachineReadableCodeObject,
                  readable.type == .qr,
                  let content = readable.stringValue else { return nil }

            let bounds = readable.bounds
            let corners = readable.corners.map { $0 }

            return QRRecognitionResult(content: content, bounds: bounds, corners: corners)
        }

        onResults(results)
    }
}
