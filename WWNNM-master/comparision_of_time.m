y=randn(1000,30);
y=y*y';
tic
[U S V] = svd(y,'econ');
S=max(S-10,0);
x = U*S*V';
toc
tic
x  = LRAppro( y,1,0,1,30 );
toc