
function eh = sp_Wiener_SR(noisy)
    
    noisy = noisy*32767;
    len = length(noisy);
    
    [PSD_n, pSNR] = sp_noiseEstimation_SR(noisy);

    eh = zeros(len,1);    

    load betaParr;
    load hypergeo;

    R = ones(129,1);

    A_pre = ones(129,1);

    frame_num = floor(len/128);
 
    disp('Wiener ...');

    % ----------    frame by frame    -----------
    for ij = 0 : frame_num-2 
    
        % ----- beta-MMSE enhancement ----- 
        x  = noisy( ij*128+1 : ij*128+256 );
        X = fft(x);
        R = abs(X(1:129));

        Angx = X(1:129);

        Rk = max((R.^2)./PSD_n, ones(129,1));
        Kc=0.98*(A_pre.^2)./PSD_n+(1-0.98)*(Rk-1);

        Kc=max(Kc, 0.00000011);

        G=(Kc./(Kc+1))'; % a priori Wiener Filtering

        A = G';
        A_pre = A.*R;

        enhS = A.* Angx;
        e = real(ifft( [enhS; conj(enhS(128:-1:2))] )); % e: enhanced speech

        eh(ij*128+1 : ij*128+256) = eh(ij*128+1 : ij*128+256) + e.*hanning(256);

    end % wav

    eh = eh/32767;
