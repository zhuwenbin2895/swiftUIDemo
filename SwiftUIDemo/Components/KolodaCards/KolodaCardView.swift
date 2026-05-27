import SwiftUI

struct KolodaCardView: View {
    let item: KolodaCardItem
    let config: KolodaConfig

    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: config.cornerRadius)
                .fill(item.color.gradient)
                .shadow(color: .black.opacity(0.15), radius: 8, x: 0, y: 4)

            VStack(spacing: 16) {
                if let imageName = item.imageName {
                    Image(systemName: imageName)
                        .font(.system(size: 60))
                        .foregroundStyle(.white.opacity(0.9))
                }

                Text(item.title)
                    .font(.title2.bold())
                    .foregroundStyle(.white)

                Text(item.subtitle)
                    .font(.subheadline)
                    .foregroundStyle(.white.opacity(0.8))
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 20)
            }
        }
        .frame(width: config.cardSize.width, height: config.cardSize.height)
    }
}
