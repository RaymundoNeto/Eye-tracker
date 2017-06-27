function gazeHeatmap(x,y,x_res,y_res,method)
% This function gets a set of x and y gaze coordinates and plots a heatmap
% of fixation positions using a gaussian kernel.
% It uses the gkde2.m function to estimate the probability density function
% that is used to create the heat map
%
% Input: 
%   x: gaze position on x axis
%   y: gaze position on y axis
%   x_res: screen resolution on the x axis
%   y_res: screen resolution on the y axis
%   method: heatmap can be created simply using 'histogram' or estimating
%   'kdensity'. The second methods takes a lot of time.
%
% Output: a gaze heatmap with a circle of 0.5 and 2 deg visual angle aroung
% fixation cross. Colorbar unit is relative frequency of fixations in each
% pixel.
%
% Author: Raymundo Machado de Azevedo Neto
% Date created: 08 jun 2017
% Last update: 27 jun 2017

%% Initial variables
hist_bin = 1000;

%% Check inputs

% Find x and y dimensions
[lx,cx] = size(x);
[ly,cy] = size(y);

% check if x and y are vectors
if (lx ~= 1 && cx ~= 1) || (ly ~= 1 && cy ~= 1)
    error('X and Y must be either column or row vectors');
end

% check if x and y are row or column vetors. If column, transform into row
% vector
if lx > 1
    x = x';
end

if ly > 1
    y = y';
end

if isequal(method,'kdensity')
    %% Estimate probability density function
    % estimate kernel density using 200 points (fined grained and takes a
    % while)
    p.N = 100;
    d = gkde2([x;y],p);
    
elseif isequal(method,'histogram')
    %% Estimate density with histogram
    d.pdf = hist3([x' y'],[hist_bin hist_bin]);
end

%% Plot heatmap
% Create background image with zeros across the whole screen (gkde2.m
% function estimates kernel density only around gaze points and looses the
% rest of the screen)
background = zeros(y_res,x_res);

% Plot background
imagesc(background)
hold on

% Plot gaze data estimating
if isequal(method,'kdensity')
    d.pdf = (d.pdf./sum(sum(d.pdf)))*100; % Convert density to relative frequency (%)
    imagesc(d.x(:),d.y(:),d.pdf);    
elseif isequal(method,'histogram')
    [d.x d.y] = meshgrid(linspace(min(x),max(x),hist_bin),linspace(min(y),max(y),hist_bin));
    d.pdf = (d.pdf./sum(sum(d.pdf)))*100; % Convert histogram to relative frequency (%)
    imagesc(d.x(:),d.y(:),d.pdf');
end

% Make axis evenly spaced
% set(gca,'YDir','normal') % Eye-link origin is at the left upper corner. Don't need to flip axis.
axis image

% Include colorbar
colorbar

% Check matlab version. If Matlab is older than 2014b, use paruly function
% to make coloar map parula
[~,date] = version;

if str2double(date(end-3:end)) < 2014
    colormap(paruly)
end

% create dashed circle on fixation cross area
x_c = 800; % Fixation cross center x
% y_c = 485; % Fixation cross center y
y_c = 715; % Fixation cross center y
ang = 0:0.01:2*pi; % Angle to draw circle
r = 11; % fixation cross radius
r_2deg = 44; % @ degrees around fixation cross
xp = r*cos(ang); % x position along the circle
yp = r*sin(ang); % y position along the circle
xp_2deg = r_2deg*cos(ang); % x position along the circle 2 degrees visual angle 
yp_2deg = r_2deg*sin(ang); % y position along the circle 2 degrees visual angle 
plot(x_c+xp,y_c+yp,'--k','LineWidth',1)
plot(x_c+xp_2deg,y_c+yp_2deg,'--k','LineWidth',1)
hold off
