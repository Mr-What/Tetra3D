% return ideal tetra measurements.
% use given file name if provided.
% use global setting
% use hard-coded
function fn = idealTetraMeasFile(fileName=[])
    global tetra
    fn=[];
    if isstring(fileName)
        fn = fileName;
        disp(['Setting default ideal cal print measurements to ' , fn]);
        tetra.measFileIdeal = fileName;
    else
        fn = tetra.measFileIdeal;
        disp(['Using ideal calibration print measurements from ', fn]);
    end
    if isempty(fn)
        fn = 'idealDeltaCalMeas10_60.m';
        disp(['Setting default ideal cal print measurement file to ' , fn]);
        tetra.measFileIdeal = fn;
    end
end

        
