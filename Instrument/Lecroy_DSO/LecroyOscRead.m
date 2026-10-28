function  [OSC_data] = LecroyOscRead(wfiled,SR,SC)

% Execute device object function(s).
% Note to find available function/property, run instrument control toolbox app

% This code requires lecroy_basic_driver.mdd file in your working folder. it can be downloaded at 
% https://kr.mathworks.com/matlabcentral/fileexchange/12862-lecroy-oscilloscopes-matlab-instrument-driver

IPaddr2 = '129.254.169.159'; % LeCroy
nlength = SR*1e4; 

deviceObj=LecroyOscConnect(IPaddr2,nlength);  connect(deviceObj);   % connect device 


sampletime  = 1/160e9 *nlength; 
set(deviceObj.Acquisition(1), 'Timebase',sampletime);   % set capture length 

pause(1.0);
% get(deviceObj.Acquisition(1),'state')

% set trigger
%set(deviceObj.Trigger(1),'Source','channel4');  
set(deviceObj.Trigger(1),'Source','channel1');  
set(deviceObj.Trigger(1),'Level',0e-3);  

% set scale 
set(deviceObj.Channel(1),'Scale',SC*1e-3); 
set(deviceObj.Channel(2),'Scale',SC*1e-3);
set(deviceObj.Channel(3),'Scale',SC*1e-3);
set(deviceObj.Channel(4),'Scale',SC*1e-3);

% single sweep 
invoke(deviceObj.Trigger(1),'trigger');  

[Y1,X1,Y1UNIT,X1UNIT, HEADER1] = invoke(deviceObj.Waveform(1),'readwaveform','channel1');
[Y2,X2,Y2UNIT,X2UNIT, HEADER2] = invoke(deviceObj.Waveform(2),'readwaveform','channel2');
[Y3,X1,Y3UNIT,X3UNIT, HEADER3] = invoke(deviceObj.Waveform(3),'readwaveform','channel3');
[Y4,X1,Y4UNIT,X4UNIT, HEADER4] = invoke(deviceObj.Waveform(4),'readwaveform','channel4');

% Disconnect device object from hardware.
disconnect(deviceObj);
delete(deviceObj);
 
X=[X1;X2;X3;X4]';
Y=[Y1;Y2;Y3;Y4]';
%% Resampling to get samples at the same time point

for ii=2:4
    Y(:,ii) =  interp1(X(:,ii),Y(:,ii), X(:,1), 'spline');
end

 
channelout1 = complex(Y(:,1)', Y(:,2)');
channelout2 = complex(Y(:,3)', Y(:,4)');
scope_out = [channelout1; channelout2];

 
end
