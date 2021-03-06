#' @importFrom httr GET
#' @importFrom httr content
#' @importFrom purrr map
#' @importFrom purrr flatten
#' @importFrom purrr discard
#' @importFrom purrr map_chr
#' @importFrom tibble tibble
#' @importFrom stringi stri_trans_general
#' @importFrom lubridate parse_date_time
#' @importFrom lubridate year
#' @title Downloads and tidies information on the legislation in the Federal Senate
#' @description Downloads and tidies information on the legislation in the Federal Senate.
#' @param bill_id \code{integer}. This number is the id given to each bill in the
#' Senate database. For example, running \code{sen_bills_current()} will return a
#'  dataframe with the variable \code{bill_id} in the first column. These numbers
#'  can be used as this id. If id is not \code{NULL} (the default), all other
#'  parameters will be set to \code{NULL}, as 'bill_id' cannot be used in conjunction
#'  with the other parameters. If any one of the other parameters are used (without using bill_id),
#'  all three need to be used.
#' @param type \code{character}. The abbreviation of the vote type you're looking
#' for. A full list of these can be obtained with the \code{sen_bill_list()}
#' function. Other types can be seen with \code{sen_bills_subtypes()}.
#' @param number . Bill number. Simple integer, like \code{2}, which will be bill number 00002.
#' @param year \code{integer}. Four-digit year, such as \code{2013}.
#' @param ascii \code{logical}. If \code{TRUE}, strips Latin characters from
#' strings.
#' @return A tibble, of classes \code{tbl_df}, \code{tbl} and \code{data.frame}.
#' @author Robert Myles McDonnell, Guilherme Jardim Duarte & Danilo Freire.
#' @examples
#' pls_5_2010 <- sen_bills(type = "PLS", number = 5, year = 2010)
#'
#' # Get info on the first bill in the dataframe returned
#' # by sen_bills_current(), which has an id of 25:
#' sen25 <- sen_bills(bill_id = 25)
#' @export
sen_bills <- function(bill_id = NULL, type = NULL,
                      number = NULL, year = NULL,
                      ascii = TRUE){

  if(!is.null(bill_id)){
    type <- NULL; number <- NULL; year <- NULL
    base_url <- "http://legis.senado.gov.br/dadosabertos/materia/" %p% bill_id
  } else{
    base_url <- "http://legis.senado.gov.br/dadosabertos/materia/" %p%
      type %p% "/" %p% number %p% "/" %p% year
  }
  if(!is.null(year)){
    Y <- Sys.Date()
    Y <- lubridate::year(Y)
    if(year > Y){
      stop("Please enter a valid year.")
    }
  }

  request <- httr::GET(base_url)
  request <- status(request)

  request <- request$DetalheMateria$Materia
  if(is.null(request)){
    stop("No data matches your search")
  }

  # Bill Author:
  author_id <- request$Autoria
  if(depth(author_id) > 3){
    author_id <- request$Autoria$Autor
  }
  author_id <- purrr::flatten(author_id)

  # Bill Topics:
  topic_s <- request$Assunto$AssuntoEspecifico
  if(purrr::is_empty(topic_s)){
    topic_s <- list(Codigo = NA, Descricao = "None")
  }
  topic_g <- request$Assunto$AssuntoGeral
  if(purrr::is_empty(topic_g)){
    topic_g <- list(Codigo = NA, Descricao = "None")
  }

  # Bill Situation:
  situation <- request$SituacaoAtual$Autuacoes$Autuacao

  # bill ID:
  id <- request$IdentificacaoMateria

  nulo <- NA_character_


  bills <- tibble::tibble(
  bill_id = purrr::map_chr(request, .null = nulo, "CodigoMateria") %>% disc(),
  bill_house = purrr::map_chr(request, .null = nulo, "NomeCasaOrigem") %>% disc(),
  bill_house_abbr = purrr::map_chr(request, .null = nulo, "SiglaCasaOrigem") %>% disc(),
  bill_origin = purrr::map_chr(request$OrigemMateria, .null = nulo, "NomePoderOrigem") %>% disc(),
  bill_house_initiated = purrr::map_chr(request, .null = nulo, "NomeCasaIniciadora") %>% disc(),
  bill_house_init_abbr = purrr::map_chr(request, .null = nulo, "SiglaCasaIniciadora") %>% disc(),
  bill_type = purrr::map_chr(request, .null = nulo, "DescricaoSubtipoMateria") %>% disc(),
  bill_type_abbr = purrr::map_chr(request, .null = nulo, "SiglaSubtipoMateria") %>% disc(),
  bill_number = purrr::map_chr(request, .null = nulo, "NumeroMateria") %>% disc(),
  bill_year = purrr::map_chr(request, .null = nulo, "AnoMateria") %>% disc(),
  bill_author = purrr::map_chr(author_id, "NomeAutor", .null = nulo),
  bill_author_type = purrr::map_chr(author_id, "DescricaoTipoAutor",
                                    .null = nulo),
  bill_author_id = purrr::map_chr(author_id, "CodigoParlamentar",
                                  .null = nulo),
  bill_author_gender = purrr::map_chr(author_id, "SexoParlamentar",
                                      .null = nulo),
  bill_author_party = purrr::map_chr(author_id, "SiglaPartidoParlamentar",
                                     .null = nulo),
  bill_author_state = purrr::map_chr(author_id, "UfAutor", .null = nulo),
  bill_author_order = purrr::map_chr(author_id, "NumOrdemAutor",
                                     .null = nulo),
  bill_details_short = request$DadosBasicosMateria$EmentaMateria,
  #bill_indexing = request$DadosBasicosMateria$IndexacaoMateria,
  bill_situation = purrr::map_chr(situation, "DescricaoSituacao",
                                  .null = nulo) %>% disc(),
  bill_situation_house = purrr::map_chr(situation, "NomeCasaLocal",
                                        .null = nulo) %>%  disc(),
  bill_situation_place = purrr::map_chr(situation, "NomeLocal",
                                        .null = nulo) %>%  disc()
  )


  # dates:
  bill_date_presented <- suppressWarnings(lubridate::parse_date_time(
    request$DadosBasicosMateria$DataApresentacao, orders = "Ymd"))
  if(purrr::is_empty(bill_date_presented)){
    bill_date_presented <- NA_character_
  }
  bill_date_considered <- suppressWarnings(lubridate::parse_date_time(
    request$DadosBasicosMateria$DataLeitura, orders = "Ymd"))
  if(purrr::is_empty(bill_date_considered)){
    bill_date_considered <- NA_character_
  }

  bill_situation_date <- purrr::map_chr(situation, "DataSituacao",
                                       .null = nulo) %>%  disc()
  bill_situation_date <- suppressWarnings(lubridate::parse_date_time(
    bill_situation_date, orders = "Ymd"))

  #
  bill_complementary = purrr::map_chr(request, "IndicadorComplementar",
                                      .null = nulo) %>%  disc()
  bill_complementary = ifelse(bill_complementary == "Sim", "Yes",
                              ifelse(bill_complementary == "N\u00a3o", "No", NA))
  bill_in_passage = purrr::map_chr(request, "IndicadorTramitando",
                                   .null = nulo) %>% disc()
  bill_in_passage = ifelse(bill_in_passage == "Sim", "Yes",
                           ifelse(bill_in_passage == "N\u00a3o", "No", NA))

  bill_details = purrr::map_chr(request, "ExplicacoesEmentaMateria",
                                .null = nulo) %>% disc()
  if(purrr::is_empty(bill_details)){
    bill_details = purrr::map_chr(request, "ExplicacaoEmentaMateria",
                                  .null = nulo) %>% disc()
  }
  if(purrr::is_empty(bill_details)){
    bill_details = NA_character_
  }

  bills <- bills %>%
    dplyr::mutate(
      bill_date_presented = bill_date_presented,
      bill_date_considered = bill_date_considered,
      bill_in_passage = bill_in_passage,
      bill_complementary = bill_complementary,
      bill_details = bill_details,
      bill_situation_date = bill_situation_date,
      bill_topic_general = topic_g$Descricao,
      bill_topic_general_id = topic_g$Codigo,
      bill_topic_specific = topic_s$Descricao,
      bill_topic_specific_id = topic_s$Codigo
    )


  if(isTRUE(ascii)){
    bills <- bills %>%
      dplyr::mutate(
        bill_author = stringi::stri_trans_general(bill_author,
                                                  "Latin-ASCII"),
        bill_details_short = stringi::stri_trans_general(
          bill_details_short, "Latin-ASCII"),
        bill_details = stringi::stri_trans_general(bill_details,
                                                   "Latin-ASCII"),
        # bill_indexing = stringi::stri_trans_general(
        #   bill_indexing, "Latin-ASCII"),
        bill_topic_general = stringi::stri_trans_general(
          bill_topic_general, "Latin-ASCII"),
        bill_topic_specific = stringi::stri_trans_general(
          bill_topic_specific, "Latin-ASCII"))
  }
  return(bills)
}
