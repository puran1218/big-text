import SwiftUI

struct PrimaryActionButton: View {
    let title: LocalizedStringKey
    let isEnabled: Bool
    let action: () -> Void

    @State private var isPressed = false

    var body: some View {
        Button(action: action) {
            Text(title)
                .font(BigTextTypography.buttonText)
                .foregroundStyle(isEnabled ? .black : BigTextColors.textDisabled)
                .frame(maxWidth: .infinity)
                .frame(height: BigTextSpacing.buttonHeight)
                .background(isEnabled ? .white : BigTextColors.controlBackground)
                .cornerRadius(BigTextSpacing.cornerRadius)
                .scaleEffect(isPressed ? 0.97 : 1.0)
                .animation(.easeInOut(duration: 0.1), value: isPressed)
        }
        .disabled(!isEnabled)
        .buttonStyle(PlainButtonStyle())
        .onLongPressGesture(minimumDuration: 0, pressing: { pressing in
            isPressed = pressing
        }, perform: {})
    }
}
