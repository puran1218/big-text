import SwiftUI

struct EditorView: View {
    @Binding var text: String
    let onShow: () -> Void

    @Environment(\.locale) private var locale

    private var isTextEmpty: Bool {
        text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }

    private var appTitle: String {
        locale.language.languageCode?.identifier == "zh" ? "大字" : "Big Text"
    }

    var body: some View {
        VStack(spacing: BigTextSpacing.pagePadding) {
            // App Title Area
            VStack(alignment: .leading, spacing: 4) {
                // Title
                Text(appTitle)
                    .font(BigTextTypography.appTitle)
                    .foregroundStyle(BigTextColors.textPrimary)

                // Tagline
                Text("app.subtitle", bundle: .main)
                    .font(BigTextTypography.hintText)
                    .foregroundStyle(BigTextColors.textSecondary)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.top, BigTextSpacing.pagePadding)

            Spacer()

            // Input Area
            BigTextInput(text: $text)

            Spacer()

            // Show Button
            PrimaryActionButton(
                title: "editor.showButton",
                isEnabled: !isTextEmpty,
                action: onShow
            )
            .padding(.bottom, BigTextSpacing.pagePadding)
        }
        .padding(.horizontal, BigTextSpacing.pagePadding)
        .background(BigTextColors.appBackground)
    }
}
