import SwiftUI

struct BigTextInput: View {
    @Binding var text: String
    @FocusState private var isFocused: Bool

    var body: some View {
        ZStack(alignment: .topLeading) {
            if text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                Text("Enter text to display", bundle: .main)
                    .font(BigTextTypography.inputText)
                    .foregroundStyle(BigTextColors.textSecondary)
                    .padding(.horizontal, BigTextSpacing.inputPadding)
                    .padding(.vertical, 16)
                    .allowsHitTesting(false)
            }

            TextEditor(text: $text)
                .font(BigTextTypography.inputText)
                .foregroundStyle(BigTextColors.textPrimary)
                .scrollContentBackground(.hidden)
                .background(Color.clear)
                .padding(.horizontal, BigTextSpacing.inputPadding - 8)
                .padding(.vertical, 8)
                .focused($isFocused)
                .onAppear {
                    isFocused = true
                }
        }
        .frame(minHeight: 300)
        .background(BigTextColors.surface)
        .cornerRadius(BigTextSpacing.cornerRadius)
    }
}
