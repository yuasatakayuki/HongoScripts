{
TF1* dgaus=new TF1("dgaus","[0]*exp(-(x-[1])*(x-[1])/[2]/[2])+[3]*exp(-(x-[4])*(x-[4])/[5]/[5])");
dgaus->SetParameters(1,0,1,1,0,1);
TF1* kdgaus=new TF1("kdgaus","([0]*exp(-(x-[1])*(x-[1])/[2]/[2])+[3]*exp(-(x-[4])*(x-[4])/[5]/[5]))*[6]");
kdgaus->SetParameters(1,0,1,1,0,1,1);

TF1* tgaus=new TF1("tgaus","[0]*exp(-(x-[1])*(x-[1])/[2]/[2])+[3]*exp(-(x-[4])*(x-[4])/[5]/[5])+[6]*exp(-(x-[7])*(x-[7])/[8]/[8])");
tgaus->SetParameters(1,0,1,1,0,1,1,0,1);
TF1* ktgaus=new TF1("ktgaus","([0]*exp(-(x-[1])*(x-[1])/[2]/[2])+[3]*exp(-(x-[4])*(x-[4])/[5]/[5])+[6]*exp(-(x-[7])*(x-[7])/[8]/[8]))*[9]");
tgaus->SetParameters(1,0,1,1,0,1,1,0,1,1);
}
