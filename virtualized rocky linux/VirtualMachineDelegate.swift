import Virtualization

class VirtualMachineDelegate: NSObject, VZVirtualMachineDelegate {
    
    func guestDidStop(_ virtualMachine: VZVirtualMachine) {}
    
    func virtualMachine(_ virtualMachine: VZVirtualMachine, didStopWithError error: any Error) {
        fatalError("Virtual machine stopped with error: \(error)")
    }
}
