//
//  adsrEnvelope.swift
//  AudioKit
//
//  Created by Aurelius Prochazka, revision history on Github.
//  Copyright © 2017 Aurelius Prochazka. All rights reserved.
//

extension AKOperation {

    /// Gate based linear AHD envelope generator
    ///
    /// - Parameters:
    ///   - gate: 1 for on and 0 for off
    ///   - attack: Attack time, in seconds. (Default: 0.1)
    ///   - hold: Hold time, in seconds. (Default: 0.3)
    ///   - release: Release time, in seconds. (Default: 0.2)
    ///
    public func gatedADSREnvelope(
        gate: AKParameter,
        attack: AKParameter = 0.1,
        decay: AKParameter = 0.0,
        sustain: AKParameter = 1,
        release: AKParameter = 0.2
        ) -> AKOperation {
        return AKOperation(module:  "adsr *", inputs: toMono(), gate, attack, decay, sustain, release)
    }
}
