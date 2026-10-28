 function [scope_out] = LeCroy_Scope_Read( sims, params )  
%  Usage      :  [scope_out] = LeCroy_Scope_Read( sims, params )  
% Set scope address (default 127.0.0.1 is local loopback, for running MATLAB directly on the scope itself)

% scopeIPaddress = '129.254.43.167';
scopeIPaddress = '192.168.10.5';

% Create a TCPIP object.
interfaceObj = instrfind('Type', 'tcpip', 'RemoteHost', scopeIPaddress, 'RemotePort', 1861, 'Tag', '');
if isempty(interfaceObj)
    interfaceObj = tcpip(scopeIPaddress, 1861);
else
    fclose(interfaceObj);
    interfaceObj = interfaceObj(1);
end
% Create a device object. 
deviceObj = icdevice('TeledyneLeCroy_LabmasterScopes.mdd', interfaceObj);
% set(interfaceObj, 'InputBufferSize', 200000); 
% Connect device object to hardware.
connect(deviceObj);

% groupObj = get(deviceObj, 'Util');
% groupObj = groupObj(1); %check need or no need check
% invoke(groupObj, 'sendcommand', 'VBS app.Acquisition.Horizontal.EnableAlignChannelSamples="1"');

% reason for invoke
groupObj = get(deviceObj, 'trigger');   
groupObj = groupObj(1);
invoke(groupObj, 'trigger');

pause(0.5);

set(deviceObj.Trigger(1), 'Mode', 'stop');  % stop before save data

% Execute device object function(s).
groupObj = get(deviceObj, 'Waveform');
% groupObj = groupObj(1);

[Y1,X1,Y1UNIT,X1UNIT,HEADER1] = invoke(groupObj, 'readwaveform', 'channel2');
[Y2,X2,Y2UNIT,X2UNIT,HEADER2] = invoke(groupObj, 'readwaveform', 'channel3');
[Y3,X3,Y3UNIT,X3UNIT,HEADER3] = invoke(groupObj, 'readwaveform', 'channel6');
[Y4,X4,Y4UNIT,X4UNIT,HEADER4] = invoke(groupObj, 'readwaveform', 'channel7');


% [Y1,X1,Y1UNIT,X1UNIT,HEADER1] = invoke(groupObj, 'readwaveform', 'channel6');
% [Y2,X2,Y2UNIT,X2UNIT,HEADER2] = invoke(groupObj, 'readwaveform', 'channel7');
% [Y3,X3,Y3UNIT,X3UNIT,HEADER3] = invoke(groupObj, 'readwaveform', 'channel2');
% [Y4,X4,Y4UNIT,X4UNIT,HEADER4] = invoke(groupObj, 'readwaveform', 'channel3');

% set(deviceObj.Trigger(1), 'Mode', 'run');  % run after save data
% set(deviceObj.Trigger(1), 'Mode', 'stop');  % stop after save data

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