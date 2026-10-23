% standard timestamp to second.
function s = timestamp(t=now(),fmt='yymmddHHMMSS')
    s = datestr(t,fmt);
end
