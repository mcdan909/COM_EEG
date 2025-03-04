% Combine elecs for ROIs and plot

ERP = pop_loaderp( 'filename', 'RL_GoodSubAvg_NewID.erp', 'filepath',...
 '/2tb-2015-08/COM_EEG/Data/18-Aug-2016_RLEMBC_Datasets_Including100COH_NewID/' );

% CPP & FCtheta
ERP = pop_erpchanoperator( ERP, {  'ch36 = (ch8+ch22+ch31)/3 label roiCPP',  'ch37 = (ch4+ch18+ch30)/3 label roiFC'} , 'ErrorMsg', 'popup',...
 'Warning', 'on' );

% ADAN (contra/ipsi)
%ERP = pop_erpchanoperator( ERP, {  'ch36 = (ch2+ch3+ch5)/3 label roiADAN'} , 'ErrorMsg', 'popup', 'Warning', 'on' );

ERP = pop_ploterps( ERP, [ 1 2],  37 , 'AutoYlim', 'on', 'Axsize', [ 0.05 0.08], 'BinNum', 'on', 'Blc', 'no', 'Box', [ 1 2], 'ChLabel', 'on',...
 'FontSizeChan',  10, 'FontSizeLeg',  12, 'FontSizeTicks',  10, 'LegPos', 'bottom', 'Linespec', {'k-' , 'r-' }, 'LineWidth',  1, 'Maximize',...
 'on', 'Position', [ 103.667 33.6429 107 31.9286], 'Style', 'Classic', 'Tag', 'ERP_figure', 'Transparency',  0, 'xscale', [ -800.0 796.0   -800:200:600 ],...
 'YDir', 'normal' );