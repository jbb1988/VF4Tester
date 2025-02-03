import SwiftUI

// MARK: - FAQ Section

struct FAQItem: Identifiable {
    let id = UUID()
    let question: String
    let answer: String
}

struct FAQSectionView: View {
    private let faqItems: [FAQItem] = [
        FAQItem(question: "How do I record a test?", answer: "Go to the Test tab, input your meter readings, and tap 'Record Test' to store your data."),
        FAQItem(question: "How can I view my test history?", answer: "Your test history is available under the History tab, where you can search, view details, and export results."),
        FAQItem(question: "Does the app work offline?", answer: "Yes, all test data is stored locally so you can work offline and sync or export when connectivity is restored."),
        FAQItem(question: "How do I adjust the settings?", answer: "Use the Settings tab to customize appearance, volume units, and other preferences."),
        FAQItem(question: "Where can I get help?", answer: "Visit the Help tab for FAQs, troubleshooting guides, and contact support information.")
    ]
    
    @State private var expandedIDs: Set<UUID> = []
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Frequently Asked Questions")
                .font(.title2)
                .fontWeight(.bold)
                .foregroundColor(.accentColor)
                .padding(.horizontal)
            
            ForEach(faqItems) { item in
                DisclosureGroup(
                    isExpanded: Binding(
                        get: { expandedIDs.contains(item.id) },
                        set: { isExpanded in
                            if isExpanded {
                                expandedIDs.insert(item.id)
                            } else {
                                expandedIDs.remove(item.id)
                            }
                        }
                    )
                ) {
                    Text(item.answer)
                        .font(.body)
                        .foregroundColor(.primary)
                        .padding(.top, 8)
                        .multilineTextAlignment(.leading)
                } label: {
                    Text(item.question)
                        .font(.headline)
                        .foregroundColor(.primary)
                        .multilineTextAlignment(.leading)
                }
                .padding()
                .background(Color(UIColor.secondarySystemBackground))
                .cornerRadius(12)
                .shadow(color: Color.black.opacity(0.05), radius: 4, x: 0, y: 2)
                .padding(.horizontal)
            }
        }
        .padding(.vertical)
    }
}

// MARK: - Checkbox Toggle Style

struct CheckboxToggleStyle: ToggleStyle {
    func makeBody(configuration: ToggleStyle.Configuration) -> some View {
        Button(action: { configuration.isOn.toggle() }) {
            HStack {
                Image(systemName: configuration.isOn ? "checkmark.square.fill" : "square")
                    .foregroundColor(configuration.isOn ? .blue : .gray)
                configuration.label
                    .multilineTextAlignment(.leading)
            }
        }
        .buttonStyle(PlainButtonStyle())
    }
}

// MARK: - Operator Checklist Section

struct ChecklistItem: Identifiable {
    let id = UUID()
    let title: String
    var isCompleted: Bool = false
}

struct ChecklistSection: Identifiable {
    let id = UUID()
    let title: String
    var items: [ChecklistItem]
}

struct OperatorChecklistView: View {
    @State private var sections: [ChecklistSection] = [
        ChecklistSection(title: "1. Preparation", items: [
            ChecklistItem(title: "Identify meter size & type"),
            ChecklistItem(title: "Verify test port size and install necessary adapters"),
            ChecklistItem(title: "Ensure bypass is closed to isolate test")
        ]),
        ChecklistSection(title: "2. Debris Purge (Flush sediment before testing)", items: [
            ChecklistItem(title: "Connect test port to diffuser"),
            ChecklistItem(title: "Open meter pit valve fully"),
            ChecklistItem(title: "Run water until clear (~30 sec - 1 min)"),
            ChecklistItem(title: "Close meter pit valve")
        ]),
        ChecklistSection(title: "3. Air Purge (Remove air for accurate readings)", items: [
            ChecklistItem(title: "Connect test port to VF4 inlet"),
            ChecklistItem(title: "Open 3” float & spill valve fully"),
            ChecklistItem(title: "Crack open ¾” float & spill valve (~¼ turn)"),
            ChecklistItem(title: "Slowly open meter pit valve fully"),
            ChecklistItem(title: "Observe steady water stream at exit (No sputtering)"),
            ChecklistItem(title: "Close ¾” valve first, then close 3” valve"),
            ChecklistItem(title: "Ensure pressure gauge ≥20 PSI")
        ]),
        ChecklistSection(title: "4. Low-Flow Test (Start with small flows)", items: [
            ChecklistItem(title: "Reset VF4 totalizer to zero"),
            ChecklistItem(title: "Write down meter start read"),
            ChecklistItem(title: "Set flow control valve to target GPM"),
            ChecklistItem(title: "Run test to desired volume (e.g., 100 gallons)"),
            ChecklistItem(title: "Slowly close flow control valve at end"),
            ChecklistItem(title: "Write down meter end read"),
            ChecklistItem(title: "Calculate accuracy ((End Read - Start Read) ÷ Totalizer Volume)")
        ]),
        ChecklistSection(title: "5. Mid-Flow Test (If applicable)", items: [
            ChecklistItem(title: "Determine mid-flow GPM from chart"),
            ChecklistItem(title: "Run test using the 3” side (recommended)"),
            ChecklistItem(title: "Follow same steps as low-flow test")
        ]),
        ChecklistSection(title: "6. High-Flow Test (Measure max flow)", items: [
            ChecklistItem(title: "Reset VF4 totalizer & meter start read"),
            ChecklistItem(title: "Open 3” flow control valve to max achievable GPM"),
            ChecklistItem(title: "Run for 3 min (if full volume can’t be achieved)"),
            ChecklistItem(title: "Slowly close flow control valve at end"),
            ChecklistItem(title: "Write down meter end read"),
            ChecklistItem(title: "Calculate accuracy")
        ]),
        ChecklistSection(title: "7. Test Completion & Depressurization", items: [
            ChecklistItem(title: "Close meter pit valve fully"),
            ChecklistItem(title: "Depressurize VF4 by opening 3” & ¾” valves"),
            ChecklistItem(title: "Verify pressure gauge at 0 PSI"),
            ChecklistItem(title: "Disconnect hoses & store equipment")
        ]),
        ChecklistSection(title: "8. Special Notes", items: [
            ChecklistItem(title: "Raise exit hose above VF4 for optimal pressure")
        ])
    ]
    
