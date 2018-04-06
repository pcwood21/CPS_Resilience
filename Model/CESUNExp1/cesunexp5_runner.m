function [output] = cesunexp5_runner(~,mu_target,sigma_log,failureCount)

clear DSim;

runTime=300;

[profits,latencies,DSim,residualHist,priceHist,failedClients]=cesunexp5_runscenario(runTime,mu_target,sigma_log,failureCount);

output.profits=profits;
output.latencies=latencies;
output.residualHist=residualHist;
output.priceHist=priceHist;
output.failedClients=failedClients;
output.DSim=DSim;
end