close all; clc;

time_step = 0.01;
max_voltage = 5;
num_entries = 5e5;
t = linspace(0,time_step*num_entries,num_entries);
start_at = 10;

voltage = ones(num_entries,1)'*max_voltage;
voltage(1:10) = 0;
voltage_now = t(1)/max(t) * max_voltage;
jump = ceil((num_entries-start_at)*time_step)*0.1;
i = start_at;

while i < num_entries-jump
    grow = t(i)/max(t);
    for j = 1:jump-1
        if j<(jump-1)*.7
            voltage_now = grow*max_voltage;
        else
            voltage_now = 0;
        end
        voltage(i+j) = voltage_now;
    end
    i = i + jump;
    jump = jump + 100;
    voltage(i) = voltage_now;
    fprintf('.')
end
fprintf('\n')
voltage = voltage(1:num_entries); % clip off unwanted extra values.
input_data = voltage;

% blackbox parameters
System_parameters;

% simulation
start_simulink;
model = 'NeuralNetUnitLDC_IO.slx';
load_system(model);

input = timeseries(input_data,t,'Name','input to blackbox');
out_temp = sim(model, 'SrcWorkspace','current',...
        'StartTime',string(t(1)),...
        'StopTime',string(t(end)),...
        'FixedStep', string(time_step));
output = out_temp.output;

% prepare the data after simulation
in_data = {input.Data(:)};
target_data = {output.Data(1:end-1)};

% plot_inputOutput