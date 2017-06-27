function gaze_density = gazeDensity(x,y,fix_center,radius,screen_dist,screen_width,screen_res_x)

% This function estimates the percentage of gaze data points acquired with
% eye-tracker inside one(or many) circle(s).

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


%% Main loop to estimate density in all radii provide as input
for r = 1:length(radius)
    
    %% Create boundries of circle around fixation  
    
    % convert radius from degrees to pixels
    radius_pix = visangle2stimsize(radius(r),radius(r),screen_dist,screen_width,screen_res_x);
    
    % Calculate distance of gaze from fixation cross center
    diff_gaze_fixation = [x - fix_center(1) y - fix_center(2)];
    dist_gaze_fixation = sqrt(sum(diff_gaze_fixation.^2,2));        
    
    % Estimate how many points lie inside the circle with input radius
    percentage_inside(r) = (sum(dist_gaze_fixation < radius_pix)/length(dist_gaze_fixation))*100;
        
end

gaze_density = percentage_inside;