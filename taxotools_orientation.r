# load libraries
library(taxotools)
library(dplyr)
library(usethis)

# taxonomic data frame in common format
df <- read.csv('input/test_taxonomy.csv') 

# cast with canonical column for many functions
df_canon <- cast_canonical(df,
                           canonical = "canonical",
                           genus = "Genus",
                           species = "Species",
                           subspecies = "Subspecies") 

# melt out separate binomials from canonical
df_melted <- melt_canonical(df_canon,
                            canonical = "canonical",
                            genus = "Genus_2",
                            species = "Species_2",
                            subspecies = "Subspecies_2")

# consolidate a list of synonyms
scNames <- c("Utetheisa ornatrix", "Grammia virgo")
synList <- list_itis_syn(scNames)
df_syns <- cast_cs_field(synList,"Name","Syn")

# check if any part of name resolves to GBIF and GNR (returns match or NULL)
check_scientific("Bertholdia arizonensis")

# DarwinCore to Taxolist format
namelist <- read.csv('input/taxa_7734398.txt', sep='\t') # darwinCore table
darwin <- DwC2taxo(namelist, statuslist = NA, source = NA)

# helper function to expand abbreviated names
expand_name("Arctia caja", "A. plantaginis") # works
expand_name("Arctia caja", "A. plantaginis", "A villica", "A.flavia") # out of scope

# resolve names in a list against a taxolist, including fuzzy match
master <- darwin
mylist <- data.frame("id"= c(11,12),
                     "scname" = c("Grammia virgo", "Grammia phyllira"),
                     stringsAsFactors = F)
res <- get_accepted_names(namelist = mylist,
                          master=master,
                          canonical = "scname")
# get_accepted_names(namelist,
#                    master,
#                    gen_syn = NA,
#                    namelookup = NA,
#                    mastersource = NA,
#                    match_higher = FALSE,
#                    canonical = NA,
#                    genus = NA,
#                    species = NA,
#                    subspecies = NA,
#                    prefix = "",
#                    verbose = TRUE)

# Guess taxonomic rank, based on simple criteria
guess_taxo_rank("Abcd") # genus or higher
guess_taxo_rank("Ab cd") # species
guess_taxo_rank("A b cd") # subspecies
guess_taxo_rank("A b c d") # unknown

# get a list of synonyms from ITIS (but ITIS sucks)
itissyn <- get_itis_syn("Utetheisa ornatrix")

# get a list of synonyms from wikipedia.org; some loss of info from var/form names
wikisyn <- list_wiki_syn("Utetheisa ornatrix")

# list high taxonomy from 
higher <- list_higher_taxo(indf=darwin, "canonical")

#Converts a Synonym list with Accepted Names and Synonym columns to taxolist format
syntax <- syn2taxo(synList)

# synonymize subspecies with parent species
synsub_master <- synonymize_subspecies(master, verbose = FALSE)

# wikipedia synonyms to a taxolist
wikisyntaxo <- wiki2taxo(wikisyn)
# can produce duplicate canonical names:
wikisyntaxo %>%
  group_by(canonical) %>%
  summarize("names" = n())
