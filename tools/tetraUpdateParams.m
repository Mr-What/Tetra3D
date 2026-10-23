% extract parts of a tetra parameter set to be updated
function up = tetraUpdateParams(cal,gp)
    global tetra

    nf = length(cal.fields);
    for k=1:nf
        nam = cal.fields{k};  % field name
        up.(nam) = gp.(nam);
    end
end
