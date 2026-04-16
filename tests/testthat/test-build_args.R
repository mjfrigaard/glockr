# Helper: call build_args with all defaults except the one under test
default_args <- function(...) {
  args <- list(
    sort          = "code",
    no_complexity = FALSE,
    no_duplicates = FALSE,
    no_gen        = FALSE,
    include_ext   = NULL,
    exclude_ext   = NULL,
    not_match     = NULL,
    by_file       = FALSE
  )
  args[names(list(...))] <- list(...)
  do.call(glockr:::build_args, args)
}

# --- %||% -------------------------------------------------------------------

test_that("%||% returns left value when it is not NULL", {
  expect_equal("a" %||% "b", "a")
  expect_equal(0L  %||% 99L, 0L)
  expect_equal(FALSE %||% TRUE, FALSE)
})

test_that("%||% returns right value when left is NULL", {
  expect_equal(NULL %||% "b",   "b")
  expect_equal(NULL %||% 42L,   42L)
  expect_equal(NULL %||% FALSE, FALSE)
})

# --- defaults ---------------------------------------------------------------

test_that("build_args() always emits --format json", {
  args <- default_args()
  idx  <- which(args == "--format")
  expect_length(idx, 1L)
  expect_equal(args[[idx + 1L]], "json")
})

test_that("build_args() defaults to --sort code", {
  args <- default_args()
  idx  <- which(args == "--sort")
  expect_length(idx, 1L)
  expect_equal(args[[idx + 1L]], "code")
})

test_that("build_args() emits no optional flags by default", {
  args <- default_args()
  optional_flags <- c(
    "--by-file", "--no-complexity", "--no-duplicates", "--no-gen",
    "--include-ext", "--exclude-ext", "--not-match"
  )
  expect_false(any(optional_flags %in% args))
})

# --- sort values ------------------------------------------------------------

test_that("build_args() accepts all valid sort values", {
  valid <- c("name", "files", "lines", "code", "comments", "blanks", "complexity")
  for (s in valid) {
    args <- default_args(sort = s)
    expect_equal(args[[which(args == "--sort") + 1L]], s,
                 label = paste("sort =", s))
  }
})

test_that("build_args() rejects an invalid sort value", {
  expect_error(default_args(sort = "bad"), "should be one of")
})

# --- boolean flags ----------------------------------------------------------

test_that("build_args() adds --by-file when by_file = TRUE", {
  expect_true("--by-file" %in% default_args(by_file = TRUE))
})

test_that("build_args() omits --by-file when by_file = FALSE", {
  expect_false("--by-file" %in% default_args(by_file = FALSE))
})

test_that("build_args() adds --no-complexity when no_complexity = TRUE", {
  expect_true("--no-complexity" %in% default_args(no_complexity = TRUE))
})

test_that("build_args() omits --no-complexity when no_complexity = FALSE", {
  expect_false("--no-complexity" %in% default_args(no_complexity = FALSE))
})

test_that("build_args() adds --no-duplicates when no_duplicates = TRUE", {
  expect_true("--no-duplicates" %in% default_args(no_duplicates = TRUE))
})

test_that("build_args() adds --no-gen when no_gen = TRUE", {
  expect_true("--no-gen" %in% default_args(no_gen = TRUE))
})

# --- extension filters ------------------------------------------------------

test_that("build_args() adds --include-ext with a single extension", {
  args <- default_args(include_ext = "R")
  idx  <- which(args == "--include-ext")
  expect_length(idx, 1L)
  expect_equal(args[[idx + 1L]], "R")
})

test_that("build_args() collapses multiple include extensions with a comma", {
  args <- default_args(include_ext = c("R", "py", "js"))
  expect_equal(args[[which(args == "--include-ext") + 1L]], "R,py,js")
})

test_that("build_args() adds --exclude-ext with a single extension", {
  args <- default_args(exclude_ext = "json")
  idx  <- which(args == "--exclude-ext")
  expect_length(idx, 1L)
  expect_equal(args[[idx + 1L]], "json")
})

test_that("build_args() collapses multiple exclude extensions with a comma", {
  args <- default_args(exclude_ext = c("js", "ts"))
  expect_equal(args[[which(args == "--exclude-ext") + 1L]], "js,ts")
})

# --- not_match --------------------------------------------------------------

test_that("build_args() adds one --not-match flag per pattern", {
  args   <- default_args(not_match = c("test", "vendor"))
  nm_idx <- which(args == "--not-match")
  expect_length(nm_idx, 2L)
  expect_equal(args[nm_idx + 1L], c("test", "vendor"))
})

test_that("build_args() handles a single not_match pattern", {
  args <- default_args(not_match = "node_modules")
  nm_idx <- which(args == "--not-match")
  expect_length(nm_idx, 1L)
  expect_equal(args[[nm_idx + 1L]], "node_modules")
})

# --- combinations -----------------------------------------------------------

test_that("build_args() combines multiple flags correctly", {
  args <- default_args(
    sort          = "lines",
    by_file       = TRUE,
    no_complexity = TRUE,
    include_ext   = c("R", "py"),
    not_match     = "test"
  )
  expect_equal(args[[which(args == "--sort") + 1L]], "lines")
  expect_true("--by-file"       %in% args)
  expect_true("--no-complexity" %in% args)
  expect_equal(args[[which(args == "--include-ext") + 1L]], "R,py")
  expect_equal(args[[which(args == "--not-match")  + 1L]], "test")
})
