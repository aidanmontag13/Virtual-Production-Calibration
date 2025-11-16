% Import images and Extract Color Patches
colorCheckerPath = 'images/colorchecker.tiff';
imaged_colorCheckerPath = 'images/alexa_cc_0000.tiff';

rgbValues = extractColorCheckerRGB(colorCheckerPath);
imaged_rgbValues = extractColorCheckerRGB(imaged_colorCheckerPath);

% Compensate for flare and exposure difference in two images
greyscale_white = rgbValues(19,2); % Find the linear CV for the digital CC white patch
greyscale_black = rgbValues(24,2); % Find the linear CV for the digital CC white patch

imaged_greyscale_white = imaged_rgbValues(19,:); % Find the linear CV for the imaged CC white patch
imaged_greyscale_black = imaged_rgbValues(24,:); % Find the linear CV for the imaged CC black patch

offset_factor = greyscale_black - imaged_greyscale_black % Create offset factor based on black patches
offset_corrected_imaged_rgbValues = imaged_rgbValues + offset_factor; % Apply offset to minimize impact of flair
offset_corrected_imaged_rgbValues = max(0, min(1, offset_corrected_imaged_rgbValues));

scale_factor = greyscale_white ./ offset_corrected_imaged_rgbValues(19,:) % Create scale factor based on white patches
exposure_corrected_imaged_rgbValues = offset_corrected_imaged_rgbValues .* scale_factor; % Scale imaged CC to digital CC
exposure_corrected_imaged_rgbValues = max(0, min(1, exposure_corrected_imaged_rgbValues));

% Extract Greyscale
greyscale = rgbValues(19:24, :)
imaged_greyscale = exposure_corrected_imaged_rgbValues(19:24, :)

input_r = imaged_greyscale(:, 1);
input_g = imaged_greyscale(:, 2);
input_b = imaged_greyscale(:, 3);

output_w = greyscale(:, 3);

% Plot Grayscale to verify linearity
figure (1);
clf;
hold on;

plot(input_r, 'Color', [1 0 0], 'LineWidth', 2); % red
plot(input_g, 'Color', [0 1 0], 'LineWidth', 2); % green
plot(input_b, 'Color', [0 0 1], 'LineWidth', 2); % blue
plot(output_w, 'Color', [0 0 0], 'LineWidth', 2); % black

xlabel('Input Index');
ylabel('Output Value');
title('Greyscale Ramp');
grid on;
hold off;

% Create 3x3 Matrix using Fmincon
x0 = [1 0 0 0 1 0 0 0 1];

options = optimoptions('fmincon','Display','iter','Algorithm','interior-point');

objfun = @(x) costFunction(x, exposure_corrected_imaged_rgbValues(1:24,:), rgbValues(1:24,:));

[xopt, fval] = fmincon(objfun, x0, [], [], [], [], [], [], [], options);

% Reshape result into 3x3 matrix
M_opt = reshape(xopt, [3,3]);

disp('Optimized 3x3 matrix:');
disp(M_opt);

% Apply 3x3 matrix to evaluate
matrix_test = exposure_corrected_imaged_rgbValues * M_opt';
matrix_test = max(0, min(1, matrix_test));

disp("Average Original Error")
(mean(abs(exposure_corrected_imaged_rgbValues - rgbValues))) .* 255

disp("Average Error with Matrix")
(mean(abs(matrix_test - rgbValues))) .* 255

% Create 3D Lut with 3x3 Matrix
N = 33;
LUT3D = zeros(N,N,N,3);

for r = 1:N
    for g = 1:N
        for b = 1:N
            RGBTriplet = ([r,g,b] - 1) / (N - 1);
            CalibratedRGBTriplet = RGBTriplet * M_opt';
            CalibratedRGBTriplet = max(0, min(1, CalibratedRGBTriplet));
            LUT3D(r,g,b,:) = CalibratedRGBTriplet;
        end
    end
end

N = 16;
LUT3D_UE = zeros(N,N,N,3);

for r = 1:N
    for g = 1:N
        for b = 1:N
            RGBTriplet = ([r,g,b] - 1) / (N - 1);
            CalibratedRGBTriplet = RGBTriplet * M_opt';
            CalibratedRGBTriplet = max(0, min(1, CalibratedRGBTriplet));
            LUT3D_UE(r,g,b,:) = CalibratedRGBTriplet;
        end
    end
end

% Plot 3D Lut
plot3DLUT(LUT3D_UE)

% Save in .tiff format
texturepath = "outputs/Alexa2Wall_lut.tiff";
cubepath = "outputs/Alexa2Wall_lut.cube";

Save3DLUTasTexture(LUT3D_UE, texturepath)
exportCube(LUT3D, cubepath)

% import test image
camera_image = im2double(imread(imaged_colorCheckerPath));
cc_image = im2double(imread(colorCheckerPath));

[h, w, ~] = size(camera_image);

% Apply 3x3 matrix
reshaped_camera_image = reshape(camera_image, [], 3);          % N x 3 (rows = pixels)
offset_corrected_reshaped_camera_image = reshaped_camera_image - offset_factor;
offset_corrected_camera_image = max(0, min(1, offset_corrected_reshaped_camera_image));
exposure_corrected_reshaped_camera_image = offset_corrected_reshaped_camera_image .* scale_factor;
exposure_corrected_reshaped_camera_image = max(0, min(1, exposure_corrected_reshaped_camera_image));
matrix_corrected_reshaped_camera_image = exposure_corrected_reshaped_camera_image * M_opt.';          % apply 3x3 color correction
matrix_corrected_reshaped_camera_image = max(0, min(1, matrix_corrected_reshaped_camera_image));   % clamp to [0,1]
exposure_corrected_camera_image = reshape(exposure_corrected_reshaped_camera_image, h, w, 3);
matrix_corrected_camera_image = reshape(matrix_corrected_reshaped_camera_image, h, w, 3);

f = figure(3);
set(f, 'Name', 'Color Checker', 'NumberTitle', 'off');
clf(f);

% Show original image
subplot(1,3,1);          % 1 row, 2 columns, first plot
imshow(exposure_corrected_camera_image);     % replace with your original image variable
title('Original Image');

% Show original colorchecker
subplot(1,3,2);          % 1 row, 2 columns, second plot
imshow(cc_image);     % replace with your original image variable
title('Original Color Checker');

% Show imaged colorchecker with correction
subplot(1,3,3);          % 1 row, 3 columns, third plot
imshow(matrix_corrected_camera_image);
title('Corrected Image');

plot_color_patches(rgbValues, matrix_test, 'Calibrated Patches (Inside) against Ground Truth Patches')

plot_color_patches(rgbValues, exposure_corrected_imaged_rgbValues, 'Uncalibrated Patches (Inside) against Ground Truth Patches')









