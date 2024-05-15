% YCbCr
% imNTU
function [Y,Cb,Cr] = YCbCr_fn(imNTU)
Y  = imNTU(:, :, 1)*0.299 + imNTU(:, :, 2)*0.587 + imNTU(:, :, 3)*0.114;  % RGB => YCbCr
Cb = -0.169*imNTU(:, :, 1) - imNTU(:, :, 2)* 0.331 + imNTU(:, :, 3)*0.500 + 128; %Deviation 127.5
Cr = imNTU(:, :, 1)*0.500 - imNTU(:, :, 2)*0.419 - imNTU(:, :, 3)*0.081 +128; %Deviation 127.5

