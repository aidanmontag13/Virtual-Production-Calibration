function rgbValues = extractColorCheckerRGB(imagePath)
% extractColorCheckerRGB  Import a color checker image and sample RGB values.
%
%   rgbValues = extractColorCheckerRGB(imagePath)
%   Opens the specified image, lets the user click on the 24 patches,
%   computes mean RGB in a small neighborhood around each click, and
%   returns a 24x3 matrix of double values in [0, 1].
%
% Example:
%   rgb = extractColorCheckerRGB('colorchecker.tiff');

    % --- Load image
    img = imread(imagePath);
    fig = figure('Name', 'Color Checker');
    imshow(img);
    title('Click the center of each of the 24 patches (left to right, top to bottom)');
    hold on;

    % --- Parameters
    bitdepth = 16;
    numPatches = 24;
    sampleRadius = 25; % radius of neighborhood (pixels)
    rgbValues = zeros(numPatches, 3);

    % --- Manual sampling
    for i = 1:numPatches
        [x, y] = ginput(1); % click once per patch
        x = round(x); y = round(y);

        % define small neighborhood around click
        xRange = max(1, x - sampleRadius):min(size(img,2), x + sampleRadius);
        yRange = max(1, y - sampleRadius):min(size(img,1), y + sampleRadius);

        region = img(yRange, xRange, :);
        meanRGB = squeeze(mean(mean(region, 1), 2));

        % normalize to [0, 1]
        rgbValues(i, :) = double(meanRGB) / 2^bitdepth;

        % show patch number overlay
        plot(x, y, 'wo', 'MarkerSize', 50, 'LineWidth', 2);
        text(x+8, y, sprintf('%d', i), 'Color', 'w', 'FontSize', 10, 'FontWeight', 'bold');

        % --- Close figure after the final click
        if i == numPatches
            pause(0.5);  % small pause to ensure plot updates
            close(fig);
        end
    end
end

