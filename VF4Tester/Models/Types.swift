import Foundation

// MARK: - VolumeUnit

enum VolumeUnit: String, CaseIterable, Codable, Identifiable {
    case gallons = "Gallons"
    case liters = "Liters"
    case cubicFeet = "Cubic Feet"
    
    var id: Self { self }
}

// MARK: - TestType

enum TestType: String, CaseIterable, Codable, Identifiable {
    case lowFlow = "Low Flow"
    case highFlow = "High Flow"
    
    var id: Self { self }
}

// MARK: - MeterReading

struct MeterReading: Codable {
    var smallMeterStart: Double
    var smallMeterEnd: Double
    var largeMeterStart: Double
    var largeMeterEnd: Double
    var totalVolume: Double
    var flowRate: Double
    
    var accuracy: Double {
        let smallDiff = smallMeterEnd - smallMeterStart
        let largeDiff = largeMeterEnd - largeMeterStart
        let totalMeterVolume = smallDiff + largeDiff
        guard totalVolume != 0 else { return 0 }
        let rawAccuracy = (totalMeterVolume / totalVolume) * 100
        return (rawAccuracy * 100).rounded() / 100
    }
}

// MARK: - TestResult

struct TestResult: Identifiable, Codable {
    let id: UUID
    let testType: TestType
    let reading: MeterReading
    var notes: String
    let date: Date
    var meterImageData: Data?
    
    var isPassing: Bool {
        switch testType {
        case .lowFlow:
            return reading.accuracy >= 95 && reading.accuracy <= 101
        case .highFlow:
            return reading.accuracy >= 98.5 && reading.accuracy <= 101.5
        }
    }
    
    init(id: UUID = UUID(),
         testType: TestType,
         reading: MeterReading,
         notes: String = "",
         date: Date = Date(),
         meterImageData: Data? = nil) {
        self.id = id
        self.testType = testType
        self.reading = reading
        self.notes = notes
        self.date = date
        self.meterImageData = meterImageData
    }
}

// MARK: - Configuration

struct Configuration: Codable {
    var preferredVolumeUnit: VolumeUnit = .gallons
}

