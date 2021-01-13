function [ TiffStack2 ] = ReadTiffstack( I )
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here
imfinfo(I);
InfoImage = imfinfo(I);
mImage = InfoImage(1).Width;
nImage = InfoImage(1).Height;
NumberImages = length(InfoImage);
TiffStack = zeros(nImage, mImage, NumberImages, 'uint16');
TifLink = Tiff(I, 'r');
for i = 1:NumberImages
    TifLink.setDirectory(i);
    TiffStack(:,:,i) = TifLink.read();
end

TifLink.close();
TiffStack2 = TiffStack;
end


