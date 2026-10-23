% Copy over only fields from klipper printer.cfg file
function gp = tetraExtractCfgParams(igp)
    global tetra
    fn = tetra.cfgFields;
    n = length(fn);
    for k=1:n
        gp.(fn{k}) = igp.(fn{k});
    end
end
