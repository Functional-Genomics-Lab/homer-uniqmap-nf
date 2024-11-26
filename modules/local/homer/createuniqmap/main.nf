process HOMER_CREATEUNIQMAP {
    cpus 16
    memory '10GB'
    time '2h'
    conda "${moduleDir}/environment.yml"
    container "${workflow.containerEngine == 'singularity' && !task.ext.singularity_pull_docker_container
        ? 'oras://community.wave.seqera.io/library/homer_zip:c9b7d4ac4204910a'
        : 'community.wave.seqera.io/library/homer_zip:609bdbc38096592d'}"

    input:
    path mappable_regions
    val genome_name
    val read_length

    output:
    path ("uniqmap/"), emit: uniqmap_dir
    path ("uniqmap*.zip"), emit: uniqmap_zip
    path "versions.yml", emit: versions

    when:
    task.ext.when == null || task.ext.when

    script:
    def args = task.ext.args ?: ''
    def prefix = task.ext.prefix ?: ""
    def VERSION = '4.11'
    // Zip up the uniqmap directory
    // Results in uniqmap.hg38.50nt.zip
    // uniqmap.<genome>.<read_length>nt.zip
    // Then inside of it
    // hg38-50nt-uniqmap/chr18.p.uniqmap
    // Might just be easier to make it in HOMER_CREATEUNIQMAP and publish both
    """
    mkdir -p uniqmap
    homerTools special uniqmap \\
        ${genome_name}-${read_length}nt-uniqmap/ \\
        ${mappable_regions}

    zip -r \\
        uniqmap.${genome_name}.${read_length}nt.zip \\
        ${genome_name}-${read_length}nt-uniqmap/

    cat <<-END_VERSIONS > versions.yml
    "${task.process}":
        homer: ${VERSION}
    END_VERSIONS
    """

    stub:
    def VERSION = '4.11'
    """
    mkdir -p uniqmap

    cat <<-END_VERSIONS > versions.yml
    "${task.process}":
        homer: ${VERSION}
    END_VERSIONS
    """
}
