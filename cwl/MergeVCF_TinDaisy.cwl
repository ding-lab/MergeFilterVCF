class: CommandLineTool
cwlVersion: v1.0
id: merge_vcf_td
baseCommand:
  - /bin/bash
  - /opt/MergeFilterVCF/src/merge_vcf.sh
inputs:
  - id: reference
    type: File
    inputBinding:
      position: 0
      prefix: '-R'
    label: Reference FASTA
    secondaryFiles:
      - .fai
      - ^.dict
  - id: strelka_snv_vcf
    type: File
    inputBinding:
      position: 10
  - id: strelka_indel_vcf
    type: File
    inputBinding:
      position: 11
  - id: varscan_snv_vcf
    type: File
    inputBinding:
      position: 12
  - id: varscan_indel_vcf
    type: File
    inputBinding:
      position: 13
  - id: mutect_vcf
    type: File
    inputBinding:
      position: 14
  - id: pindel_vcf
    type: File
    inputBinding:
      position: 15
  - id: dryrun
    type: boolean?
    inputBinding:
      position: 0
      prefix: '-d'
  - id: merge_all
    type: boolean?
    inputBinding:
      position: 0
      prefix: '-P'
    doc: Include non-PASS variants in merge
  - id: ref_remap
    type: boolean?
    inputBinding:
      position: 0
      prefix: '-N'
    doc: Change ambiguous codes in REF to N
  - id: xargs
    type: string?
    inputBinding:
      position: 0
      prefix: '-X'
    doc: Additional arguments to CombineVariants
outputs:
  - id: merged_vcf
    type: File
    outputBinding:
      glob: output/merged.vcf
label: Merge_VCF_TD
arguments:
  - position: 0
    prefix: '-o'
    valueFrom: output/merged.vcf
requirements:
  - class: ResourceRequirement
    ramMin: 8000
  - class: DockerRequirement
    dockerPull: mwyczalkowski/merge_vcf_gatk:20200608
  - class: InlineJavascriptRequirement
