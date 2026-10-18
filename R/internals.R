.rename_fb_cols <- function(df) {
  var_names <- df[1,] %>% as.character()

  new_names <- paste(var_names, names(df), sep = "_")

  new_names <- new_names %>%
    gsub("\\..[0-9]", "", .) %>%
    gsub("\\.[0-9]", "", .) %>%
    gsub("\\.", "_", .) %>%
    gsub("_Var", "", .) %>%
    gsub("# Pl", "Num_Players", .) %>%
    gsub("%", "_percent", .) %>%
    gsub("_Performance", "", .) %>%
    # gsub("_Penalty", "", .) %>%
    gsub("1/3", "Final_Third", .) %>%
    gsub("\\+/-", "Plus_Minus", .) %>%
    gsub("/", "_per_", .) %>%
    gsub("-", "_minus_", .) %>%
    gsub("90s", "Mins_Per_90", .) %>%
    gsub("__", "_", .) %>%
    gsub("_$", "", .)

  names(df) <- new_names
  df[-1,]
}

#' Clean advanced statistic tables
#'
#' Returns cleaned dataframe for each of the team statistic tables used by get_season_team_stats()
#'
#' @param input_table_element element of the html table on the league season page
#'
#' @return a data frame for the selected league seasons advanced statistic
#'
#' @importFrom magrittr %>%
#' @importFrom rlang .data
#' @noRd
#'
.clean_advanced_stat_table <- function(input_table_element) {

  stat_df <- input_table_element %>%
    rvest::html_table() %>%
    data.frame()

  stat_df <- .rename_fb_cols(stat_df)

  cols_to_transform <- stat_df %>%
    dplyr::select(-.data[["Squad"]]) %>% names()

  stat_df <- stat_df %>%
    dplyr::mutate_at(.vars = cols_to_transform, .funs = function(x) {gsub(",", "", x)}) %>%
    dplyr::mutate_at(.vars = cols_to_transform, .funs = function(x) {gsub("+", "", x)}) %>%
    dplyr::mutate_at(.vars = cols_to_transform, .funs = as.numeric)

  return(stat_df)
}

#' Clean player season statistic tables
#'
#' Returns cleaned dataframe for each of the player statistic tables used by fb_player_season_stats()
#'
#' @param input_table_element element of the html table on the player page
#'
#' @return a data frame for the selected player's advanced statistic
#'
#' @importFrom magrittr %>%
#' @importFrom rlang .data
#' @noRd
#'

.clean_player_season_stats <- function(input_table_element) {
  stat_df <- input_table_element %>%
    rvest::html_table() %>%
    data.frame()

  var_names <- stat_df[1, ] %>% as.character()

  new_names <- paste(var_names, names(stat_df), sep = "_")

  new_names <- new_names %>%
    gsub("\\..[0-9]", "", .) %>%
    gsub("\\.[0-9]", "", .) %>%
    gsub("\\.", "_", .) %>%
    gsub("_Var", "", .) %>%
    gsub("_Playing", "", .) %>%
    gsub("%", "_percent", .) %>%
    gsub("_Performance", "", .) %>%
    # gsub("_Penalty", "", .) %>%
    gsub("1/3", "Final_Third", .) %>%
    gsub("\\+/-", "Plus_Minus", .) %>%
    gsub("/", "_per_", .) %>%
    gsub("-", "_minus_", .) %>%
    gsub("90s", "Mins_Per_90", .) %>%
    gsub("__", "_", .)

  names(stat_df) <- new_names
  stat_df <- stat_df[-1, ]

  stat_df <- stat_df %>% dplyr::select(-.data[["Matches"]])

  remove_rows <- min(grep("Season", stat_df$Season)):nrow(stat_df)

  stat_df <- stat_df[-remove_rows, ]

  cols_to_transform <- stat_df %>%
    dplyr::select(-.data[["Season"]], -.data[["Squad"]], -.data[["Comp"]]) %>%
    names()

  stat_df <- stat_df %>% dplyr::mutate(Squad = gsub("^[^A-Z]*([A-Z].*)", "\\1", .data[["Squad"]]))

  if ("Country" %in% cols_to_transform) {
    stat_df <- stat_df %>% dplyr::mutate(Country = gsub("^.*? ([A-Z])", "\\1", .data[["Country"]]))
    cols_to_transform <- setdiff(cols_to_transform, "Country")
  }

  if ("LgRank" %in% cols_to_transform) {
    cols_to_transform <- setdiff(cols_to_transform, "LgRank")
  }

  stat_df <- stat_df %>%
    dplyr::mutate_at(dplyr::vars(tidyselect::all_of(cols_to_transform)), .funs = function(x) {
      gsub(",", "", x)
    }) %>%
    dplyr::mutate_at(dplyr::vars(tidyselect::all_of(cols_to_transform)), .funs = function(x) {
      gsub("+", "", x)
    }) %>%
    dplyr::mutate_at(dplyr::vars(tidyselect::all_of(cols_to_transform)), .funs = as.numeric)

  return(stat_df)
}


