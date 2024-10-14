clear all; close all;
maxIterations = 1000; gridSize = 2000; % Total grid size
blockSize = 500; % Each block size is 500 x 500
nBlocks = 2; % Number of blocks along each axis (2 x 2 blocks)
xlim = [-0.748766713922161, -0.748766707771757];
ylim = [0.123640844894862, 0.123640851045266];
% Setup
tic();
x = linspace(xlim(1), xlim(2), gridSize);
y = linspace(ylim(1), ylim(2), gridSize);
[xGrid, yGrid] = meshgrid(x, y);
z0 = xGrid + 1i * yGrid;
count = ones(size(z0));
% Iteration
for blockRow = 1:nBlocks
    for blockCol = 1:nBlocks
        % Define block indices for current block
        rowStart = (blockRow - 1) * blockSize + 1;
        rowEnd = blockRow * blockSize;
        colStart = (blockCol - 1) * blockSize + 1;
        colEnd = blockCol * blockSize;
        
        % Extract block
        zBlock = z0(rowStart:rowEnd, colStart:colEnd);
        countBlock = ones(size(zBlock));
        
        % Iterate for Mandelbrot set on this block
        z = zBlock;
        for n = 0:maxIterations
            z = z .* z + zBlock; % Main iteration formula
            inside = abs(z) <= 2;
            countBlock = countBlock + inside;
        end
        countBlock = log(countBlock);
        
        % Update the count matrix with the processed block
        count(rowStart:rowEnd, colStart:colEnd) = countBlock;
    end
end

% Show the result
cpuTime = toc();
set(gcf, 'Position', [200 200 600 600]);
imagesc(x, y, count);
axis image; axis off;
colormap([jet(); flipud(jet()); 0 0 0]);
drawnow;
title(sprintf('%1.2f secs (2x2 blocks)', cpuTime));
