% QPSK Digital Communication System Simulation
% Using Monte Carlo Method for BER (Bit Error Rate) Performance Analysis

clear; clc;
% Monte Carlo Simulation Configuration
numBitsPerBlock  = 1e5;     % Number of bits per transmission block
minErrorEvents   = 100;     % Minimum error events
maxBitsSimulated = 1e6;     % Maximum bits to simulate
ebNoDbRange      = -1:8;    % Eb/N0 range

% QPSK
M = 4;
esNoDbRange = ebNoDbRange + 10*log10(log2(M));

% BER storage vector
bitErrorRate = zeros(1, length(ebNoDbRange));

for snrIndex = 1:length(ebNoDbRange)
    accumulatedErrors = 0;    % Cumulative error events
    processedBits     = 0;    % Total processed bits
    
    % Monte Carlo iteration loop
    while((accumulatedErrors < minErrorEvents) && (processedBits < maxBitsSimulated))
        % -----Source-----
        % Generate random binary information sequence
        transmittedBits = randi([0, 1], 1, numBitsPerBlock);
        
        % -----Modulator-----
        % Gray-coded QPSK symbol mapping
        inPhaseData = transmittedBits(1:2:end);
        quadData    = transmittedBits(2:2:end);
        qpskSymbols = (1 - 2*inPhaseData) + 1j * (1 - 2*quadData);
        
        % -----Channel-----
        % Additive White Gaussian Noise
        receivedSymbols = add_awgn_noise(qpskSymbols, esNoDbRange(snrIndex));
        
        % -----Demodulator-----
        detectedInPhase = real(receivedSymbols) < 0;
        detectedQuad    = imag(receivedSymbols) < 0;
        
        % Symbol to Bits
        detectedBits = reshape([detectedInPhase; detectedQuad], 1, []);
        
        % Error Analysis
        blockErrors       = sum((transmittedBits ~= detectedBits));
        accumulatedErrors = accumulatedErrors + blockErrors;
        processedBits     = processedBits + numBitsPerBlock;
        
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
ebNoLinear = 10.^(ebNoDbRange/10);
theoreticalBer = qfunc(sqrt(2*ebNoLinear));

% Performance Visualization
figure('Position', [100 100 800 600]);

% Plot configuration
plotLineWidth = 2;
markerSize = 17;

% Monte Carlo simulation results
semilogy(ebNoDbRange, bitErrorRate, 'b.', ...
         'MarkerSize', markerSize, ...
         'DisplayName', 'Simulated BER');
hold on;

% Theoretical bound
semilogy(ebNoDbRange, theoreticalBer, 'b-', ...
         'LineWidth', plotLineWidth, ...
         'DisplayName', 'Theoretical BER');

% Plot aesthetics
grid on;
ylim([1e-4 1]);
xlim([min(ebNoDbRange) max(ebNoDbRange)]);
xlabel('$E_b/N_0$ (dB)', 'FontSize', 12, 'Interpreter', 'latex');
ylabel('Bit Error Rate (BER)', 'FontSize', 12, 'Interpreter', 'latex');
title('QPSK Performance Analysis: Simulated vs Theoretical', ...
      'FontSize', 14, 'Interpreter', 'latex');
legend('Location', 'southwest', 'FontSize', 10);
legend('boxoff');
set(gcf, 'Color', 'white');
set(gca, 'FontSize', 11);