nextflow.preview.output = true

include { HOMER_GETMAPPABLEREGIONS } from './modules/local/homer/getmappableregions'
include { HOMER_CREATEUNIQMAP      } from './modules/local/homer/createuniqmap'

workflow {
    main:
    ch_versions = Channel.empty()

    // Split FASTA by chromosome
    split_fastas = file(params.fasta).splitFasta(by: 1, file: true)

    // Generate mappable regions
    HOMER_GETMAPPABLEREGIONS(
        split_fastas,
        params.parallel_sequences_analyzed,
        params.read_length
    )
    ch_versions = ch_versions.mix(HOMER_GETMAPPABLEREGIONS.out.versions)

    // Create uniqmap directory
    HOMER_CREATEUNIQMAP(
        HOMER_GETMAPPABLEREGIONS.out.txt,
        params.genome_name,
        params.read_length
    )
    ch_versions = ch_versions.mix(HOMER_CREATEUNIQMAP.out.versions)

    publish:
    HOMER_CREATEUNIQMAP.out.uniqmap_zip >> 'homer'
}

output {
    'homer' {
        mode 'copy'
    }
}
