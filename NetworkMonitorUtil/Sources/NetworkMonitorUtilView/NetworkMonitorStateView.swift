import SwiftUI
import NetworkMonitorUtil

public struct NetworkMonitorStateView: View {
    @Binding public var showView: Bool
    @State private var hasConnection = true
    
    @StateObject private var networkUtil = NetworkMonitorUtil.shared
    
    public init(showView: Binding<Bool>) {
        self._showView = showView
    }
    
    public static var slideInOut: AnyTransition {
        .asymmetric(
            insertion: .move(edge: .top),
            removal: .move(edge: .top)
        )
    }
    
    public var body: some View {
        if showView {
            HStack {
                Image(systemName: hasConnection ? "wifi" : "wifi.slash")
                    .imageScale(.large)
                Text(
                    hasConnection ? "Your Internet connection is back" : "You don't have an active Internet connection."
                )
            }
            .padding([.horizontal, .bottom], 6)
            .padding(.top, 38)
            .frame(maxWidth: .infinity)
            .foregroundColor(.white)
            .font(.caption)
            .background(hasConnection ? Color.green : Color.red)
            .edgesIgnoringSafeArea(.top)
            .onReceive(NetworkMonitorUtil.shared.$isConnected) { isConnected in
                hasConnection = isConnected
                if hasConnection {
                    if showView {
                        DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(3)) {
                            showView = false
                        }
                    }
                } else {
                    showView = true
                }
            }
        }
    }
}

struct SwiftUIView_Previews: PreviewProvider {
    static var previews: some View {
        NetworkMonitorStateView(showView: .constant(true))
    }
}
