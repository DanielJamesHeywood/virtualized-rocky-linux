import SwiftUI
import Virtualization

struct VirtualizedRockyLinuxView: NSViewRepresentable {
    
    let virtualMachineDelegate = VirtualMachineDelegate()
    
    func makeNSView(context: Context) -> VZVirtualMachineView {
        let view = VZVirtualMachineView()
        view.automaticallyReconfiguresDisplay = true
        view.capturesSystemKeys = true
        view.virtualMachine = makeVirtualMachine(delegate: virtualMachineDelegate)
        return view
    }
    
    func updateNSView(_ view: VZVirtualMachineView, context: Context) {}
}

func makeVirtualMachine(delegate: VirtualMachineDelegate) -> VZVirtualMachine {
    let virtualMachine = VZVirtualMachine(configuration: makeVirtualMachineConfiguration())
    virtualMachine.delegate = delegate
    virtualMachine.start(
        completionHandler: { result in
            switch result {
            case .success(()):
                break
            case let .failure(error):
                fatalError("Failed to start virtual machine with error: \(error)")
            }
        }
    )
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

