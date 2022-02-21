# TinJasmine

Looking at case C3L-00102 on katmai here:
    BASE=/scratch1/fs1/dinglab/m.wyczalkowski/cromwell-data/cromwell-workdir/cromwell-executions/TinJasmine.cwl/b50a25fa-ee76-40dd-9abf-4abcca8157ea
YAML file: /storage1/fs1/dinglab/Active/Projects/CPTAC3/Analysis/CromwellRunner/TinJasmine/02.PDA5/yaml/C3L-00102.yaml

This had an error, `unparsable vcf record with allele W`

## Configuration
Files:
reference=/storage1/fs1/dinglab/Active/Resources/References/GRCh38.d1.vd1/GRCh38.d1.vd1.fa
gatk_indel=$BASE/call-vld_filter_gatk_indel/execution/VLD_FilterVCF_output.vcf
gatk_snv=$BASE/call-vld_filter_gatk_snp/execution/VLD_FilterVCF_output.vcf
pindel=$BASE/call-vld_filter_pindel/execution/VLD_FilterVCF_output.vcf
varscan_indel=$BASE/call-vld_filter_varscan_indel/execution/VLD_FilterVCF_output.vcf
varscan_snv=$BASE/call-vld_filter_varscan_snp/execution/VLD_FilterVCF_output.vcf

Output to:
    /storage1/fs1/dinglab/Active/Projects/CPTAC3/Analysis/CromwellRunner/TinJasmine/03.ref_remap.dev/testing-output


