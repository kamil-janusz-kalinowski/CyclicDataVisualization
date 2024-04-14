%
% This script demonstrates colorizing grayscale images using different colormaps and creating animations from the colorized images.
% It includes functions for loading images, colorizing images, creating animations, and writing GIF files.
% The main function `main` showcases the usage of these functions by colorizing a grayscale image using different colormaps and plotting the results.
%It also creates animations from the colorized images using different colormaps.

%clc; clear; close all;

addpath("colormaps")
addpath("../materials")

%% Show results of colormaps

filename_img = "vortex_phase1.png";
filename_mask = "vortex_mask.png";
filename_amp = "vortex_amplitude.png";

img_phase = loadImg(filename_img);
img_amp = loadImg(filename_amp);
img_mask = loadImg(filename_mask);

mask = img_mask ~= 0;

color_map = jet(256);
img_colorized_bad = colorizeImage(img_phase, mask, color_map);

color_map = crameri('romaO');
img_colorized_good = colorizeImage(img_phase, mask, color_map);

plotResults(img_phase, img_colorized_bad, img_colorized_good);

%% Create animation

img_phase = loadImg("vortex_phase1.png");
createAnimations(img_phase, mask, 'vortex_phase1', img_amp);


img_phase = loadImg("vortex_phase2.png");
createAnimations(img_phase, mask, 'vortex_phase2', img_amp);


function img = loadImg(filename)
    [img, cmap] = imread(filename);
    if ~isempty(cmap)
        img = ind2rgb(img,cmap);
    end
    if 3 == size(img,3)
        img = rgb2gray(img);
    end

    img = im2double(img);
    img = uint8((img - min(img(:)))* 255/max(img(:)));
end

function createAnimations(img_phase, mask, outputName, img_amp)
    createAnimation(img_phase, mask, gray(256), [outputName '_phase1_gray.gif'], 6, 1, img_amp);
    createAnimation(img_phase, mask, jet(256), [outputName '_phase1_jet.gif'], 6, 1, img_amp);
    createAnimation(img_phase, mask, crameri('romaO'), [outputName '_phase1_romaO.gif'], 6, 1, img_amp);
end

function color_image = colorizeImage(gray_image_uint8, mask, colormap)
    % Zdefiniuj kolorowe mapy (możesz je dostosować do swoich preferencji)

    % Inicjalizuj obraz kolorowy
    color_image = zeros(size(gray_image_uint8, 1), size(gray_image_uint8, 2), 3);

    % Kolorowanie na podstawie intensywności piksela
    for yy = 1:size(gray_image_uint8, 1)
        for xx = 1:size(gray_image_uint8, 2)

            intensity = gray_image_uint8(yy, xx);
            if mask(yy,xx)
                intensity = mod(intensity, 255) + 1;
                color_image(yy, xx, :) = colormap(intensity, :);
            end
        end
    end
end

function plotResults(img_origin, img_colorized_bad, img_colorized_good)
    figure()
    subplot(1,3,1)
    imshow(img_origin, [])
    title('Original')
    
    subplot(1,3,2)
    imshow(img_colorized_bad)
    title('Colorized - bad')
    
    subplot(1,3,3)
    imshow(img_colorized_good)
    title('Colorized - good')
end

function createAnimation(img_gray_uint8, mask, colormap, output_filename, shift_speed, time_of_animation, img_amp_gray)
    data_img = createDataImgAnimation(img_gray_uint8, mask, colormap, img_amp_gray);
    data_gif = createDataGifAnimation(output_filename, shift_speed, time_of_animation);
    grayImageToAnimation(data_img, data_gif);
end

function data = createDataImgAnimation(img_gray, mask, colormap, img_amp_gray)
    data.img = img_gray;
    data.mask = mask;
    data.colorMap = colormap;
    data.img_amp = img_amp_gray;
end

function data = createDataGifAnimation(outputFileName, shift_speed, time_animation, num_of_colors)
    if nargin < 4
        num_of_colors = 256;
    end

    data.name_save_file = outputFileName; 
    data.shift_speed = shift_speed;
    data.num_of_frames = round(num_of_colors/shift_speed);
    data.delay_time = time_animation/data.num_of_frames;

    if data.delay_time < 0.02
        warning("Delay time is below 0.02 seconds ("+string(round(data.delay_time,4))+"). This may cause issues with the GIF.");
    end
end

function grayImageToAnimation(data_img, data_gif)
    h = waitbar(0,'Processing...');
    for ii = 1 : data_gif.num_of_frames
        colorImage = colorizeImageWithShift(data_img.img, -ii*data_gif.shift_speed, data_img.mask, data_img.colorMap);

        colorImage = applyIntesivity(colorImage, data_img.img_amp);

        writeGif(colorImage, data_gif.name_save_file, data_gif.delay_time);

        waitbar(ii/data_gif.num_of_frames, h, sprintf('Processing... %0.2f%%', ii/data_gif.num_of_frames*100)); % Aktualizacja paska ładowania
    end
    close(h);
end

function colorImage = colorizeImageWithShift(grayImage, value_shift, mask, colorMap)
    if nargin < 3
        mask = grayImage ~= 0;
    end

    grayImage = double(grayImage) + value_shift .* double(mask);
    colorImage = colorizeImage(grayImage, mask, colorMap);
end

function writeGif(colorImage, outputFileName, delayTime)
    % writeGif - Writes a color image to a GIF file.
    %
    %   writeGif(colorImage, outputFileName, delayTime)
    %
    %   This function writes a color image to a GIF file. If the file with
    %   the given name does not exist, it creates a new GIF file and writes
    %   the first frame. If the file already exists, it appends the color
    %   image as a new frame.
    %
    %   Arguments:
    %   - colorImage: Color image to write.
    %   - outputFileName: Name of the output GIF file.
    %   - delayTime: Delay time for each frame in seconds.
    %

    % Convert color image to indexed image with a color map of 256 colors
    [indexedImage, colmap] = rgb2ind(colorImage, 256); % Convert to indexed image

    % Check if the file with the given name exists
    if exist(outputFileName, 'file') ~= 2
        % If the file does not exist, write the first frame with Loopcount set to inf
        imwrite(indexedImage, colmap, outputFileName, 'gif', 'Loopcount', inf, 'DelayTime', delayTime);
    else
        % If the file exists, append the indexed image as a new frame
        imwrite(indexedImage, colmap, outputFileName, 'gif', 'WriteMode', 'append', 'DelayTime', delayTime);
    end
end

function colorImage = applyIntesivity(colorImage, img_amp)
    img_lab = rgb2lab(colorImage);
    img_lab(:,:,1) = img_amp;
    colorImage = lab2rgb(img_lab);
    
end
