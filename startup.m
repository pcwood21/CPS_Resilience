d=genpath(pwd);
[t,s]=strtok(d,pathsep());
while(~isempty(s))
    if(isempty(regexp(t,'(\.svn|\.git|tmp|scripts|rundata)')))
        addpath(t);
    end
    addpath('./cluster_scripts');
    [t,s]=strtok(s,pathsep());
end
clear d s t