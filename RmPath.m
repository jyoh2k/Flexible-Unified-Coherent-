
global SW_DEBUG_ONLY
SW_DEBUG_ONLY = 1;

global  DSP_PATH
if ( SW_DEBUG_ONLY == 1 )
    currentFolder = [ pwd, filesep ] ;
    DSP_PATH=[ currentFolder '../../DSP_Platform/'];
    DSP_PATH= currentFolder;
else
    currentFolder = [ pwd, filesep ] ;
    DSP_PATH=currentFolder;
end 

rmpath( [ DSP_PATH 'Analysis']  );
rmpath( [ DSP_PATH 'Common' ] );
rmpath( [ DSP_PATH 'Filters' ] );
rmpath( [ DSP_PATH 'Receiver'] );
rmpath( [ DSP_PATH 'Transmitter'] );
rmpath( [ DSP_PATH 'Components'] );
rmpath( [ DSP_PATH 'ProbabilityShaping'] );
rmpath( [ DSP_PATH 'FEC']);
rmpath( [ DSP_PATH 'GUI'] );
rmpath( [ DSP_PATH 'PtnGen'] );

global  SW_PATH 
currentFolder = [ pwd, filesep ] ;
SW_PATH=currentFolder ;
rmpath( [ SW_PATH 'Channel' ] ); 
rmpath( [ SW_PATH 'GUI'] );
rmpath( [ SW_PATH 'InitFiles'] );
rmpath( [ SW_PATH 'Instrument'] );
rmpath( [ SW_PATH 'Instrument' filesep 'iqtools'] );
rmpath( [ SW_PATH 'RunFiles' ] );
rmpath( [ SW_PATH 'THz_DSP'] );
global ampCorrFilename;
global arbConfigFilename

if ( SW_DEBUG_ONLY == 0 )
    rmpath('C:/Users/ETRI/Documents/MATLAB files/MeasurementTool');
end 

arbConfigFilename=[currentFolder 'Instrument' filesep  'ConfigFile' filesep 'arbConfig_M8194.mat'];
ampCorrFilename=[currentFolder 'Instrument' filesep 'ConfigFile' filesep 'ampCorr.mat'];

global  DATA_PATH1 
if ( SW_DEBUG_ONLY == 1 )
    DATA_PATH1 ='/mnt/5_ExpData/TeraHertz/';
%     DATA_PATH1 ='Y:\5_ExpData\'TeraHertz\;
else
    DATA_PATH1 ='C:/Users/ETRI/Documents/MATLAB files/THz/THz_exp/Rha';
end

if ( MatLic ) 
    rmpath( [ DSP_PATH 'Tool'] );
end

global KKDSP
KKDSP = 0;