    @State private var expandedSectionIDs: Set<UUID> = []
    
    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            Text("VF4 In-Field Testing Checklist")
                .font(.title)
                .fontWeight(.bold)
                .foregroundColor(.accentColor)
                .padding(.horizontal)
            
            ForEach($sections) { $section in
                DisclosureGroup(
                    isExpanded: Binding(
                        get: { expandedSectionIDs.contains(section.id) },
                        set: { newValue in
                            if newValue {
                                expandedSectionIDs.insert(section.id)
                            } else {
                                expandedSectionIDs.remove(section.id)
                            }
                        }
                    )
                ) {
                    VStack(alignment: .leading, spacing: 8) {
                        ForEach($section.items) { $item in
                            Toggle(isOn: $item.isCompleted) {
                                Text(item.title)
                                    .font(.body)
                                    .foregroundColor(.primary)
                                    .multilineTextAlignment(.leading)
                            }
                            .toggleStyle(CheckboxToggleStyle())
                        }
                    }
                    .padding(.top, 8)
                } label: {
                    Text(section.title)
                        .font(.headline)
                        .foregroundColor(.primary)
                        .multilineTextAlignment(.leading)
                }
                .padding()
                .background(Color(UIColor.secondarySystemBackground))
                .cornerRadius(12)
                .shadow(radius: 3)
                .padding(.horizontal)
            }
        }
        .padding(.vertical)
    }
}

// MARK: - Polished Contact Support View

struct ContactSupportView: View {
    @Environment(\.openURL) var openURL
    
    var body: some View {
        VStack(spacing: 16) {
            HStack {
                Image(systemName: "headphones")
                    .font(.largeTitle)
                    .foregroundColor(.blue)
                Text("Contact Support")
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundColor(.blue)
                Spacer()
            }
            Divider()
            VStack(spacing: 4) {
                Text("MARS Company")
                    .font(.body)
                    .foregroundColor(.primary)
                Text("3925 SW 13th Street")
                    .font(.body)
                    .foregroundColor(.primary)
                Text("Ocala, FL 34474")
                    .font(.body)
                    .foregroundColor(.primary)
                Link("Visit our website", destination: URL(string: "https://marswater.com")!)
                    .font(.body)
                    .foregroundColor(.blue)
            }
            .multilineTextAlignment(.center)
            HStack(spacing: 20) {
                Button(action: {
                    if let phoneURL = URL(string: "tel://8777MYMARS") {
                        openURL(phoneURL)
                    }
                }) {
                    Label("Call Support", systemImage: "phone.fill")
                        .font(.headline)
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color.blue.opacity(0.2))
                        .cornerRadius(10)
                }
                Button(action: {
                    if let emailURL = URL(string: "mailto:support@marswater.com") {
                        openURL(emailURL)
                    }
                }) {
                    Label("Email Support", systemImage: "envelope.fill")
                        .font(.headline)
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color.green.opacity(0.2))
                        .cornerRadius(10)
                }
            }
        }
        .padding()
        .background(Color(UIColor.tertiarySystemBackground))
        .cornerRadius(12)
        .shadow(color: Color.black.opacity(0.1), radius: 4, x: 0, y: 2)
        .padding(.horizontal)
    }
}

// MARK: - Main Help View

struct HelpView: View {
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading, spacing: 30) {
                    FAQSectionView()
                    ContactSupportView()
                    OperatorChecklistView()
                }
                .padding()
            }
            .navigationTitle("Help & FAQs")
        }
    }
}

struct HelpView_Previews: PreviewProvider {
    static var previews: some View {
        HelpView()
    }
}

