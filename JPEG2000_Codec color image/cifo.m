function image= cifo(inputpart)
image=inputpart;
%az=zeros(64,64);
[cA,cH,cV,cD] = dwt2(im2double(image),'haar');
[cAA,cAH,cAV,cAD] = dwt2(cA,'haar'); %аппроксим коэф вейвлет.
image=cAA; 
end