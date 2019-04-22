n = 64;
m = 2;
im = zeros(n, m);
im = perlin_noise(im);

figure; imagesc(im); colormap gray;

% A = zeros(n, 1);
% A = perlin_noise(A);
% plot(A)
