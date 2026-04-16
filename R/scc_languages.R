#' List languages supported by scc
#'
#' @return A [tibble::tibble()] with one row per language and columns
#'   `language` and `extensions`.
#'   
#' @export
#' 
#' @examples
#' \dontrun{
#' scc_languages()
#' }
scc_languages <- function() {
  scc <- find_scc()
  res <- processx::run(scc, args = "--languages", error_on_status = FALSE)
  raw <- trimws(strsplit(res$stdout, "\n")[[1]])
  raw <- raw[nchar(raw) > 0L]

  # Each line is: "LanguageName (ext1,ext2,...)"
  parsed <- regmatches(raw, regexec("^(.+?)\\s+\\((.+)\\)$", raw))
  valid  <- Filter(function(x) length(x) == 3L, parsed)

  tibble::tibble(
    language   = vapply(valid, `[[`, character(1L), 2L),
    extensions = vapply(valid, `[[`, character(1L), 3L)
  )
}
