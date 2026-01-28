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
    configuration.bootLoader = makeBootLoader()
    configuration.cpuCount = 4.clamped(
        to: VZVirtualMachineConfiguration.minimumAllowedCPUCount...VZVirtualMachineConfiguration.maximumAllowedCPUCount
    )
    configuration.memorySize = (8 * 1024 * 1024 * 1024 as UInt64).clamped(
        to: VZVirtualMachineConfiguration.minimumAllowedMemorySize...VZVirtualMachineConfiguration.maximumAllowedMemorySize
    )
    configuration.consoleDevices = [makeSpiceAgentConsoleDeviceConfiguration()]
    configuration.networkDevices = [makeNATNetworkDeviceConfiguration()]
    configuration.storageDevices = [makeDiskImageBlockDeviceConfiguration()]
    configuration.entropyDevices = [VZVirtioEntropyDeviceConfiguration()]
    configuration.audioDevices = [makeAudioDeviceConfiguration()]
    configuration.graphicsDevices = [makeGraphicsDeviceConfiguration()]
    configuration.keyboards = [VZUSBKeyboardConfiguration()]
    configuration.platform = makePlatformConfiguration()
    configuration.pointingDevices = [VZUSBScreenCoordinatePointingDeviceConfiguration()]
    do {
        try configuration.validate()
    } catch {
        fatalError("Failed to validate virtual machine configuration with error: \(error)")
    }
    return configuration
}

func makeBootLoader() -> VZEFIBootLoader {
    let bootLoader = VZEFIBootLoader()
    let variableStoreURL = URL.applicationSupportDirectory.appending(component: "variable store")
    if FileManager.default.fileExists(atPath: variableStoreURL.relativePath) {
        bootLoader.variableStore = VZEFIVariableStore(url: variableStoreURL)
    } else {
        do {
            bootLoader.variableStore = try VZEFIVariableStore(creatingVariableStoreAt: variableStoreURL)
        } catch {
            fatalError("Failed to create variable store with error: \(error)")
        }
    }
    return bootLoader
}

func makeSpiceAgentConsoleDeviceConfiguration() -> VZVirtioConsoleDeviceConfiguration {
    let configuration = VZVirtioConsoleDeviceConfiguration()
    configuration.ports[0] = makeSpiceAgentConsolePortConfiguration()
    return configuration
}

func makeSpiceAgentConsolePortConfiguration() -> VZVirtioConsolePortConfiguration {
    let configuration = VZVirtioConsolePortConfiguration()
    configuration.name = VZSpiceAgentPortAttachment.spiceAgentPortName
    configuration.attachment = VZSpiceAgentPortAttachment()
    return configuration
}

func makeNATNetworkDeviceConfiguration() -> VZVirtioNetworkDeviceConfiguration {
    let configuration = VZVirtioNetworkDeviceConfiguration()
    configuration.attachment = VZNATNetworkDeviceAttachment()
    return configuration
}

func makeBlockDeviceConfiguration() -> VZVirtioBlockDeviceConfiguration {
    let diskImageURL = URL.applicationSupportDirectory.appending(component: "disk.img")
    if !FileManager.default.fileExists(atPath: diskImageURL.relativePath) {
        guard FileManager.default.createFile(atPath: diskImageURL.relativePath, contents: nil) else {
            fatalError("Failed to create disk image")
        }
        guard let diskImageHandle = FileHandle(forWritingAtPath: diskImageURL.relativePath) else {
            fatalError("Failed to create disk image handle")
        }
        do {
            try diskImageHandle.truncate(atOffset: 256 * 1024 * 1024 * 1024)
        } catch {
            fatalError("Failed to truncate disk image with error: \(error)")
        }
    }
    do {
        return try VZVirtioBlockDeviceConfiguration(
            attachment: VZDiskImageStorageDeviceAttachment(url: diskImageURL, readOnly: false)
        )
    } catch {
        fatalError("Failed to create disk image attachment for block device with error: \(error)")
    }
}

func makeAudioDeviceConfiguration() -> VZVirtioSoundDeviceConfiguration {
    let configuration = VZVirtioSoundDeviceConfiguration()
    configuration.streams = [makeSoundDeviceInputStreamConfiguration(), makeSoundDeviceOutputStreamConfiguration()]
    return configuration
}

func makeSoundDeviceInputStreamConfiguration() -> VZVirtioSoundDeviceInputStreamConfiguration {
    let configuration = VZVirtioSoundDeviceInputStreamConfiguration()
    configuration.source = VZHostAudioInputStreamSource()
    return configuration
}

func makeSoundDeviceOutputStreamConfiguration() -> VZVirtioSoundDeviceOutputStreamConfiguration {
    let configuration = VZVirtioSoundDeviceOutputStreamConfiguration()
    configuration.sink = VZHostAudioOutputStreamSink()
    return configuration
}

func makeGraphicsDeviceConfiguration() -> VZVirtioGraphicsDeviceConfiguration {
    let configuration = VZVirtioGraphicsDeviceConfiguration()
    configuration.scanouts = [VZVirtioGraphicsScanoutConfiguration(widthInPixels: 1280, heightInPixels: 720)]
    return configuration
}

func makePlatformConfiguration() -> VZGenericPlatformConfiguration {
    let configuration = VZGenericPlatformConfiguration()
    let machineIdentifierURL = URL.applicationSupportDirectory.appending(component: "machine identifier")
    if let machineIdentifier = try? VZGenericMachineIdentifier(dataRepresentation: Data(contentsOf: machineIdentifierURL)) {
        configuration.machineIdentifier = machineIdentifier
    } else {
        do {
            try configuration.machineIdentifier.dataRepresentation.write(to: machineIdentifierURL)
        } catch {
            fatalError("Failed to save machine identifier with error: \(error)")
        }
    }
    return configuration
}

extension Comparable {
    
    func clamped(to limits: ClosedRange<Self>) -> Self {
        min(max(limits.lowerBound, self), limits.upperBound)
    }
}
