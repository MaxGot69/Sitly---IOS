import SwiftUI

struct FilterButton: View {
    let title: String
    var isActive: Bool = false
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.system(size: 14, weight: .medium))
                .foregroundColor(isActive ? .white : .white.opacity(0.7))
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
                .background(
                    isActive ? Color.green.opacity(0.6) : Color.white.opacity(0.15)
                )
                .cornerRadius(20)
        }
    }
}

