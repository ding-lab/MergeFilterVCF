Merge VCF files and filter the result according to which callers called them.

There are two separate steps, each with their own script and CWL tool:
* Merge VCF
* Filter VCF

# Merge VCF

Combine VCF files from several callers into one
The following files are combined:
* GATK indel          ("gatk_indel")
* GATK SNV            ("gatk_snv")
* pindel indel        ("pindel")
* varscan indel       ("varscan_indel")
* varscan SNV         ("varscan_snv")

priority: gatk_snv,varscan_snv,gatk_indel,varscan_indel,pindel

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

For the current implementation of TinJasmine, we retain only the FILTER=PASS calls and we do not remap the ambiguity
codes.

Implementation is based on GATK 3.8 CombineVariants

# Filter VCF

Filters calls based on the value of the `set` field which is written to the merged VCF file.  In the
current implementation, variants which are called by only by `varscan_indel` or `gatk_indel` are excluded.
We retain these variants in the VCF file with FILTER=`merge` 


# Author

Matthew Wyczalkowski <m.wyczalkowski@wustl.edu>

