
function [PSD_n, pSNR] = sp_noiseEstimation_SR(noisy)

% ----- initial --------
n  = noisy( 1 : 256 );
N1 = fft(n);
N = abs(N1(1:129));
Dw = N;
D1 = N;

minBuffer = N*[1 1 1 1];

FrameNum = 0;
frame_num = min(20000, floor(length(noisy)/128));

% -------------------------
Y = zeros(129,1);
for ij = 0 : frame_num-2 
    
    n  = noisy( ij*128+1 : ij*128+256 );

    N1 = fft(n);
    N = abs(N1(1:129))';
    
    Alphaw = 0.85;
    
    for i=1:129
        Dw(i) = Alphaw*Dw(i) + (1-Alphaw)*N(i);
    end

    FrameNum=rem(FrameNum+1,20);
    if FrameNum
        minBuffer(:,1)=min(minBuffer(:,1),Dw);
    else
        minBuffer=[Dw,minBuffer(:,1:3)];
    end
    
    D=min(minBuffer,[],2);
    Betak = 0.98;
    D1 = Betak * D1 + (1-Betak) * D;

    PSD_n = D1.^2;
    PSD_n(1:128) = 2*PSD_n(1:128);
    
    Y = Y + N'.^2;
end

Y = Y/(frame_num-1);
pSNR = mean(Y)/mean(PSD_n);
