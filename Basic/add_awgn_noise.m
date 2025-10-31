function receivedSignal = add_awgn_noise(transmittedSymbols, signalToNoiseRatioDb)
% Add complex AWGN to baseband symbols by Es/N0 (dB).
% 
% Inputs:
%   transmittedSymbols   - Complex baseband symbols
%   signalToNoiseRatioDb - Energy per symbol to noise density ratio (Es/N0) in dB
%
% Output:
%   receivedSignal       - Transmitted symbols corrupted by AWGN

% Convert signal-to-noise ratio from dB to linear scale
signalToNoiseRatioLinear = 10^(signalToNoiseRatioDb/10);

% Calculate average signal power
symbolCount  = length(transmittedSymbols);
signalPower  = sum(abs(transmittedSymbols).^2) / symbolCount;

% Calculate noise power spectral density (N0)
noiseDensity = signalPower / signalToNoiseRatioLinear;

% Generate complex Gaussian noise
noiseStdDev  = sqrt(noiseDensity/2);
noiseReal    = noiseStdDev * randn(size(transmittedSymbols));
noiseImag    = noiseStdDev * randn(size(transmittedSymbols));
noiseComplex = noiseReal + 1j*noiseImag;

% Add noise to transmitted signal
receivedSignal = transmittedSymbols + noiseComplex;

end