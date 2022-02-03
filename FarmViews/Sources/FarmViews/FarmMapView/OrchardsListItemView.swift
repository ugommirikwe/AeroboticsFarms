import SwiftUI
import DomainModel

struct OrchardsListItemView: View {
    var orchard: DomainModel.Orchard
    
    var body: some View {
        VStack(alignment: .leading) {
            Text(orchard.name)
                .font(.title)
                .frame(maxWidth: .infinity, alignment: .leading)
            
            Text("\(orchard.hectares) hectares")
                .font(.caption)
                .frame(maxWidth: .infinity, alignment: .leading)
            
            Text("Crop Type: \(orchard.cropType)")
                .font(.footnote)
                .frame(maxWidth: .infinity, alignment: .leading)
        }
        .padding()
        .background(.thickMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
        .overlay(RoundedRectangle(cornerRadius: 20, style: .continuous)
            .stroke(Color.white, lineWidth: 1)
        )
    }
}

struct OrchardsListItemView_Previews: PreviewProvider {
    static var previews: some View {
        OrchardsListItemView(orchard: FarmViewModelMock().orchardsList[0])
    }
}
