import SwiftUI
import Combine

class TestViewModel: ObservableObject {
    // MARK: - Test Recording Properties
    @Published var currentTest: TestType = .lowFlow
    @Published var smallMeterStart: String = ""
    @Published var smallMeterEnd: String = ""
    @Published var largeMeterStart: String = ""
    @Published var largeMeterEnd: String = ""
    @Published var totalVolume: Double = 0.0
    @Published var flowRate: Double = 0.0
    @Published var notes: String = ""
    @Published var testResults: [TestResult] = []
    @Published var errorMessage: String? = nil
    @Published var isCalculatingResults: Bool = false
    @Published var showingResults: Bool = false
    
    // MARK: - Configuration
    @Published var configuration: Configuration = Configuration()
    
    // MARK: - Appearance Options
    enum AppearanceOption: String, CaseIterable, Identifiable, Codable {
        case system = "System Default"
        case light = "Light"
        case dark = "Dark"
        
        var id: Self { self }
        var colorScheme: ColorScheme? {
            switch self {
            case .system: return nil
            case .light:  return .light
            case .dark:   return .dark
            }
        }
    }
    
    @Published var appearance: AppearanceOption = .system
    
    // MARK: - Methods
    
    func loadData() {
        // Load any stored data if needed.
        print("Loading data...")
    }
    
    func calculateResults(with image: UIImage?) {
        let newResult = TestResult(
            testType: currentTest,
            reading: MeterReading(
                smallMeterStart: Double(smallMeterStart) ?? 0,
                smallMeterEnd: Double(smallMeterEnd) ?? 0,
                largeMeterStart: Double(largeMeterStart) ?? 0,
                largeMeterEnd: Double(largeMeterEnd) ?? 0,
                totalVolume: totalVolume,
                flowRate: flowRate
            ),
            notes: notes,
            date: Date(),
            meterImageData: nil  // Set to nil (or update if you want to store image data)
        )
        testResults.append(newResult)
        showingResults = true
    }
}

