#' Count lines of code by language
#'
#' Runs `scc` on one or more paths and returns a per-language summary.
#'
#' @param path Character vector of file/directory paths to analyse.
#'   Defaults to the current working directory.
#' @param sort Character. Column to sort results by. One of `"name"`,
#'   `"files"`, `"lines"`, `"code"`, `"comments"`, `"blanks"`,
#'   `"complexity"`. Default `"code"`.
#' @param no_complexity Logical. Skip complexity calculation (faster).
#'   Default `FALSE`.
#' @param no_duplicates Logical. Exclude duplicate files. Default `FALSE`.
#' @param no_gen Logical. Exclude generated files. Default `FALSE`.
#' @param include_ext Character vector of file extensions to include
#'   (e.g. `c("R", "py")`). `NULL` (default) includes all.
#' @param exclude_ext Character vector of file extensions to exclude.
#'   `NULL` (default) excludes none.
#' @param not_match Character vector of regular expressions. Files/directories
#'   whose names match any pattern are ignored. `NULL` (default) matches none.
#'
#' @return A [tibble::tibble()] with columns:
#'   \describe{
#'     \item{language}{Programming language name.}
#'     \item{files}{Number of files.}
#'     \item{lines}{Total line count.}
#'     \item{code}{Lines of code.}
#'     \item{comments}{Lines of comments.}
#'     \item{blanks}{Blank lines.}
#'     \item{complexity}{Cyclomatic complexity total.}
#'     \item{weighted_complexity}{Complexity weighted by lines.}
#'     \item{bytes}{File size in bytes.}
#'     \item{uloc}{Unique lines of code.}
#'   }
#'
#' @export
#' @examples
#' \dontrun{
#' scc()               # current directory
#' scc("~/myproject")  # a specific path
#' scc(sort = "lines", no_complexity = TRUE)
#' }
scc <- function(
    path           = ".",
    sort           = "code",
    no_complexity  = FALSE,
    no_duplicates  = FALSE,
    no_gen         = FALSE,
    include_ext    = NULL,
    exclude_ext    = NULL,
    not_match      = NULL) {

  scc_bin <- find_scc()
  args    <- build_args(
    sort          = sort,
    no_complexity = no_complexity,
    no_duplicates = no_duplicates,
    no_gen        = no_gen,
    include_ext   = include_ext,
    exclude_ext   = exclude_ext,
    not_match     = not_match,
    by_file       = FALSE
  )
  args <- c(args, path)

  res <- processx::run(scc_bin, args = args, error_on_status = FALSE)
  if (res$status != 0L) {
    stop("scc failed:\n", res$stderr, call. = FALSE)
  }

  parse_scc_json(res$stdout, by_file = FALSE)
}
