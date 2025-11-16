function plot3DLUT(LUT3D)
% plot3DLUT  Visualize a 3D LUT as a color cube
%
%   plot3DLUT(LUT3D)
%
%   LUT3D: an N×N×N×3 matrix representing RGB LUT values in [0,1]
%
%   Example:
%       plot3DLUT(LUT3D);

    % Validate input
    if ndims(LUT3D) ~= 4 || size(LUT3D, 4) ~= 3
        error('Input must be an N×N×N×3 matrix representing a 3D LUT.');
    end

    % Get LUT size (e.g., 33)
    N = size(LUT3D, 1);

    % Create coordinate grid
    [xIdx, yIdx, zIdx] = ndgrid(1:N, 1:N, 1:N);

    % Flatten LUT channels
    R = LUT3D(:,:,:,1);
    G = LUT3D(:,:,:,2);
    B = LUT3D(:,:,:,3);
    Colors = [R(:), G(:), B(:)];

    % Flatten grid
    X = xIdx(:);
    Y = yIdx(:);
    Z = zIdx(:);

    f = figure(2);  % create or get figure #2
    set(f, 'Name', sprintf('3D LUT (%dx%dx%d)', N, N, N), 'NumberTitle', 'off');
    clf(f);          % clear only that figure
    scatter3(X, Y, Z, 36, Colors, 'filled');
    xlabel('Red index');
    ylabel('Green index');
    zlabel('Blue index');
    title('3D LUT Visualization');
    grid on;
    axis equal;
    box on;
end
