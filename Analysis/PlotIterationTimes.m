% ========================================================================================================= %
% Reads log and plots iteration time and % of processed pixels per iteration.
% ========================================================================================================= %

%% Parameters:
logPath =   fullfile('Results','Logs','gmissa_WNNVD_20.mat');
outPath =   fullfile('Analysis','Figures','TimePerIt.png');
b_saveFig = true;

%% Read log:
load(logPath, 'sLog');

%% Plot:
figure('units','normalized','outerposition',[0 0 1 1]);
yyaxis left
plot(1:length(sLog.vTime), sLog.vTime, '*-', 'LineWidth', 2);
ylabel('t [sec]');
yyaxis right
plot(1:length(sLog.vProcessed), sLog.vProcessed*100, '*-', 'LineWidth', 2);
ylabel('Processed Pixels [%]');
xlabel('it');
grid on;
title('Time & Processed Pixels');

if b_saveFig
    saveas(gcf, outPath);
end
