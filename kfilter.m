function [data]=kfilter(data,fq,X,cutoff,rtime)
% This function filters kinematic data of matrix DATA by using a dual-pass 
% X-order butterworth filter with a specified cut-off frequency (low pass).
% Sintax: [DATA]=kfilter(DATA,FQ,X,CUTOFF,RTIME)
% Input:
%   DATA - Kinematic data matrix (It could be a 1, 2 or 3 column matrix)
%   FQ - sampling frequency
%   X - Filter order (default - 4)
%   CUTOFF - Filter cut-off frequency (default - 10)
%   RTIME -  Flag if the first column is a time vector ('yes' or 'no')
% Output:
%   DATA - kinematic data filtered
%
% See also FFTCUTOFF for a cut-off frequency choice using power
% spectrum density.
% Author: Raymundo Machado de Azevedo Neto, raymundo.neto@usp.br
% Date: 20oct2009

% verifying inputs
if ~exist('X','var')
    X=4;
end
if ~exist('cutoff','var')
    cutoff=10;
end
if ~exist('rtime','var')
    rtime='no';
end

% Verify if the firts columns is a time vector
if isequal(rtime,'no')
    n=1;
elseif isequal(rtime,'yes')
    n=2;
else
    error('Just "yes" and "no" strings are accepted for this input argument')
end

% Filter all columns of data matrix
for k=n:size(data,2)
    % butterworth transfer function parameters
    [b,a]=butter(X,cutoff/(fq/2));
    % Filtering
    data(:,k)=filtfilt(b,a,data(:,k));
end