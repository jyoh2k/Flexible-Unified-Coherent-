% =========================================================
% BCH Shortened(62, 35) + QPSK + AWGN Simulation 
% X축: SNR (Es/N0) [dB]
% =========================================================

% close all; clc;

%% ---- BCH 파라미터 ----
N_bch = 63;
K_bch = 36; 

N_s = N_bch - 1;   % shortened: 62
K_s = K_bch - 1;   % shortened: 35
 
params.en = 2;
params.n = N_s;
params.k = K_s;

fprintf('========================================\n');
fprintf('  BCH Shortened (%d, %d) Simulation\n', N_s, K_s);
fprintf('  기반 BCH(%d, %d)\n', N_bch, K_bch);
fprintf('  변조: QPSK,  채널: AWGN\n');
fprintf('  X축: SNR = Es/N0 [dB]\n');
fprintf('========================================\n\n');


%% ---- 시뮬레이션 파라미터 ----
SNR_dB_vec        = 0:1:13;       % SNR (Es/N0) [dB]
num_errors_target = 1000;
max_frames        = 1000000;
bits_per_symbol   = 2;            % QPSK: 2 bits/symbol
code_rate         = K_s / N_s;    % BCH 코드율


% ---- SNR <-> Eb/N0 변환 관계 ----
% SNR (Es/N0) = Eb/N0 * bits_per_symbol        (uncoded)
% SNR (Es/N0) = Eb/N0 * bits_per_symbol * R    (coded, R=code_rate)
%
% 노이즈 분산: sigma^2 = 1 / (2 * SNR_linear)
%   -> sigma = sqrt(1 / (2 * SNR_linear))
%
% 단, coded/uncoded 는 동일 SNR 기준으로 비교
% (같은 전송 파워, 같은 대역폭 가정)


%% ---- 결과 저장 ----
BER_coded   = zeros(1, length(SNR_dB_vec));
BER_uncoded = zeros(1, length(SNR_dB_vec));
FER_coded   = zeros(1, length(SNR_dB_vec));
%% ---- 메인 루프 ----
for idx = 1:length(SNR_dB_vec)
    SNR_dB  = SNR_dB_vec(idx);
    SNR_lin = 10^(SNR_dB / 10);   % Es/N0 (linear)

    % 노이즈 표준편차 (단위 에너지 심볼 기준, I/Q 각 성분)
    sigma = sqrt(1 / (2 * SNR_lin));
    bit_err_coded   = 0;
    bit_err_uncoded = 0;
    frame_err_coded = 0;
    total_bits      = 0;
    total_frames    = 0;

    for frame = 1:max_frames
        %% 정보 비트 생성
        info_bits = randi([0 1], 1, K_s);
        %% ================================================
        %%  CODED 경로 (BCH + QPSK)
        %% ================================================

        % Shortened BCH 인코딩
        codeword  = SigEncoder( info_bits,  params );

        % QPSK 변조 (62비트 -> 31심볼)
        b1_c = codeword(1:2:end);
        b2_c = codeword(2:2:end);
        tx_c = ((1-2*b1_c) + 1j*(1-2*b2_c)) / sqrt(2);

        % AWGN (coded와 uncoded 동일한 sigma 사용 = 동일 SNR 비교)
        noise_c = sigma * (randn(1,length(tx_c)) + 1j*randn(1,length(tx_c)));
        rx_c    = tx_c + noise_c;


        % QPSK 복조
        rx_bits_c          = zeros(1, N_s);

        rx_bits_c(1:2:end) = double(real(rx_c) < 0);
        rx_bits_c(2:2:end) = double(imag(rx_c) < 0);

        % Shortened BCH 디코딩
        rx_full = [0, rx_bits_c];
        [dec_info, cnumerr] = SigDecoder( rx_bits_c, params );

        berr = sum(dec_info ~= info_bits);
        bit_err_coded = bit_err_coded + berr;
        if berr > 0
            frame_err_coded = frame_err_coded + 1;
        end


        %% ================================================
        %%  UNCODED 경로 (QPSK only)
        %%  동일 SNR, K_s 비트 전송 (1패딩 -> 36비트 -> 18심볼)
        %% ================================================

        unc_tx_bits = [info_bits, 0];   % 36비트
        b1_u = unc_tx_bits(1:2:end);
        b2_u = unc_tx_bits(2:2:end);
        tx_u = ((1-2*b1_u) + 1j*(1-2*b2_u)) / sqrt(2);


        noise_u = sigma * (randn(1,length(tx_u)) + 1j*randn(1,length(tx_u)));
        rx_u    = tx_u + noise_u;
        rx_unc          = zeros(1, 36);
        rx_unc(1:2:end) = double(real(rx_u) < 0);
        rx_unc(2:2:end) = double(imag(rx_u) < 0);
        rx_unc = rx_unc(1:K_s);

        bit_err_uncoded = bit_err_uncoded + sum(rx_unc ~= info_bits);

        total_bits   = total_bits + K_s;
        total_frames = total_frames + 1;

        if (bit_err_coded >= num_errors_target) && (frame >= 500)
            break;
        end
    end


    BER_coded(idx)   = bit_err_coded   / total_bits;
    BER_uncoded(idx) = bit_err_uncoded / total_bits;
    FER_coded(idx)   = frame_err_coded / total_frames;


    % Eb/N0 환산값도 함께 출력 (참고용)
    EbN0_coded_dB   = SNR_dB - 10*log10(bits_per_symbol * code_rate);
    EbN0_uncoded_dB = SNR_dB - 10*log10(bits_per_symbol);


    fprintf('SNR=%2d dB | BER(BCH)=%.2e |  BER(Unc)=%.2e |  FER=%.2e | fr=%d\n', ...  
        SNR_dB,   ...  
        BER_coded(idx), BER_uncoded(idx), FER_coded(idx), total_frames);
