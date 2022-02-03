import SwiftUI

extension View {
    func segmentedPickerForegroundColors(normal: Color, selected: Color) -> some View {
        let uiColorNormal = UIColor(normal)
        let uiColorSelected = UIColor(selected)
        
        UISegmentedControl.appearance().setTitleTextAttributes([.foregroundColor: uiColorNormal], for: .normal)
        UISegmentedControl.appearance().setTitleTextAttributes([.foregroundColor: uiColorSelected], for: .selected)
        return self
    }
}
