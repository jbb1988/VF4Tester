import SwiftUI

// MARK: - Export Options
enum ExportOption: String, CaseIterable {
    case csv = "Export as CSV"
    case pdf = "Export as PDF"
    case icloud = "Export to iCloud"
}

struct TestHistoryView: View {
    @EnvironmentObject var viewModel: TestViewModel
    @State private var searchText: String = ""
    @State private var showExportActionSheet: Bool = false
    @State private var showShareSheet: Bool = false
    @State private var exportData: Data? = nil

    private let dateFormatter: DateFormatter = {
         let formatter = DateFormatter()
         formatter.dateStyle = .short
         formatter.timeStyle = .short
         return formatter
    }()

    // Filter test results based on search text.
    var filteredResults: [TestResult] {
        if searchText.isEmpty {
            return viewModel.testResults
        } else {
            return viewModel.testResults.filter { result in
                result.testType.rawValue.localizedCaseInsensitiveContains(searchText) ||
                result.notes.localizedCaseInsensitiveContains(searchText)
            }
        }
    }
    
    var body: some View {
        // DO NOT wrap in a NavigationView here if MainTabView already provides one.
        List {
            if filteredResults.isEmpty {
                Text("No test results available.")
                    .foregroundColor(.secondary)
            } else {
                ForEach(filteredResults) { result in
                    NavigationLink(destination: TestDetailView(testResult: result)) {
                        VStack(alignment: .leading, spacing: 5) {
                            Text(result.testType.rawValue)
                                .font(.headline)
                            Text("Accuracy: \(String(format: "%.1f%%", result.reading.accuracy))")
                                .font(.subheadline)
                                .foregroundColor(result.isPassing ? .green : .red)
                            HStack {
                                Text("Volume: \(result.reading.totalVolume, specifier: "%.1f")")
                                Spacer()
                                Text("Flow Rate: \(result.reading.flowRate, specifier: "%.1f") GPM")
                            }
                            .font(.caption)
                            Text("Date: \(result.date, formatter: dateFormatter)")
                                .font(.caption)
                        }
                        .padding(.vertical, 5)
                    }
                }
            }
        }
        .listStyle(InsetGroupedListStyle())
        .searchable(text: $searchText, prompt: "Search tests")
        .navigationTitle("Test History")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button(action: {
                    showExportActionSheet = true
                }) {
                    Image(systemName: "square.and.arrow.up")
                }
            }
        }
        .actionSheet(isPresented: $showExportActionSheet) {
            ActionSheet(
                title: Text("Export Options"),
                message: Text("Choose an export format"),
                buttons: exportActionButtons()
            )
        }
        .sheet(isPresented: $showShareSheet) {
            if let data = exportData {
                CustomShareSheet(activityItems: [data])
            } else {
                VStack {
                    Text("Export data not available.")
                    Button("Dismiss") { showShareSheet = false }
                }
            }
        }
    }
    
    // Constructs the export action sheet buttons.
    func exportActionButtons() -> [ActionSheet.Button] {
        var buttons: [ActionSheet.Button] = []
        for option in ExportOption.allCases {
            buttons.append(.default(Text(option.rawValue)) {
                switch option {
                case .csv:
                    exportData = generateCSVForResults(filteredResults)
                case .pdf:
                    exportData = generatePDFForResults(filteredResults)
                case .icloud:
                    // For demonstration, using CSV data for iCloud export.
                    exportData = generateCSVForResults(filteredResults)
                }
                if exportData != nil {
                    showShareSheet = true
                }
            })
        }
        buttons.append(.cancel())
        return buttons
    }
    
    // Generates CSV data for an array of TestResult.
    func generateCSVForResults(_ results: [TestResult]) -> Data? {
        var csvString = "Test Type,Small Start,Small End,Large Start,Large End,Total Volume,Flow Rate,Accuracy,Notes,Date\n"
        let df = DateFormatter()
        df.dateStyle = .short
        df.timeStyle = .short
        for result in results {
            let dateStr = df.string(from: result.date)
            let line = "\(result.testType.rawValue),\(result.reading.smallMeterStart),\(result.reading.smallMeterEnd),\(result.reading.largeMeterStart),\(result.reading.largeMeterEnd),\(result.reading.totalVolume),\(result.reading.flowRate),\(String(format: "%.1f", result.reading.accuracy)),\(result.notes),\(dateStr)\n"
            csvString += line
        }
        return csvString.data(using: .utf8)
    }
    
    // Generates a simple PDF data for an array of TestResult.
    func generatePDFForResults(_ results: [TestResult]) -> Data? {
        let pdfMetaData = [
            kCGPDFContextCreator: "VEROflow-4 Field Tester",
            kCGPDFContextAuthor: "MARS Company",
            kCGPDFContextTitle: "Test History"
        ]
        let format = UIGraphicsPDFRendererFormat()
        format.documentInfo = pdfMetaData as [String: Any]
        
        let pageWidth = 8.5 * 72.0
        let pageHeight = 11 * 72.0
        let pageRect = CGRect(x: 0, y: 0, width: pageWidth, height: pageHeight)
        let renderer = UIGraphicsPDFRenderer(bounds: pageRect, format: format)
        
        let data = renderer.pdfData { context in
            context.beginPage()
            let title = "Test History"
            let titleAttributes: [NSAttributedString.Key: Any] = [.font: UIFont.systemFont(ofSize: 24, weight: .bold)]
            let titleSize = title.size(withAttributes: titleAttributes)
            let titleRect = CGRect(x: (pageRect.width - titleSize.width) / 2,
                                   y: 50,
                                   width: titleSize.width,
                                   height: titleSize.height)
            title.draw(in: titleRect, withAttributes: titleAttributes)
            
            var yPosition = titleRect.maxY + 20
            let textAttributes: [NSAttributedString.Key: Any] = [.font: UIFont.systemFont(ofSize: 12)]
            
            for result in results {
                let line = "\(result.testType.rawValue) | \(String(format: "%.1f", result.reading.accuracy))% | \(result.date)"
                let lineSize = line.size(withAttributes: textAttributes)
                if yPosition + lineSize.height > pageRect.height - 40 {
                    context.beginPage()
                    yPosition = 40
                }
                let lineRect = CGRect(x: 40, y: yPosition, width: pageRect.width - 80, height: lineSize.height)
                line.draw(in: lineRect, withAttributes: textAttributes)
                yPosition += lineSize.height + 10
            }
        }
        return data
    }
}