#' Clean each match advanced statistic tables
#'
#' Returns cleaned data frame for each of the team statistic tables for each selected match
#'
#' @param df_in a raw match stats data frame
#'
#' @return a cleaned data frame for the selected match advanced statistic
#'
#' @importFrom magrittr %>%
#' @importFrom rlang .data
#' @noRd
#'
.clean_match_advanced_stats_data <- function(df_in) {

  var_names <- df_in[1,] %>% as.character()

  new_names <- paste(var_names, names(df_in), sep = "_")

  new_names <- new_names %>%
    gsub("\\..[0-9]", "", .) %>%
    gsub("\\.[0-9]", "", .) %>%
    gsub("\\.", "_", .) %>%
    gsub("_Var", "", .) %>%
    gsub("#", "Player_Num", .) %>%
    gsub("%", "_percent", .) %>%
    gsub("_Performance", "", .) %>%
    gsub("_Penalty", "", .) %>%
    gsub("1/3", "Final_Third", .) %>%
    gsub("\\+/-", "Plus_Minus", .) %>%
    gsub("/", "_per_", .) %>%
    gsub("-", "_minus_", .) %>%
    gsub("90s", "Mins_Per_90", .) %>%
    gsub("__", "_", .)

  names(df_in) <- new_names
  df_in <- df_in[-1,]

  if(any(grepl("Nation", colnames(df_in)))) {
    df_in$Nation <- gsub(".*? ", "", df_in$Nation)
  }

  # cols_to_transform <- df_in %>%
  #   dplyr::select(-.data[["Player"]], -.data[["Nation"]], -.data[["Pos"]], -.data[["Age"]]) %>% names()

  non_num_vars <- c("Player", "Nation", "Pos", "Age")
  cols_to_transform <- names(df_in)[!names(df_in) %in% non_num_vars]

  df_in <- df_in %>%
    dplyr::mutate_at(.vars = cols_to_transform, .funs = function(x) {gsub(",", "", x)}) %>%
    dplyr::mutate_at(.vars = cols_to_transform, .funs = function(x) {gsub("+", "", x)}) %>%
    dplyr::mutate_at(.vars = cols_to_transform, .funs = as.numeric)

  return(df_in)
}


#' Clean stat table column names
#'
#' Returns cleaned column names for stats tables
#'
#' @param df_in a raw match stats data frame
#'
#' @return a data frame with cleaned names
#'
#' @importFrom magrittr %>%
#' @importFrom rlang .data
#' @noRd
#'
.clean_table_names <- function(df_in) {
  var_names <- df_in[1,] %>% as.character()

  new_names <- paste(var_names, names(df_in), sep = "_")

  new_names <- new_names %>%
    gsub("\\..[0-9]", "", .) %>%
    gsub("\\.[0-9]", "", .) %>%
    gsub("\\.", "_", .) %>%
    gsub("_Var", "", .) %>%
    gsub("#", "Num_", .) %>%
    gsub("%", "_percent", .) %>%
    # gsub("_Performance", "", .) %>%
    gsub("_Penalty", "", .) %>%
    gsub("1/3", "Final_Third", .) %>%
    gsub("\\+/-", "Plus_Minus", .) %>%
    gsub("/", "_per_", .) %>%
    gsub("-", "_minus_", .) %>%
    gsub("90s", "Mins_Per_90", .) %>%
    gsub("__", "_", .)

  names(df_in) <- new_names
  df_in <- df_in[-1,]

  colnames(df_in) <- gsub("_$", "", colnames(df_in))

  return(df_in)
}



