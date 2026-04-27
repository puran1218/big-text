import SwiftUI

struct DisplayHintToast: View {
    let message: LocalizedStringKey
    let isVisible: Bool

    var body: some View {
        if isVisible {
            Text(message)
                .font(BigTextTypography.hintText)
                .foregroundStyle(BigTextColors.textPrimary)
                .padding(.horizontal, BigTextSpacing.overlayPadding)
                .padding(.vertical, 10)
                .background(BigTextColors.controlBackground)
                .cornerRadius(20)
                .transition(.opacity)
        }
    }
}