struct TestDetailView: View {
    var testResult: TestResult
    @State private var showShareSheet: Bool = false
    @State private var exportData: Data? = nil

    private let df: DateFormatter = {
         let formatter = DateFormatter()
         formatter.dateStyle = .long
         formatter.timeStyle = .long
         return formatter
    }()

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                Group {
                    Text("Test Type: \(testResult.testType.rawValue)")
                        .font(.title2)
                    Text("Small Meter Start: \(testResult.reading.smallMeterStart, specifier: "%.1f")")
                    Text("Small Meter End: \(testResult.reading.smallMeterEnd, specifier: "%.1f")")
                    Text("Large Meter Start: \(testResult.reading.largeMeterStart, specifier: "%.1f")")
                    Text("Large Meter End: \(testResult.reading.largeMeterEnd, specifier: "%.1f")")
                    Text("Total Volume: \(testResult.reading.totalVolume, specifier: "%.1f")")
                    Text("Flow Rate: \(testResult.reading.flowRate, specifier: "%.1f") GPM")
                }
                Text("Accuracy: \(String(format: "%.1f%%", testResult.reading.accuracy))")
                    .font(.headline)
                    .foregroundColor(testResult.isPassing ? .green : .red)
                Text("Status: \(testResult.isPassing ? "PASS" : "FAIL")")
                    .foregroundColor(testResult.isPassing ? .green : .red)
                Text("Date: \(testResult.date, formatter: df)")
                    .font(.subheadline)
                Divider()
                Text("Notes:")
                    .font(.headline)
                Text(testResult.notes)
            }
            .padding()
        }
        .navigationTitle("Test Details")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button(action: {
                    exportData = generateCSVForResult(testResult)
                    showShareSheet = true
                }) {
                    Image(systemName: "square.and.arrow.up")
                }
            }
        }
        .sheet(isPresented: $showShareSheet) {
            if let data = exportData {
                CustomShareSheet(activityItems: [data])
            } else {
                VStack {
                    Text("Export data not available.")
                    Button("Dismiss") { showShareSheet = false }
                }
            }
        }
    }
    
    func generateCSVForResult(_ result: TestResult) -> Data? {
        var csvString = "Test Type,Small Start,Small End,Large Start,Large End,Total Volume,Flow Rate,Accuracy,Notes,Date\n"
        let df = DateFormatter()
        df.dateStyle = .long
        df.timeStyle = .long
        let dateStr = df.string(from: result.date)
        let line = "\(result.testType.rawValue),\(result.reading.smallMeterStart),\(result.reading.smallMeterEnd),\(result.reading.largeMeterStart),\(result.reading.largeMeterEnd),\(result.reading.totalVolume),\(result.reading.flowRate),\(String(format: "%.1f", result.reading.accuracy)),\(result.notes),\(dateStr)\n"
        csvString += line
        return csvString.data(using: .utf8)
    }
}

// Renamed to CustomShareSheet to avoid duplicate declarations.
struct CustomShareSheet: UIViewControllerRepresentable {
    var activityItems: [Any]
    var applicationActivities: [UIActivity]? = nil

    func makeUIViewController(context: Context) -> UIActivityViewController {
        UIActivityViewController(activityItems: activityItems,
                                 applicationActivities: applicationActivities)
    }
    func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {}
}

struct TestHistoryView_Previews: PreviewProvider {
    static var previews: some View {
        let vm = TestViewModel()
        vm.testResults = [
            TestResult(
                testType: .lowFlow,
                reading: MeterReading(smallMeterStart: 10, smallMeterEnd: 20, largeMeterStart: 0, largeMeterEnd: 0, totalVolume: 10, flowRate: 5),
                notes: "Test LowFlow",
                date: Date().addingTimeInterval(-86400),
                meterImageData: nil
            ),
            TestResult(
                testType: .highFlow,
                reading: MeterReading(smallMeterStart: 15, smallMeterEnd: 25, largeMeterStart: 0, largeMeterEnd: 0, totalVolume: 50, flowRate: 30),
                notes: "Test HighFlow",
                date: Date(),
                meterImageData: nil
            )
        ]
        return TestHistoryView().environmentObject(vm)
    }
}

