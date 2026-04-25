import SwiftUI

struct EditorView: View {
    @Binding var text: String
    let onShow: () -> Void

    private var isTextEmpty: Bool {
        text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }

    var body: some View {
        VStack(spacing: BigTextSpacing.pagePadding) {
            // App Title
            Text("Big Text", bundle: .main)
                .font(BigTextTypography.appTitle)
                .foregroundStyle(BigTextColors.textPrimary)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.top, BigTextSpacing.pagePadding)

            Spacer()

            // Input Area
            BigTextInput(text: $text)

            Spacer()

            // Show Button
            PrimaryActionButton(
                title: "Show",
                isEnabled: !isTextEmpty,
                action: onShow
            )
            .padding(.bottom, BigTextSpacing.pagePadding)
        }
        .padding(.horizontal, BigTextSpacing.pagePadding)
        .background(BigTextColors.appBackground)
    }
}
