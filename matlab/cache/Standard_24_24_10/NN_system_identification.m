%% Neural Net training and data generation
% Tyson Cross       1239448
% James Goodhead    1387118

% clear all; 
clc; close all;

%{ 
 Data signal generation-> 
   0:=standard_step (positive step input)
   1:=random_stepped
   2:=random_walk
   3:=random_sinudoidal
%}

% Phases to run
use_cached_data     = 0         % if false, generate new data
signal_choice       = 0         % Data signal generation
use_cached_net      = 0         % if false, generate new NARX net
do_train            = 1         % if true, perform training
recover_checkpoint  = 0         % if training did not finish, use checkpoint
archive_net         = 1         % archive NN, data and figures to subfolder
make_images         = 1         % generate performance figures


%% Data generation phase
if (use_cached_data==false)
    disp('Generating and caching data...')

    time_step = 0.01;
    max_voltage = 5;
    num_entries = 2e5;
    t = linspace(0,time_step*num_entries,num_entries);
    start_at = 10;

    
    switch signal_choice
       case 0 % positive step
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
           end
           signal_name = 'Standard';
           
       case 1 % random_stepped
           i = start_at;
           voltage = zeros(i,1,1)';
           while i<num_entries
               min_time_jump = randi(2)/time_step;
               max_time_jump = randi(20)/time_step;
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
           signal_name = 'Stepped';
           
       case 2 % random_walk
            divisions = ceil(num_entries/round(sqrt(num_entries)));
            sample_coarse = linspace(1,num_entries,divisions);
            sample_fine = linspace(1,num_entries,num_entries);
            value_coarse = max_voltage*rand([divisions 1])';
            value_fine = interp1(sample_coarse, value_coarse, sample_fine,'spline');
            voltage = min(max(-max_voltage,value_fine*2 - max_voltage), max_voltage);
            voltage(1:start_at) = 0;
            signal_name = 'Walk';
            
       case 3 % random_sinudoidal
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
           signal_name = 'Sinusoidal';
           
       otherwise
           disp('No signal specified! Script stopped.')
           return
    end

    clear i j
    
    voltage = voltage(1:num_entries); % clip off unwanted extra values.

    % blackbox parameters
    System_parameters;

    % simulation
    start_simulink;
    model = 'NeuralNetUnitLDC_IO.slx';
    load_system(model);

    input = timeseries(voltage,t,'Name','input to blackbox');
    out_temp = sim(model, 'SrcWorkspace','current',...
            'StartTime',string(t(1)),...
            'StopTime',string(t(end)),...
            'FixedStep', string(time_step));
    output = out_temp.output;
    
    % prepare the data after simulation
    in_data = num2cell(input.Data(:)');
    target_data = num2cell(output.Data(1:end-1)');
%     lag = round(mean(nncorr(cell2mat(in_data),cell2mat(target_data),num_entries-1)));


    plot_inputOutput;
        
    % report sizes:
    fprintf("Data set of %d entries \n", numel(in_data));
    [a,b] = size(in_data);
    fprintf("Data consists of %d timesteps of %d elements\n",b,a);

    save('cache/IO_data',...
        'in_data','target_data',...
        'time_step','t', 'model','signal_name');
    clear v_input voltage_steps out_temp tout v_1 v_2 i input output 
    clear time_jump max_voltage num_entries voltage_now max_time_jump 
    clear freq time_input max_frew min_freq grow chance
    clear divisions sample_coarse sample_fine value_coarse value_fine 
    clear max_freq min_freq freq_val freqs freq_range freq offset magnitude
    clear j i min_time_jump model out_data start_at
    disp("Data generated") 
else
    load('cache/IO_data');
    disp('Loaded IO data from cache...')
end

%% NARX creation phase
if (use_cached_net==false)
    disp("Creating NARX net...")

    fprintf("NARX net has input size: %d \n", numel(t));
    trained_status = false;

    % NN setup
    input_delays = 1:24;
    feedback_delays = 1:24;
    hidden_layers = 10;
    net = narxnet(input_delays,feedback_delays,hidden_layers);
    if strcmp(signal_name,'Standard')
        net.divideFcn = 'divideint';
    else
        net.divideFcn = 'divideblock';
    end
    net.divideParam.trainRatio = 75/100;
    net.divideParam.valRatio = 15/100;
    net.divideParam.testRatio = 10/100;

    save('cache/NN_model',...
        'trained_status','net',...
        'hidden_layers','input_delays','feedback_delays');
    clear numelements indices indices indices_new indices_main
    disp('Cached untrained NARX net')
else
    load('cache/NN_model');
    if (trained_status)
        disp('Trained NARX net loaded from cache...')
        if (training_complete==false)
            disp("WARNING: training was stopped by user previously")
        end
    else
        disp('Untrained NARX net loaded from cache...')
    end
end

[inputs,feedbackDelays,layerStates,targets] = ...
        preparets(net,in_data,{},target_data);

%% Training phase
if do_train
    disp("Training NARX net (open loop)")
    training_complete = false;
    if (recover_checkpoint==true)
        if exist('cache/checkpoint.mat','file') == 2
            load('cache/checkpoint.mat');
            disp("Recovered last checkpoint")
            [inputs,feedbackDelays,layerStates,targets] = ...
                preparets(net,in_data,{},target_data);
        else
            disp("Unable to recover last checkpoint, retraining")
        end
    end
    
    net.trainFcn =  'trainlm';
    net.trainParam.epochs = 1000;
    net.trainParam.show = 10;
    net.trainParam.min_grad = 1e-10;
    net.trainParam.max_fail = 6;
    [net,TR] = train(net,inputs,targets,feedbackDelays,...
        'CheckpointFile','cache/checkpoint.mat');
    beep;
    disp("Training complete")
    trained_status = true;
    if strcmp(TR.stop,"User stop.")==false
        training_complete = true;
    end
    if exist('cache/checkpoint.mat','file') == 2
        delete cache/checkpoint.mat;
    end
    
    save('cache/NN_model','inputs','feedbackDelays','layerStates','targets',...
        'in_data','target_data','TR',...
        'trained_status','training_complete','net',...
        'hidden_layers','input_delays','feedback_delays');
    disp('Cached trained NARX net')
end
    
%% Training tests and performance evaluation

if trained_status
    % simulate the network and plot the resulting errors
    outputs = sim(net,inputs,feedbackDelays);
    errors = gsubtract(targets(TR.testInd),outputs(TR.testInd));
    performance_open = perform(net,targets,outputs)

    % figures
    if make_images
        plot_outputOpen;
        plot_errorOpen;
    end


    %% Deployment and testing

    % Close the loop
    net_closed = closeloop(net);

    % Test the NARX net with original data
    [inputs_c,feedbackDelays_c,layerStates_c,targets_c] = ...
        preparets(net_closed,in_data,{},target_data);
    outputs_closed  = net_closed(inputs_c,{},layerStates_c);
    % outputs_closed_sim  = sim(net_closed,inputs_c,{});
    errors_closed = gsubtract(targets_c(TR.testInd),outputs_closed(TR.testInd));
    performance_closed = perform(net_closed,targets_c,outputs_closed);

    % figures
    if make_images
        plot_trainPerform;
        plot_trainState;
%         plot_trainRegression;
        plot_outputClosed;
        plot_errorClosed;
        pause(4)                        % delay for java object -> figure
        plot_netView;
    end
    
    clear max_val max_index 

end

%% Save metadata, caches and matlab script
if (archive_net) && (trained_status)
   disp('Copying data, please wait...')
   currentFileName = strcat(mfilename('fullpath'),'.m');
   if (exist(currentFileName)==2)
       hash_str = mlreportgen.utils.hash(string(datetime('now')));
       [y,m,d] = ymd(datetime('now'));
       foldername = strcat("cache/", string(y), '_', string(m),...
           '_', string(d), '_', signal_name, '_',...
           num2str(max(input_delays)), '_', ...
           num2str(max(feedback_delays)), '_',...
           num2str(hidden_layers), '_', extractBefore(hash_str,8));
       mkdir(foldername);
       copyfile(currentFileName, foldername);
       copyfile('cache/NN_model.mat',foldername);
       copyfile('cache/IO_data.mat',foldername);
      if make_images
           diag = helpdlg('Push OK to save all open plots','Export Paused');
           uiwait(diag);
           figHandles = findobj('Type', 'figure');
           for i=1:length(figHandles)
                figure(figHandles(i).Number);
                fig_name = figHandles(i).Name;
                fig_name(isspace(fig_name)==1)='_';
                fig_name = regexprep(fig_name, '[ .,''!?()]', '');
                fn = sprintf('%s/%s.pdf',foldername,fig_name);
                export_fig(fn,figHandles(i))
           end
           fprintf("%d figures exported to %s\n",length(figHandles),foldername)
           pause(6);
           close all;
       end
       gensim(net_closed,time_step);
       fn = sprintf('%s/narx_net.slx',foldername);
       save_system(gcs,fn)
       bdclose(gcs);
       diary(strcat(foldername,'/training_info.txt'));
       TR
       diary off;
       fprintf("Data archived in %s\n",foldername)
   else
       dprintf('WARNING: %s does not exist!\n',currentFileName);
   end
else
    disp("WARNING: output NARX data not archived")
end