import SwiftUI

// MARK: - Field Enum

enum Field: Hashable {
    case smallStart, smallEnd, largeStart, largeEnd, notes
}

// MARK: - MarsReadingField View

struct MarsReadingField: View {
    var title: String
    @Binding var text: String
    var focusField: FocusState<Field?>.Binding
    var field: Field
    
    var body: some View {
        VStack(alignment: .leading) {
            Text(title)
                .font(.subheadline)
            TextField(title, text: $text)
                .keyboardType(.decimalPad)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .focused(focusField, equals: field)
        }
    }
}

// MARK: - Custom View Modifiers

struct MarsSectionHeaderModifier: ViewModifier {
    func body(content: Content) -> some View {
        content
            .font(.headline)
            .foregroundColor(.accentColor)
    }
}

extension View {
    func marsSectionHeaderStyle() -> some View {
        self.modifier(MarsSectionHeaderModifier())
    }
}

struct MarsSectionModifier: ViewModifier {
    func body(content: Content) -> some View {
        content
            .padding()
            .background(Color(UIColor.secondarySystemBackground))
            .cornerRadius(12)
            .shadow(radius: 3)
    }
}

extension View {
    func marsSectionStyle() -> some View {
        self.modifier(MarsSectionModifier())
    }
    
    func placeholder<Content: View>(
        when shouldShow: Bool,
        alignment: Alignment = .leading,
        @ViewBuilder placeholder: () -> Content
    ) -> some View {
        ZStack(alignment: alignment) {
            if shouldShow {
                placeholder().foregroundColor(.gray)
            }
            self
        }
    }
}

