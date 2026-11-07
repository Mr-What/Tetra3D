% list all configured tetra calibrations
function tetraCalList()
    global tetra
    nam = fieldnames(tetra.cal);
    for k=1:length(nam)
        cal = tetra.cal.(nam);
        disp(nam);
        for m=1:length(cal.fields)
            s = '';
            if sum(cal.scalar==m) > 0, s='(scalar)'; end
            fprintf(1,'\t%s %s\n',cal.field{m}, s);
        end
    end
end
