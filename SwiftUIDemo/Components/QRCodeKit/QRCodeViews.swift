import SwiftUI
import AVFoundation

// MARK: - Camera Preview View

struct CameraPreviewView: UIViewRepresentable {
    let session: AVCaptureSession

    func makeUIView(context: Context) -> UIView {
        let view = UIView(frame: .zero)
        let previewLayer = AVCaptureVideoPreviewLayer(session: session)
        previewLayer.videoGravity = .resizeAspectFill
        view.layer.addSublayer(previewLayer)
        context.coordinator.previewLayer = previewLayer
        return view
    }

    func updateUIView(_ uiView: UIView, context: Context) {
        context.coordinator.previewLayer?.frame = uiView.bounds
    }

    func makeCoordinator() -> Coordinator { Coordinator() }

    class Coordinator {
        var previewLayer: AVCaptureVideoPreviewLayer?
    }
}

// MARK: - Camera Scanner View

struct QRCameraScannerView: View {
    @StateObject private var scanner = QRCameraScanner()
    @Environment(\.dismiss) private var dismiss
    @State private var results: [QRRecognitionResult] = []

    var body: some View {
        ZStack {
            CameraPreviewView(session: scanner.captureSession)
                .ignoresSafeArea()

            VStack {
                Spacer()

                RoundedRectangle(cornerRadius: 12)
                    .stroke(Color.green, lineWidth: 3)
                    .frame(width: 250, height: 250)
                    .overlay(
                        VStack {
                            HStack {
                                cornerMark(rotation: 0)
                                Spacer()
                                cornerMark(rotation: 90)
                            }
                            Spacer()
                            HStack {
                                cornerMark(rotation: 270)
                                Spacer()
                                cornerMark(rotation: 180)
                            }
                        }
                        .padding(4)
                    )

                Spacer()

                if !results.isEmpty {
                    VStack(spacing: 8) {
                        ForEach(results) { result in
                            Text(result.content)
                                .font(.caption)
                                .padding(8)
                                .background(.ultraThinMaterial)
                                .cornerRadius(8)
                        }
                    }
                    .padding()
                }

                Button("关闭") {
                    scanner.stopScanning()
                    dismiss()
                }
                .buttonStyle(.borderedProminent)
                .padding(.bottom, 40)
            }
        }
        .onAppear {
            scanner.setupSession()
            scanner.startScanning()
        }
        .onDisappear {
            scanner.stopScanning()
        }
        .onChange(of: scanner.scannedResults) { _, newValue in
            results = newValue
        }
    }

    private func cornerMark(rotation: Double) -> some View {
        Image(systemName: "viewfinder")
            .font(.title2)
            .foregroundColor(.green)
            .rotationEffect(.degrees(rotation))
    }
}

// MARK: - Image Picker for Recognition

struct QRImagePickerView: UIViewControllerRepresentable {
    @Binding var selectedImage: UIImage?
    @Environment(\.dismiss) private var dismiss

    func makeUIViewController(context: Context) -> UIImagePickerController {
        let picker = UIImagePickerController()
        picker.sourceType = .photoLibrary
        picker.delegate = context.coordinator
        return picker
    }

    func updateUIViewController(_ uiViewController: UIImagePickerController, context: Context) {}

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    class Coordinator: NSObject, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
        let parent: QRImagePickerView

        init(_ parent: QRImagePickerView) {
            self.parent = parent
        }

        func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]) {
            parent.selectedImage = info[.originalImage] as? UIImage
            parent.dismiss()
        }

        func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
            parent.dismiss()
        }
    }
}
