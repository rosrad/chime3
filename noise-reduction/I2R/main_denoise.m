fclose all; close all; clear all; clc;

addpath .\betaMath
addpath .\betaUltis

%%
dB = -10;
noiseType = 'white';
method = 'beta-order'; % 'MMSE' %  'betaMask' % 'LSA' % 'Wiener' % 'beta-order';

sphDirInp = ['D:\LinuxSR\swbd\data_sphTranscrip\Data\Eval_Data\eval2000\2000HUB5\english_' num2str(dB) 'dB_' noiseType];
sphDirOut = ['D:\LinuxSR\swbd\data_sphTranscrip\Data\Eval_Data\eval2000\2000HUB5\english_' num2str(dB) 'dB_' noiseType '_' method];


if (~exist(sphDirOut,'dir'))  mkdir(sphDirOut);  end

%%
loc = [sphDirInp '\*.sph'];
list = dir(loc);
Nsph = max(size(list));   
%%

for q = 1:Nsph
    
    %%        
    % --- read sphere ---
    
    segName  = list(q).name;
    segName  = strrep(segName, '.sph', '');
    segName  = strrep(segName, '.SPH', '');            
    sphNameR = [sphDirInp '\' segName '.sph'];
    
    [signal, channel, header] = sphRead(sphNameR);
    
    sig = zeros(length(signal),1);
    
    %%
    disp(['dB = ' num2str(dB) '.']);

    if channel == 2
        
        sigl = signal(1:2:end);
        
        if strcmp(method, 'beta-order')
            
            y = sp_betaOrder_SR(sigl);                        
            
        elseif strcmp(method, 'MMSE')
            
            y = sp_MMSE_SR(sigl);                        
            
        elseif strcmp(method, 'LSA')
            
            y = sp_LSA_SR(sigl);
            
        elseif strcmp(method, 'betaMask')
            
            y = sp_betaMask_SR(sigl, dB);
            
        elseif strcmp(method, 'Wiener')
            
            y = sp_Wiener_SR(sigl);
            
        end
        
        sig(1:2:end) = y;
        
        % ------------------------------------
        
        sigr = signal(2:2:end);
        
        
        if strcmp(method, 'beta-order')
            
            y = sp_betaOrder_SR(sigr, dB);
            
        elseif strcmp(method, 'MMSE')
            
            y = sp_MMSE_SR(sigr);
            
        elseif strcmp(method, 'LSA')
            
            y = sp_LSA_SR(sigr);
            
        elseif strcmp(method, 'betaMask')
            
            y = sp_betaMask_SR(sigr);
            
        elseif strcmp(method, 'Wiener')
            
            y = sp_Wiener_SR(sigr);
            
        end
        
        sig(2:2:end) = y;
        
        % ------------------------------------
    else
        
        disp('error because channel is not stereo');
        return;
        
    end 
    %%
    % --- write sphere ---
    sphNameW = [sphDirOut '\' segName '.sph'];
    sphWrite(sphNameW, header, sig);
    
    clear sig signal sigl sigr header ;

end % q  