#' Convert formatted valuations to numeric
#'
#' Returns a numeric data type for player valuations
#'
#' @param euro_value raw valuation from transfermarkt.com
#'
#' @return a cleaned numeric data value for market and/or transfer valuation
#'
#' @importFrom magrittr %>%
#' @noRd
#'
.convert_value_to_numeric <- function(euro_value) {
  clean_val <- gsub("[^\x20-\x7E]", "", euro_value) %>% tolower()
  if(grepl("free", clean_val)) {
    clean_val <- 0
  } else if(grepl("loan fee", clean_val)) {
    clean_val <- suppressWarnings(gsub("loan fee:", "", clean_val)) %>% .convert_value_to_numeric
  } else if(grepl("m", clean_val)) {
    clean_val <- suppressWarnings(gsub("m", "", clean_val) %>% as.numeric() * 1000000)
  } else if(grepl("th.", clean_val)) {
    clean_val <- suppressWarnings(gsub("th.", "", clean_val) %>% as.numeric() * 1000)
  } else if(grepl("k", clean_val)) {
    clean_val <- suppressWarnings(gsub("k", "", clean_val) %>% as.numeric() * 1000)
  } else {
    clean_val <- suppressWarnings(as.numeric(clean_val) * 1)
  }
  return(clean_val)
}

.get_understat_json <- function(page_url) {
  tryCatch(
    httr::GET(page_url, httr::set_cookies(.cookies = c("beget" = "begetok"))) %>% httr::content(),
    error = function(e) NA
  )
}


#' Fetch Understat data from its JSON endpoints
#'
#' Understat no longer embeds data in the page HTML; it is loaded from
#' `getLeagueData`, `getTeamData`, `getMatchData` and `getPlayerData`.
#'
#' @param page_url understat.com league, team, match or player page URL
#'
#' @return the parsed JSON as a list, or `NA` on failure
#'
#' @importFrom magrittr %>%
#' @importFrom httr GET add_headers set_cookies content
#' @importFrom jsonlite fromJSON
#' @noRd
#'
.understat_api <- function(page_url) {
  path <- sub("^https?://understat\\.com/", "", page_url) %>% sub("[?#].*$", "", .) %>% sub("/$", "", .)
  api_path <- if (grepl("^league/", path)) {
    sub("^league/", "getLeagueData/", path)
  } else if (grepl("^team/", path)) {
    sub("^team/", "getTeamData/", path)
  } else if (grepl("^match/", path)) {
    sub("^match/", "getMatchData/", path)
  } else if (grepl("^player/", path)) {
    sub("^player/", "getPlayerData/", path)
  } else {
    return(NA)
  }

  tryCatch(
    {
      resp <- httr::GET(
        paste0("https://understat.com/", api_path),
        httr::add_headers(`X-Requested-With` = "XMLHttpRequest", Referer = page_url),
        httr::set_cookies(.cookies = c("beget" = "begetok"))
      )
      httr::stop_for_status(resp)
      resp %>% httr::content(as = "text", encoding = "UTF-8") %>% jsonlite::fromJSON(simplifyVector = FALSE)
    },
    error = function(e) NA
  )
}


