% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/sen_bills_various.R
\name{sen_bills_current}
\alias{sen_bills_current}
\title{Downloads and tidies information on legislation from the current
legislature of the Federal Senate}
\usage{
sen_bills_current(
  year = NULL,
  date = NULL,
  time = NULL,
  number = NULL,
  type = NULL,
  passing = NULL
)
}
\arguments{
\item{year}{Format YYYY. Returns legislation from this year.}

\item{date}{date requested, format YYYYMMDD. Returns information on
legislation on or after this time.}

\item{time}{Format hour-minute-second (HHmmSS). Returns information on
legislation on or after this time.}

\item{number}{bill number.}

\item{type}{type of legislation.}

\item{passing}{is the bill currently under consideration in the Senate?
Possible values are \code{NULL} (the default), "Yes" or "No". \code{NULL}
returns the information obtained from "Yes" and "No".}
}
\value{
A tibble, of classes \code{tbl_df}, \code{tbl} and \code{data.frame}.
}
\description{
Downloads and tidies information on legislation from the current
legislature of the Federal Senate.
}
\examples{
\donttest{
all <- sen_bills_current()
plc_2015 <- sen_bills_current(year = 2015, type = "PLS")
}
}
\author{
Robert Myles McDonnell, Guilherme Jardim Duarte & Danilo Freire.
}
