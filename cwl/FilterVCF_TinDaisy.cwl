class: CommandLineTool
cwlVersion: v1.0
id: merge_filter_td
baseCommand:
  - /bin/bash
  - /opt/MergeFilterVCF/src/filter_vcf.sh
inputs:
  - id: input_vcf
    type: File
    inputBinding:
      position: 10
  - id: dryrun
    type: boolean?
    inputBinding:
      position: 0
      prefix: '-d'
  - id: bypass
    type: boolean?
    inputBinding:
      position: 0
      prefix: '-B'
    doc: Bypass filter
  - id: remove_filtered
    type: boolean?
    inputBinding:
      position: 0
      prefix: '-R'
    doc: >-
      Remove filtered variants.  Default is to mark these in FILTER field and
      retain in VCF
outputs:
  - id: merged_vcf
    type: File
    outputBinding:
      glob: output/filtered.vcf
label: Merge_Filter_TD
arguments:
  - position: 0
    prefix: '-o'
    valueFrom: output/filtered.vcf
  - position: 0
    prefix: '-X'
    valueFrom: 'strelka,varscan,mutect,sindel,varindel,pindel'
requirements:
  - class: ResourceRequirement
    ramMin: 8000
  - class: DockerRequirement
    dockerPull: mwyczalkowski/merge_vcf_filter:20201002
  - class: InlineJavascriptRequirement
