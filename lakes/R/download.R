#' Downloads metadata
#'
#' https://planetarycomputer.microsoft.com/dataset/sentinel-2-l2a
#' @importFrom rstac stac stac_search get_request sign_planetary_computer
#'  items_sign
#' @importFrom purrr map_dfr map
#' @importFrom dplyr bind_rows left_join filter
#' @export
scenes_metadata <- function(date_range, bbox, max_nodata = 20, max_cloud = 20) {
  items <- stac("https://planetarycomputer.microsoft.com/api/stac/v1/") %>%
      stac_search(collections = "sentinel-2-l2a", bbox = bbox, datetime = date_range, limit = 100) %>%
      get_request() %>%
      items_sign(sign_fn = sign_planetary_computer())

  if (length(items$features) == 0) {
    return (list())
  }

  # compile item properties into data.frame
  properties <- map_dfr(
    items$features,
    ~ data.frame(
      id = .$id, p = .$properties,
      lng_left = .$bbox[1], lng_right = .$bbox[3],
      lat_lower = .$bbox[2], lat_upper = .$bbox[4])
    )

  # gather links into data.frame
  map(
    items$features,
    ~ map_dfr(.$assets, ~ data.frame(band_name = .$title, link = .$href), .id = "band")
  ) %>%
    set_names(properties$id) %>%
    bind_rows(.id = "id") %>%
    left_join(properties) %>%
    filter(
      p.s2.nodata_pixel_percentage < max_nodata,
      p.eo.cloud_cover < max_cloud,
      band %in% c(str_c("B", str_pad(1:12, 0, side = "left", width = 2)), "B8A", "SCL", "WVP")
    )
}

#' @importFrom terra rast crs ext
#' @importFrom reticulate source_python
#' @export
read_windows <- function(links, bbox, epsg = "epsg:4326") {
  source_python(system.file("extdata/download.py", package = "lakes"))
  result <- py$read_windows(links, bbox)
  if (length(result) == 0) {
    warning("skipping")
    return (list())
  }

  result <- rast(result)
  crs(result) <- epsg
  ext(result) <- ext(bbox[1], bbox[3], bbox[2], bbox[4])
  result
}

#' @importFrom stars read_stars
#' @importFrom sf st_crop
#' @export
download_scene <- function(links, band_names, bbox) {
  scenes <- list()
  for (i in seq_along(links)) {
    scenes[[band_names[[i]]]] <- read_stars(links[i], proxy = TRUE) %>%
      st_crop(bbox)
  }

  do.call(c, scenes)
}
