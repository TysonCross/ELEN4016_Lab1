figNow = gcf;

fontName='CMU Serif';
fontSize = 28;
set(groot,'defaultAxesFontName', fontName,...
    'defaultTextFontName', fontName,...
    'DefaultAxesColor','none',...
    'FixedWidthFontName', 'ElroNet Monospace', 'DefaultLineLineWidth',1.5);

h2 = findobj('-property','FontName');

for i=1:length(h2)
    h2(i).FontSize = fontSize;
    h2(i).FontName = fontName;
end

axtrainPerform = gca;
axtrainPerform.FontSize = 20;

xlabel(axtrainPerform,'Time [s] \rightarrow',...
    'FontName',fontName,...
    'FontSize',fontSize);
ylabel(axtrainPerform,'Voltage [V] \rightarrow',...
    'FontName',fontName,...
    'FontSize',fontSize);

axtrainPerform.Legend.FontSize = 20;
axtrainPerform.Legend.Position = [618.883421400259 267.499998453449 329.5 71.5];

axtrainPerform = figNow.CurrentAxes;
axtrainPerform.Position = FillAxesPos(axtrainPerform,0.99);

hold off

clear ax1 ax2 cmap fontName fontSize legend1 len line_thin line_thick marker_size
clear marker_spacing offset p_hi p_lo p_nominal phi r1 r2 r3 scr scr_ratio

export_fig('/Users/Tyson/Documents/Academic/4th Year/ELEN4016/Labs/Lab1/matlab/cache/2019_4_23_Sinusoidal_2_2_2_bcc4d48/Step_Response_comparison.pdf',gcf)
% export_fig('/Users/Tyson/Documents/Academic/4th Year/ELEN4016/Labs/Lab1/matlab/cache/2019_4_22_Stepped_2_2_8_9a92945/Neural_Network_Training_Time-Series_Response_plotresponse_Epoch_882_Maximum_epoch_reached.pdf',gcf)
