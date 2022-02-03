import SwiftUI

public struct SettingsView: View {
    @Environment(\.presentationMode) var presentationMode
    @ObservedObject var viewModel: SettingsViewModel
    
    private enum FocusField: Hashable {
        case baseURLField, apiTokenField
    }
    @FocusState private var focusedField: FocusField?
    
    public init(viewModel: SettingsViewModelProtocol) {
        self.viewModel = viewModel as! SettingsViewModel
    }
    
    public var body: some View {
        NavigationView {
            Form {
                Section(
                    header: Text("Enter Remote API credentials"),
                    footer: footer
                ) {
                    baseURLFormField
                    apiTokenFormField
                }
            }
            .disabled(viewModel.isProcessing)
            .onAppear {
                if viewModel.baseURLFieldValue.isEmpty {
                    DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(1)) {
                        focusedField = .baseURLField
                    }
                }
            }
            .onSubmit {
                if focusedField == .baseURLField {
                    focusedField = .apiTokenField
                } else {
                    submitSettingsValue()
                }
            }
            .navigationTitle("Settings")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    if viewModel.isProcessing {
                        ProgressView()
                    } else {
                        Button(action: submitSettingsValue) {
                            Text("Done")
                        }
                        .disabled(!viewModel.isSettingsValid)
                    }
                }
            }
        }
        .interactiveDismissDisabled()
    }
    
    @ViewBuilder private var footer: some View {
        if !viewModel.errorMessage.isEmpty {
            Text(viewModel.errorMessage)
                .font(.footnote)
                .foregroundColor(.red)
                .frame(maxWidth: .infinity, alignment: .leading)
        }
    }
    
    private var baseURLFormField: some View {
        HStack {
            TextField("API Base URL", text: $viewModel.baseURLFieldValue)
                .focused($focusedField, equals: .baseURLField)
                .font(.caption)
                .autocapitalization(.none)
                .keyboardType(.URL)
                .submitLabel(.next)
            
            clearButton(for: .baseURLField)
        }
    }
    
    private var apiTokenFormField: some View {
        HStack {
            TextField("API Token", text: $viewModel.apiTokenFieldValue)
                .focused($focusedField, equals: .apiTokenField)
                .font(.caption)
                .autocapitalization(.none)
                .disableAutocorrection(true)
                .submitLabel(.done)
            
            clearButton(for: .apiTokenField)
        }
    }
    
    @ViewBuilder private func clearButton(for field: FocusField) -> some View {
        switch field {
        case .baseURLField:
            if !viewModel.baseURLFieldValue.isEmpty {
                TextFieldClearButton(action: viewModel.clearBaseURLFieldValue)
            }
        case .apiTokenField:
            if !viewModel.apiTokenFieldValue.isEmpty {
                TextFieldClearButton(action: viewModel.clearApiTokenFieldValue)
            }
        }
    }
    
    private func submitSettingsValue() {
        if viewModel.isSettingsValid && !viewModel.isProcessing {
            focusedField = nil
            if viewModel.onSubmitSettings() {
                presentationMode.wrappedValue.dismiss()
            }
            return
        }
        
        focusedField = viewModel.baseURLFieldValue.isEmpty ? .baseURLField : .apiTokenField
    }
}

struct SettingsView_Previews: PreviewProvider {
    @ObservedObject static var viewModel = SettingsViewModelMock()
    static var previews: some View {
        ZStack {
            NavigationView {
                SettingsView(viewModel: viewModel)
            }
        }
    }
}

struct TextFieldClearButton: View {
    var action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Image(systemName: "xmark.circle.fill")
                .imageScale(.small)
                .tint(.secondary)
        }
    }
}
