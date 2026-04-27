import SwiftUI

struct BackControlOverlay: View {
    let isVisible: Bool
    let onBack: () -> Void

    var body: some View {
        if isVisible {
            VStack {
                HStack {
                    Button(action: onBack) {
                        HStack(spacing: 6) {
                            Image(systemName: "chevron.left")
                            Text("display.backButton", bundle: .main)
                        }
                        .font(BigTextTypography.hintText)
                        .foregroundStyle(BigTextColors.textPrimary)
                        .padding(.horizontal, 16)
                        .padding(.vertical, 10)
                        .background(BigTextColors.controlBackground)
                        .cornerRadius(20)
                    }
                    .padding(.leading, BigTextSpacing.pagePadding)
                    .padding(.top, BigTextSpacing.pagePadding)

                    Spacer()
                }

                Spacer()
            }
            .transition(.opacity)
        }
    }
}
