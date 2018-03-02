clear; clc; close all;
do_the_plot = true;

DIR   = './MOI Data/';
FILES = dir(DIR);
moments_of_inertia = zeros(1, length(FILES));

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
  omega          = abs(rpm2rads(data(:, 3))); % rad/sec
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

  if(do_the_plot)
    figure; hold on; grid on;
    plot(t, 1000*real_torque, 'DisplayName', 'motor torque (mNm)')
    plot(t, omega, 'DisplayName', 'angular velocity \omega (rad/s)')
    plot(t, fit_omega(t), 'DisplayName', 'angular velocity linear fit')
    xlabel('time (sec)')
    title(['Trial ', fname])
    legend('show', 'location', 'southeast')
    print(['img/', fname], '-dpng')
  end

  % torque = I*alpha -> I = torque/alpha
  I = abs(mean(real_torque/alpha));
  fprintf('%s: I = %f\n', fname, I)

  moments_of_inertia(i) = I;
end

moments_of_inertia = moments_of_inertia(moments_of_inertia ~= 0);
fprintf('mean: %f kg m^2\n', mean(moments_of_inertia))
fprintf('std dev: %f\n', std(moments_of_inertia))
