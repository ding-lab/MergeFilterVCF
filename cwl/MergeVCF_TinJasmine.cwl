class: CommandLineTool
cwlVersion: v1.0
id: merge_vcf
baseCommand:
  - /bin/bash
  - /opt/MergeFilterVCF/src/merge_vcf_TinJasmine.sh
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
  - id: gatk_indel
    type: File
    inputBinding:
      position: 10
    label: GATK indel VCF
  - id: gatk_snv
    type: File
    inputBinding:
      position: 11
    label: GATK SNV VCF
  - id: pindel
    type: File
    inputBinding:
      position: 12
    label: Pindel indel VCF
  - id: varscan_indel
    type: File
    inputBinding:
      position: 13
    label: Varscan indel VCF
  - id: varscan_snv
    type: File
    inputBinding:
      position: 14
    label: Varscan SNV VCF
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
    doc: Do not exclude non-PASS variants
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
label: Merge_VCF
arguments:
  - position: 0
    prefix: '-o'
    valueFrom: output/merged.vcf
requirements:
  - class: ResourceRequirement
    ramMin: 8000
  - class: DockerRequirement
    dockerPull: mwyczalkowski/merge_vcf_gatk:20201002
  - class: InlineJavascriptRequirement
