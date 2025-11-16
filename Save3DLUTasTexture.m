function Save3DLUTasTexture(LUT3D, filename)
% Save3DLUTasTexture - Save a 3D LUT (NxNxNx3) as a 2D image for Unreal
%
% LUT3D: NxNxNx3 double, values 0-1
% filename: string, e.g., 'LUT.tiff' or 'LUT.png'

N = 16;

% Flatten LUT to 2D
% Each row is a slice of B dimension, stacked horizontally
img2D = zeros(N, N*N, 3);

for b = 1:N
    slice = squeeze(LUT3D(:,:,b,:)); % N x N x 3
    slice = permute(slice, [2 1 3]); % Swap X and Y
    colStart = (b-1)*N + 1;
    colEnd = b*N;
    img2D(:, colStart:colEnd, :) = slice;
end

% Convert to uint16 for high precision or uint8 if you prefer
%img2D_uint16 = uint16(img2D * 65535);  % 16-bit
img2D_uint8 = uint8(img2D * 255);    % 8-bit option

% Write image
imwrite(img2D_uint8, filename);

disp(['Saved 3D LUT to ', filename, ' (size: ', num2str(size(img2D_uint8)), ')']);
end