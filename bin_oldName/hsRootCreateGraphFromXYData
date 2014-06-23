#!/bin/bash

#20090709 Takayuki Yuasa file created
#20090730 Takayuki Yuasa data point number set to zero initially

if [ _$1 = _ ];
then
echo "usage : root_create_graph_from_xy.sh (input data file)"
exit
fi

if [ ! -f $1 ];
then
echo "file not found..."
exit
fi

file=$1

root -l << EOF &> /dev/null
{
ifstream ifs("$file");
TGraph* g=new TGraph(0);
double a,b;
int i=0;
while(!ifs.eof()){
 ifs >> a >> b; g->SetPoint(i,a,b);
 i++;
}
TFile f("${file}.root","recreate");
g->SetName("graph");
g->Write();
}
.q
EOF


