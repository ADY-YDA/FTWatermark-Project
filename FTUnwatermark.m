function FTUnwatermark(markedimagepath, origimagepath, outputpath)
% FTUNWATERMARK commandline: FTUnwatermark(markedimagepath, origimagepath, outputpath)
% Output in tif to not lose information to compression
% Example commandline:
% FTUnwatermark("markedsample.tif", "sample.jpeg", "sampleextractedw.tif")

marked = imread(markedimagepath);
original = imread(origimagepath);

% image fft
redChannel = marked(:, :, 1);
greenChannel = marked(:, :, 2);
blueChannel = marked(:, :, 3);
Ri = fft2(redChannel);
Gi = fft2(greenChannel);
Bi = fft2(blueChannel);

% original image fft
redChannel = original(:, :, 1);
greenChannel = original(:, :, 2);
blueChannel = original(:, :, 3);
Ro = fft2(redChannel);
Go = fft2(greenChannel);
Bo = fft2(blueChannel);

% division of image fft and original image fft, extracting original watermark
complex_uint64 = @(A,B) A./B;
Rw = complex_uint64(Ri,Ro)*255;
Gw = complex_uint64(Gi,Go)*255;
Bw = complex_uint64(Bi,Bo)*255;

output = uint8(cat(3,real(Rw),real(Gw),real(Bw)));
figure(6)
imshow(output)
title("Extracted watermark")
imwrite(output, outputpath, 'tif');
end