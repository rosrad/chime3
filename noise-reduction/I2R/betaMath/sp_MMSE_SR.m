% Subroutine code

function eh = sp_MMSE_SR(noisy, dB)
    
    noisy = noisy*32767;
    len = length(noisy);
    
    [PSD_n, pSNR] = sp_noiseEstimation_SR(noisy);

    % PSD_n = PSD_n*((0.5-dB/(30))^2);
    
    eh = zeros(len,1);

    load betaParr;
    load hypergeo;

    R = ones(129,1);

    A_pre = ones(129,1);

    frame_num = floor(len/128);
 
    disp('MMSE ...');

    % ----------    frame by frame    -----------
    for ij = 0 : frame_num-2 
    
        % ----- beta-MMSE enhancement ----- 
        x  = noisy( ij*128+1 : ij*128+256 );
        X = fft(x);
        R = abs(X(1:129));
        R2 = R.^2;
        Angx = X(1:129);

        % ------------- various MMSE method -------------------
           NBeta = 5*ones(129,1);     % MMSE
        % -----------------------------------------------------

        Rk = max((R.^2)./PSD_n, ones(129,1));
        Kc=0.98*(A_pre.^2)./PSD_n+(1-0.98)*(Rk-1);

        Rk=min(Rk, 9000000);
        Kc=max(Kc, 0.00000011);

        Vk=Rk.*Kc./(Kc+1);
        v = 100*log10(Vk)+701;
        index = floor(v);
        d = v-index;

        for ii=1:129
            mfv = (1-d(ii))*hg(NBeta(ii),index(ii)) + d(ii)*hg(NBeta(ii),index(ii)+1);

            temp0 = orderBeta(NBeta(ii));
            temp1 = (Vk(ii)^0.5)/Rk(ii)*mfv^(1.0/temp0)*Ga_root(NBeta(ii));

            G(ii)=temp1;
        end

        A = G';
        A_pre = A.*R;

        enhS = A.* Angx;
        e  = real(ifft( [enhS; conj(enhS(128:-1:2))] )); % e: enhanced speech

        eh(ij*128+1 : ij*128+256) = eh(ij*128+1 : ij*128+256) + e.*hanning(256);

    end % wav

    eh = eh/32767;
