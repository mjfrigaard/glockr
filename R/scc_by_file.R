#' Count lines of code per file
#'
#' Runs `scc` on one or more paths with the `--by-file` flag and returns
#' one row per source file.
#'
#' @inheritParams scc
#'
#' @return A [tibble::tibble()] with columns:
#'   \describe{
#'     \item{language}{Programming language name.}
#'     \item{filename}{File name (basename).}
#'     \item{location}{Full file path.}
#'     \item{lines}{Total line count.}
#'     \item{code}{Lines of code.}
#'     \item{comments}{Lines of comments.}
#'     \item{blanks}{Blank lines.}
#'     \item{complexity}{Cyclomatic complexity.}
#'     \item{weighted_complexity}{Complexity weighted by lines.}
#'     \item{bytes}{File size in bytes.}
#'     \item{generated}{Logical; `TRUE` if file is auto-generated.}
#'     \item{minified}{Logical; `TRUE` if file is minified.}
#'   }
#'
#' @export
#' 
#' @examples
#' \dontrun{
#' scc_by_file()
#' scc_by_file("~/myproject", include_ext = "R")
#' }
scc_by_file <- function(
    path          = ".",
    sort          = "code",
    no_complexity = FALSE,
    no_duplicates = FALSE,
    no_gen        = FALSE,
    include_ext   = NULL,
    exclude_ext   = NULL,
    not_match     = NULL) {

  scc_bin <- find_scc()
  args    <- build_args(
    sort          = sort,
    no_complexity = no_complexity,
    no_duplicates = no_duplicates,
    no_gen        = no_gen,
    include_ext   = include_ext,
    exclude_ext   = exclude_ext,
    not_match     = not_match,
    by_file       = TRUE
  )
  args <- c(args, path)

  res <- processx::run(scc_bin, args = args, error_on_status = FALSE)
  if (res$status != 0L) {
    stop("scc failed:\n", res$stderr, call. = FALSE)
  }

  parse_scc_json(res$stdout, by_file = TRUE)
}
