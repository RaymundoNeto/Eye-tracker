function cluster_mode = annealedMeanShift(x,y,h_min,plotFlag)

% This function estimates the mode of a 2D cluster of eye-tracker gaze
% positions (x,y) in order to detect systematic error in data collection.
% The algorithm was developed and tested by Zhang and Hornof (2011) -
% Mode-of-disparities error correction of eye-tracking data.
% Input:
%   x: vector containing eye gaze position in the x axis
%   y: vector containing eye gaze position in the y axis
%   h_min: bandwidth minimum to be used as stop criterion for searching the
%   mode. h_min should be provided in the same units as x and y. A good
%   value for h_min is 1 degree visual angle or its corresponding value in
%   pixels.
%   plotFlag: 1 if want to visually check the process of finding the
%   cluster mode. 0 otherwise.
% Output:
%    cluster_mode: x and y coordinates of the cluster mode
%
% Tips for using the function:
%   - Preprocess data before using it. Apropriately interpolate data
%   between blinks and values outside the presentation screen.
% Function toy example:
% Create vectors x and y
% x = randn(1000,1)*100;
% y = randn(1000,1)*100;
%
% In this toy example, h_min = 40 works fine
% h_min = 40;
%
% Watch function at work
% cluster_mode = annealedMeanShift(x,y,h_min,1)
%
% Author: Raymundo Machado de Azevedo Neto - raymundo.neto@usp.br
% Date created: 12 jun 2017
% Last updated: 13 jun 2017

%% Checking input
% check if x and y are 1D vectors
if size(x,1) ~= 1 && size(x,2) ~= 1
    error('X must be either a row or column vector')
end

if size(y,1) ~= 1 && size(y,2) ~= 1
    error('Y must be either a row or column vector')
end

% check if x and y have the same length
if length(x) ~= length(y)
    error('X and Y must have the same dimension. Here, X has length %d and Y has length %d', length(x),length(y))
end

% If x and y are vector with thre same length, make sure both a
% column-vectors
if size(x,1) < size(x,2)
    x = x';
end

if size(y,1) < size(y,2)
    y = y';
end

if ~exist('plotFlag','var')
    plotFlag = 0;
end


%% Estimate first bandwidth (h) as the distance between the two most distant points
distance = pdist([x y]); % This built-in matlab function calculates the pairwise euclidean (default) distance across all data points.
h = max(distance);
% distance_matrix = tril(ones(length(x)),-1); % create lower triangular matrix to help keep track of position coordinates of distances
% distance_matrix(distance_matrix == 1) = distance;

%% Estimate cluster mode in cases where the minimum bandwidth is greater than the distance between the two most distant points (h < h_min)
if h < h_min
   k = [mean(x) mean(y)]; 
end

%% Step 1: randomly pick a starting point k (x and y coordinates) among all data points
initial_point = ceil(rand(1)*(length(x)-1e-6));

% Plot initial situation
if plotFlag == 1
    figure(1), clf, hold on
    scatter(x,y)
    scatter(x(initial_point),y(initial_point),100,[1 0 0],'filled')
    axis image
    pause(0.5)
end

% Change initial position to old_k variable for updating later
old_k = [x(initial_point) y(initial_point)];

% Loop decreasing bandwidth on each iteration
while h > h_min
    
    % Stop criterion
    stopThresh = 1e-3; %when mean has converged
    
    %% Step 2: Calculate the weighted average of the initial point k using a gaussian distribution with bandwidth h_initial
    
    % Estimate the probability value for all data points for a gaussian pdf
    % centered on data point k
    Sigma = [h 0; 0 h];
    gaussian_pdf = mvnpdf([x y],old_k,Sigma);
    
    % Estimate the weighted average for first k data point at the current
    % bandwidth
    k = (sum([x y].* [gaussian_pdf gaussian_pdf]))/sum(gaussian_pdf);
    
    %% Repeat Steps 2 and 3 until the value o k does not change
    % Loop until the value of k doesn't change by e = 0.0001
    while 1
        
        % Step 3: set the value of k to old k to compare them on each iteration
        old_k = k;
        
        % Step 2 again
        gaussian_pdf = mvnpdf([x y],old_k,Sigma);
        k = (sum([x y].* [gaussian_pdf gaussian_pdf]))/sum(gaussian_pdf);
        
        
        % Plot on each iteration
        if plotFlag == 1
            figure(1), clf, hold on
            scatter(x,y)
            scatter(k(1),k(2),100,[1 0 0],'filled')
            axis image
            title(['Bandwidth = ' num2str(h)])
            pause(0.0001)
        end
                
        % If k stops changing, break loop
        if norm(k - old_k) < stopThresh
            break
        end
        
    end
    
    % Update bandwidth value by halving its size on each iteration
    h = round(h*2/3);
    
    % If bandwidth is lower than h_min, make h = h_min
    if h < h_min
        h = h_min;
    end
end

%% Output
cluster_mode = k;

% Plot final k
if plotFlag == 1
    figure(1), clf, hold on
    scatter(x,y)
    scatter(k(1),k(2),100,[1 0 0],'filled')
    axis image
end