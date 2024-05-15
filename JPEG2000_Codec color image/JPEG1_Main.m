    
            % Image Compression (RGB)
    clc; clear;
    tic;
    imNTU = imread('1.jpg');      
    %------------------------resizing image---------
    BlockSize = 8;    
    [rows1, columns1, numberOfColorChannels] = size(imNTU);
    e1=floor(rows1/BlockSize);
    e2=floor(columns1/BlockSize);
        %h1 = e1*BlockSize;
        h1= 1536;
       %h2 = e2*BlockSize;
        %h2 =128;
    imNTU = imresize(imNTU,[h1 h1]) ;
    %----------------------------------------------------------------------
    figure(1);
    imshow(imNTU);
    title('original image ')
    fprintf('the size of the original image is :' )
    info = imfinfo('1.jpg');
    ImageSize = info.FileSize
    %___________________________________________________
    a = size(imNTU);           
    width = a(1); height = a(2);
    imNTU = double(imNTU);      %%%transfer to 'double type' for calculation
    R = imNTU(:, :, 1);
    G = imNTU(:, :, 2);
    B = imNTU(:, :, 3);
    %% YCbCr  
    trans = [0.299 0.587 0.114 ; -0.169 -0.334 0.500 ; 0.500 -0.419 -0.081];  
    inv_trans = inv(trans); 
    Y =  trans(1,1)* R + trans(1,2)* G + trans(1,3)* B;
    Cb = trans(2,1)* R + trans(2,2)* G + trans(2,3)* B +128;
    Cr = trans(3,1)* R + trans(3,2)* G + trans(3,3)* B +128;
    
    Cb1(:,:) = Cb(1:2:end,1:2:end);  % 2 for 1
    Cr1(:,:) = Cr(1:2:end,1:2:end);  % 2 for 1 
    
    %% DCT2D_fn
    
    Cf = dctmtx(8);   %using DCT TRANSFORM
    
    %____________wavelet transforme________________
    Cf = haarmtx(8);         %using HAAR wevelet
    %Cf =(1/sqrt(8))*walsh(8);          %using Walsh wevelet
    %______________________________________________
    %[YF ,CbF ,CrF] = DCT2D_fn(Y,Cb1,Cr1,width,height,Cf);
    YF  = blkproc(Y  ,[8 8],'P1*x*P2',Cf,Cf');
    CbF = blkproc(Cb1,[8 8],'P1*x*P2',Cf,Cf');
    CrF = blkproc(Cr1,[8 8],'P1*x*P2',Cf,Cf');
    
    
    %for i=1:10    %if you want to plot psnr and Compression_Ratio
        var = 1;     
        %i;
       % var = var - 0.1*i;
    %% Quantization
    Qy = floor(var * [16 11 10 16 24 40 51 61;
                     12 12 14 19 26 58 60 55;
                     14 13 16 24 40 57 69 56;
                     14 17 22 29 51 87 80 62;
                     18 22 37 56 68 109 103 77;
                     24 35 55 64 81 104 113 92;
                     49 64 78 87 103 121 120 101;
                     72 92 95 98 112 100 103 99]);
                 
    Qc = floor(var * [17 18 24 47 99 99 99 99;
                     18 21 26 66 99 99 99 99;
                     24 26 56 99 99 99 99 99;
                     47 66 99 99 99 99 99 99;
                     99 99 99 99 99 99 99 99;
                     99 99 99 99 99 99 99 99;
                     99 99 99 99 99 99 99 99;
                     99 99 99 99 99 99 99 99]); 
                 
    YQ  = blkproc(YF ,[8 8],'round(x./P1)',Qy);
    CbQ = blkproc(CbF,[8 8],'round(x./P1)',Qc);
    CrQ = blkproc(CrF,[8 8],'round(x./P1)',Qc);
    
    %% DC differential encoding (Interlaced Scanning   Y => Cb => Cr )
    % AC  ZigZag scanning
    [DC,  AC_zig] = DCdif_fn(YQ,CbQ,CrQ,width,height); %% DC+AC
    
    %% Huffman Encoding
    DC_Huff = DC_Huff_fn(DC);
    L = width*height*1.5/64;
    %AC_check = [];
    %AC_check = [AC_check AC_zig(63*i-62:63*i)];
    AC_Huff = AC_Huff(AC_zig);
    
    %% Compression Ratio
    %data_len(i) = length(AC_Huff) + length(DC_Huff) ; 
    %bit_rate(i) = data_len(i)/width/height;
    %Compression_Ratio(i) = 24/bit_rate(i);
    %_________________________
    
    data_len = length(AC_Huff) + length(DC_Huff);  
    bit_rate = data_len/width/height;
    Compression_Ratio = 24/bit_rate
    fprintf('the size of the compressed image is :' )
    compressedsize = ImageSize/Compression_Ratio
    %% JPEG Decoder
    AC_decode = AC_De_Huff(AC_Huff);
    DC_decode = DC_De_Huff(DC_Huff);
    [YY CbCb CrCr] = MatCom_fn(DC_decode,AC_decode,Cf,Qy,Qc);
    Cbr = four_two_zero_recovery(width,height,CbCb);
    Crr = four_two_zero_recovery(width,height,CrCr); 
    
    
    R2 = inv_trans(1,1)* YY + inv_trans(1,2)* (Cbr-128) + inv_trans(1,3)* (Crr-128) ;
    G2 = inv_trans(2,1)* YY + inv_trans(2,2)* (Cbr-128) + inv_trans(2,3)* (Crr-128) ;
    B2 = inv_trans(3,1)* YY + inv_trans(3,2)* (Cbr-128) + inv_trans(3,3)* (Crr-128) ;
    
    
    %% PSNR
    imfinal = cat(3,R2,G2,B2) ;
    se = abs(imNTU-imfinal).^2;
    %PSNR(i) = 10*log10(255*255 * 3*width*height/sum(se(:) ) );
    PSNR = 10*log10(255*255 * 3*width*height/sum(se(:) ) )
    
    clear AC_Huff;
    clear DC_Huff;
    %end
    %% Final
    figure(2)
    imfinal = uint8( cat(3,R2,G2,B2) );
    imshow(imfinal)
    title('compressed image')
    
    %figure(3)
    %plot(bit_rate,PSNR)
          
