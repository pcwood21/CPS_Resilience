function [output] = cesunexp1_latency1_runner(~,latencyMagnitude,failureCount)

clear DSim;

runTime=300;

[profits,latencies,DSim,residualHist,priceHist,failedClients]=cesunexp1_runscenario(runTime,latencyMagnitude,failureCount);

output.profits=profits;
output.latencies=latencies;
output.residualHist=residualHist;
output.priceHist=priceHist;
output.failedClients=failedClients;
output.DSim=DSim;
end