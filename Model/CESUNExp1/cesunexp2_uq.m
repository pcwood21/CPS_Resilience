load('UQData_Sample2.mat');

x=[UQData.latencies UQData.failedDevices]';
%x=[mean(UQData.latencies'); mean(UQData.failedDevices')];
%x=[UQData.latencyMean'; mean(UQData.failedDevices')];
t=[(UQData.performance)]; % UQData.resilience UQData.reliability];

netSet={};
for i=1:5

trainFcn = 'trainbr';
hiddenLayerSize = [6 4];
net = fitnet(hiddenLayerSize,trainFcn);
net.input.processFcns = {'removeconstantrows','mapminmax'};
net.output.processFcns = {'removeconstantrows','mapminmax'};
net.divideParam.trainRatio = 75/100;
net.divideParam.valRatio = 0/100;
net.divideParam.testRatio = 25/100;
net.trainParam.epochs=100;
[net,tr] = train(net,x,t);
netSet{i}=net;

end