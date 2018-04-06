
%DSim=cesunexp1_genscenario(zeros(500,1));
%aList=DSim.getAgentsByName('dsim.MktPlayer');
%nMktPlayers=length(aList);

seedList=1:7;
numFailures=[0 1 2 5 10 20];
mu_target=0.5:0.5:3;
sigma_log=-3.5:0.5:-0.5;
create_run(5,'cesunexp5_runner',seedList,mu_target,sigma_log,numFailures);
