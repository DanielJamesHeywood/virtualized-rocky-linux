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
    
    func updateNSView(_ nsView: VZVirtualMachineView, context: Context) {}
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
    configuration.cpuCount = 4.clamped(
        to: VZVirtualMachineConfiguration.minimumAllowedCPUCount...VZVirtualMachineConfiguration.maximumAllowedCPUCount
    )
    configuration.memorySize = (8 * 1024 * 1024 * 1024 as UInt64).clamped(
        to: VZVirtualMachineConfiguration.minimumAllowedMemorySize...VZVirtualMachineConfiguration.maximumAllowedMemorySize
    )
    do {
        try configuration.validate()
    } catch {
        fatalError("Failed to validate virtual machine configuration with error: \(error)")
    }
    return configuration
}

extension Comparable {
    
    func clamped(to limits: ClosedRange<Self>) -> Self {
        min(limits.lowerBound, max(self, limits.upperBound))
    }
}
