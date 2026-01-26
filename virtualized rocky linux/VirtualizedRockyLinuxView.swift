import SwiftUI
import Virtualization

struct VirtualizedRockyLinuxView: NSViewRepresentable {
    
    func makeNSView(context: Context) -> VZVirtualMachineView {
        let view = VZVirtualMachineView()
        view.automaticallyReconfiguresDisplay = true
        view.capturesSystemKeys = true
        view.virtualMachine = _makeVirtualMachine()
        return view
    }
    
    func updateNSView(_ view: VZVirtualMachineView, context: Context) {}
}

func _makeVirtualMachine() -> VZVirtualMachine {
    let virtualMachine = VZVirtualMachine(configuration: _makeVirtualMachineConfiguration())
    return virtualMachine
}

func _makeVirtualMachineConfiguration() -> VZVirtualMachineConfiguration {
    let configuration = VZVirtualMachineConfiguration()
    do {
        try configuration.validate()
    } catch {
        fatalError("Failed to validate virtual machine configuration with error: \(error)")
    }
    return configuration
}

