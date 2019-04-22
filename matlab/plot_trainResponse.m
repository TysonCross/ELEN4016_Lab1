%% Display setting and output setup
% set(0,'ShowHiddenHandles','on'); delete(get(0,'Children')); % close windows
scr = get(groot,'ScreenSize');                              % screen resolution
phi = (1 + sqrt(5))/2;
scr_ratio = phi/3;
offset = [ scr(3)/4 scr(4)/4]; 
figPerform = [offset(1) offset(2) scr(3)*scr_ratio scr(4)*scr_ratio];
figPerform =  figure('Position',fig_pos,'Tag','TRAINING_PLOTRESPONSE','NumberTitle','off',...
    'Name','Neural Network Training Time-Series Response (plotresponse)'););

set(figPerform,'numbertitle','off',...                            % Give figure useful title
        'name','NN training performance',...
        'Color','white');
  
fontName='CMU Serif';
fontSize = 28;
set(groot,'defaultAxesFontName', fontName,...
    'defaultTextFontName', fontName,...
    'DefaultAxesColor','none',...
    'FixedWidthFontName', 'ElroNet Monospace');

%CREATEFIGURE(X1, Y1, X2, Y2, X3, YMatrix1, X4, YMatrix2, X5, YMatrix3, X6, Y3, X7, Y4, Y5, X8, Y6, Y7, X9, Y8, Y9)
%  X1:  vector of x data
%  Y1:  vector of y data
%  X2:  vector of x data
%  Y2:  vector of y data
%  X3:  vector of x data
%  YMATRIX1:  matrix of y data
%  X4:  vector of x data
%  YMATRIX2:  matrix of y data
%  X5:  vector of x data
%  YMATRIX3:  matrix of y data
%  X6:  vector of x data
%  Y3:  vector of y data
%  X7:  vector of x data
%  Y4:  vector of y data
%  Y5:  vector of y data
%  X8:  vector of x data
%  Y6:  vector of y data
%  Y7:  vector of y data
%  X9:  vector of x data
%  Y8:  vector of y data
%  Y9:  vector of y data

% Create axes
axes1 = axes('Parent',figure1,'Position',[0.13 0.3545 0.775 0.5705]);
hold(axes1,'on');

% Create plot
plot(X1,Y1,'DisplayName','Errors','Parent',axes1,'LineWidth',2,...
    'Color',[1 0.6 0]);

% Create plot
plot(X2,Y2,'DisplayName','Response','Parent',axes1,'LineWidth',1,...
    'Color',[0 0 0]);

% Create multiple lines using matrix input to plot
plot1 = plot(X3,YMatrix1,'Parent',axes1,'LineStyle','none','Color',[0 0 1]);
set(plot1(1),'DisplayName','Training Targets','Marker','.','LineWidth',1.5);
set(plot1(2),'DisplayName','Training Outputs','Marker','+','LineWidth',1);

% Create multiple lines using matrix input to plot
plot2 = plot(X4,YMatrix2,'Parent',axes1,'LineStyle','none',...
    'Color',[0 0.8 0]);
set(plot2(1),'DisplayName','Validation Targets','Marker','.',...
    'LineWidth',1.5);
set(plot2(2),'DisplayName','Validation Outputs','Marker','+','LineWidth',1);

% Create multiple lines using matrix input to plot
plot3 = plot(X5,YMatrix3,'Parent',axes1,'LineStyle','none','Color',[1 0 0]);
set(plot3(1),'DisplayName','Test Targets','Marker','.','LineWidth',1.5);
set(plot3(2),'DisplayName','Test Outputs','Marker','+','LineWidth',1);

% Create ylabel
ylabel('Output and Target','FontWeight','bold','FontSize',12);

% Create title
title('Response of Output Element 1 for Time-Series 1','FontWeight','bold',...
    'FontSize',12);

% Uncomment the following line to preserve the X-limits of the axes
% xlim(axes1,[1 99998]);
box(axes1,'on');
% Set the remaining axes properties
set(axes1,'XTickLabel',{});
% Create legend
legend(axes1,'show');

% Create axes
axes2 = axes('Parent',figure1,'Position',[0.13 0.11 0.775 0.20375]);
hold(axes2,'on');

% Create plot
plot(X6,Y3,'Parent',axes2,'Color',[0 0 0]);

% Create plot
plot(X7,Y4,'Parent',axes2,'LineWidth',2,'Color',[1 0.6 0]);

% Create plot
plot(X3,Y5,'DisplayName','Targets - Outputs','Parent',axes2,'Marker','.',...
    'LineWidth',1.5,...
    'LineStyle','none',...
    'Color',[0 0 1]);

% Create plot
plot(X8,Y6,'Parent',axes2,'LineWidth',2,'Color',[1 0.6 0]);

% Create plot
plot(X4,Y7,'Parent',axes2,'Marker','.','LineWidth',1.5,'LineStyle','none',...
    'Color',[0 0.8 0]);

% Create plot
plot(X9,Y8,'Parent',axes2,'LineWidth',2,'Color',[1 0.6 0]);

% Create plot
plot(X5,Y9,'Parent',axes2,'Marker','.','LineWidth',1.5,'LineStyle','none',...
    'Color',[1 0 0]);

% Create ylabel
ylabel('Error','FontWeight','bold','FontSize',FontSize);

% Create xlabel
xlabel('Time','FontWeight','bold','FontSize',FontSize);

% Uncomment the following line to preserve the X-limits of the axes
% xlim(axes2,[1 99998]);
box(axes2,'on');
% Create legend
legend(axes2,'show');

axes1 = figPerform.CurrentAxes;
axes1.Position = FillAxesPos(axes1,0.99);
axes2 = figPerform.CurrentAxes;
axes2.Position = FillAxesPos(axes2,0.99);

hold off

clear ax1 ax2 cmap fontName fontSize legend1 len line_thin line_thick marker_size
clear marker_spacing offset p_hi p_lo p_nominal phi r1 r2 r3 scr scr_ratio