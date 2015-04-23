        
 function [signal, channel, header] = sphRead(sphNameR)

            fid_r=fopen(sphNameR,'rb');
            temp=fread(fid_r);
            fclose(fid_r);
            
            header=temp(1:1024);
            signal = mu2lin(temp(1025:end));

            header1=char(header');
            i2=findstr(header1,'channel_count -i');
            channel = str2num(header1(i2+17:i2+17));
        
 return;
