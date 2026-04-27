import SwiftUI

struct EditorView: View {
    @Binding var text: String
    let onShow: () -> Void

    @Environment(\.locale) private var locale

    private var isTextEmpty: Bool {
        text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }

    private var isChineseLanguage: Bool {
        locale.language.languageCode?.identifier == "zh"
    }

    private var mainTitle: String {
        isChineseLanguage ? "大字" : "Big Text"
    }

    private var subtitle: String {
        isChineseLanguage ? "Big Text" : "大字"
    }

    var body: some View {
        VStack(spacing: BigTextSpacing.pagePadding) {
            // App Title Area
            VStack(alignment: .leading, spacing: 4) {
                // Main title
                Text(mainTitle)
                    .font(BigTextTypography.appTitle)
                    .foregroundStyle(BigTextColors.textPrimary)

                // Subtitle (other language)
                Text(subtitle)
                    .font(.system(size: 18, weight: .medium, design: .rounded))
                    .foregroundStyle(BigTextColors.textSecondary)

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
