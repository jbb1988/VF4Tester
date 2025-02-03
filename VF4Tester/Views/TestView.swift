import SwiftUI
import UIKit

// MARK: - TestView
// This file assumes that the following are defined in SharedComponents.swift:
//   - MarsReadingField, Field enum
//   - Custom view modifiers: .marsSectionStyle(), .marsSectionHeaderStyle(), .placeholder(when:alignment:placeholder:)

struct TestView: View {
    @EnvironmentObject var viewModel: TestViewModel
    @FocusState private var focusedField: Field?
    
    // Removed photo-related state since the feature is removed.
    // @State private var showImagePicker: Bool = false
    // @State private var meterPhoto: UIImage? = nil
    
    // Local state for input fields.
    @State private var totalVolumeText: String = ""
    @State private var flowRateText: String = ""
    @State private var meterSizeText: String = ""
    @State private var jobNumberText: String = ""
    @State private var additionalRemarksText: String = ""
    
    var isLowFlowTest: Bool {
        viewModel.currentTest == .lowFlow
    }
    
    var passRangeText: String {
        isLowFlowTest ? "95% - 101%" : "98.5% - 101.5%"
    }
    
    var body: some View {
        Form {
            // Test Type Section
            testTypeSection
            
            // Meter Readings Section
            meterReadingsSection
            
            // Test Parameters Section
            testParametersSection
            
            // Additional Details Section
            additionalDetailsSection
            
            // Notes Section
            notesSection
            
            // (Meter Photo Section Removed)
            
            // Record Test Section (modified to pass nil for meter photo)
            recordTestSection
            
            // Latest Result Section
            latestResultSection
        }
        .navigationTitle("VEROflow‑4 Field Test")
        .toolbar {
            ToolbarItemGroup(placement: .keyboard) {
                Spacer()
                Button(action: { dismissKeyboard() }) {
                    Image(systemName: "keyboard.chevron.compact.down")
                }
            }
        }
        // Sheet for ImagePicker removed since the feature is removed.
        .onAppear {
            totalVolumeText = String(viewModel.totalVolume)
            flowRateText = String(viewModel.flowRate)
            viewModel.loadData()
        }
        .alert(item: Binding(get: {
            viewModel.errorMessage.map { SimpleError(message: $0) }
        }, set: { _ in viewModel.errorMessage = nil })) { error in
            Alert(title: Text("Error"), message: Text(error.message), dismissButton: .default(Text("OK")))
        }
    }
    
    // MARK: - Computed Subviews
    
    private var testTypeSection: some View {
        Section {
            Picker("Test Type", selection: $viewModel.currentTest) {
                Text("Low Flow (0.75-40 GPM)").tag(TestType.lowFlow)
                Text("High Flow (25-650 GPM)").tag(TestType.highFlow)
            }
            .pickerStyle(SegmentedPickerStyle())
        }
        .marsSectionStyle()
    }
    
    private var meterReadingsSection: some View {
        Section(header: Text("Meter Readings").marsSectionHeaderStyle()) {
            VStack(spacing: 16) {
                smallMeterReadings
                Divider()
                largeMeterReadings
            }
        }
    }
    
    private var smallMeterReadings: some View {
        VStack(alignment: .leading) {
            Text("Small Meter Readings")
                .font(.subheadline)
                .bold()
            HStack {
                MarsReadingField(title: "Start",
                                 text: $viewModel.smallMeterStart,
                                 focusField: $focusedField,
                                 field: .smallStart)
                Spacer()
                MarsReadingField(title: "End",
                                 text: $viewModel.smallMeterEnd,
                                 focusField: $focusedField,
                                 field: .smallEnd)
                    .onSubmit {
                        if let start = Double(viewModel.smallMeterStart),
                           let end = Double(viewModel.smallMeterEnd),
                           end < start {
                            viewModel.errorMessage = "Small meter: End reading must be ≥ start reading."
                        } else {
                            viewModel.errorMessage = nil
                        }
                    }
            }
        }
    }
    
    private var largeMeterReadings: some View {
        VStack(alignment: .leading) {
            Text("Large Meter Readings")
                .font(.subheadline)
                .bold()
            HStack {
                MarsReadingField(title: "Start",
                                 text: $viewModel.largeMeterStart,
                                 focusField: $focusedField,
                                 field: .largeStart)
                Spacer()
                MarsReadingField(title: "End",
                                 text: $viewModel.largeMeterEnd,
                                 focusField: $focusedField,
                                 field: .largeEnd)
                    .onSubmit {
                        if let start = Double(viewModel.largeMeterStart),
                           let end = Double(viewModel.largeMeterEnd),
                           end < start {
                            viewModel.errorMessage = "Large meter: End reading must be ≥ start reading."
                        } else {
                            viewModel.errorMessage = nil
                        }
                    }
            }
        }
    }
    
