import SwiftUI

struct BigTextInput: View {
    @Binding var text: String
    @FocusState private var isFocused: Bool

    private let maxCharacterLimit = 200

    var body: some View {
        VStack(spacing: 0) {
            ZStack(alignment: .topLeading) {
                if text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                    Text("editor.placeholder", bundle: .main)
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
                    .onChange(of: text) { oldValue, newValue in
                        // Prevent typing beyond the character limit
                        if newValue.count > maxCharacterLimit {
                            text = String(newValue.prefix(maxCharacterLimit))
                        }
                    }
            }
            .frame(minHeight: 300)

            // Character count display
            HStack {
                Spacer()
                Text(String(format: String(localized: "editor.characterCount", defaultValue: "%d/200"), characterCount))
                    .font(.caption)
                    .foregroundStyle(characterCount > 180 ? Color.red : BigTextColors.textSecondary)
                    .padding(.horizontal, BigTextSpacing.inputPadding)
                    .padding(.vertical, 8)
            }
        }
        .background(BigTextColors.surface)
        .cornerRadius(BigTextSpacing.cornerRadius)
    }

    private var characterCount: Int {
        text.count
    }
}
