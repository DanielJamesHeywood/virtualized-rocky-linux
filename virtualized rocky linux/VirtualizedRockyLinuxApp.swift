import SwiftUI

@main
struct VirtualizedRockyLinuxApp: App {
    
    var body: some Scene {
        Window("virtualized rocky linux", id: "virtualizedRockyLinuxApp", content: { ContentView() })
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
