function plot_color_patches(uncal, calib, plottitle)
N = size(uncal,1);
rows = 4; cols = 6;
big = 1; small = 0.4; off = (big-small)/2;

figure; clf; hold on; axis equal off;

for i = 1:N
    r = rows - 1 - floor((i-1)/cols);
    c = mod(i-1, cols);
    x = c*big; y = r*big;

    patch([x x+big x+big x], [y y y+big y+big], uncal(i,:), 'edgecolor','none');
    patch([x+off x+off+small x+off+small x+off], ...
          [y+off y+off y+off+small y+off+small], calib(i,:), 'edgecolor','none');
end

xlim([0 cols]); ylim([0 rows]);
title(plottitle);
end
