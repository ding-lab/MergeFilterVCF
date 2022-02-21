# TinDaisy 

Direct testing of merge filter for TinDaisy on katmai

Based on 
from : /gscuser/mwyczalk/projects/TinDaisy/TinDaisy/submodules/VLD_FilterVCF/testing/direct_call-TinDaisy/README.md

Using test CCRCC case C3L-00908.
See MGI:/gscuser/mwyczalk/projects/TinDaisy/testing/dbSnP-filter-dev/VEP_annotate.testing.C3L-00908/testing/README.data.md
for details on this dataset.  It is based on CromwellRunner run: 06_CCRCC.HotSpot.20200511
Path on MGI: /gscmnt/gc2541/cptac3_analysis/cromwell-workdir/cromwell-executions/tindaisy-hotspot.cwl/47c63123-dab6-417b-a431-c9aa9589e6e4/results

Results of this run are copied to katmai here:
/home/mwyczalk_test/Projects/TinDaisy/testing/C3L-00908-data/dat

Starting dataset - input into merge is output of vld steps

call-hotspot_vld_mutect/
RESULTS/call-hotspot_vld_mutect/hotspot_vld.cwl/f5a823e8-707b-4a1e-b5d6-a1c0ae021bea/call-hotspotfilter/execution/output/HotspotFiltered.vcf

call-hotspot_vld_pindel/
RESULTS/call-hotspot_vld_pindel/hotspot_vld.cwl/e5de7d1c-ad01-41b0-90ba-fa22e0428c5d/call-hotspotfilter/execution/output/HotspotFiltered.vcf

call-hotspot_vld_strelka_indel/
RESULTS/call-hotspot_vld_strelka_indel/hotspot_vld.cwl/8996e5d4-2692-49df-814a-5f5319947369/call-hotspotfilter/execution/output/HotspotFiltered.vcf

call-hotspot_vld_strelka_snv/
RESULTS/call-hotspot_vld_strelka_snv/hotspot_vld.cwl/312c678b-11be-416e-935f-227ae03386e1/call-hotspotfilter/execution/output/HotspotFiltered.vcf

call-hotspot_vld_varscan_indel/
RESULTS/call-hotspot_vld_varscan_indel/hotspot_vld.cwl/e0cef30e-1d27-40ad-8f1c-18d1e3a291b7/call-hotspotfilter/execution/output/HotspotFiltered.vcf

call-hotspot_vld_varscan_snv/
RESULTS/call-hotspot_vld_varscan_snv/hotspot_vld.cwl/27ac9be3-7575-4477-8f85-5d3652992ee9/call-hotspotfilter/execution/output/HotspotFiltered.vcf
