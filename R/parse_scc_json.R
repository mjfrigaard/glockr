#' Parse JSON output from scc into a tibble
#'
#' Converts the raw JSON written to stdout by `scc --format json` into a
#' [tibble::tibble()]. Handles empty or blank output by returning a zero-row
#' tibble with the correct column schema via [empty_scc_tibble()].
#'
#' @param json_text Character scalar: raw stdout captured from `scc`.
#' @param by_file Logical. When `TRUE` unpacks the per-file `Files` array
#'   inside each language block; when `FALSE` (default) returns one row per
#'   language.
#'
#' @return A [tibble::tibble()]. Column layout matches [scc()] when
#'   `by_file = FALSE` and [scc_by_file()] when `by_file = TRUE`.
#'
#' @examples
#' \dontrun{
#' json <- processx::run("scc", c("--format", "json", "."))$stdout
#' parse_scc_json(json)
#'
#' json_by_file <- processx::run("scc", c("--format", "json", "--by-file", "."))$stdout
#' parse_scc_json(json_by_file, by_file = TRUE)
#' }
parse_scc_json <- function(json_text, by_file = FALSE) {
  if (!nzchar(trimws(json_text))) return(empty_scc_tibble(by_file))

  # scc --debug writes diagnostic lines (e.g. "DEBUG ...") to stdout; strip them
  lines     <- strsplit(json_text, "\n", fixed = TRUE)[[1L]]
  json_text <- paste(lines[!grepl("^(DEBUG|VERBOSE)\\s", lines)], collapse = "\n")
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
        weighted_complexity = round(as.double(lang$WeightedComplexity), 2),
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
          weighted_complexity = round(as.double(f$WeightedComplexity), 2),
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