end



%% ---- 플롯 ----
figure('Position', [100 100 820 640]);

% QPSK 이론 BER: BER = 0.5*erfc(sqrt(Es/(2N0)))
SNR_th  = 0:0.1:12;
BER_th  = 0.5 * erfc(sqrt(10.^(SNR_th/10))* sqrt(1/2));

subplot(2,1,1);
semilogy(SNR_dB_vec, BER_uncoded, 'bs-', 'LineWidth', 2, 'MarkerSize', 8); hold on;
semilogy(SNR_dB_vec, BER_coded,   'ro-', 'LineWidth', 2, 'MarkerSize', 8);
semilogy(SNR_th,     BER_th,      'b--', 'LineWidth', 1.5);
grid on;
xlabel('SNR = Es/N0 (dB)', 'FontSize', 12);
ylabel('BER', 'FontSize', 12);
title(sprintf('BCH Shortened(%d,%d) + QPSK / AWGN  [SNR 기준]', N_s, K_s), 'FontSize', 13);

legend('Uncoded QPSK (Sim)', ...  
       sprintf('BCH(%d,%d)+QPSK (Sim)', N_s, K_s), ...  
       'Uncoded QPSK (Theory)', ...  
       'Location', 'SouthWest');
ylim([1e-7 1]); xlim([SNR_dB_vec(1) SNR_dB_vec(end)]);



subplot(2,1,2);
semilogy(SNR_dB_vec, FER_coded, 'ro-', 'LineWidth', 2, 'MarkerSize', 8);
grid on;
xlabel('SNR (dB)', 'FontSize', 12);
ylabel('FER', 'FontSize', 12);
title(sprintf('BCH Shortened(%d,%d) FER / AWGN  [SNR 기준]', N_s, K_s), 'FontSize', 13);
legend(sprintf('BCH(%d,%d)+QPSK', N_s, K_s), 'Location', 'SouthWest');
ylim([1e-6 1]); xlim([SNR_dB_vec(1) SNR_dB_vec(end)]);

fprintf('\nSimulation complete!\n');
