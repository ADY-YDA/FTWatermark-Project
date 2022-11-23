function FTWatermark(imagepath, watermarkpath, outputpath)
% FTWATERMARK commandline: 'FTWatermark(imagepath, watermarkimagepath, outputpath)
% Both images need to have even number of pixels in width and height
% Image to add watermark needs to be 2 pixels larger in width and height
% than watermark image, since watermark image will be edited to be larger
% Output in tif to not lose information to compression
% Example commandline:
% FTWatermark("sample.jpeg","watermark.jpeg","markedsample.tif")

image = imread(imagepath);
watermark = imread(watermarkpath);

figure(1)
title("Image before watermark")
imshow(image)

% editing watermark to make symmetrical and add rows/columns
redChannel = watermark(:, :, 1);
greenChannel = watermark(:, :, 2);
blueChannel = watermark(:, :, 3);
l = size(redChannel);
la = size(redChannel)+[2 2];
% flipping
redChannel(1:l(1)/2,:) = flip(redChannel(1+l(1)/2:l(1),:));
redChannel(:,1:l(2)/2) = flip(redChannel(:,1+l(2)/2:l(2)),2);
greenChannel(1:l(1)/2,:) = flip(greenChannel(1+l(1)/2:l(1),:));
greenChannel(:,1:l(2)/2) = flip(greenChannel(:,1+l(2)/2:l(2)),2);
blueChannel(1:l(1)/2,:) = flip(blueChannel(1+l(1)/2:l(1),:));
blueChannel(:,1:l(2)/2) = flip(blueChannel(:,1+l(2)/2:l(2)),2);
% inserting empty rows and columns
% inserting rows
redChannel = [255*ones(1, l(2)); redChannel(1:l(1)/2,:); 255*ones(1,l(2)); redChannel(1+l(1)/2:l(1),:)];
greenChannel = [255*ones(1, l(2)); greenChannel(1:l(1)/2,:); 255*ones(1,l(2)); greenChannel(1+l(1)/2:l(1),:)];
blueChannel = [255*ones(1, l(2)); blueChannel(1:l(1)/2,:); 255*ones(1,l(2)); blueChannel(1+l(1)/2:l(1),:)];
% inserting columns
redChannel = [255*ones(la(1),1) redChannel(:,1:l(2)/2) 255*ones(la(1), 1) redChannel(:,1+l(2)/2:l(2))];
greenChannel = [255*ones(la(1),1) greenChannel(:,1:l(2)/2) 255*ones(la(1), 1) greenChannel(:,1+l(2)/2:l(2))];
blueChannel = [255*ones(la(1),1) blueChannel(:,1:l(2)/2) 255*ones(la(1), 1) blueChannel(:,1+l(2)/2:l(2))];
% watermark now symmetrical with needed extra rows and columns
watermark = uint8(cat(3,redChannel,greenChannel,blueChannel));
figure(2)
clf
imshow(watermark)
title("Watermark after symmetry edit")
imwrite(watermark, "editedwatermark.tif", 'tif');

% image fft
redChannel = image(:, :, 1);
greenChannel = image(:, :, 2);
blueChannel = image(:, :, 3);
Ri = fft2(redChannel);
Gi = fft2(greenChannel);
Bi = fft2(blueChannel);
Im = log(abs(fftshift(Ri)));
figure(3)
clf
imagesc(Im);
title("Image to watermark after fft")
colormap('gray'); colorbar

% watermark
redChannel = watermark(:, :, 1);
greenChannel = watermark(:, :, 2);
blueChannel = watermark(:, :, 3);
Rw = complex(double(redChannel)./255);
Gw = complex(double(greenChannel)./255);
Bw = complex(double(blueChannel)./255);

% convolution of image and watermark
complex_uint64 = @(A,B) A.*B;
Ro = complex_uint64(Ri,Rw);
Go = complex_uint64(Gi,Gw);
Bo = complex_uint64(Bi,Bw);
Im = log(abs(fftshift(Ro)));
figure(4)
clf
imagesc(Im);
title("After multiplying by 'normalized' watermark")
colormap('gray'); colorbar

% ifft back to image
Ro = ifft2(Ro,"symmetric");
Go = ifft2(Go,"symmetric");
Bo = ifft2(Bo,"symmetric");
output = uint8(cat(3,Ro,Go,Bo));
figure(5)
clf
imshow(output)
title("Image after watermark")
imwrite(output, outputpath, 'tif');
end
