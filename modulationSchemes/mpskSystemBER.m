% M-PSK Bit Error Rate (BER) Simulation
clear; clc;

% Monte Carlo Simulation Parameters
numSymsPerBlock   = 1e5;      % Number of symbols processed per Monte Carlo block
minBitErrEvents   = 100;      % Minimum number of bit errors to collect for each SNR point
maxSymsSimulated  = 1e6;      % Safety cap on the number of simulated symbols
ebNoDbRange       = -1:25;    % Eb/N0 range in dB

% Modulation Orders Under Test
Mset = [2, 4, 8, 16, 32, 64]; % M-PSK modulation orders (Gray coded)

% Storage vector for BER results (re-used for each constellation order)
bitErrorRate = zeros(1, length(ebNoDbRange));

% Create a figure for the BER comparison
figure('Position', [60 60 950 950]);
colors  = lines(length(Mset));
markers = {'o', 's', 'd', '^', 'v', 'p'};

for mIndex = 1:length(Mset)
    M = Mset(mIndex);
    k = log2(M);                                % Bits per symbol
    esNoDbRange = ebNoDbRange + 10*log10(k);    % Convert Eb/N0 to Es/N0 in dB
    maxBitsSimulated = maxSymsSimulated * k;    % Safety cap on the number of simulated bits

    for snrIndex = 1:length(ebNoDbRange)
        accumulatedBitErr = 0;   % Total number of bit errors accumulated
        processedSyms      = 0;   % Total number of symbols processed
        processedBits      = 0;   % Total number of bits processed
        
        % Monte Carlo Iteration
        while (accumulatedBitErr < minBitErrEvents) && (processedBits < maxBitsSimulated)
            % Transmitter: Gray-coded symbol generation (0 ... M-1)
            txSyms = randi([0, M-1], numSymsPerBlock, 1);
            
            % Modulator: Gray-coded M-PSK with phase offset pi/M (Matlab standard)
            s = pskmod(txSyms, M, pi/M, 'gray');
            
            % Channel: Add complex AWGN according to Es/N0 (dB)
            r = add_awgn_noise(s, esNoDbRange(snrIndex));
            
            % Demodulator: Gray-coded symbol decisions
            rxSyms = pskdemod(r, M, pi/M, 'gray');
            
            % Bit Error Counting: convert symbols to bit labels (MSB-first)
            txBits = de2bi(txSyms, k, 'left-msb');
            rxBits = de2bi(rxSyms, k, 'left-msb');
            bitErrs = sum(txBits(:) ~= rxBits(:));
            
            accumulatedBitErr = accumulatedBitErr + bitErrs;
            processedSyms     = processedSyms + numSymsPerBlock;
            processedBits     = processedSyms * k;
            
            % Progress Display in Command Window
            fprintf('M=%2d | Eb/N0=%2d dB | %d/%d bit errors, %d/%d bits | BER=%10.2e\r', ...
                M, ebNoDbRange(snrIndex), ...
                accumulatedBitErr, minBitErrEvents, ...
                processedBits, maxBitsSimulated, ...
                accumulatedBitErr / max(1, processedBits));
        end
        fprintf('\n');
        bitErrorRate(snrIndex) = accumulatedBitErr / max(1, processedBits);
    end

    % Theoretical Bit Error Rate for Gray-coded M-PSK
    EbN0linear = 10.^(ebNoDbRange/10);
    EsN0linear = EbN0linear * k;

    % Analytical built-in BER, exact for coherent Gray-coded M-PSK)
    theoreticalBER = berawgn(ebNoDbRange, 'psk', M, 'nondiff');

    % Visualization: simulated BER (markers) & theoretical BER (lines)
    semilogy(ebNoDbRange, bitErrorRate, ...
        'Marker', markers{mIndex}, 'MarkerSize', 10, ...
        'MarkerEdgeColor', colors(mIndex,:), 'MarkerFaceColor', colors(mIndex,:), ...
        'LineWidth', 0.5, 'LineStyle', 'none', ...
        'DisplayName', sprintf('M=%d (Sim)', M)); hold on;

    semilogy(ebNoDbRange, theoreticalBER, ...
        'Color', colors(mIndex,:), 'LineWidth', 2, 'LineStyle', '-', ...
        'DisplayName', sprintf('M=%d (Theory)', M));
end

% Final Plot Formatting
grid on;
ylim([1e-6 1]);
xlim([min(ebNoDbRange) max(ebNoDbRange)]);
xlabel('$E_b/N_0$ (dB)', 'Interpreter','latex', 'FontSize',12);
ylabel('Bit Error Rate (BER)', 'Interpreter','latex', 'FontSize',12);
title('M-PSK Bit Error Rate Comparison', 'FontSize',14);
legend('Location','southwest', 'NumColumns', 2); legend boxoff;
set(gcf,'Color','white');
set(gca,'FontSize',11);