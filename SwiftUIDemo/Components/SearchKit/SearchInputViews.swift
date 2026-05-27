import SwiftUI
import Combine
import Speech

// MARK: - 搜索输入框

struct SearchInputView: View {
    @Binding var text: String
    var placeholder: String = "搜索..."
    var onSubmit: ((String) -> Void)?
    var onClear: (() -> Void)?
    @State private var isVoiceActive = false
    @StateObject private var voiceManager = VoiceInputManager()

    var body: some View {
        HStack(spacing: 8) {
            Image(systemName: "magnifyingglass")
                .foregroundColor(.secondary)

            TextField(placeholder, text: $text)
                .textFieldStyle(.plain)
                .autocorrectionDisabled()
                .onSubmit {
                    onSubmit?(text)
                }

            if !text.isEmpty {
                Button {
                    text = ""
                    onClear?()
                } label: {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundColor(.secondary)
                }
            }

            Button {
                if voiceManager.isRecording {
                    voiceManager.stopRecording()
                } else {
                    voiceManager.startRecording { result in
                        text = result
                        onSubmit?(result)
                    }
                }
                isVoiceActive = voiceManager.isRecording
            } label: {
                Image(systemName: voiceManager.isRecording ? "mic.fill" : "mic")
                    .foregroundColor(voiceManager.isRecording ? .red : .secondary)
            }
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 10)
        .background(Color(uiColor: .systemGray6))
        .cornerRadius(10)
    }
}

// MARK: - 搜索历史视图

struct SearchHistoryView: View {
    @ObservedObject var historyManager: SearchHistoryManager
    var onSelect: (String) -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text("搜索历史")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                Spacer()
                Button("清除") {
                    historyManager.clearHistory()
                }
                .font(.caption)
            }

            FlowLayout(spacing: 8) {
                ForEach(historyManager.history, id: \.self) { item in
                    Button {
                        onSelect(item)
                    } label: {
                        Text(item)
                            .font(.callout)
                            .padding(.horizontal, 12)
                            .padding(.vertical, 6)
                            .background(Color(.systemGray5))
                            .cornerRadius(16)
                            .foregroundColor(.primary)
                    }
                }
            }
        }
        .padding(.horizontal)
    }
}

// MARK: - 搜索建议视图

struct SearchSuggestionsView: View {
    let suggestions: [String]
    let query: String
    var onSelect: (String) -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            ForEach(suggestions, id: \.self) { suggestion in
                Button {
                    onSelect(suggestion)
                } label: {
                    HStack {
                        Image(systemName: "magnifyingglass")
                            .foregroundColor(.secondary)
                            .font(.caption)
                        HighlightedText(text: suggestion, highlight: query)
                        Spacer()
                        Image(systemName: "arrow.up.left")
                            .foregroundColor(.secondary)
                            .font(.caption)
                    }
                    .padding(.horizontal, 16)
                    .padding(.vertical, 10)
                }
                Divider().padding(.leading, 40)
            }
        }
        .background(Color(uiColor: .systemBackground))
    }
}

// MARK: - 关键词高亮文本

struct HighlightedText: View {
    let text: String
    let highlight: String

    var body: some View {
        if highlight.isEmpty {
            Text(text)
                .foregroundColor(.primary)
        } else {
            buildHighlightedText()
        }
    }

    private func buildHighlightedText() -> Text {
        let loweredText = text.lowercased()
        let loweredHighlight = highlight.lowercased()

        guard let range = loweredText.range(of: loweredHighlight) else {
            return Text(text).foregroundColor(.primary)
        }

        let before = String(text[text.startIndex..<range.lowerBound])
        let match = String(text[range.lowerBound..<range.upperBound])
        let after = String(text[range.upperBound..<text.endIndex])

        return Text("\(Text(before).foregroundColor(.primary))\(Text(match).foregroundColor(.blue).bold())\(Text(after).foregroundColor(.primary))")
    }
}

// MARK: - FlowLayout

struct FlowLayout: Layout {
    var spacing: CGFloat = 8

    func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) -> CGSize {
        let result = layout(in: proposal.width ?? 0, subviews: subviews)
        return result.size
    }

    func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) {
        let result = layout(in: bounds.width, subviews: subviews)
        for (index, position) in result.positions.enumerated() {
            subviews[index].place(at: CGPoint(x: bounds.minX + position.x, y: bounds.minY + position.y), proposal: .unspecified)
        }
    }

    private func layout(in width: CGFloat, subviews: Subviews) -> (size: CGSize, positions: [CGPoint]) {
        var positions: [CGPoint] = []
        var x: CGFloat = 0
        var y: CGFloat = 0
        var maxHeight: CGFloat = 0
        var totalHeight: CGFloat = 0

        for subview in subviews {
            let size = subview.sizeThatFits(.unspecified)
            if x + size.width > width && x > 0 {
                x = 0
                y += maxHeight + spacing
                maxHeight = 0
            }
            positions.append(CGPoint(x: x, y: y))
            x += size.width + spacing
            maxHeight = max(maxHeight, size.height)
            totalHeight = y + maxHeight
        }

        return (CGSize(width: width, height: totalHeight), positions)
    }
}

// MARK: - 语音输入管理器

class VoiceInputManager: ObservableObject {
    @Published var isRecording = false
    @Published var transcription = ""

    private var audioEngine: AVAudioEngine?
    private var recognitionTask: SFSpeechRecognitionTask?
    private var recognitionRequest: SFSpeechAudioBufferRecognitionRequest?
    private var completion: ((String) -> Void)?

    func startRecording(completion: @escaping (String) -> Void) {
        self.completion = completion

        SFSpeechRecognizer.requestAuthorization { [weak self] status in
            DispatchQueue.main.async {
                guard status == .authorized else { return }
                self?.beginRecording()
            }
        }
    }

    private func beginRecording() {
        let audioEngine = AVAudioEngine()
        self.audioEngine = audioEngine

        let recognizer = SFSpeechRecognizer(locale: Locale(identifier: "zh-CN"))
        let request = SFSpeechAudioBufferRecognitionRequest()
        self.recognitionRequest = request

        let inputNode = audioEngine.inputNode
        let format = inputNode.outputFormat(forBus: 0)

        inputNode.installTap(onBus: 0, bufferSize: 1024, format: format) { buffer, _ in
            request.append(buffer)
        }

        recognitionTask = recognizer?.recognitionTask(with: request) { [weak self] result, error in
            if let result = result {
                DispatchQueue.main.async {
                    self?.transcription = result.bestTranscription.formattedString
                }
            }
            if error != nil || result?.isFinal == true {
                DispatchQueue.main.async {
                    self?.stopRecording()
                }
            }
        }

        do {
            try audioEngine.start()
            isRecording = true
        } catch {
            stopRecording()
        }
    }

    func stopRecording() {
        audioEngine?.stop()
        audioEngine?.inputNode.removeTap(onBus: 0)
        recognitionRequest?.endAudio()
        recognitionTask?.cancel()
        isRecording = false

        if !transcription.isEmpty {
            completion?(transcription)
        }
        transcription = ""
    }
}
