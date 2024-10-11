if isempty(gcp())
    parpool();
end
nworkers = gcp().NumWorkers;
if nworkers ~= 8
    error('This program requires exactly 4 workers for 2 x 2 blocks.');
end

gridSize = 1000;   % Total grid size 1000 x 1000
blockSize = 500;   % Each block will be 500 x 500 points
maxIterations = 1000;

% Define the limits of the Mandelbrot domain
xlim = [-0.748766713922161, -0.748766707771757];
ylim = [0.123640844894862, 0.123640851045266];

% On the workers, Setup
tic();
spmd
    % Determine the block position for this worker (2x2 grid)
    [row, col] = ind2sub([2, 2], spmdIndex());
    
    % Define the x and y ranges for this block
    xStart = xlim(1) + (col - 1) * (diff(xlim) / 2);
    xEnd = xlim(1) + col * (diff(xlim) / 2);
    yStart = ylim(1) + (row - 1) * (diff(ylim) / 2);
    yEnd = ylim(1) + row * (diff(ylim) / 2);
    
    % Create the grid for this block
    x = linspace(xStart, xEnd, blockSize);
    y = linspace(yStart, yEnd, blockSize);
    [xGrid, yGrid] = meshgrid(x, y);
    z0 = xGrid + 1i * yGrid; 
    count = ones(size(z0));
    
    % Calculate Mandelbrot set for this block
    z = z0;
    for n = 0:maxIterations
        z = z .* z + z0;
        inside = abs(z) <= 2; 
        count = count + inside;
    end
    count = log(count);
end

% On the client, Show
cpuTime = toc();
set(gcf, 'Position', [200 200 600 600]);

% Concatenate results from each block and display the full grid
fullX = linspace(xlim(1), xlim(2), gridSize);
fullY = linspace(ylim(1), ylim(2), gridSize);
finalImage = zeros(gridSize);

% Stitch together the blocks from each worker
for i = 1:4
    [row, col] = ind2sub([2, 2], i);
    rowStart = (row - 1) * blockSize + 1;
    rowEnd = row * blockSize;
    colStart = (col - 1) * blockSize + 1;
    colEnd = col * blockSize;
    
    finalImage(rowStart:rowEnd, colStart:colEnd) = count{i};
end

% Display the final image
imagesc(fullX, fullY, finalImage);
axis image;
axis off;
colormap([jet(); flipud(jet()); 0 0 0]);
drawnow;
title(sprintf('%1.2f secs (with spmd)', cpuTime));
