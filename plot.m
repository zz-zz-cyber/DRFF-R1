%% 数据加载与预处理
% STFT分析区间为[startTime, endTime)，单位为秒；超出文件末尾时截断。
startTime = 0;
endTime = 0.1;
maxPlotPoints = 20000; % 时域预览点数上限（仅用于展示，不用于STFT）
data = load('./mini_se_4_0.mat', 'RF0_I', 'RF0_Q', 'Fs', 'CenterFreq');
signal_I = data.RF0_I(:);
signal_Q = data.RF0_Q(:);
Fs = 40e6; % 旧文件缺少元数据时使用默认值
CenterFreq = 5.745e9;
if isfield(data, 'Fs'), Fs = data.Fs; end
if isfield(data, 'CenterFreq'), CenterFreq = data.CenterFreq; end
validateattributes(Fs, {'numeric'}, {'real','scalar','finite','positive'});
validateattributes(CenterFreq, {'numeric'}, {'real','scalar','finite','nonnegative'});
Fs = double(Fs);
CenterFreq = double(CenterFreq);
validateattributes(signal_I, {'single','double'}, {'real','vector','nonempty'});
validateattributes(signal_Q, {'single','double'}, {'real','vector','nonempty'});
assert(numel(signal_I) == numel(signal_Q), 'I/Q采样点数必须相同。');
validateattributes(startTime, {'numeric'}, {'real','scalar','finite','nonnegative'});
validateattributes(endTime, {'numeric'}, {'real','scalar','finite','>',startTime});
validateattributes(maxPlotPoints, {'numeric'}, {'real','scalar','finite','integer','>=',2});
N = numel(signal_I);
firstSample = ceil(startTime*Fs) + 1;
lastSample = min(N, ceil(endTime*Fs));
assert(lastSample-firstSample+1 >= 512, '分析区间必须包含至少512个采样点。');
% 只为选定区间构造复数信号；统一行/列方向，避免隐式扩展。
complex_signal = complex(signal_I(firstSample:lastSample), signal_Q(firstSample:lastSample));
complex_signal = complex_signal(:);
% 均匀抽点预览整段I/Q；可能遗漏窄脉冲，不作为降采样分析信号。
plotIndices = unique(round(linspace(1, N, min(N, maxPlotPoints))));
t = (plotIndices-1)/Fs;

%% 时域图绘制
figure('Position', [100 100 1400 600])
subplot(1,2,1)
plot(t, signal_I(plotIndices), 'b', 'DisplayName', 'I分量')
hold on
plot(t, signal_Q(plotIndices), 'r', 'DisplayName', 'Q分量')
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
[S, F, T] = stft(complex_signal, Fs, 'Window', window, ...
    'OverlapLength', noverlap, 'FrequencyRange', 'centered');
T = T + (firstSample-1)/Fs; % 还原到文件中的绝对时间

F_absolute = F + CenterFreq;      % 转换为绝对频率
freq_GHz = F_absolute / 1e9;      % 单位转换为GHz

imagesc(T, freq_GHz, 20*log10(abs(S)))   
axis xy
colormap jet
colorbar('southoutside')
title('STFT时频图')
xlabel('时间 (s)') 
ylabel('频率 (GHz)')                   

% 坐标轴范围修正
freqLimits = (CenterFreq + [-Fs/2, Fs/2])/1e9;
ylim(freqLimits)
xlim([startTime, min(endTime, N/Fs)])
yticks(linspace(freqLimits(1), freqLimits(2), 9))
set(gca, 'FontSize', 11, 'YDir','normal') 

%% 图形全局设置
set(gcf, 'Color', [0.96 0.96 0.96])
set(findall(gcf,'Type','axes'), 'Box', 'on', 'Layer','top')
