import SwiftUI

/// In-app logo mark. For the Home Screen icon, drag a 1024×1024 PNG into Xcode → Assets → App Icon.
struct AppLogoMark: View {
    var size: CGFloat = 88

    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: size * 0.22, style: .continuous)
                .fill(
                    LinearGradient(
                        colors: [Color(red: 0.3, green: 0.75, blue: 0.95), Color(red: 0.15, green: 0.45, blue: 0.95)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
            Image(systemName: "shippingbox.fill")
                .font(.system(size: size * 0.42, weight: .medium))
                .foregroundStyle(.white)
            Image(systemName: "scalemass.fill")
                .font(.system(size: size * 0.24, weight: .semibold))
                .foregroundStyle(.yellow.opacity(0.95))
                .offset(x: size * 0.18, y: -size * 0.16)
        }
        .frame(width: size, height: size)
        .shadow(color: .black.opacity(0.18), radius: size * 0.08, y: size * 0.04)
    }
}

#Preview {
    AppLogoMark()
        .padding()
}
