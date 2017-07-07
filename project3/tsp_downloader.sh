cd data

curl "http://elib.zib.de/pub/mp-testdata/tsp/tsplib/tsp/$1.tsp" -o "$1.tsp"
curl "http://elib.zib.de/pub/mp-testdata/tsp/tsplib/tsp/$1.opt.tour" -o "$1.opt"

cd ..