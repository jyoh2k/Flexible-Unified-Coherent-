function deviceObj = LecroyOscConnect(IPaddr2,N)
% Create a TCPIP object.


% interfaceObj = instrfind('Type', 'tcpip', 'RemoteHost', '129.254.42.39', 'RemotePort', 1861, 'Tag', '');
interfaceObj = instrfind('Type', 'tcpip', 'RemoteHost', IPaddr2, 'RemotePort', 1861, 'Tag', '');

% Create the TCPIP object if it does not exist
% otherwise use the object that was found.
if isempty(interfaceObj)
    interfaceObj = tcpip(IPaddr2, 1861);
else
    fclose(interfaceObj);
    interfaceObj = interfaceObj(1);
end

% Create a device object. 
% deviceObj = icdevice('lecroy_basic_driver.mdd', interfaceObj);
deviceObj = icdevice('TeledyneLeCroy_LabmasterScopes.mdd', interfaceObj);



set(interfaceObj, 'InputBufferSize', round(2*N));
% set(interfaceObj, 'OutputBufferSize', round(2*N));


% Connect device object to hardware.
connect(deviceObj);

% Disconnect device object from hardware.
disconnect(deviceObj);

% Configure property value(s).
set(interfaceObj, 'Name', ['TCPIP-',IPaddr2]);

% Disconnect device object from hardware.
disconnect(deviceObj);
set(interfaceObj, 'RemoteHost', IPaddr2);

% % Execute device object function(s).
% groupObj = get(deviceObj, 'Trigger');
% groupObj = groupObj(1);
% invoke(groupObj, 'trigger');
% groupObj = get(deviceObj, 'Waveform');
% groupObj = groupObj(1);
% [Y1,X,YUNIT,XUNIT,HEADER] = invoke(groupObj, 'readwaveform', 'channel1');
end