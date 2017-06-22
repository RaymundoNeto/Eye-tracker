function varargout = SaccDetect(total_time, xpos, ypos,velx,vely,threshold,method)%, vmax, vmaxhor, vmaxver, ampl
% This function calculates saccadic movements related parameter from data colecterd with an eye-tracker.
% Sintax:[saccStTime, saccEnTime, saccDur, ampl, vmax, vmaxhor,vmaxver]=...
%           ...=SaccDetect(total_time, xpos, ypos,threshold)
% Input:
%   total_time - Time vector.
%   xpos - Position vector of the X-axis.
%   ypos - Position vector of the Y-axis.
%   threshold - Velocity Thhreshold that classifies saccadic movements (default - 60 degrees/s).
%   method - User should choose between 'resultant' (resultant
%   velocity),'horizontal',for horizontal velocity, or 'vertical', for
%   vertical velocity.
%   
% Output:
%   sacc_st_time - Index of the start of each saccadic movement.
%   sacc_end_time - Index of the end of each saccadic
%   movement.
%   sacc_duration - Duration of each saccadic
%   ampl - Amplitude of each saccadic movement.
%   movement.
%   vmax - Resultant maximum velocity of each saccadic movement.
%   vmax_hor - Maximum velocity of each saccadic movement in the X-axis.
%   vmax_ver - Maximum velocity of each saccadic movement in the y-axis.

% ToDo: exclude unrealistic saccades (too high peak velocities (!), too short
% saccades etc.), probably use acceleration-criterion

%% Initializing default values
if ~exist('threshold','var')
    threshold=60;
end

if ~exist('method','var')
    method='resultant';
end

%% Calculating velocity parameters (degrees/s)
if isequal(method,'resultant')
    eyeVel=sqrt(velx.^2+vely.^2);
elseif isequal(method,'horizontal')
    eyeVel=velx;
elseif isequal(method,'vertical')
    eyeVel=vely;
end

%% Finding the start and end of saccades
% Create a logical vector with true (1) for values higher than threshold,
% and false (0) for values lower than threshold.

saccIndDet = abs(eyeVel) > threshold;  % returns ones and zeros

% Saccade is only detected if there are 3 samples above threshold. To Do:
% Adapt this part of the code in order automaticaly create the matrix with
% different size, depending on the acquisition frequency of the eye tracker
saccInd = [false(1,size(eyeVel,2)); saccIndDet(1:end-2,:) & saccIndDet(2:end-1,:) & saccIndDet(3:end,:); false(1,size(eyeVel,2))];
% saccInd = [false(1,size(eyeVel,2)); saccIndDet(1:end-2,:) & saccIndDet(2:end-1,:); false(1,size(eyeVel,2))];

% Eliminates the possibility of detecting saccades at the beginning and end of
% the experiment.
saccInd(1:5,:) = false;
saccInd(end-5:end,:) = false;

%% Start and end of saccade

% Start
[startInd] = find(saccInd & ~[false(1,size(eyeVel,2));saccInd(1:end-1,:)]);
startInd = startInd - 1;

% End
[endInd] = find(saccInd & ~[saccInd(2:end,:); false(1,size(eyeVel,2))]);
endInd = endInd + 2;


startInd(startInd < 1) = 1;
endInd(endInd>length(total_time)) = length(total_time);

% Calculate saccade amplitude
if isequal(method,'resultant')
    ampl=sqrt((xpos(startInd)-xpos(endInd)).^2 +(ypos(startInd)-ypos(endInd)).^2);
elseif isequal(method,'horizontal')
    ampl=xpos(startInd)-xpos(endInd);
elseif isequal(method,'vertical')
    ampl=ypos(startInd)-ypos(endInd);
end

%% Exclude too short saccades 
killInd = abs(ampl) <= 83; % Saccades that are shorter than 2 degrees (currently 83 pixels on a setup with 1600x1200 screen resolution and participants 57 cm away from screen and screen width of 40 cm). 
startInd(killInd)  = [];
endInd(killInd)  = [];
ampl(killInd)=[];

%% Calculating output variables
if ~isempty(startInd) && ~isempty(endInd)
    sacc_st_time  = total_time(startInd);
    sacc_end_time = total_time(endInd);
    sacc_duration = sacc_end_time - sacc_st_time;
else
    sacc_st_time  = [];
    sacc_end_time = [];
    sacc_duration = [];
end

% velocity variables
for k = 1:length(startInd)
    vmax(k,1)=max(eyeVel(startInd(k):endInd(k))); %#ok<*AGROW>
    vmax_hor(k,1)=max(velx(startInd(k):endInd(k)));
    vmax_ver(k,1)=max(vely(startInd(k):endInd(k)));
end

%% Organazing output
switch nargout
    case 1
        varargout{1}=sacc_st_time;
    case 2
        varargout{1}=sacc_st_time;
        varargout{2}=sacc_end_time;
    case 3
        varargout{1}=sacc_st_time;
        varargout{2}=sacc_end_time;
        varargout{3}=sacc_duration;
    case 4
        varargout{1}=sacc_st_time;
        varargout{2}=sacc_end_time;
        varargout{3}=sacc_duration;
        varargout{4}=ampl;
    case 5
        varargout{1}=sacc_st_time;
        varargout{2}=sacc_end_time;
        varargout{3}=sacc_duration;
        varargout{4}=ampl;
        varargout{5}=vmax;
    case 6
        varargout{1}=sacc_st_time;
        varargout{2}=sacc_end_time;
        varargout{3}=sacc_duration;
        varargout{4}=ampl;
        varargout{5}=vmax;
        varargout{6}=vmax_hor;
    case 7
        varargout{1}=sacc_st_time;
        varargout{2}=sacc_end_time;
        varargout{3}=sacc_duration;
        varargout{4}=ampl;
        varargout{5}=vmax;
        varargout{6}=vmax_hor;
        varargout{7}=vmax_ver;
end
