% =========================================================

% Hamming (7, 4) + QPSK + AWGN Simulation 

% X축: SNR (Es/N0) [dB]

% =========================================================



%% ---- Hamming 파라미터 설정 ----

m = 3;                       % Parity bits
n_ham = 2^m - 1;             % Codeword length = 7
k_ham = n_ham - m;           % Message length = 4
params.m = m;
params.en = 1;               % Hamming 모드 활성화

fprintf('========================================\n');
fprintf('  Hamming (%d, %d) Simulation\n', n_ham, k_ham);
fprintf('  변조: QPSK,  채널: AWGN\n');
fprintf('  X축: SNR = Es/N0 [dB]\n');
fprintf('========================================\n\n');



%% ---- 시뮬레이션 파라미터 ----

SNR_dB_vec        = 0:1:12;       % SNR (Es/N0) [dB]

num_errors_target = 150;          % 통계적 신뢰성을 위한 에러 타겟

max_frames        = 1000000;

bits_per_symbol   = 2;            % QPSK

code_rate         = k_ham / n_ham; % Hamming(7,4) 코드율



%% ---- 결과 저장 변수 ----

BER_coded   = zeros(1, length(SNR_dB_vec));

BER_uncoded = zeros(1, length(SNR_dB_vec));

FER_coded   = zeros(1, length(SNR_dB_vec));



%% ---- 메인 루프 ----

for idx = 1:length(SNR_dB_vec)

    SNR_dB  = SNR_dB_vec(idx);

    SNR_lin = 10^(SNR_dB / 10);   % Es/N0 (linear)



    % 노이즈 표준편차 (이전 분석 결과 반영: Q(sqrt(Es/N0)) 기준)

    sigma = sqrt(1 / (2 * SNR_lin));

    

    bit_err_coded   = 0;

    bit_err_uncoded = 0;

    frame_err_coded = 0;

    total_bits      = 0;

    total_frames    = 0;



    for frame = 1:max_frames

        %% 정보 비트 생성

        info_bits = randi([0 1], 1, k_ham);



        %% ================================================

        %%  CODED 경로 (Hamming + QPSK)

        %% ================================================

        % Hamming 인코딩 (7비트 생성)

        codeword = SigEncoder(info_bits, params);



        % QPSK 변조를 위해 8비트로 패딩 (7비트 -> 8비트, 4심볼)

        cw_padded = [codeword, 0];

        b1_c = cw_padded(1:2:end);

        b2_c = cw_padded(2:2:end);

        tx_c = ((1-2*b1_c) + 1j*(1-2*b2_c)) / sqrt(2);



        % AWGN 채널

        noise_c = sigma * (randn(1,length(tx_c)) + 1j*randn(1,length(tx_c)));

        rx_c    = tx_c + noise_c;



        % QPSK 복조

        rx_bits_p          = zeros(1, 8);

        rx_bits_p(1:2:end) = double(real(rx_c) < 0);

        rx_bits_p(2:2:end) = double(imag(rx_c) < 0);

        rx_bits_c          = rx_bits_p(1:7); % 패딩 제거



        % Hamming 디코딩

        [dec_info, corrected] = SigDecoder(rx_bits_c, params);



        % 에러 계산

        berr = sum(dec_info ~= info_bits);

        bit_err_coded = bit_err_coded + berr;

        if berr > 0

            frame_err_coded = frame_err_coded + 1;

        end



        %% ================================================

        %%  UNCODED 경로 (QPSK only)

        %% ================================================

        % 동일 SNR에서 4비트 전송 (2심볼)

        b1_u = info_bits(1:2:end);

        b2_u = info_bits(2:2:end);

        tx_u = ((1-2*b1_u) + 1j*(1-2*b2_u)) / sqrt(2);



        noise_u = sigma * (randn(1,length(tx_u)) + 1j*randn(1,length(tx_u)));

        rx_u    = tx_u + noise_u;

        

        rx_unc          = zeros(1, 4);

        rx_unc(1:2:end) = double(real(rx_u) < 0);

        rx_unc(2:2:end) = double(imag(rx_u) < 0);



        bit_err_uncoded = bit_err_uncoded + sum(rx_unc ~= info_bits);



        total_bits   = total_bits + k_ham;

        total_frames = total_frames + 1;



        if (bit_err_coded >= num_errors_target) && (frame >= 1000)

            break;

        end

    end



    BER_coded(idx)   = bit_err_coded   / total_bits;

    BER_uncoded(idx) = bit_err_uncoded / total_bits;

    FER_coded(idx)   = frame_err_coded / total_frames;



    fprintf('SNR=%2d dB | BER(Ham)=%.2e | BER(Unc)=%.2e | FER=%.2e | frames=%d\n', ...  
        SNR_dB, BER_coded(idx), BER_uncoded(idx), FER_coded(idx), total_frames);

end



%% ---- 결과 시각화 ----

figure('Position', [100 100 800 600]);



% 수정된 QPSK 이론 BER (SNR = Es/N0 기준)

SNR_th  = 0:0.1:SNR_dB_vec(end);

BER_th  = 0.5 * erfc(sqrt(10.^(SNR_th/10) / 2)); 



subplot(2,1,1);

semilogy(SNR_dB_vec, BER_uncoded, 'bs-', 'LineWidth', 2); hold on;

semilogy(SNR_dB_vec, BER_coded,   'ro-', 'LineWidth', 2);

semilogy(SNR_th,     BER_th,      'k--', 'LineWidth', 1.5);

grid on;

xlabel('SNR = Es/N0 (dB)'); ylabel('BER');

title(sprintf('Hamming(%d,%d) Performance over AWGN', n_ham, k_ham));

legend('Uncoded (Sim)', 'Hamming Coded (Sim)', 'QPSK Theory', 'Location', 'SouthWest');

ylim([1e-6 1]);



subplot(2,1,2);

semilogy(SNR_dB_vec, FER_coded, 'ro-', 'LineWidth', 2);

grid on;

xlabel('SNR (dB)'); ylabel('FER');

title('Hamming Coded FER');

ylim([1e-5 1]);



fprintf('\nSimulation complete!\n');
