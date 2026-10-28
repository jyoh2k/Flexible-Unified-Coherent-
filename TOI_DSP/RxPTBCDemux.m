function [AOUT, pol] = RxPTBCDemux( AIN, trainingseq, params )
%   Training sequence correlation 기반 1-tap  Demux
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
    OV                    = params.OV/params.PTBC_factor; 

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


    if mod(num_symbol_for_demux, 2) ~= 0
        error('num_symbol_for_demux는 짝수여야 합니다 (2-symbol 블록 처리).');
    end
    if num_symbol_for_demux > size(trainingseq, 2)
        error('num_symbol_for_demux(%d)가 trainingseq 길이(%d)보다 큽니다.', ...
               num_symbol_for_demux, size(trainingseq,2));
    end

    AOUT = AIN;   % 기본값(초기화), 아래에서 전체를 equalize하여 덮어씀

    % ---------- Symbol-rate 샘플 추출 (timing sync 완료 가정) ----------
    idxTrain = trainStartIdx : OV : trainStartIdx + (num_symbol_for_demux *2 -1)*OV;
    if idxTrain(end) > d2
        error('training 구간이 AIN 길이를 벗어납니다. trainStartIdx/OV/num_symbol_for_demux를 확인하세요.');
    end

    AIN_dn = AIN(:, idxTrain);
    
    Rx_train = [ AIN_dn(:, 1:2:end); conj(AIN_dn(:, 2:2:end));];
    S_train  =  trainingseq(:, 1: num_symbol_for_demux );  
               
    [h_init] = get_stbc_H( Rx_train, S_train,   params);


    % ---------- 출력 struct 구성 ----------
    pol.Hinv = h_init;

end

function [H] = get_stbc_H( rx_prl, decided_prl,  params)
    trained_h = zeros(size(decided_prl));
    for idx=1:size(decided_prl,2)
        h= get_stbc( rx_prl(:, idx), decided_prl(:, idx), params);
        trained_h(:, idx) = h;
    end

    h = mean(trained_h,2);
    H(1 ) = conj(h(1));
    H(3) = h(2);
    H(2) = conj(h(2));
    H(4) = -h(1);

end

function [h ] = get_stbc( rx, tx, params)
    h(1) = rx(1) * conj(tx(1)) - conj(rx(2)) * tx(2);
    h(2) = rx(1) * conj(tx(2)) + conj(rx(2)) * tx(1);
    norm1 = sum(abs(rx(1:2)) .^2 );
    h = h /norm1;
end


