clear; clc; close all;

FILE = '../LA_UNIT01_BASE_7mNm';
% FILE = '../LA_UNIT07_BASE_10mNm';
% FILE = '../LA_UNIT01_Control';

data = load(FILE);     % [ms, nNm, RPM, Amp]
data = data(2:end, :); % first row is all zeros no matter what, delete it

t              = data(:, 1)/1000;      % seconds
command_torque = data(:, 2)/1000;      % Nm
omega          = rpm2rads(data(:, 3)); % rad/sec
current        = data(:, 4);           % amps

figure; hold on; grid on;
plot(t, command_torque)
plot(t, current)
plot(t, omega)
