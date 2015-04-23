
% to write signal into sphere format

function sphWrite(sphNameW, header, signal) 
            
    sig = [header; lin2mu(signal)];
    
        fid_w = fopen(sphNameW, 'wb');
        fwrite(fid_w, sig, 'uint8');
        
    fclose(fid_w);
    
return; 