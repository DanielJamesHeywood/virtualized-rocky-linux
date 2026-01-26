import SwiftUI
import Virtualization

struct VirtualizedRockyLinuxView: NSViewRepresentable {
    
    func makeNSView(context: Context) -> VZVirtualMachineView {
        VZVirtualMachineView()
    }
    
    func updateNSView(_ view: VZVirtualMachineView, context: Context) {}
}
