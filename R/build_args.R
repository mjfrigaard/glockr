#' Build the scc argument vector
#'
#' Translates R-level options into the character vector of CLI flags passed
#' to `scc` via [processx::run()].
#'
#' @param sort Character. Column to sort by. One of `"name"`, `"files"`,
#'   `"lines"`, `"code"`, `"comments"`, `"blanks"`, `"complexity"`.
#' @param no_complexity Logical. Add `--no-complexity` flag when `TRUE`.
#' @param no_duplicates Logical. Add `--no-duplicates` flag when `TRUE`.
#' @param no_gen Logical. Add `--no-gen` flag when `TRUE`.
#' @param include_ext Character vector of extensions to include, or `NULL`.
#'   Multiple extensions are collapsed to a comma-separated string.
#' @param exclude_ext Character vector of extensions to exclude, or `NULL`.
#'   Multiple extensions are collapsed to a comma-separated string.
#' @param not_match Character vector of regex patterns. Each becomes its own
#'   `--not-match <pattern>` pair in the output, or `NULL` for none.
#' @param by_file Logical. Add `--by-file` flag when `TRUE`.
#'
#' @return Character vector of CLI arguments, always starting with
#'   `c("--format", "json", "--sort", <sort>)`.
#'
#' @examples
#' \dontrun{
#' # Default language-level summary
#' build_args("code", FALSE, FALSE, FALSE, NULL, NULL, NULL, FALSE)
#'
#' # Per-file, R only, skip complexity
#' build_args("lines",
#'   no_complexity = TRUE,
#'   no_duplicates = FALSE,
#'   no_gen        = FALSE,
#'   include_ext   = "r",
#'   exclude_ext   = NULL,
#'   not_match     = NULL,
#'   by_file       = TRUE
#' )
#' }
build_args <- function(
    sort,
    no_complexity,
    no_duplicates,
    no_gen,
    include_ext,
    exclude_ext,
    not_match,
    by_file) {

  sort <- match.arg(
    sort,
    c("name", "files", "lines", "code", "comments", "blanks", "complexity")
  )

  args <- c("--format", "json", "--sort", sort)

  if (isTRUE(by_file))       args <- c(args, "--by-file")
  if (isTRUE(no_complexity)) args <- c(args, "--no-complexity")
  if (isTRUE(no_duplicates)) args <- c(args, "--no-duplicates")
  if (isTRUE(no_gen))        args <- c(args, "--no-gen")

  if (!is.null(include_ext)) {
    args <- c(args, "--include-ext", paste(include_ext, collapse = ","))
  }
  if (!is.null(exclude_ext)) {
    args <- c(args, "--exclude-ext", paste(exclude_ext, collapse = ","))
  }
  if (!is.null(not_match)) {
    for (pat in not_match) args <- c(args, "--not-match", pat)
  }

  args
}
