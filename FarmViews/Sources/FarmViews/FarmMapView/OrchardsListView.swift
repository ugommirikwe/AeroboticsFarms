import SwiftUI
import Combine
import DomainModel

struct OrchardsListView: View {
    @ObservedObject private var viewModel: FarmViewModel
    @Binding var isVisible: Bool
    @Binding var selectedOrchard: DomainModel.Orchard?
    
    public init(
        viewModel: FarmViewModelProtocol,
        isVisible: Binding<Bool>,
        selectedOrchard: Binding<DomainModel.Orchard?>
    ) {
        self.viewModel = viewModel as! FarmViewModel
        self._isVisible = isVisible
        self._selectedOrchard = selectedOrchard
    }
    
    var body: some View {
        VStack {
            HStack {
                Text(viewModel.orchardsListViewCountTitle)
                    .font(.largeTitle)
                    .padding(.horizontal, 8)
                
                Spacer()
                
                Button(action: {
                    withAnimation {
                        isVisible = false
                    }
                }) {
                    Image(systemName: "xmark.circle.fill")
                        .imageScale(.large)
                }
                .foregroundColor(.secondary)
            }
            .frame(maxWidth: .infinity)
            
            ScrollViewReader { container in
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 10) {
                        ForEach(viewModel.orchardsList, id: \.id) { orchard in
                            OrchardsListItemView(orchard: orchard)
                                .tag(orchard.id)
                                .onTapGesture {
                                    selectedOrchard = orchard
                                }
                                .onReceive(Just(selectedOrchard)) { newValue in
                                    guard let selectedOrchard = newValue else {
                                        return
                                    }
                                    
                                    container.scrollTo(selectedOrchard.id)
                                }
                        }
                    }
                }
            }
        }
        .padding()
        .background(.ultraThinMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
        .shadow(color: .gray, radius: 10, x: 0, y: 5)
    }
}

struct OrchardsListView_Previews: PreviewProvider {
    static var previews: some View {
        OrchardsListView(
            viewModel: FarmViewModelMock(),
            isVisible: .constant(true),
            selectedOrchard: .constant(nil)
        ).environmentObject(FarmViewModelMock())
    }
}
