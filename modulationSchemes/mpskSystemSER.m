% M-PSK Symbol Error Rate (SER) Simulation
clear; clc;

% Monte Carlo Simulation
numSymsPerBlock   = 1e5;      % Number of symbols per simulation block
minSymErrEvents   = 100;      % Minimum number of symbol errors to collect
maxSymsSimulated  = 1e6;      % Maximum number of symbols to simulate
ebNoDbRange       = -1:25;    % Eb/N0 range in dB

% Modulation Order
Mset = [2, 4, 8, 16, 32, 64]; % M-PSK modulation orders

% Storage vector for SER results
symErrorRate = zeros(1, length(ebNoDbRange));

% Create a figure
figure('Position', [60 60 950 950]);
colors = lines(length(Mset));
markers = {'o', 's', 'd', '^', 'v', 'p'};

for mIndex = 1:length(Mset)
    M = Mset(mIndex);
    k = log2(M); esNoDbRange = ebNoDbRange + 10*log10(k);
    for snrIndex = 1:length(ebNoDbRange)
        accumulatedSymErr = 0;    % Total number of symbol errors accumulated
        processedSyms     = 0;    % Total number of symbols processed
        
        % Monte Carlo Iteration
        while (accumulatedSymErr < minSymErrEvents) && (processedSyms < maxSymsSimulated)
            % Transmitter
            % Generate random transmitted symbol indices (0 ... M-1)
            txSyms = randi([0, M-1], numSymsPerBlock, 1);
            
            % Modulator
            % Gray-coded MPSK with phase offset pi/M (standard for M-PSK)
            s = pskmod(txSyms, M, pi/M, 'gray');
            
            % Channel
            % Add complex AWGN according to Es/N0 (dB)
            r = add_awgn_noise(s, esNoDbRange(snrIndex));
            
            % Demodulator
            rxSyms = pskdemod(r, M, pi/M, 'gray');
            
            % Symbol Error Counting
            symErrs           = sum(txSyms ~= rxSyms);
            accumulatedSymErr = accumulatedSymErr + symErrs;
            processedSyms     = processedSyms + numSymsPerBlock;
            
            % Progress Display
            fprintf('M=%2d | Eb/N0=%2d dB | %d/%d symbol errors, %d/%d symbols | SER=%10.2e\r', ...
                M, ebNoDbRange(snrIndex), ...
                accumulatedSymErr, minSymErrEvents, ...
                processedSyms, maxSymsSimulated, ...
                accumulatedSymErr/max(1,processedSyms));
        end
        fprintf('\n');
        symErrorRate(snrIndex) = accumulatedSymErr / processedSyms;
    end
    % Theoretical Symbol Error Rate
    EbN0linear = 10.^(ebNoDbRange/10);
    EsN0linear = EbN0linear * k;
    
    if M == 2
        % BPSK exact SER (same as BER)
        theoreticalSER = qfunc(sqrt(2*EbN0linear));
    else
        % M-PSK approximate SER
        theoreticalSER = 2 * qfunc(sqrt(2*EsN0linear) * sin(pi/M));
        theoreticalSER = min(theoreticalSER, 1);
    end
    
    % Visualization
    % Plot simulated results with markers
    semilogy(ebNoDbRange, symErrorRate, ...
        'Marker', markers{mIndex}, 'MarkerSize', 10, ...
        'MarkerEdgeColor', colors(mIndex,:), 'MarkerFaceColor', colors(mIndex,:), ...
        'LineWidth', 0.5, 'LineStyle', 'none', ...
        'DisplayName', sprintf('M=%d (Sim)', M)); hold on;
    
    % Plot theoretical results with solid lines
    semilogy(ebNoDbRange, theoreticalSER, ...
        'Color', colors(mIndex,:), 'LineWidth', 2, 'LineStyle', '-', ...
        'DisplayName', sprintf('M=%d (Theory)', M));
end

% Final Plot Formatting
grid on;
ylim([1e-5 1]);
xlim([min(ebNoDbRange) max(ebNoDbRange)]);
xlabel('$E_b/N_0$ (dB)', 'Interpreter','latex', 'FontSize',12);
ylabel('Symbol Error Rate (SER)', 'Interpreter','latex', 'FontSize',12);
title('M-PSK Symbol Error Rate', 'FontSize',14);
legend('Location','southwest', 'NumColumns', 2); legend boxoff;
set(gcf,'Color','white');
set(gca,'FontSize',11);