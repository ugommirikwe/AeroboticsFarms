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
                    header: Text("Enter Remote API Connection Details"),
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
                    return
                }
                
                if viewModel.apiTokenFieldValue.isEmpty {
                    DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(1)) {
                        focusedField = .apiTokenField
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
                ToolbarItem(placement: .navigationBarLeading) {
                    if viewModel.canCancel {
                        Button("Cancel") {
                            viewModel.cancelChanges()
                            presentationMode.wrappedValue.dismiss()
                        }
                    }
                }
                
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
        VStack {
            HStack {
                TextField("API Base URL", text: $viewModel.baseURLFieldValue)
                    .focused($focusedField, equals: .baseURLField)
                    .font(.body)
                    .autocapitalization(.none)
                    .disableAutocorrection(true)
                    .keyboardType(.URL)
                    .submitLabel(.next)
                Spacer()
                clearButton(for: .baseURLField)
            }
            .padding(.vertical, 8)
            
            if !viewModel.baseURLFieldValue.isEmpty {
                Text("API Base URL")
                    .font(.system(.caption).smallCaps())
                    .foregroundColor(.secondary)
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
        }
        .animation(.linear, value: viewModel.baseURLFieldValue)
    }
    
    private var apiTokenFormField: some View {
        VStack {
            HStack {
                TextField("API Token", text: $viewModel.apiTokenFieldValue)
                    .focused($focusedField, equals: .apiTokenField)
                    .font(.body)
                    .autocapitalization(.none)
                    .submitLabel(.done)
                
                Spacer()
                clearButton(for: .apiTokenField)
            }
            .padding(.vertical, 8)
            
            if !viewModel.apiTokenFieldValue.isEmpty {
                Text("API Access Token")
                    .font(.system(.caption).smallCaps())
                    .foregroundColor(.secondary)
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
        }
        .animation(.linear, value: viewModel.apiTokenFieldValue)
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
