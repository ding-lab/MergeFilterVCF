Merge VCF files and filter the result according to which callers called them.

There are two separate steps, each with their own script, docker image, and CWL tool:
* Merge VCF
* Filter VCF

Orginal implementation of merging and filtering was in
[TinDaisy-Core][tindaisy-core], based on [SomaticWrapper][somaticwrapper] code.
In [TinJasmine][tinjasmine], implementation in own Docker image, and this was
then ported to [TinDaisy][tindaisy].

[tindaisy-core]: https://github.com/ding-lab/TinDaisy-Core/blob/master/src/merge_vcf.pl
[somaticwrapper]: https://github.com/ding-lab/somaticwrapper
[tinjasmine]: https://github.com/ding-lab/TinJasmine
[tindaisy]: https://github.com/ding-lab/TinDaisy

# Merge VCF

## TinJasmine germline
Combine VCF files from several callers into one
The following files are combined:
* GATK indel          ("gatk_indel")
* GATK SNV            ("gatk_snv")
* pindel indel        ("pindel")
* varscan indel       ("varscan_indel")
* varscan SNV         ("varscan_snv")

priority: gatk_snv,varscan_snv,gatk_indel,varscan_indel,pindel

## TinDaisy somatic
The following files are combined:
* strelka SNV         ("strelka")
* strelka indel       ("sindel")
* varscan SNV         ("varscan")
* varscan indel       ("varindel")
* mutect SNV          ("mutect")
* pindel indel        ("pindel")

priority: varscan,mutect,strelka,varindel,pindel,sindel

## Common to both
Two types of filtering can be done to input data:
* retain only FILTER=PASS calls
    Only variants with FILTER value of PASS or . are retained for merging
    unless -P flag is set.  Given input A.vcf, intermediate files filtered.A.vcf are created
* remap any ambiguity codes in REF (not ACGTN) to N.
    Optionally remap IUPAC Ambiguity Codes to N for the reference allele, to avoid errors like,
        unparsable vcf record with allele R
    This generates intermediate files remap_ref.A.vcf.  Because these take up space and this
    problem is rarely seen unless -P is defined, by default we do not do this remapping
    See https://droog.gs.washington.edu/parc/images/iupac.html  Remapping to N suggested by Chris Miller

For the current implementation of TinJasmine and TinDaisy, we retain only the FILTER=PASS calls and we do not remap the ambiguity
codes.

Implementation is based on GATK 3.8 CombineVariants

# Filter VCF

Filters calls based on the value of the `set` field which is written to the merged VCF file.  

For TinJasmine, require 2/3 consensus for indels, so variants which are called by only by `varscan_indel` or `gatk_indel` are excluded, i.e.,
`--exclude varscan_indel,gatk_indel`

For TinDaisy, require 2/3 consensus for both indels and snv, so exclude variants reported by just one caller, i.e.,
`--exclude strelka,varscan,mutect,sindel,varindel,pindel`

We retain these variants in the VCF file with FILTER=`merge` 

# Author

Matthew Wyczalkowski <m.wyczalkowski@wustl.edu>
