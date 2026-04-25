import SwiftUI

struct AutoFitTextView: View {
    let text: String

    var body: some View {
        GeometryReader { geometry in
            Text(text)
                .font(.system(size: 320, weight: .black))
                .foregroundStyle(BigTextColors.textPrimary)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .minimumScaleFactor(0.1)
                .lineLimit(5)
                .multilineTextAlignment(.center)
                .padding(geometry.size.width * 0.1)
        }
    }
}
