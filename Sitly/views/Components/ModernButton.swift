import SwiftUI

struct ModernButton: View {
    let title: String
    let icon: String?
    let action: () -> Void
    let style: ModernButtonStyle
    
    init(
        title: String,
        icon: String? = nil,
        style: ModernButtonStyle = .primary,
        action: @escaping () -> Void
    ) {
        self.title = title
        self.icon = icon
        self.style = style
        self.action = action
    }
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 8) {
                if let icon = icon {
                    Image(systemName: icon)
                        .font(.system(size: 16, weight: .semibold))
                }
                
                Text(title)
                    .font(.system(size: 16, weight: .semibold, design: .rounded))
            }
            .foregroundColor(style.textColor)
            .frame(maxWidth: .infinity)
            .frame(height: style.height)
            .background(style.background)
            .cornerRadius(style.cornerRadius)
            .overlay(
                RoundedRectangle(cornerRadius: style.cornerRadius)
                    .stroke(style.borderColor, lineWidth: style.borderWidth)
            )
        }
        .buttonStyle(PlainButtonStyle())
    }
}

// MARK: - Button Styles

enum ModernButtonStyle {
    case primary
    case secondary
    case destructive
    case outline
    
    var background: some ShapeStyle {
        switch self {
        case .primary:
            AnyShapeStyle(LinearGradient(
                colors: [.mint, .green],
                startPoint: .leading,
                endPoint: .trailing
            ))
        case .secondary:
            AnyShapeStyle(Color.clear)
        case .destructive:
            AnyShapeStyle(LinearGradient(
                colors: [.red, .red.opacity(0.8)],
                startPoint: .leading,
                endPoint: .trailing
            ))
        case .outline:
            AnyShapeStyle(Color.clear)
        }
    }
    
    var textColor: Color {
        switch self {
        case .primary, .destructive:
            return .white
        case .secondary, .outline:
            return .white
        }
    }
    
    var borderColor: Color {
        switch self {
        case .primary, .secondary, .destructive:
            return .clear
        case .outline:
            return .white.opacity(0.2)
        }
    }
    
    var borderWidth: CGFloat {
        switch self {
        case .outline:
            return 1
        default:
            return 0
        }
    }
    
    var height: CGFloat {
        switch self {
        case .primary, .destructive:
            return 56
        case .secondary, .outline:
            return 44
        }
    }
    
    var cornerRadius: CGFloat {
        switch self {
        case .primary, .destructive:
            return 16
        case .secondary, .outline:
            return 12
        }
    }
}

// MARK: - Preview

#Preview {
    VStack(spacing: 20) {
        ModernButton(title: "Primary Button", icon: "checkmark", style: .primary) {
            print("Primary tapped")
        }
        
        ModernButton(title: "Secondary Button", style: .secondary) {
            print("Secondary tapped")
        }
        
        ModernButton(title: "Destructive Button", style: .destructive) {
            print("Destructive tapped")
        }
        
        ModernButton(title: "Outline Button", style: .outline) {
            print("Outline tapped")
        }
    }
    .padding()
    .background(Color.black)
} 