#' Clean Understat JSON data
#'
#' Returns a cleaned Understat data frame
#'
#' @param page_url understat.com page URL
#' @param script_name name of the data set, as it used to be named in the page's
#'   script tags (`datesData`, `playersData`, `teamsData`, `shotsData`)
#'
#' @return a cleaned Understat data frame
#'
#' @importFrom magrittr %>%
#' @importFrom jsonlite fromJSON toJSON
#' @noRd
#'
.get_clean_understat_json <- function(page_url, script_name) {
  api_data <- .understat_api(page_url)

  out_df <- data.frame()
  if(is.list(api_data)) {
    records <- switch(
      script_name,
      datesData = api_data[["dates"]],
      playersData = api_data[["players"]],
      teamsData = unname(api_data[["teams"]]),
      shotsData = {
        shots <- api_data[["shots"]]
        # match pages split shots by side, player pages return a flat list
        if (all(c("h", "a") %in% names(shots))) c(shots[["h"]], shots[["a"]]) else shots
      },
      NULL
    )

    if(length(records) > 0) {
      null_to_na <- function(x) if (is.null(x)) NA else if (is.list(x)) lapply(x, null_to_na) else x
      out_df <- lapply(records, null_to_na) %>% jsonlite::toJSON(auto_unbox = TRUE) %>% jsonlite::fromJSON()
      # some outputs don't come with the season present, so add it in if the URL has one
      season_start <- stringr::str_match(page_url, "/(?:league|team)/[^/]+/(\\d{4})/?$")[, 2]
      if(!any(grepl("season", colnames(out_df))) && !is.na(season_start)) {
        season <- paste0(season_start, "/", as.integer(season_start) + 1)
        out_df <- cbind(season, out_df)
      }

      out_df <- do.call(data.frame, out_df)
    }
  }

  return(out_df)

}


#' Understat shots location helper function
#'
#' Returns a cleaned Understat shooting location  data frame
#'
#' @param type_url can be season, team, match, player URL
#'
#' @return a cleaned Understat shooting location data frame
#'
#' @importFrom magrittr %>%
#' @importFrom stats runif
#' @noRd
#'
.understat_shooting <- function(type_url) {
  main_url <- "https://understat.com/"
  # need to get the game IDs first, filtering out matches not yet played as these URLs will error
  games <-  .get_clean_understat_json(page_url = type_url, script_name = "datesData") %>%
    dplyr::filter(.data[["isResult"]])
  # then create a chr vector of match URLs
  match_urls <- paste0(main_url, "match/", games$id)

  # start scrape:
  shots_data <- data.frame()

  for(each_match in match_urls) {
    Sys.sleep(round(runif(1, 1, 2)))
    tryCatch(df <- .get_clean_understat_json(page_url = each_match, script_name = "shotsData"), error = function(e) data.frame())
    if(nrow(df) == 0) {
      print(glue::glue("Shots data for match_url {each_match} not available"))
    }
    shots_data <- rbind(shots_data, df)

  }
  return(shots_data)
}


#' Clean date fields
#'
#' Returns a date format in YYYY-MM-DD from 'mmm d, yyyy'
#'
#' @param dirty_dates formatted date value
#'
#' @return a cleaned date
#'
#' @importFrom magrittr %>%
#' @noRd
#'
.tm_fix_dates <- function(dirty_dates) {

  fix_date <- function(dirty_date) {
    if(is.na(dirty_date)) {
      clean_date <- NA_character_
    } else if (grepl("\\.", dirty_date)) {

      first_part <- sub("\\..*", "", dirty_date)

      # Count digits
      n <- nchar(first_part)

      if (n == 4) {
        # Do something if 4 digits
        tryCatch({clean_date <- lubridate::ymd(dirty_date) %>% as.character()}, error = function(e) {clean_date <- NA_character_})
      } else if (n == 2) {
        # Do something else if 2 digits
        tryCatch({clean_date <- lubridate::dmy(dirty_date) %>% as.character()}, error = function(e) {clean_date <- NA_character_})
      } else {
        # Fallback
        clean_date <- NA_character_
      }


    } else {
      split_string <- strsplit(dirty_date, split = " ") %>% unlist() %>% gsub(",", "", .)
      if(length(split_string) != 3) {
        clean_date <- NA_character_
      } else {
        tryCatch({clean_date <- lubridate::ymd(paste(split_string[3], split_string[1], split_string[2], sep = "-")) %>%
          as.character()}, error = function(e) {clean_date <- NA_character_})
      }
    }

    return(clean_date)
  }
  clean_dates <- dirty_dates %>% purrr::map_chr(fix_date)

  return(clean_dates)
}


#' Replace Empty Values
#'
#' Returns a NA character for empty values
#'
#' @param val a value that can either be empty, or not empty
#'
#' @return NA_character where the extracted value is empty, or the value itself
#' @noRd
#'
.replace_empty_na <- function(val) {
  if(length(val) == 0) {
    val <- NA_character_
  } else {
    val <- val
  }
  return(val)
}


