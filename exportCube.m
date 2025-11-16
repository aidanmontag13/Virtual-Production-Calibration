function exportCube(lut3D, filename)
% exportCube Export 1D + 3D LUTs to a .cube file
%
% Inputs:
%   filename  - string, output .cube file path
%   lut1D_r   - 1xN double, red channel 1D LUT
%   lut1D_g   - 1xN double, green channel 1D LUT
%   lut1D_b   - 1xN double, blue channel 1D LUT
%   lut3D     - NxNxNx3 double, 3D LUT
%
% The function writes the 1D LUT first, then the 3D LUT, in standard .cube format.

    N3 = size(lut3D, 1);   % 3D LUT size

    fid = fopen(filename, 'w');
    if fid == -1
        error('Cannot open file: %s', filename);
    end

    % --- Header ---
    fprintf(fid, 'TITLE "Exported LUT"\n');
    fprintf(fid, 'LUT_3D_SIZE %d\n', N3);
    fprintf(fid, 'DOMAIN_MIN 0.0 0.0 0.0\n');
    fprintf(fid, 'DOMAIN_MAX 1.0 1.0 1.0\n\n');

    % --- Write 3D LUT ---
    % .cube files usually store the 3D LUT in Blue fastest, then Green, then Red
    for b = 1:N3
        for g = 1:N3
            for r = 1:N3
                fprintf(fid, '%.6f %.6f %.6f\n', ...
                    lut3D(r,g,b,1), lut3D(r,g,b,2), lut3D(r,g,b,3));
            end
        end
    end

    fclose(fid);
    fprintf('LUT exported to %s\n', filename);
end
