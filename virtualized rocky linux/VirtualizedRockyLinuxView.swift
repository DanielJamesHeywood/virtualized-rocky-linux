import SwiftUI
import Virtualization

struct VirtualizedRockyLinuxView: NSViewRepresentable {
    
    func makeNSView(context: Context) -> VZVirtualMachineView {
        let view = VZVirtualMachineView()
        view.automaticallyReconfiguresDisplay = true
        view.capturesSystemKeys = true
        view.virtualMachine = makeVirtualMachine()
        return view
    }
    
    func updateNSView(_ view: VZVirtualMachineView, context: Context) {}
}

func makeVirtualMachine() -> VZVirtualMachine {
    let virtualMachine = VZVirtualMachine(configuration: makeVirtualMachineConfiguration())
    return virtualMachine
}

func makeVirtualMachineConfiguration() -> VZVirtualMachineConfiguration {
    let configuration = VZVirtualMachineConfiguration()
    do {
        try configuration.validate()
    } catch {
        fatalError("Failed to validate virtual machine configuration with error: \(error)")
    }
    return configuration
}

