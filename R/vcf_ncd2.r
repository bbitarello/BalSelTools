# @
#
# This is a function called vcf_ncd1.R
# which makes an input file for NCD1 from a vcf file
#
# You can learn more about package authoring with RStudio at:
#
#   v
#
# Some useful keyboard shortcuts for package authoring:
#
#   Install Package:           'Cmd + Shift + B'
#   Check Package:             'Cmd + Shift + E'
#   Test Package:              'Cmd + Shift + T'
#' @export
vcf_ncd2 <-
        function(x = inp,
                 outfile = outfile,
                 nind = nind,
                 index.col = index.col,
                 fold = fold,
                 verbose = verbose) {
                npop <- length(nind)
                assertthat::assert_that(npop == 2 |
                                                npop == 3, msg = "If only one species is represented, you should use ncd1.\n")
                pop0_cols <- c(index.col, index.col + (nind[1] - 1))
                if (npop > 2) {
                        nind <- nind[c(1, 2)]
                }
                npop2 <- length(nind)
                if (verbose == T) {
                        cat(
                                glue::glue(
                                        "Your vcf contains {npop} populations. Only {npop2} are considered:"
                                ),
                                "\n"
                        )
                }
                if (verbose == T) {
                        cat(
                                glue::glue(
                                        "Pop0: {nind[1]} diploid individuals.Columns {pop0_cols[1]}:{pop0_cols[2]}. This is your population of interest."
                                ),
                                "\n"
                        )
                }
                pop1_cols <-
                        c(index.col + (nind[1]), index.col + (sum(nind) - 1))
                if (verbose == T) {
                        cat(
                                glue::glue(
                                        "Pop1: {nind[2]} diploid individuals.Columns {pop1_cols[1]}:{pop1_cols[2]}. This is your outgroup."
                                ),
                                "\n"
                        )
                }
                tableout <-
                        data.table::data.table(
                                CHR = NA,
                                POS = NA,
                                ANC = NA,
                                REF = NA,
                                ALT = NA,
                                tx_1 = NA,
                                tn_1 = NA,
                                tx_2 = NA,
                                tn_2 = NA
                        )
                counter = 0
                for (l in 1:nrow(x)) {
                        cat(l, "\r")
                        chr <- x[l, 1]
                        pos <- x[l, 2]
                        ref <- x[l, 4]
                        alt <- x[l, 5]

                        if (!(ref %in% c("A", "C", "G", "T") &
                              alt %in% c("A", "C", "G", "T"))) {
                                if (verbose == T) {
                                        cat(
                                                glue::glue(
                                                        "Line {l} {ref} {alt} will be skipped. Only bi-allelic SNPs PASS"
                                                ),
                                                "\n"
                                        )
                                }
                                counter = counter + 1
                                next
                        }
                        x <- data.table::setDT(x)
                        anc <-
                                x[l, colnames(x)[index.col + (sum(nind) - 1)], with = F]
                        anc <-
                                stringr::str_split(anc, "|", simplify = F)[[1]][[2]]
                        drv = 0
                        total = 0
                        drv2 = 0
                        total2 = 0

                        for (i in pop0_cols) {
                                al <-
                                        stringr::str_split(x[l, colnames(x)[i], with = F], "|", simplify = F)[[1]]
                                if (al[1] != anc) {
                                        drv = drv + 1
                                }
                                if (al[2] != anc) {
                                        drv = drv + 1
                                }
                                total = total + 2
                        }
                        for (i in (index.col + nind[1]):(index.col + nind[1] + (nind[2] -
                                                                                1))) {
                                al <-
                                        stringr::str_split(x[l, colnames(x)[i], with = F], "|", simplify = F)[[1]]
                                if (al[1] != anc) {
                                        drv2 = drv2 + 1
                                }
                                if (al[2] != anc) {
                                        drv2 = drv2 + 1
                                }
                                total2 = total2 + 2
                        }
                        tableout <-
                                rbind(
                                        tableout,
                                        data.table::data.table(
                                                chr,
                                                pos,
                                                ref,
                                                ref,
                                                alt,
                                                tx_1 = drv,
                                                tn_1 = total,
                                                tx_2 = drv2,
                                                tn_2 = total2
                                        ),
                                        use.names = FALSE
                                )
                }
                tableout <- tableout[-1,]
                if (verbose == T) {
                        cat(glue::glue("Printing output to {outfile}..."),
                            "\n")
                }
                data.table::fwrite(tableout,
                                   file = outfile,
                                   sep = "\t",
                                   col.names = F)
                if (verbose == T) {
                        cat(glue::glue("Lines skipped: {counter}"), "\n")
                }

                return(tableout)

        }