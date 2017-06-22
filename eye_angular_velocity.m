function [vel_ang_x,vel_ang_y,desl_x,desl_y]=eye_angular_velocity(posX,posY,distance,width,resolution,fq)

% Sintax: [vel_ang_x,vel_ang_y,desl_x,desl_y]=angular_velocity(posX,posY,distance,width,resolution,fq)
% This function calculates visual angle velocity from Eye Tracker data.
% Input:
%   posX - vector containing X-axis eye position (pixels)
%   posY - vector containing Y-axis eye position (pixels)
%   distance - the sum of the distance (cm) between the screen and the
%   mirror and the distance between the mirror the subject's eyes.
%   width - Width (cm) of the screen in which visual stimulus was projected
%   resolution - resolution of the Eye-tracker.
%   fq - acquisition frequency of the Eye Tracker (Hz)
% Output:
%   vel_angleX - visual angle velocity in the X-axis (degress/s).
%   vel_angleY - visual angle velocity in the Y-axis (degress/s).
%   desl_x
%   desl_y
%
% Date Created: 04-10-2012
% Authors: Raymundo Machado de Azevedo Neto (raymundo.neto@usp.br)
%          Katerina Lukasova (katerinaluka@gmail.com)

% Calculating displacement
desl_x_pixel=gradient(posX,2);
desl_y_pixel=gradient(posY,2);

% Convert displacement from pixels to angles
[desl_x,desl_y]=stimsize2visangle(desl_x_pixel,desl_y_pixel,distance,width,resolution);

% Calculate angular velocity for x and y
vel_ang_x=desl_x/(1/fq);
vel_ang_y=desl_y/(1/fq);