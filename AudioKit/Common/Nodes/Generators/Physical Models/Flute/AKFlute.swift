//
//  AKFlute.swift
//  AudioKit
//
//  Created by Aurelius Prochazka, revision history on Github.
//  Copyright © 2017 Aurelius Prochazka. All rights reserved.
//

/// STK Flutee
///
open class AKFlute: AKNode, AKToggleable, AKComponent {
    public typealias AKAudioUnitType = AKFluteAudioUnit
    /// Four letter unique description of the node
    public static let ComponentDescription = AudioComponentDescription(generator: "flut")

    // MARK: - Properties

    private var internalAU: AKAudioUnitType?
    private var token: AUParameterObserverToken?

    fileprivate var frequencyParameter: AUParameter?
    fileprivate var amplitudeParameter: AUParameter?

    /// Ramp Time represents the speed at which parameters are allowed to change
    @objc open dynamic var rampTime: Double = AKSettings.rampTime {
        willSet {
            internalAU?.rampTime = newValue
        }
    }

    /// Variable frequency. Values less than the initial frequency will be doubled until it is greater than that.
    @objc open dynamic var frequency: Double = 110 {
        willSet {
            if frequency != newValue {
                if let existingToken = token {
                    frequencyParameter?.setValue(Float(newValue), originator: existingToken)
                }
            }
        }
    }

    /// Amplitude
    @objc open dynamic var amplitude: Double = 0.5 {
        willSet {
            if amplitude != newValue {
                if let existingToken = token {
                    amplitudeParameter?.setValue(Float(newValue), originator: existingToken)
                }
            }
        }
    }

    /// Tells whether the node is processing (ie. started, playing, or active)
    @objc open dynamic var isStarted: Bool {
        return internalAU?.isPlaying() ?? false
    }

    // MARK: - Initialization

    /// Initialize the mandolin with defaults
    override convenience init() {
        self.init(frequency: 110)
    }

    /// Initialize the STK Flute model
    ///
    /// - Parameters:
    ///   - frequency: Variable frequency. Values less than the initial frequency will be doubled until it is
    ///                greater than that.
    ///   - amplitude: Amplitude
    ///
    public init(
        frequency: Double = 440,
        amplitude: Double = 0.5) {

        self.frequency = frequency
        self.amplitude = amplitude

        _Self.register()

        super.init()
        AVAudioUnit._instantiate(with: _Self.ComponentDescription) { [weak self] avAudioUnit in

            self?.avAudioNode = avAudioUnit
            self?.internalAU = avAudioUnit.auAudioUnit as? AKAudioUnitType
        }

        guard let tree = internalAU?.parameterTree else {
            return
        }

        frequencyParameter = tree["frequency"]
        amplitudeParameter = tree["amplitude"]

        token = tree.token (byAddingParameterObserver: { [weak self] address, value in

            DispatchQueue.main.async {
                if address == self?.frequencyParameter?.address {
                    self?.frequency = Double(value)
                } else if address == self?.amplitudeParameter?.address {
                    self?.amplitude = Double(value)
                }
            }
        })
        internalAU?.frequency = Float(frequency)
        internalAU?.amplitude = Float(amplitude)
    }

    /// Trigger the sound with an optional set of parameters
    ///   - frequency: Frequency in Hz
    /// - amplitude amplitude: Volume
    ///
    open func trigger(frequency: Double, amplitude: Double = 1) {
        self.frequency = frequency
        self.amplitude = amplitude
        internalAU?.start()
        internalAU?.triggerFrequency(Float(frequency), amplitude: Float(amplitude))
    }

    /// Function to start, play, or activate the node, all do the same thing
    open func start() {
        internalAU?.start()
    }

    /// Function to stop or bypass the node, both are equivalent
    open func stop() {
        internalAU?.stop()
    }
}
