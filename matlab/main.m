%clc; clear; close all;

addpath("colormaps")
addpath("../materials")

%% Show results of colormaps

filename_img = "vortex_phase1.png";
filename_mask = "vortex_amp.png";
img = loadImg(filename_img);
img_amp = loadImg(filename_mask);

mask = img_amp ~= 0;

color_map = jet(256);
img_colorized_bad = colorizeImage(img, mask, color_map);

color_map = crameri('romaO');
img_colorized_good = colorizeImage(img, mask, color_map);

plotResults(img, img_colorized_bad, img_colorized_good);

%% Create animation

img = loadImg("vortex_phase1.png");
createAnimation(img, mask, gray(256), 'anim_phase1_gray.gif', 6, 1);
createAnimation(img, mask, jet(256), 'anim_phase1_jet.gif', 6, 1);
createAnimation(img, mask, crameri('romaO'), 'anim_phase1_romaO.gif', 6, 1);

img = loadImg("vortex_phase2.png");
createAnimation(img, mask, gray(256), 'anim_phase2_gray.gif', 6, 1);
createAnimation(img, mask, jet(256), 'anim_phase2_jet.gif', 6, 1);
createAnimation(img, mask, crameri('romaO'), 'anim_phase2_romaO.gif', 6, 1);


function img = loadImg(filename)
    img = imread(filename);
    
    img = im2double(img);
    img = uint8((img - min(img(:)))* 255/max(img(:)));
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

function createAnimation(img_gray_uint8, mask, colormap, output_filename, shift_speed, time_of_animation)
    data_img = createDataImgAnimation(img_gray_uint8, mask, colormap);
    data_gif = createDataGifAnimation(output_filename, shift_speed, time_of_animation);
    grayImageToAnimation(data_img, data_gif);
end

function data = createDataImgAnimation(img_gray, mask, colormap)
    data.img = img_gray;
    data.mask = mask;
    data.colorMap = colormap;
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


