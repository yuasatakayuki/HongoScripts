#!/bin/bash


pwd=`pwd`
if [ `basename $pwd` != spectral_analysis ];
then
echo "run this script at analysis/gso/spectral_analysis/ folder."
exit
fi

read -p "input tag name > " tag
if [ _$tag = _ ];
then
echo "tag name empty...exit"
exit
fi

#create gti
if [ ! -f gtis/$tag/cleaned_evt_nxb_merged.gti ];
then
mkdir -p gtis/$tag pis/$tag plots/$tag &> /dev/null
pin_merge_gtis.sh "../data/gso_evt.evt+2" "../data/gso_nxb.evt+2" gtis/$tag/cleaned_evt_nxb_merged.gti
fi

#extract spectra
gso_extract_spectrum_with_gti.sh ../data/gso_evt.evt ../data/pseudo.evt gtis/${tag}/cleaned_evt_nxb_merged.gti pis/${tag}/gso_evt_gti_evt_nxb_merged.pi
gso_extract_spectrum_with_gti.sh ../data/gso_nxb.evt ../data/pseudo.evt gtis/${tag}/cleaned_evt_nxb_merged.gti nxbs/${tag}/gso_nxb_gti_evt_nxb_merged.pi

#plot
gso_create_spectra_check_plot.sh \
 pis/${tag}/gso_evt_gti_evt_nxb_merged_dtcor_binGSO.pi \
 nxbs/${tag}/gso_nxb_gti_evt_nxb_merged.pi \
 nxbs/${tag}/gso_nxb_gti_evt_nxb_merged_times100.pi \
 `gso_find_responsefile_auto.sh pis/${tag}/gso_evt_gti_evt_nxb_merged_dtcor_binGSO.pi` \
 plots/${tag}/gso_evt_gti_evt_nxb_merged_binGSO.pdf \
 `gso_find_arffile_auto.sh pis/${tag}/gso_evt_gti_evt_nxb_merged_dtcor_binGSO.pi`
