import SwiftUI
import Virtualization

@main
struct VirtualizedRockyLinuxApp: App {
    
    let _virtualMachine = _makeVirtualMachine()
    
    var body: some Scene {
        Window("virtualized rocky linux", id: "virtualizedRockyLinuxApp", content: { VirtualizedRockyLinuxView() })
    }
}

func _makeVirtualMachine() -> VZVirtualMachine {
    let virtualMachine = VZVirtualMachine(configuration: _makeVirtualMachineConfiguration())
    return virtualMachine
}

func _makeVirtualMachineConfiguration() -> VZVirtualMachineConfiguration {
    let configuration = VZVirtualMachineConfiguration()
    return configuration
}
