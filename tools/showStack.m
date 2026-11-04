% print out stack in an abbreviated readable format
function showStack(nLevels)
    dbs = dbstack();
    for k=1:length(dbs)
        if k > nLevels, return; end
        fprintf(1,'%3d) %3d %s\n',k,dbs(k).line,dbs(k).name);
    end
end
