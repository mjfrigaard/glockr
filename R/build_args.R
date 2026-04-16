#' Build the scc argument vector
#'
#' @keywords internal
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