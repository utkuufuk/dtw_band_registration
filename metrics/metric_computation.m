clc, clearvars
format long

% number of test images
NUM_IMAGES = 10;

% image dimensions
NUM_ROWS_DTW = 8192;
NUM_ROWS_SIFT = 8128;
NUM_COLS = 8160;

% maximum shifted rows/cols 
ROW_MARGIN = 50;
COL_MARGIN = 10;

% rows to crop from the bottom of SIFT image
ROWS_TO_CROP_SIFT = NUM_ROWS_SIFT - (NUM_ROWS_DTW - 2 * ROW_MARGIN);

% additional rows to crop from the bottom of SIFT image and from the top of DTW image
ROWS_TO_CROP_BOTH = 12;

% number of reference rows & cols in each iteration
NUM_REF_ROWS_COLS = linspace(5, 45, 5);

for i = 1:NUM_IMAGES
    fprintf('\nIMAGE #%d:\n------------------------------------------------------------\n\n', i);
    
    % read & crop L1 pan to match L1R pan
    panL1 = imread(strcat('../images/', num2str(i), '/L1/0/image.tif'));
    panL1 = panL1(ROW_MARGIN + ROWS_TO_CROP_BOTH + 1:end - ROW_MARGIN, COL_MARGIN + 1:end - COL_MARGIN);

    % compute spatial metrics using L1 pan and pansharpened DTW outputs
    for r = NUM_REF_ROWS_COLS
        fprintf('Number of reference rows/cols: %d\n\n', r);
        
        % read & crop DTW to match SIFT
        pansharpDtw = imread(strcat('../images/', num2str(i), '/DTW/', num2str(r), '_refs/dtw_hcs.tif'));
        pansharpDtw = pansharpDtw(1 + ROWS_TO_CROP_BOTH:end, :, :);
        
        [~, metricVec] = compute_spatial_metric(pansharpDtw, panL1);
        fprintf('DTW Regisered Image:\nRed: %f\nGreen: %f\nBlue: %f\n\n', metricVec(1), metricVec(2), metricVec(3));
    end
    
    % read L1R pan & pansharp
    panL1R = imread(strcat('../images/', num2str(i), '/L1R/0/image.tif'));
    pansharpSift = imread(strcat('../images/', num2str(i), '/L1R/sift_hcs.tif'));
    
    % flip & crop SIFT to match DTW
    panL1R = flip(panL1R, 1);
    panL1R = flip(panL1R, 2);
    panL1R = panL1R(1:end - ROWS_TO_CROP_SIFT - ROWS_TO_CROP_BOTH, COL_MARGIN + 1:end - COL_MARGIN, :);
    pansharpSift = flip(pansharpSift, 1);
    pansharpSift = flip(pansharpSift, 2);
    pansharpSift = pansharpSift(1:end - ROWS_TO_CROP_SIFT - ROWS_TO_CROP_BOTH, COL_MARGIN + 1:end - COL_MARGIN, :);
    
    [~, metricVec] = compute_spatial_metric(pansharpSift, panL1R);
    fprintf('\nL1R Reference Image:\nRed: %f\nGreen: %f\nBlue: %f\n\n', metricVec(1), metricVec(2), metricVec(3));
end