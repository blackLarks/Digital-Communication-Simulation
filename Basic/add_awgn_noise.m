function receivedSignal = add_awgn_noise(transmittedSymbols, signalToNoiseRatioDb)
% add_awgn_noise Simulates an Additive White Gaussian Noise (AWGN) channel
%
% This function models the effects of thermal noise in a communication channel
% by adding complex Gaussian noise to the transmitted signal. The noise power
% is calculated based on the desired signal-to-noise ratio (SNR).
%
% Theory:
%   - AWGN is a fundamental channel model in communications
%   - The noise is "additive" because it's added to the signal
%   - "White" means the noise has uniform power across all frequencies
%   - "Gaussian" refers to the normal distribution of noise amplitudes
%
% Inputs:
%   transmittedSymbols  - Complex baseband symbols (e.g., QPSK constellation points)
%   signalToNoiseRatioDb - Energy per symbol to noise density ratio (Es/N0) in dB
%
% Output:
%   receivedSignal     - Transmitted symbols corrupted by AWGN
%
% Example:
%   receivedSignal = addAwgnChannel(qpskSymbols, 10) % Add noise at 10dB Es/N0

    % Convert signal-to-noise ratio from dB to linear scale
    % SNR(linear) = 10^(SNR(dB)/10)
    signalToNoiseRatioLinear = 10^(signalToNoiseRatioDb/10);
    
    % Calculate average signal power
    % P = (1/N) * Σ|x[n]|²
    symbolCount = length(transmittedSymbols);
    signalPower = sum(abs(transmittedSymbols).^2) / symbolCount;
    
    % Calculate noise power spectral density (N0)
    % Using the relation: Es/N0 = SignalPower/NoisePower
    noiseDensity = signalPower / signalToNoiseRatioLinear;
    
    % Generate complex Gaussian noise
    % - Real and imaginary parts are independent
    % - Each component has variance = noiseDensity/2
    % - Factor of 1/2 ensures total noise power equals noiseDensity
    noiseStdDev = sqrt(noiseDensity/2);
    noiseReal = noiseStdDev * randn(size(transmittedSymbols));
    noiseImag = noiseStdDev * randn(size(transmittedSymbols));
    noiseComplex = noiseReal + 1j*noiseImag;
    
    % Add noise to transmitted signal
    % Received signal = transmitted signal + noise
    receivedSignal = transmittedSymbols + noiseComplex;
    
    % Note: The received signal now has the following properties:
    % 1. Signal component preserved exactly
    % 2. Noise component is complex Gaussian
    % 3. Signal-to-noise ratio matches specified Es/N0
end