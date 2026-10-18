
#' Get Understat team player stats
#'
#' Retrieve Understat team player stats.
#'
#' @inheritParams understat_team_season_shots
#'
#' @return a dataframe of player stats for a selected team season
#'
#' @export
understat_team_players_stats <- function(team_url) {
  f_possibly <- purrr::possibly(.understat_team_players_stats, otherwise = data.frame(), quiet = FALSE)
  purrr::map_dfr(
    team_url,
    f_possibly
  )
}

.understat_team_players_stats <- function(team_url) {
  # .pkg_message("Scraping player stats for team {team_url}. Please acknowledge understat.com as the data source")

  players_data <- .get_clean_understat_json(team_url, "playersData")

  names(players_data)[names(players_data) == "team_title"] <- "team_name"
  names(players_data)[names(players_data) == "id"] <- "player_id"

  withr::local_options(list(readr.num_columns = 0))
  players_data <- readr::type_convert(players_data)

  return(players_data)
}


#' Get Understat team statistics breakdowns
#'
#' Returns a data frame for the selected team(s) with stats broken down in
#' different ways. Breakdown groups include:
#'
#' \emph{"Situation"}, \emph{"Formation}", \emph{"Game state"},
#' \emph{"Timing"}, \emph{"Shot zones"}, \emph{"Attack speed"}, \emph{"Result"}
#'
#' @param team_urls the url(s) of the teams in question
#'
#' @return returns a dataframe of all stat groups and values
#'
#' @importFrom magrittr %>%
#'
#' @export
understat_team_stats_breakdown <- function(team_urls) {
  f_possibly <- purrr::possibly(.understat_team_stats_breakdown, otherwise = data.frame(), quiet = FALSE)
  purrr::map_dfr(team_urls, f_possibly)
}

.understat_team_stats_breakdown <- function(team_url) {
  api_data <- .understat_api(team_url)

  full_df <- data.frame()
  if(is.list(api_data)) {
    team_name <- sub("^.*/team/([^/]+).*$", "\\1", team_url) %>% gsub("_", " ", .)
    season <- as.numeric(stringr::str_match(team_url, "/(\\d{4})/?$")[, 2])

    # statistics data
    data_statistics <-
      jsonlite::toJSON(api_data[["statistics"]], auto_unbox = TRUE) %>%
      jsonlite::parse_json(simplifyVector=TRUE)

    .parse_understat <- function(stat_list, stat_group) {
      x <- stat_list[stat_group] %>% .[[1]]
      stat_group_name <- stat_group
      all_names <- names(x)

      get_each_stat <- function(stat_name) {
        stat_name <- stat_name
        stat_vals <- x[stat_name] %>% unname() %>%
          do.call(data.frame, .)
        out_df <- data.frame(team_name=team_name, season_start_year=season, stat_group_name=stat_group_name, stat_name=stat_name, stringsAsFactors = F)
        out_df <- dplyr::bind_cols(out_df, stat_vals)
        out_df[,"stat"] <- NULL
        return(out_df)
      }

      purrr::map_df(all_names, get_each_stat)
    }

    stat_group_options <- names(data_statistics)

    full_df <- data.frame()

    for(i in stat_group_options) {
      test <- .parse_understat(stat_list = data_statistics, stat_group = i)
      full_df <- dplyr::bind_rows(full_df, test)
    }
  }
  return(full_df)
}
