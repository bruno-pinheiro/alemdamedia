library(dplyr)
library(tidyr)

# https://datacatalog.worldbank.org/dataset/global-financial-development

if (!file.exists("data-raw/GFDD_CSV.zip")){
  download.file("http://databank.worldbank.org/data/download/GFDD_CSV.zip", destfile = "data-raw/GFDD_CSV.zip")
  unzip("data-raw/GFDD_CSV.zip", exdir = "data-raw")
}

if (!file.exists("data-raw/GDP.csv")){
  download.file("http://databank.worldbank.org/data/download/GFDD_CSV.zip", destfile = "data-raw/GDP.csv")
}



dados <- read.csv("data-raw/GFDDData.csv", stringsAsFactors = FALSE)

indicadores <- c(
  "Bank accounts per 1,000 adults",
  "Bank branches per 100,000 adults",
  "Bank capital to total assets (%)",
  "Bank concentration (%)",
  "Bank cost to income ratio (%)",
  "Bank credit to bank deposits (%)", 
  "Bank deposits to GDP (%)",
  "Credit card (% age 15+)",
  "Debit card (% age 15+)",
  "Domestic credit to private sector (% of GDP)",
  "Electronic payments used to make payments (% age 15+)",
  "Firms identifying access to finance as a major constraint (%)",
  "Firms not needing a loan (%)",
  "Firms whose recent loan application was rejected (%)",
  "Firms with a bank loan or line of credit (%)",
  "GDP per capita (current US$)",
  "Loan from a financial institution in the past year (% age 15+)",
  "Loan from a private lender in the past year (% age 15+)",
  "Loan from an employer in the past year (% age 15+)",
  "Loan from family or friends in the past year (% age 15+)",
  "Loan in the past year (% age 15+)",
  "Loan through store credit in the past year (% age 15+)",
  "Loans from nonresident banks (amounts outstanding) to GDP (%)",
  "Loans from nonresident banks (net) to GDP (%)",
  "Loans requiring collateral (%)",
  "Mobile phone used to pay bills (% age 15+)",
  "Mobile phone used to send money (% age 15+)",
  "Population, total",
  "Private credit by deposit money banks and other financial institutions to GDP (%)",
  "Private credit by deposit money banks to GDP (%)",
  "Provisions to nonperforming loans (%)"
)

lista_indicadores <- dados %>%
  filter(Indicator.Name %in% indicadores) %>% 
  distinct(Indicator.Code, Indicator.Name) %>%
  arrange(Indicator.Code)

dados <- dados %>% 
  select(Country.Name, Indicator.Name, Indicator.Code, X2017) %>% 
  filter(Indicator.Name %in% indicadores) %>% 
  select(-Indicator.Name) %>% 
  spread(Indicator.Code, X2017)

dados <- dados %>% 
  select(names(dados)[colSums(is.na(dados)) / nrow(dados) < .4])

write.csv(dados, "content/post/data/GFDDData_clean.csv", row.names = FALSE)

lista_indicadores <- lista_indicadores %>% 
  filter(Indicator.Code %in% names(dados))

write.csv(lista_indicadores, "content/post/data/GFDD_lista_indicadores.csv", row.names = FALSE)


gdp <- read.csv("content/post/data/GDP.csv", stringsAsFactors = FALSE)

dados <- dados %>%
  left_join(select(gdp, Country.Name, GDP_2018), by = "Country.Name")
