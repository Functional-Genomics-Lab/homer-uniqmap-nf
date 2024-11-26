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
        HOMER_GETMAPPABLEREGIONS.out.txt
    )
    ch_versions = ch_versions.mix(HOMER_CREATEUNIQMAP.out.versions)

    // TODO Zip up the uniqmap directory
    // Results in uniqmap.hg38.50nt.zip
    // uniqmap.<genome>.<read_length>nt.zip
    // Then inside of it
    // hg38-50nt-uniqmap/chr18.p.uniqmap
    // Might just be easier to make it in HOMER_CREATEUNIQMAP and publish both

    publish:
    HOMER_CREATEUNIQMAP.out.uniqmap_dir >> 'homer' // /uniqmap get's implicitly added
}

output {
    'homer' {
        mode 'copy'
    }
}
