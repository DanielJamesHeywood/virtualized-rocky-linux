import Virtualization

class VirtualMachineDelegate: NSObject, VZVirtualMachineDelegate {
    
    func guestDidStop(_ virtualMachine: VZVirtualMachine) {
        NSApplication.shared.terminate(nil)
    }
    
    func virtualMachine(_ virtualMachine: VZVirtualMachine, didStopWithError error: any Error) {
        fatalError("Virtual machine stopped with error: \(error)")
    }
}
