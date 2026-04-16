#' Parse JSON output from scc into a tibble
#'
#' @param json_text Character scalar: raw stdout from scc.
#' @param by_file Logical: was `--by-file` used?
#' 
#' @return A [tibble::tibble()].
#' @keywords internal
parse_scc_json <- function(json_text, by_file = FALSE) {
  if (!nzchar(trimws(json_text))) return(empty_scc_tibble(by_file))

  raw <- jsonlite::fromJSON(json_text, simplifyVector = FALSE)
  if (length(raw) == 0L) return(empty_scc_tibble(by_file))

  if (!by_file) {
    rows <- lapply(raw, function(lang) {
      tibble::tibble(
        language            = lang$Name,
        files               = lang$Count %||% 0L,
        lines               = lang$Lines,
        code                = lang$Code,
        comments            = lang$Comment,
        blanks              = lang$Blank,
        complexity          = lang$Complexity,
        weighted_complexity = lang$WeightedComplexity,
        bytes               = lang$Bytes,
        uloc                = lang$ULOC %||% 0L
      )
    })
    do.call(rbind, rows)
  } else {
    rows <- lapply(raw, function(lang) {
      lang_name <- lang$Name
      files     <- lang$Files
      if (length(files) == 0L) return(NULL)
      lapply(files, function(f) {
        tibble::tibble(
          language            = lang_name,
          filename            = f$Filename,
          location            = f$Location,
          lines               = f$Lines,
          code                = f$Code,
          comments            = f$Comment,
          blanks              = f$Blank,
          complexity          = f$Complexity,
          weighted_complexity = f$WeightedComplexity,
          bytes               = f$Bytes,
          generated           = isTRUE(f$Generated),
          minified            = isTRUE(f$Minified)
        )
      })
    })
    rows <- unlist(rows, recursive = FALSE)
    rows <- Filter(Negate(is.null), rows)
    do.call(rbind, rows)
  }
}