# .pkg_message <- function(msg) {
#   if(getOption("mypackage.verbose", default = TRUE)) message(glue::glue(msg))
#   return(NULL)
# }


#' Load Page with headers
#'
#' loads webpages with a header passed to read_html
#'
#' @param page_url url of the page wanted to be loaded
#'
#' @return a html webpage
#'
#' @noRd
#'
.load_page <- function(page_url) {
  agent <- getOption("worldfootballR.agent", default = "RStudio Desktop (2022.7.1.554); R (4.1.1 x86_64-w64-mingw32 x86_64 mingw32)")
  ua <- httr::user_agent(agent)
  session <- rvest::session(url = page_url, ua)
  xml2::read_html(session)
}




#' Convert formatted valuations to numeric
#'
#' Returns a numeric data type for player valuations
#'
#' @param euro_value raw valuation from transfermarkt.com
#'
#' @return a cleaned numeric data value for market and/or transfer valuation
#'
#' @importFrom magrittr %>%
#' @noRd
#'
.convert_soccerdonna_value_to_numeric <- function(euro_value) {
  clean_val <- gsub("[^\x20-\x7E]", "", euro_value) %>% tolower() |> trimws()
  clean_val <- gsub("\\.", "", clean_val)
  if(grepl("free", clean_val)) {
    clean_val <- 0
  } else if(grepl("loan fee", clean_val)) {
    clean_val <- suppressWarnings(gsub("loan fee:", "", clean_val)) %>% .convert_value_to_numeric
  } else if(grepl("m", clean_val)) {
    clean_val <- suppressWarnings(gsub("m", "", clean_val) %>% as.numeric() * 1000000)
  } else if(grepl("th.", clean_val)) {
    clean_val <- suppressWarnings(gsub("th.", "", clean_val) %>% as.numeric() * 1000)
  } else if(grepl("k", clean_val)) {
    clean_val <- suppressWarnings(gsub("k", "", clean_val) %>% as.numeric() * 1000)
  } else {
    clean_val <- suppressWarnings(as.numeric(clean_val) * 1)
  }
  return(clean_val)
}






#' Transfermarkt competition and season lookup
#'
#' Reads the competition/season lookup table and extends it to the current
#' season. The table is no longer updated upstream, but every season URL is the
#' competition URL plus `/plus/?saison_id=<season_start_year>`, so newer
#' seasons can be derived from the competitions it already lists.
#'
#' @return a data frame with the columns of `main_comp_seasons.csv`
#'
#' @importFrom magrittr %>%
#' @importFrom utils read.csv
#' @noRd
#'
.tm_comp_seasons <- function() {
  meta_df <- utils::read.csv(
    url("https://raw.githubusercontent.com/JaseZiv/worldfootballR_data/master/raw-data/transfermarkt_leagues/main_comp_seasons.csv"),
    stringsAsFactors = FALSE
  )

  today <- Sys.Date()
  current_start_year <- as.integer(format(today, "%Y")) - as.integer(as.integer(format(today, "%m")) < 7)

  # the most recent season that is fully populated (the table can have stray rows beyond it)
  rows_per_season <- table(meta_df[["season_start_year"]])
  base_year <- max(as.integer(names(rows_per_season)[rows_per_season >= 0.5 * max(rows_per_season)]))
  missing_years <- seq_len(max(0, current_start_year - base_year)) + base_year
  if (length(missing_years) == 0) return(meta_df)

  comps <- meta_df[meta_df[["season_start_year"]] == base_year, ]
  new_rows <- lapply(missing_years, function(yr) {
    comps[["season_start_year"]] <- yr
    comps[["season_urls"]] <- paste0(comps[["comp_url"]], "/plus/?saison_id=", yr)
    comps
  })
  new_rows <- do.call(rbind, new_rows)

  # keep the table's own rows where it already has them
  existing <- paste(meta_df[["comp_url"]], meta_df[["season_start_year"]])
  rbind(meta_df, new_rows[!paste(new_rows[["comp_url"]], new_rows[["season_start_year"]]) %in% existing, ])
}
