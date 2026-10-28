
classdef ccdm < handle
    
    properties
        k
        n
        M
        pA
        type_seq
        x
        y
        w
        symbol
        z_encode
        z_decode
    end
    
    methods
        function obj = ccdm(M, n, rate, w, varargin)
            obj.n = n;
            obj.M = M;
            [obj.pA, obj.k, obj.type_seq] = get_ccdm_params(struct('M', obj.M, 'n', obj.n, 'k', n * rate));
            obj.w =w;  
        end
        
                
        function symbols = encode(obj, bits)
            if length(bits) ~= obj.k
                error('Parameter "bits" to sc_web_ccdm.encode() must have size: %d. Given was: %d', obj.k, length(bits));
            end
             
            symbols = encode_main( obj, bits); 
        end        
        
        function bits = decode(obj, symbols)
            if length(symbols) ~= obj.n
                error('Parameter "symbols" to ccdm.decode() must have size: %d. Given was: %d', obj.n, length(symbols));
            end
            
            symbol_type = get_type(symbols);
%             if ~isequal(symbol_type, obj.type_seq)
%                 warning(['symbol sequence has type [ ', sprintf('%d ', symbol_type), ...
%                     '], which does not match with desired one: [ ', ...
%                     sprintf('%d ', obj.type_seq), ']. Returning random sequence.']);
%                 bits = randi([0 1], [obj.k 1]);
%                 return;
%             end
             
            bits = decode_main(  obj, symbols); 
        end      
        
    end
end


function type_seq = get_type(symbols)
    symbols_u = unique(symbols);
    type_seq = zeros(length(symbols_u),1);   
    for ii=1:length(symbols_u)
        type_seq(ii) = sum(symbols_u(ii) == symbols);
    end
end


function source = decode_main(  obj, code)
    m = 2;%obj.M;
    type_seq = (obj.type_seq )';
    w=obj.w  ;
    thres_y = 2^w;
    source=[];
    obj.symbol = bit2symbol(m);  
    x =0 ; y=thres_y; i=0; j=-2; L = 0; run_length = 0; next_bit=0; z=0;
    z_array=zeros(obj.n, 1);  
    while ( L <= obj.k )% & i < length(code)) 
        if ( y < thres_y) 
                e = floor(x/thres_y);
                x = mod(x, thres_y); 
                y = 2 * y; L= L + 1; x = 2 * x;
                [source_bit, next_bit, run_length] = decide_source_symbol( e, m, next_bit, run_length);  
                source = [ source source_bit]; 
        else
        	i=i+1;             
            [x, y, z, type_seq]=read_next_code(code, i, x, y, z, type_seq);  % Read code, update interval 
        end
    end    
    % ������ ������ prob�� �ǹ� ����.
%     i = i + 1;
%     [x, y, z, type_seq]=read_next_code(code, i, x, y, z, type_seq); 
%     e = floor(x/thres_y); x = mod(x, thres_y); 
    [source_bit] = decide_source_bit1( x, m, next_bit, run_length);  
    source = [ source source_bit];
    source = source(-j+1:-j+obj.k);   
end

function code = encode_main(  obj, source) 
    m = obj.M;
    type_seq = (obj.type_seq )';
    code=zeros(1, obj.n);
    source = [source zeros(1, obj.n)];
    x =0 ; y=1; i=0; j=0;
    
    w=obj.w;
    thres_y = 2^w;
    z_array=zeros(obj.n, 1);    
    while ( i < obj.n )
        if ( y < thres_y )
            j = j +1 ;
            [x,y]=read_next_source(source, j, x,y); 
        else            
            i = i + 1 ;
            z = get_code_prob( type_seq, y);
            [code(i), type_seq, x, y] = decide_code_symbol( type_seq, x, y, z);  
        end            
    end       
    obj.z_encode = z_array';
end

% y �� ������ �β��̹Ƿ� source�� ��� ����.
% x�� ������ �������̹Ƿ� source�� ��� �޶�
function [x,y] = read_next_source(source, j, x, y)
%      source�� zero�� �ٿ����Ƿ�, 
    if ( j <= length(source))
        x = 2 * x + source(j);
    else
        x = 2 * x ;
    end
%     x = 2 * x + source(j);
    y = 2 * y;
end



% Obtain probabilities of each symbol level from the remained counts 
function z = get_code_prob( type_seq, y )
  p = type_seq/sum(type_seq);
  c = p(1,1:end-1) ;
  for idx=2:length(c)
      c (idx) = sum(p(1:idx));
  end
  z =  floor ( 1/2 + c * y ) ;  
end

function [code, type_seq, x, y] = decide_code_symbol( type_seq, x, y, z)
    idx = find (x < z );
    if ( isempty(idx ) )
        code = length(z) ;         
    else
        code = idx(1) -1 ;          
    end    
    z_ext = [ 0 z y];
    x = x - z_ext(code + 1);
    y = z_ext(code + 2) - z_ext(code + 1); 
    type_seq(code+1) = type_seq(code+1) -1;
end

function [source_symbol, next_symbol, run_length] = decide_source_symbol( e, m, next_symbol, run_length)
    source_symbol=[];
    if ( e ==  m - 1 )
        run_length = run_length +1 ;
    else
        if ( e > m - 1 )
            run_symbol = 0;
            next_symbol = next_symbol + 1;
            e = e - m;
        else
            run_symbol = m -  1;
        end
        source_symbol = [source_symbol, next_symbol];
        next_symbol = e;
        [run_symbols] = get_run_bit( run_symbol, run_length);
        run_length = 0;
        source_symbol = [source_symbol, run_symbols]; 
    end
end

function [source_bit] = decide_source_bit1( x, m, next_bit, run_length)
    source_bit=[]; 
    if ( (x ) == 1 )
        run_length = run_length + 1;
    end
    if ( x > 0 )
        run_bit = 0;
        next_bit = next_bit + 1; 
    else
        run_bit = 1;
    end
    source_bit = [source_bit, next_bit]; 
    run_bits = get_run_bit( run_bit, run_length);
    source_bit = [source_bit, run_bits]; 
end



function [source_symbol, next_symbol, run_length] = decide_source_symbol1( e, m, next_symbol, run_length)
    source_symbol=[];
%     if ( e ==  m - 1 )
%         run_length = run_length +1 ;
%     end
        if ( e >  m - 1 )
            run_symbol = 0;
            next_symbol = next_symbol + 1;
            e = e - m;
        else
            run_symbol = m -  1;
        end
        source_symbol = [source_symbol, next_symbol];
        next_symbol = e;
        [run_symbols] = get_run_bit( run_symbol, run_length);
        run_length = 0;
        source_symbol = [source_symbol, run_symbols, e]; 
        
     
end


function run_bits = get_run_bit( run_bit, run_length)
    run_bits= run_bit* ones(1, run_length);    
end 

% Read code, update interval[
function [x,y, z, type_seq]=read_next_code(code, i, x, y, z, type_seq)
    if ( length(code) < i ) % I am not sure about this.
        disp(['Error']);
    else
        z = get_code_prob( type_seq, y);
        z_ext =[0 z y];
        y = z_ext(code(i)+2) - z_ext(code(i)+1); 
        x = x  + z_ext(code(i)+1);  
        if ( type_seq(code(i)+1) == 0 )
             disp(['Error! doesnot provide next code']);
        end
        type_seq(code(i)+1) = type_seq(code(i)+1) -1;   
    end
end

function symbol = bit2symbol(m)
    symbol = zeros( m, log2(m));
    for idx=0:m-1
        symbol(idx+1, :) =bin2dec(dec2bin(idx, log2(m))')';
    end
end