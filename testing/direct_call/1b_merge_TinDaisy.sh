# /diskmnt/Datasets/Reference/GRCh38.d1.vd1/GRCh38.d1.vd1.fa
REF="/Reference/GRCh38.d1.vd1/GRCh38.d1.vd1.fa"

#     - id: strelka_snv_vcf
#       source: hotspot_vld_strelka_snv/output
#     - id: varscan_indel_vcf
#       source: hotspot_vld_varscan_indel/output
#     - id: varscan_snv_vcf
#       source: hotspot_vld_varscan_snv/output
#     - id: pindel_vcf
#       source: hotspot_vld_pindel/output
#     - id: reference_fasta
#       source: reference_fasta
#     - id: strelka_indel_vcf
#       source: hotspot_vld_strelka_indel/output
#     - id: mutect_vcf
#       source: hotspot_vld_mutect/output

IN_VCF=" \
/data/call-hotspot_vld_strelka_snv/hotspot_vld.cwl/312c678b-11be-416e-935f-227ae03386e1/call-hotspotfilter/execution/output/HotspotFiltered.vcf \
/data/call-hotspot_vld_strelka_indel/hotspot_vld.cwl/8996e5d4-2692-49df-814a-5f5319947369/call-hotspotfilter/execution/output/HotspotFiltered.vcf \
/data/call-hotspot_vld_varscan_snv/hotspot_vld.cwl/27ac9be3-7575-4477-8f85-5d3652992ee9/call-hotspotfilter/execution/output/HotspotFiltered.vcf \
/data/call-hotspot_vld_varscan_indel/hotspot_vld.cwl/e0cef30e-1d27-40ad-8f1c-18d1e3a291b7/call-hotspotfilter/execution/output/HotspotFiltered.vcf \
/data/call-hotspot_vld_mutect/hotspot_vld.cwl/f5a823e8-707b-4a1e-b5d6-a1c0ae021bea/call-hotspotfilter/execution/output/HotspotFiltered.vcf \
/data/call-hotspot_vld_pindel/hotspot_vld.cwl/e5de7d1c-ad01-41b0-90ba-fa22e0428c5d/call-hotspotfilter/execution/output/HotspotFiltered.vcf 
"

OUTD="./results"
OUT="$OUTD/merged.vcf"

# Usage: merge_vcf_TinDaisy.sh [options] strelka sindel varscan varindel mutect pindel
# -p $OUTD - intermediate files go 
CMD="bash ../../src/merge_vcf_TinDaisy.sh $@ -o $OUT -R $REF -p $OUTD $IN_VCF"

>&2 echo Running $CMD
eval $CMD

