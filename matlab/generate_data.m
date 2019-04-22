% Generate data inputs
close all; clear all; clc;

time_step = 0.01;
max_voltage = 5;
num_entries = 5e4;
t = linspace(0,time_step*num_entries,num_entries);
start_at = 10;

% random_stepped
i = start_at;
voltage = zeros(i,1,1)';
while i<num_entries
   min_time_jump = randi(2)/time_step;
   max_time_jump = randi(10)/time_step;
   chance = rand();
   if (chance<0.05)
      voltage_now = 0;
   else
      voltage_now = (min(max(-max_voltage,rand()*(max_voltage)),max_voltage))*2 - (max_voltage);
   end
   time_jump = randi(max_time_jump-1) + min_time_jump;
   j = i;
   while j<(i+time_jump)
      voltage(j) = voltage_now;
      j = j + 1;
   end
   i = i + time_jump;
end

voltage = voltage(1:num_entries); % clip off unwanted extra values.
input_data{1} = {voltage};
signal_name{1} = 'Stepped';
   
% smooth_random
voltage = zeros(i,1,1)';
divisions = ceil(num_entries/round(sqrt(num_entries)));
sample_coarse = linspace(1,num_entries,divisions);
sample_fine = linspace(1,num_entries,num_entries);
value_coarse = max_voltage*rand([divisions 1])';
value_fine = interp1(sample_coarse, value_coarse, sample_fine,'spline');
voltage = min(max(-max_voltage,value_fine*2 - max_voltage), max_voltage);
voltage(1:start_at) = 0;

voltage = voltage(1:num_entries); % clip off unwanted extra values.
signal_name{2} = 'Walk';
input_data{2} = {voltage};
            
% random_sinudoidal
voltage = zeros(num_entries,1,1)';
max_freq = 0.01;
min_freq = -0.01;
divisions = num_entries*1e-3;
freq_val = linspace(min_freq,max_freq,num_entries/divisions);
freqs = sin(freq_val.*pi.*t(1:divisions:end));
freq_range = 1e-2*(repmat(freqs,1,divisions*2));
freq = freq_range(1);
offset = 0;
magnitude = 1;
for i = start_at:num_entries
   chance = rand();
   if (chance<0.5)
        freq = 2*pi*freq_range(i);
   end
   if (chance<0.001)
       offset = rand()*max_voltage*2 - max_voltage;
   end
   if (chance<0.02)
       magnitude = min(max(0.1,rand()*2),2);
   end
   voltage_value = magnitude*sin(freq*t(i));
   voltage(i) = min(max(-max_voltage,voltage_value + offset), max_voltage);
end
voltage = voltage(1:num_entries); % clip off unwanted extra values.
input_data{3} = {voltage};
signal_name{3} = 'Sinusoidal';


% blackbox parameters
System_parameters;

% simulation
start_simulink;
model = 'NeuralNetUnitLDC_IO.slx';
load_system(model);

for i = 1:3
    input = timeseries(cell2mat(input_data{i}),t,'Name','input to blackbox');
    out_temp = sim(model, 'SrcWorkspace','current',...
            'StartTime',string(t(1)),...
            'StopTime',string(t(end)),...
            'FixedStep', string(time_step));
    output = out_temp.output;

    % prepare the data after simulation
    in_data{i} = {input.Data(:)};
    out_data{i} = {output.Data(1:end-1)};
    
end

stepped = iddata(cell2mat(out_data{1}),...
                    cell2mat(in_data{1}),...
                    time_step);

sinusoidal = iddata(cell2mat(out_data{2}),...
    cell2mat(in_data{2}),...
    time_step);

random = iddata(cell2mat(out_data{3}),...
    cell2mat(in_data{3}),...
    time_step);

clear v_input voltage_steps out_temp tout v_1 v_2 i input output 
clear time_jump max_voltage num_entries voltage_now max_time_jump 
clear freq time_input max_frew min_freq grow chance in_data target_data
clear divisions sample_coarse sample_fine value_coarse value_fine 
clear max_freq min_freq freq_val freqs freq_range freq offset magnitude
clear b B B2 B3 f input_data j i m min_time_jump model out_data R 
clear signal_name start_at V voltage voltage_value l 

disp("Data generated") 