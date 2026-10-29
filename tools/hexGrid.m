function p = hexGrid(r)
    n=1;
    for k=1:r, n=n+6*k; end
    n
    p=zeros(n,2);
    p(1,:) = [0,0];
    m=2;
    for k=1:r
        m1=m+6*k;
        p(m:m1-1,:) = hexRing(k);
        m=m1;
    end
    m-1
end
