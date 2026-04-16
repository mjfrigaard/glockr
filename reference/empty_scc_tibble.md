# Return an empty tibble with the correct schema

Used as a safe fallback when `scc` produces no output (e.g. an empty
directory or no files matching the requested extensions).

## Usage

``` r
empty_scc_tibble(by_file = FALSE)
```

## Arguments

- by_file:

  Logical. When `TRUE` returns the per-file schema (12 columns); when
  `FALSE` (default) returns the per-language schema (10 columns).

## Value

A zero-row
[`tibble::tibble()`](https://tibble.tidyverse.org/reference/tibble.html)
whose columns and types match the output of
[`scc()`](https://mjfrigaard.github.io/glockr/reference/scc.md)
(`by_file = FALSE`) or
[`scc_by_file()`](https://mjfrigaard.github.io/glockr/reference/scc_by_file.md)
(`by_file = TRUE`).
