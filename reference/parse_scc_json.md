# Parse JSON output from scc into a tibble

Converts the raw JSON written to stdout by `scc --format json` into a
[`tibble::tibble()`](https://tibble.tidyverse.org/reference/tibble.html).
Handles empty or blank output by returning a zero-row tibble with the
correct column schema via
[`empty_scc_tibble()`](https://mjfrigaard.github.io/glockr/reference/empty_scc_tibble.md).

## Usage

``` r
parse_scc_json(json_text, by_file = FALSE)
```

## Arguments

- json_text:

  Character scalar: raw stdout captured from `scc`.

- by_file:

  Logical. When `TRUE` unpacks the per-file `Files` array inside each
  language block; when `FALSE` (default) returns one row per language.

## Value

A
[`tibble::tibble()`](https://tibble.tidyverse.org/reference/tibble.html).
Column layout matches
[`scc()`](https://mjfrigaard.github.io/glockr/reference/scc.md) when
`by_file = FALSE` and
[`scc_by_file()`](https://mjfrigaard.github.io/glockr/reference/scc_by_file.md)
when `by_file = TRUE`.

## Examples

``` r
if (FALSE) { # \dontrun{
json <- processx::run("scc", c("--format", "json", "."))$stdout
parse_scc_json(json)

json_by_file <- processx::run("scc", c("--format", "json", "--by-file", "."))$stdout
parse_scc_json(json_by_file, by_file = TRUE)
} # }
```
