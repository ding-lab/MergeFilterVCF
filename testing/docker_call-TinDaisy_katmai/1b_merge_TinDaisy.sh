source ../../docker/docker_image.sh
IMAGE=$IMAGE_GATK

#DATD="/home/mwyczalk_test/Projects/GermlineCaller/C3L-00001"

OUTD="./results"
mkdir -p $OUTD

REFD="/diskmnt/Datasets/Reference"

DATAD="/home/mwyczalk_test/Projects/TinDaisy/testing/C3L-00908-data/dat"
REF="/Reference/GRCh38.d1.vd1/GRCh38.d1.vd1.fa"

PROCESS="/opt/MergeFilterVCF/src/merge_vcf_TinDaisy.sh"

OUT="/results/merged.vcf"

IN_VCF=" \
/data/call-hotspot_vld_strelka_snv/hotspot_vld.cwl/312c678b-11be-416e-935f-227ae03386e1/call-hotspotfilter/execution/output/HotspotFiltered.vcf \
/data/call-hotspot_vld_strelka_indel/hotspot_vld.cwl/8996e5d4-2692-49df-814a-5f5319947369/call-hotspotfilter/execution/output/HotspotFiltered.vcf \
/data/call-hotspot_vld_varscan_snv/hotspot_vld.cwl/27ac9be3-7575-4477-8f85-5d3652992ee9/call-hotspotfilter/execution/output/HotspotFiltered.vcf \
/data/call-hotspot_vld_varscan_indel/hotspot_vld.cwl/e0cef30e-1d27-40ad-8f1c-18d1e3a291b7/call-hotspotfilter/execution/output/HotspotFiltered.vcf \
/data/call-hotspot_vld_mutect/hotspot_vld.cwl/f5a823e8-707b-4a1e-b5d6-a1c0ae021bea/call-hotspotfilter/execution/output/HotspotFiltered.vcf \
/data/call-hotspot_vld_pindel/hotspot_vld.cwl/e5de7d1c-ad01-41b0-90ba-fa22e0428c5d/call-hotspotfilter/execution/output/HotspotFiltered.vcf "


CMD="bash $PROCESS $@ -o $OUT -R $REF $IN_VCF"

ARGS="-M docker -l"
DCMD="../../docker/WUDocker/start_docker.sh $@ $ARGS -I $IMAGE -c \"$CMD\" $DATAD:/data $REFD:/Reference $OUTD:/results"

# bash docker/WUDocker/start_docker.sh $@ -I $IMAGE $DATAD:/data $REFD:/Reference $OUTD:/results

>&2 echo Running: $DCMD
eval $DCMD


