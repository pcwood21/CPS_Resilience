
DSim=cesunexp1_genscenario(zeros(500,1));
aList=DSim.getAgentsByName('dsim.MktPlayer');
nMktPlayers=length(aList);

seedList=1:5;
numFailures=0:1:3;
latencyMagnitude=0:0.5:4;
create_run(3,'cesunexp1_latency1_runner',seedList,latencyMagnitude,numFailures);
