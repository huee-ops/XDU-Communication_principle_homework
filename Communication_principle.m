clc; clear;

% 读取MP3文件
fs = 44100;
% samples = [1,500*fs];
% [inputAudio, fs] = audioread('周杰伦-反方向的钟.mp3',samples);
[inputAudio, fs] = audioread('周杰伦-反方向的钟.mp3');
% 将左右声道平均合并为单声道
monoAudio = mean(inputAudio, 2);
% 绘制原始信号
subplot(3, 1, 1);
plot(monoAudio);
title('原始信号');

% 8kHz抽样
targetFs = 8000;
eightksampledAudio = resample(monoAudio, targetFs, fs);

% 绘制8kHz抽样后的信号
subplot(3, 1, 2);
plot(eightksampledAudio);
title('8kHz抽样后的信号');

% 量化
% 设定均匀量化的位数
bits = 16;

quantizedSignal = uencode(eightksampledAudio, bits);

% 计算均匀量化步长
quantizationStep = (max(eightksampledAudio) - min(eightksampledAudio)) / (2^bits);

% % 进行均匀量化
% quantizedSignal = round(eightksampledAudio / quantizationStep) * quantizationStep;

% 绘制量化后的信号
subplot(3, 1, 3);
plot(quantizedSignal);
title('量化后的信号');

% 自然二进制编码
binaryEncodedChannel = de2bi(quantizedSignal, bits, 'left-msb');
% 将矩阵转换为一维数组
binaryEncodedChannel_1D = reshape(binaryEncodedChannel.', 1, []);

data = binaryEncodedChannel_1D;

%2psk调制
modulated = pskmod(data, 2);

% 添加高斯白噪声
SNR = 10;  % 信噪比（dB）
noisySignal = awgn(modulated, SNR);

% 2PSK解调
demodulated = pskdemod(noisySignal, 2);


figure;

subplot(3, 1, 1);
stem(data(1:100), 'b', 'LineWidth', 2);
title('原始数据');

subplot(3, 1, 2);
stem(modulated(1:100), 'r', 'LineWidth', 2);
title('2PSK调制数据');

subplot(3, 1, 3);
stem(demodulated(1:100), 'g', 'LineWidth', 2);
title('2PSK解调数据');


scale = size(binaryEncodedChannel);
% 一维变回多维
demodulated_array = reshape(demodulated', scale(2),scale(1))';

%逆编码
decodedSignal = bi2de(reshape(binaryEncodedChannel_1D, bits, []).', 'left-msb');


% 逆量化
decodedata = udecode(decodedSignal, bits);


% 恢复原来的MP3
resampledAudio = resample(decodedata, fs, targetFs);

% 写入恢复的MP3文件
audiowrite('output.mp3', resampledAudio, fs);
sound(resampledAudio,fs)





















