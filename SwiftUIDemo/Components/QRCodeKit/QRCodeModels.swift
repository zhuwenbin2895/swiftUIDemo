import SwiftUI
import UIKit
import CoreImage

// MARK: - Error Correction Level

enum QRCorrectionLevel: String, CaseIterable, Codable {
    case L, M, Q, H

    var ciValue: String {
        switch self {
        case .L: return "L"
        case .M: return "M"
        case .Q: return "Q"
        case .H: return "H"
        }
    }

    var description: String {
        switch self {
        case .L: return "低 (7%)"
        case .M: return "中 (15%)"
        case .Q: return "较高 (25%)"
        case .H: return "高 (30%)"
        }
    }
}

// MARK: - Dot Style

enum QRDotStyle: String, CaseIterable, Codable {
    case square
    case roundedRect
    case circle
    case star
    case heart
    case diamond

    var displayName: String {
        switch self {
        case .square: return "方形"
        case .roundedRect: return "圆角矩形"
        case .circle: return "圆形"
        case .star: return "星形"
        case .heart: return "心形"
        case .diamond: return "菱形"
        }
    }
}

// MARK: - Gradient Direction

enum QRGradientDirection: String, CaseIterable, Codable {
    case topToBottom
    case leftToRight
    case topLeftToBottomRight
    case radial

    var displayName: String {
        switch self {
        case .topToBottom: return "从上到下"
        case .leftToRight: return "从左到右"
        case .topLeftToBottomRight: return "对角线"
        case .radial: return "径向"
        }
    }
}

// MARK: - Content Type

enum QRContentType: String, CaseIterable, Codable {
    case text
    case url
    case vCard
    case wifi
    case geo
    case email
    case phone

    var displayName: String {
        switch self {
        case .text: return "纯文本"
        case .url: return "URL链接"
        case .vCard: return "名片信息"
        case .wifi: return "WiFi配置"
        case .geo: return "地理位置"
        case .email: return "邮箱"
        case .phone: return "电话"
        }
    }

    var icon: String {
        switch self {
        case .text: return "doc.text"
        case .url: return "link"
        case .vCard: return "person.crop.rectangle"
        case .wifi: return "wifi"
        case .geo: return "location"
        case .email: return "envelope"
        case .phone: return "phone"
        }
    }
}

// MARK: - QR Content Encoder

struct QRContentEncoder {
    static func encode(type: QRContentType, params: [String: String]) -> String {
        switch type {
        case .text:
            return params["text"] ?? ""
        case .url:
            return params["url"] ?? "https://example.com"
        case .vCard:
            let name = params["name"] ?? ""
            let phone = params["phone"] ?? ""
            let email = params["email"] ?? ""
            let org = params["org"] ?? ""
            return """
            BEGIN:VCARD
            VERSION:3.0
            N:\(name)
            TEL:\(phone)
            EMAIL:\(email)
            ORG:\(org)
            END:VCARD
            """
        case .wifi:
            let ssid = params["ssid"] ?? ""
            let password = params["password"] ?? ""
            let encryption = params["encryption"] ?? "WPA"
            return "WIFI:T:\(encryption);S:\(ssid);P:\(password);;"
        case .geo:
            let lat = params["latitude"] ?? "0"
            let lon = params["longitude"] ?? "0"
            return "geo:\(lat),\(lon)"
        case .email:
            let address = params["address"] ?? ""
            let subject = params["subject"] ?? ""
            let body = params["body"] ?? ""
            return "mailto:\(address)?subject=\(subject)&body=\(body)"
        case .phone:
            let number = params["number"] ?? ""
            return "tel:\(number)"
        }
    }
}

// MARK: - QR Generation Config

struct QRGenerationConfig {
    var content: String = "Hello QRCode"
    var size: CGFloat = 300
    var correctionLevel: QRCorrectionLevel = .M
    var foregroundColor: Color = .black
    var backgroundColor: Color = .white
    var dotStyle: QRDotStyle = .square
    var logoImage: UIImage?
    var logoCornerRadius: CGFloat = 8
    var logoSizeRatio: CGFloat = 0.2
    var useGradient: Bool = false
    var gradientStartColor: Color = .blue
    var gradientEndColor: Color = .purple
    var gradientDirection: QRGradientDirection = .topToBottom
    var backgroundImage: UIImage?
    var backgroundImageAlpha: CGFloat = 0.3
    var rotation: Double = 0
    var watermarkImage: UIImage?
    var applyBlur: Bool = false
    var blurRadius: CGFloat = 3
    var smoothEdges: Bool = false
}

// MARK: - QR Recognition Result

struct QRRecognitionResult: Identifiable, Equatable {
    let id = UUID()
    let content: String
    let bounds: CGRect
    let corners: [CGPoint]

    static func == (lhs: QRRecognitionResult, rhs: QRRecognitionResult) -> Bool {
        lhs.id == rhs.id
    }
}

// MARK: - Demo Mock Data

struct QRDemoData: Codable {
    let sections: [QRDemoSection]
}

struct QRDemoSection: Codable, Identifiable {
    var id: String { title }
    let title: String
    let icon: String
    let items: [QRDemoItem]
}

struct QRDemoItem: Codable, Identifiable {
    var id: String { title }
    let title: String
    let subtitle: String
    let type: String
    let params: [String: String]?
}
