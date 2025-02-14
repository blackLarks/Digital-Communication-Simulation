% QPSK (Quadrature Phase Shift Keying) Digital Communication System Simulation
% Using Monte Carlo Method for BER (Bit Error Rate) Performance Analysis
% Monte Carlo principle: Estimate system performance through repeated random sampling

% Monte Carlo Simulation Configuration
numBitsPerBlock = 1e5;    % Number of bits per transmission block
                          % Statistical accuracy improves with larger blocks
minErrorEvents = 100;     % Minimum error events for statistical confidence
                          % Based on confidence interval requirements
maxBitsSimulated = 1e6;   % Maximum bits to simulate (simulation bound)
                          % Prevents excessive runtime while ensuring accuracy

% Signal-to-Noise Ratio Configuration
% Eb/N0: Energy per bit to noise power spectral density ratio
% Key metric for comparing different modulation schemes
ebNoDbRange = -1:8;       % Range of Eb/N0 values in decibels
                          % Typical range for QPSK performance evaluation

% QPSK Energy Normalization
% QPSK symbol energy (Es) to noise ratio calculation
% Es/N0 = Eb/N0 + 10log10(log2(M)), where M = 4 for QPSK
esNoDbRange = ebNoDbRange + 10*log10(log2(4));  

% Performance Metric Initialization
bitErrorRate = zeros(1, length(ebNoDbRange));  % BER storage vector

% Monte Carlo Simulation Core
for snrIndex = 1:length(ebNoDbRange)
    % Performance metric counters
    accumulatedErrors = 0;    % Cumulative error events
    processedBits = 0;        % Total processed bits
    
    % Monte Carlo iteration loop
    % Continues until statistical confidence is achieved
    while((accumulatedErrors < minErrorEvents) && (processedBits < maxBitsSimulated))
        % Transmitter
        % Generate random binary information sequence
        transmittedBits = randi([0, 1], 1, numBitsPerBlock);
        
        % QPSK Modulator
        % Gray-coded QPSK symbol mapping
        % Maps bit pairs to complex constellation points
        inPhaseData = transmittedBits(1:2:end);    % I-channel bits
        quadData = transmittedBits(2:2:end);       % Q-channel bits
        qpskSymbols = (1 - 2*inPhaseData) + 1j * (1 - 2*quadData);
        
        % Channel
        % AWGN (Additive White Gaussian Noise) channel simulation
        receivedSymbols = add_awgn_noise(qpskSymbols, esNoDbRange(snrIndex));
        
        % QPSK Demodulator
        % Optimal detection for AWGN channel
        detectedInPhase = real(receivedSymbols) < 0;  % I-channel detection
        detectedQuad = imag(receivedSymbols) < 0;     % Q-channel detection
        
        % Reconstruct bit stream from symbol decisions
        detectedBits = reshape([detectedInPhase; detectedQuad], 1, []);
        
        % Error Analysis
        % Bit error counting
        blockErrors = sum((transmittedBits ~= detectedBits));
        accumulatedErrors = accumulatedErrors + blockErrors;
        processedBits = processedBits + numBitsPerBlock;
        
        % Progress monitoring
        fprintf('Monte Carlo Progress: %d/%d errors, %d/%d bits, BER = %10.1e\n', ...
                accumulatedErrors, minErrorEvents, ...
                processedBits, maxBitsSimulated, ...
                accumulatedErrors/processedBits);
    end
    
    % Calculate empirical BER for current Eb/N0
    bitErrorRate(snrIndex) = accumulatedErrors/processedBits;
end

% Theoretical Performance Bound
% Calculate theoretical QPSK BER in AWGN
% QPSK BER = BPSK BER due to orthogonal channels
ebNoLinear = 10.^(ebNoDbRange/10);                    % Convert dB to linear
theoreticalBer = qfunc(sqrt(2*ebNoLinear));           % Q-function for QPSK

% Performance Visualization
figure('Position', [100 100 800 600]);

% Plot configuration
plotLineWidth = 2;
markerSize = 17;

% Monte Carlo simulation results
semilogy(ebNoDbRange, bitErrorRate, 'b.', ...
         'MarkerSize', markerSize, ...
         'DisplayName', 'Monte Carlo Simulation');
hold on;

% Theoretical bound
semilogy(ebNoDbRange, theoreticalBer, 'b-', ...
         'LineWidth', plotLineWidth, ...
         'DisplayName', 'Theoretical Bound');

% Plot aesthetics
grid on;
ylim([1e-4 1]);
xlim([min(ebNoDbRange) max(ebNoDbRange)]);
xlabel('$E_b/N_0$ (dB)', 'FontSize', 12, 'Interpreter', 'latex');
ylabel('Bit Error Rate (BER)', 'FontSize', 12, 'Interpreter', 'latex');
title('QPSK Performance Analysis: Monte Carlo vs Theoretical', ...
      'FontSize', 14, 'Interpreter', 'latex');
legend('Location', 'southwest', 'FontSize', 10);
legend('boxoff');
set(gcf, 'Color', 'white');
set(gca, 'FontSize', 11);