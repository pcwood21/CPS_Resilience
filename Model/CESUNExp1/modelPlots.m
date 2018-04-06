load('UQData_Sample4.mat');

[maxLatency,maxLatencyIdx]=max(mean(UQData.latencies'));
[~,minLatencyIdx]=min(mean(UQData.latencies'));

maxRP=-1*UQData.residualByTime(maxLatencyIdx,:);
maxPrice=UQData.priceByTime(maxLatencyIdx,:);
minRP=-1*UQData.residualByTime(minLatencyIdx,:);
minPrice=UQData.priceByTime(minLatencyIdx,:);
t=0:1:numel(maxRP)-1;

figure;
subplot(2,1,1);
hold all;
plot(t,minRP,'--','LineWidth',2);
plot(t,maxRP,'-','LineWidth',2);
legend('Low/0 s Latency','High/2.3 s Latency','Location','NorthWest');
ylabel('Residual Power (kW)');
ylim([-25 20]);
hold off;
subplot(2,1,2);
hold all;
plot(t,minPrice,'--','LineWidth',2);
plot(t,maxPrice,'-','LineWidth',2);
xlabel('Time (s)');
ylabel('Market Price ($)');