    private var testParametersSection: some View {
        Section(header: Text("Test Parameters").marsSectionHeaderStyle()) {
            HStack {
                Text("Total Volume")
                Spacer()
                TextField("Volume", text: $totalVolumeText)
                    .keyboardType(.decimalPad)
                    .multilineTextAlignment(.trailing)
                    .frame(width: 100)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .onChange(of: totalVolumeText) { newValue in
                        if let newVolume = Double(newValue) {
                            viewModel.totalVolume = newVolume
                        }
                    }
            }
            HStack {
                Text("Flow Rate")
                Spacer()
                TextField("GPM", text: $flowRateText)
                    .keyboardType(.decimalPad)
                    .multilineTextAlignment(.trailing)
                    .frame(width: 100)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .onChange(of: flowRateText) { newValue in
                        if let newFlowRate = Double(newValue) {
                            viewModel.flowRate = newFlowRate
                        }
                    }
                Text("GPM")
            }
        }
    }
    
    private var additionalDetailsSection: some View {
        Section(header: Text("Additional Details").marsSectionHeaderStyle()) {
            VStack(alignment: .leading) {
                TextField("Meter Size", text: $meterSizeText)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                TextField("Job #", text: $jobNumberText)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                TextField("Remarks", text: $additionalRemarksText)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
            }
        }
    }
    
    private var notesSection: some View {
        Section(header: Text("Notes").marsSectionHeaderStyle()) {
            TextEditor(text: $viewModel.notes)
                .frame(minHeight: 100)
                .placeholder(when: viewModel.notes.isEmpty) {
                    Text("Enter additional notes here...")
                        .foregroundColor(.gray)
                }
        }
    }
    
    private var recordTestSection: some View {
        Section {
            Button(action: {
                dismissKeyboard()
                viewModel.isCalculatingResults = true
                DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                    let additionalInfo = "\n\nMeter Size: \(meterSizeText)\nJob #: \(jobNumberText)\nRemarks: \(additionalRemarksText)"
                    viewModel.notes += additionalInfo
                    // Since the photo feature is removed, pass nil
                    viewModel.calculateResults(with: nil)
                    
                    // Clear input fields (preserve testResults)
                    viewModel.smallMeterStart = ""
                    viewModel.smallMeterEnd = ""
                    viewModel.largeMeterStart = ""
                    viewModel.largeMeterEnd = ""
                    viewModel.totalVolume = 0.0
                    viewModel.flowRate = 0.0
                    viewModel.notes = ""
                    totalVolumeText = ""
                    flowRateText = ""
                    meterSizeText = ""
                    jobNumberText = ""
                    additionalRemarksText = ""
                    
                    viewModel.isCalculatingResults = false
                }
            }) {
                Text("Record Test")
                    .font(.headline)
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(
                        LinearGradient(gradient: Gradient(colors: [.blue, .purple]),
                                       startPoint: .leading,
                                       endPoint: .trailing)
                    )
                    .cornerRadius(10)
                    .shadow(radius: 5)
            }
            .disabled(viewModel.isCalculatingResults)
        }
    }
    
    private var latestResultSection: some View {
        Group {
            if viewModel.showingResults, let result = viewModel.testResults.last {
                Section(header: Text("Latest Result").marsSectionHeaderStyle()) {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Test Type: \(result.testType.rawValue)")
                            .font(.headline)
                        Text("Accuracy: \(String(format: "%.1f%%", result.reading.accuracy))")
                            .foregroundColor(result.isPassing ? .green : .red)
                        Text("Status: \(result.isPassing ? "PASS" : "FAIL")")
                            .foregroundColor(result.isPassing ? .green : .red)
                        Text("Pass Range: \(passRangeText)")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
            }
        }
    }
    
    private func dismissKeyboard() {
        focusedField = nil
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder),
                                        to: nil, from: nil, for: nil)
    }
}

struct SimpleError: Identifiable {
    let id = UUID()
    let message: String
}

struct TestView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            TestView().environmentObject(TestViewModel())
        }
    }
}

