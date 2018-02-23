clear; clc; close all;

DIR   = './MOI Data/';
FILES = dir(DIR);

for i = 1:length(FILES)
  f = FILES(i);
  if(f.isdir) % skip '.' and '..'
    continue
  end
  fname = f.name;
  dir   = f.folder;

  file = strcat(dir, '/', fname);

  data = load(file);     % [ms, nNm, RPM, Amp]
  data = data(2:end, :); % first row is all zeros no matter what, delete it
  t              = data(:, 1)/1000;      % seconds
  command_torque = data(:, 2)/1000;      % Nm
  omega          = rpm2rads(data(:, 3)); % rad/sec
  current        = data(:, 4);           % amps

  % select only where the motor is really running
  idx            = current > 0.1;
  t              = t(idx);
  command_torque = command_torque(idx);
  omega          = omega(idx);
  current        = current(idx);
  real_torque    = (25.5/1000)*current; % 25.5 mNm/A

  p = polyfit(t, omega, 1);
  alpha = p(1); % slope of omega -> angular acceleration
  fit_omega = @(x) p(1).*x + p(2);

  figure; hold on; grid on;
  plot(t, real_torque)
  plot(t, omega)
  plot(t, fit_omega(t))
  title(fname);

  % torque = I*alpha -> I = torque/alpha
  I = abs(mean(real_torque/alpha));
  fprintf('%s: I = %f\n', fname, I)
end
