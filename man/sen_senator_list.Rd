% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/sen_senator_list.R
\name{sen_senator_list}
\alias{sen_senator_list}
\title{Downloads and tidies information on the senators in the Federal Senate}
\usage{
sen_senator_list(present = TRUE, state = NULL, status = NULL, ascii = TRUE)
}
\arguments{
\item{present}{\code{logical}. If \code{TRUE}, downloads data on the legislature
currently sitting in the Federal Senate, otherwise returns information on
senators who are currently absent.}

\item{state}{\code{character}. Two-letter abbreviation of Brazilian state. A list of these is
available with the function \code{UF()}.}

\item{status}{\code{character}, either "T" or "S", representing
\emph{titular} or \emph{suplente} (stand-in senator), respectively.}

\item{ascii}{\code{logical}. If \code{TRUE}, strips Latin characters from
strings.}
}
\value{
A tibble, of classes \code{tbl_df}, \code{tbl} and \code{data.frame}.
}
\description{
Downloads and tidies information on the senators in the Federal Senate.
}
\examples{
\donttest{all <- sen_senator_list()}

# Who represents Rio de Janeiro?
\donttest{
rj <- sen_senator_list(state = "RJ")
}
}
\author{
Robert Myles McDonnell, Guilherme Jardim Duarte & Danilo Freire.
}
