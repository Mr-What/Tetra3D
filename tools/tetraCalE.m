%  optimize endstops given bed probe data
%     tc  -- tetra calibration data, from tetraLoadCalData(n,...)
%     gp0 -- initial guess at tetra parameters, tc.p is default
function gp = tetraCalE(tc, gp0=[])
    gp = tetraRefineE(tc,gp0);

    up.position_endstops = gp.p.position_endstops;
    tetraWriteUpdateCfg(up,'updateE.cfg');
    rem=sprintf('err=%.6f;  bedMed=%.3f;  stDev=%.3f; z0=%.3f',...
                gp.err, tp.bedMedian-tp.probe_offset(3), ...
                tp.bedStDev, tp.probe_offset(3));
    system(['echo "# ',rem,'" >> updateE.cfg']); 
    system('cat updateE.cfg');
    gp.calData=tc;
end
