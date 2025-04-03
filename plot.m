%% 数据加载与预处理
data = load('./mini_se_4_0.mat');
signal_I = data.RF0_I; 
signal_Q = data.RF0_Q;
Fs = 40e6; % 采样率

complex_signal = signal_I + 1j*signal_Q;
complex_signal = complex_signal; 

N = length(complex_signal);
t = (0:N-1)/Fs;

%% 时域图绘制
figure('Position', [100 100 1400 600])
subplot(1,2,1)
plot(t, real(complex_signal), 'b', 'DisplayName', 'I分量') 
hold on
plot(t, imag(complex_signal), 'r', 'DisplayName', 'Q分量')
hold off
title('I/Q振幅图')
xlabel('时间 (s)'), ylabel('幅值')
legend('Location', 'best'), grid on
xlim([0 t(end)])
set(gca, 'FontSize', 11)

%% STFT计算
subplot(1,2,2)

window = hamming(512); 
noverlap = 256; 
[S, F, T] = stft(complex_signal, Fs, 'Window', window, 'OverlapLength', noverlap);

F_absolute = F + 5.745e9;         % 转换为绝对频率
freq_GHz = F_absolute / 1e9;      % 单位转换为GHz

imagesc(T, freq_GHz, 20*log10(abs(S)))   
axis xy
colormap jet
colorbar('southoutside')
title('STFT时频图')
xlabel('时间 (s)') 
ylabel('频率 (GHz)')                   

% 坐标轴范围修正
ylim([5.725, 5.765])                     
xlim([0 0.1])
yticks(5.725:0.005:5.765)           
set(gca, 'FontSize', 11, 'YDir','normal') 

%% 图形全局设置
set(gcf, 'Color', [0.96 0.96 0.96])
set(findall(gcf,'Type','axes'), 'Box', 'on', 'Layer','top')
