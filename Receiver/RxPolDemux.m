function [AOUT, pol] = RxPolDemux( AIN, trainingseq, params )
% RXPOLDEMUX  Training sequence correlation 기반 1-tap Dual-Polarization Demux
%
% 입력:
%   AIN          : 2 x d2, 수신 신호 [Rx; Ry] (X/Y 편광, oversampled)
%                  Timing 동기화가 완료되어 있어, 첫 training 심볼의
%                  center 샘플이 AIN(:, params.trainStartIdx)에 위치한다고 가정
%   trainingseq  : 2 x M, 기지(known) training 심볼 [Sx; Sy] (symbol-rate)
%   params       : struct
%       .OV                   : oversampling factor (samples/symbol)
%       .num_symbol_for_demux : 채널 추정에 사용할 training 심볼 개수 (짝수 권장)
%       .trainStartIdx        : (옵션) AIN 내 training 시작 샘플 인덱스, 기본 1
%       .UseUnitary           : (옵션) true면 무손실 유니터리 가정, 역행렬 대신
%                                정규화된 켤레전치(H^dagger) 사용. 기본 true
%
% 출력:
%   AOUT : 2 x d2, 역다중화(equalization) 완료된 심볼 시퀀스
%   pol  : struct, 추정 채널/역행렬 및 진단 정보
%       .H      : 추정된 2x2 Jones 채널 행렬
%       .Hinv   : demux(equalization)에 사용된 2x2 행렬
%       .rcondSS: training 자기상관 행렬의 rcond (직교성/조건수 진단)
%
%  Author     : Rha, Hae Young.
%  Contact    : hyrha@miroandi.com   
%  Known bugs :

    [d1, d2] = size(AIN); %#ok<ASGLU>
    OV                    = params.OV; 

    if isfield(params, 'num_symbol_for_demux')
        num_symbol_for_demux = params.num_symbol_for_demux;
    else
        num_symbol_for_demux = 256;    
    end
    
    if isfield(params, 'trainStartIdx')
        trainStartIdx = params.trainStartIdx;
    else
        trainStartIdx = 1;   % 기본: training이 AIN 맨 앞에서 시작
    end

    if isfield(params, 'UseUnitary')
        useUnitary = params.UseUnitary;
    else
        useUnitary = true;   % 기본: 손실 무시(회전만) 가정
    end

    if mod(num_symbol_for_demux, 2) ~= 0
        error('num_symbol_for_demux는 짝수여야 합니다 (2-symbol 블록 처리).');
    end
    if num_symbol_for_demux > size(trainingseq, 2)
        error('num_symbol_for_demux(%d)가 trainingseq 길이(%d)보다 큽니다.', ...
               num_symbol_for_demux, size(trainingseq,2));
    end

    AOUT = AIN;   % 기본값(초기화), 아래에서 전체를 equalize하여 덮어씀

    % ---------- Symbol-rate 샘플 추출 (timing sync 완료 가정) ----------
    idxTrain = trainStartIdx : OV : trainStartIdx + (num_symbol_for_demux-1)*OV;
    if idxTrain(end) > d2
        error('training 구간이 AIN 길이를 벗어납니다. trainStartIdx/OV/num_symbol_for_demux를 확인하세요.');
    end

    Rx_train = AIN(:, idxTrain);                       % 2 x num_symbol_for_demux
    S_train  = trainingseq(:, 1:num_symbol_for_demux);  % 2 x num_symbol_for_demux

    % ---------- 2-symbol 블록 단위 correlation 누적 (depol) ----------
    % depol의 각 열 = [h11; h21; h12; h22] (2-symbol 블록에서의 순시 correlation)
    depol = zeros(4, num_symbol_for_demux/2);

    for iSa = 1:num_symbol_for_demux/2
        idx = (iSa-1)*2 + (1:2);            % 이번 블록에 해당하는 2개 심볼 인덱스

        Rx_blk = Rx_train(:, idx);          % 2 x 2
        S_blk  = S_train(:, idx);           % 2 x 2

        Hblk = Rx_blk * S_blk';             % 2 x 2, R * S^H (순시 채널 추정)

        depol(:, iSa) = reshape(Hblk, 4, 1); % [h11; h21; h12; h22] 순서로 저장
    end

    % ---------- 블록 평균으로 채널 행렬(H_hat) 산출 ----------
    Hblk_mean = reshape(mean(depol, 2), 2, 2);  % 4x1 -> 2x2 (블록당 합의 평균)
    H_hat = Hblk_mean / 2;                       % 블록 내 심볼 수(2)로 정규화 -> per-symbol 평균

    % (참고) training이 이상적으로 직교하지 않을 경우를 위한 진단
    SS = S_train * S_train';
    pol.rcondSS = rcond(SS);
    if pol.rcondSS < 1e-6
        warning('Training sequence 직교성이 낮습니다 (rcond=%.2e). 채널 추정 정확도 저하 가능.', pol.rcondSS);
    end

    % ---------- 역행렬(Equalization 행렬) 계산 ----------
    if useUnitary
        Hn = H_hat;
        for r = 1:2
            nrm = norm(Hn(r,:));
            if nrm > 0
                Hn(r,:) = Hn(r,:) / nrm;   % 행 정규화 (전력 손실 보정)
            end
        end
        Hinv = Hn';   % Unitary 가정: 역행렬 = 켤레전치
    else
        Hinv = pinv(H_hat);   % 손실(PDL) 포함 가능한 일반적 경우
    end

    % ---------- 전체 AIN에 대해 Equalization 적용 ----------
    % H는 순시(memoryless) 1-tap 이므로 oversampled 샘플 전체에 동일하게 적용
    AOUT = Hinv * AIN;

    % ---------- 출력 struct 구성 ----------
    pol.H    = H_hat;
    pol.Hinv = Hinv;

end
