import SwiftUI

struct SettingsView: View {
    @EnvironmentObject var viewModel: TestViewModel
    @State private var selectedUnit: VolumeUnit = .gallons  // Defined in Types.swift
    
    var body: some View {
        NavigationStack {
            List {
                // Volume Settings Section
                Section(header: Text("Volume Settings")) {
                    Picker("Volume Unit", selection: $selectedUnit) {
                        ForEach(VolumeUnit.allCases, id: \.self) { unit in
                            Text(unit.rawValue).tag(unit)
                        }
                    }
                    .pickerStyle(.inline)
                }
                
                // Appearance Section
                Section(header: Text("Appearance")) {
                    Picker("App Appearance", selection: $viewModel.appearance) {
                        ForEach(TestViewModel.AppearanceOption.allCases) { option in
                            Text(option.rawValue).tag(option)
                        }
                    }
                    .pickerStyle(.segmented)
                }
            }
            .listStyle(InsetGroupedListStyle())
            .navigationTitle("Settings")
            .navigationBarTitleDisplayMode(.inline)
            .onAppear {
                // Synchronize the local unit with the configuration.
                selectedUnit = viewModel.configuration.preferredVolumeUnit
            }
            .onChange(of: selectedUnit) { newUnit in
                viewModel.configuration.preferredVolumeUnit = newUnit
            }
        }
        .preferredColorScheme(viewModel.appearance.colorScheme)
    }
}

struct SettingsView_Previews: PreviewProvider {
    static var previews: some View {
        SettingsView()
            .environmentObject(TestViewModel())
    }
}

