# Clear environment
rm(list = ls())

library(readr)
library(dplyr)
library(tidyr)
library(stringr)
library(countrycode)
library(ggplot2)
library(GGally)
library(scales)
library(plotly)
library(ggrepel)
library(mgcv)
library(car)
library(gratia)
library(psych)
library(e1071)  # For skewness and kurtosis
library(glue) # build latex table manually
library(purrr)
library(flextable)
library(officer)



# File paths
path_hexp <- "Health_expenditure_data/API_SH.XPD.GHED.PP.CD_DS2_en_csv_v2_7562.csv"
path_mort <- "Death_rate_data /API_SP.DYN.CDRT.IN_DS2_en_csv_v2_8621.csv"
path_oop <-  "Out_of_pockect_exp_data/API_SH.XPD.OOPC.CH.ZS_DS2_en_csv_v2_9851.csv"
path_polstab <- "Political_stability_data/API_PV.EST_DS2_en_csv_v2_7919.csv"
path_agedep <- "Age_dependecy_ratio_data/API_SP.POP.DPND_DS2_en_csv_v2_594254.csv"

# Read in the health expenditure data
hexp_raw <- read_csv(path_hexp, skip = 4)

# Read in the mortality rate data
mort_raw <- read_csv(path_mort, skip = 4)

# Read in the Out-of-pocket expenditure data
oop_raw <- read_csv(path_oop, skip = 4)

# Read in the Political stability data
polstab_raw <- read_csv(path_polstab, skip = 4)


# Read in the Age Dependency Ratio data
agedep_raw <- read_csv(path_agedep, skip = 4)


# Add region info and filter for Africa only
hexp_africa <- hexp_raw |>
  mutate(Region = countrycode(`Country Name`, origin = "country.name", destination = "un.region.name")) |>
  filter(Region == "Africa")

mort_africa <- mort_raw |>
  mutate(Region = countrycode(`Country Name`, origin = "country.name", destination = "un.region.name")) |>
  filter(Region == "Africa")

oop_africa <- oop_raw |>
  mutate(Region = countrycode(`Country Name`, origin = "country.name", destination = "un.region.name")) |>
  filter(Region == "Africa")

polstab_africa <- polstab_raw |>
  mutate(Region = countrycode(`Country Name`, origin = "country.name", destination = "un.region.name")) |>
  filter(Region == "Africa")

agedep_africa <- agedep_raw |>
  mutate(Region = countrycode(`Country Name`, origin = "country.name", destination = "un.region.name")) |>
  filter(Region == "Africa")


# Keep only country and years 2002–2022
years <- as.character(2002:2022)

hexp_africa <- hexp_africa |>
  select(Country = `Country Name`, all_of(years))

mort_africa <- mort_africa |>
  select(Country = `Country Name`, all_of(years))

oop_africa <- oop_africa |>
  select(Country = `Country Name`, all_of(years))

polstab_africa <- polstab_africa |>
  select(Country = `Country Name`, all_of(years))

agedep_africa <- agedep_africa |>
  select(Country = `Country Name`, all_of(years))


# Define the exclusion list
drop_countries <- c("Zimbabwe", "South Sudan", "Somalia")

# Filter all datasets
hexp_africa <- hexp_africa |>
  filter(!Country %in% drop_countries)

mort_africa <- mort_africa |>
  filter(!Country %in% drop_countries)

oop_africa <- oop_africa |>
  filter(!Country %in% drop_countries)

polstab_africa <- polstab_africa |>
  filter(!Country %in% drop_countries)

agedep_africa <- agedep_africa |>
  filter(!Country %in% drop_countries)

#unique(hexp_africa$Country)


region_key <- tribble(
  ~Country,                  ~Region,
  "Angola",                  "Central",
  "Burundi",                 "East",
  "Benin",                   "West",
  "Burkina Faso",            "West",
  "Botswana",                "Southern",
  "Central African Republic","Central",
  "Cote d'Ivoire",           "West",
  "Cameroon",                "Central",
  "Congo, Dem. Rep.",        "Central",
  "Congo, Rep.",             "Central",
  "Comoros",                 "East",
  "Cabo Verde",              "West",
  "Djibouti",                "East",
  "Algeria",                 "Northern",
  "Egypt, Arab Rep.",        "Northern",
  "Eritrea",                 "East",
  "Ethiopia",                "East",
  "Gabon",                   "Central",
  "Ghana",                   "West",
  "Guinea",                  "West",
  "Gambia, The",             "West",
  "Guinea-Bissau",           "West",
  "Equatorial Guinea",       "Central",
  "Kenya",                   "East",
  "Liberia",                 "West",
  "Libya",                   "West",
  "Lesotho",                 "Southern",
  "Morocco",                 "Northern",
  "Madagascar",              "East",
  "Mali",                    "West",
  "Mozambique",              "East",
  "Mauritania",              "West",
  "Mauritius",               "East",
  "Malawi",                  "East",
  "Namibia",                 "Southern",
  "Niger",                   "West",
  "Nigeria",                 "West",
  "Rwanda",                  "East",
  "Sudan",                   "Northern",
  "Senegal",                 "West",
  "Sierra Leone",            "West",
  "Sao Tome and Principe",   "Central",
  "Eswatini",                "Southern",
  "Seychelles",              "East",
  "Chad",                    "Central",
  "Togo",                    "West",
  "Tunisia",                 "Northern",
  "Tanzania",                "East",
  "Uganda",                  "East",
  "South Africa",            "Southern",
  "Zambia",                  "East"
)

length(region_key$Country)
#Join the region info to your data
hexp_africa <- hexp_africa |>
  left_join(region_key, by = "Country")

mort_africa <- mort_africa |>
  left_join(region_key, by = "Country")

oop_africa <- oop_africa |>
  left_join(region_key, by = "Country")

polstab_africa <- polstab_africa |>
  left_join(region_key, by = "Country")

agedep_africa <- agedep_africa |>
  left_join(region_key, by = "Country")

#Pivot both datasets to long format and merge
library(tidyr)

# Convert wide → long
hexp_long <- hexp_africa |>
  pivot_longer(cols = `2002`:`2022`, names_to = "Year", values_to = "HealthExp")

mort_long <- mort_africa |>
  pivot_longer(cols = `2002`:`2022`, names_to = "Year", values_to = "Mortality")

oop_long <- oop_africa |>
  pivot_longer(cols = `2002`:`2022`, names_to = "Year", values_to = "Oop")

polstab_long <- polstab_africa |>
  pivot_longer(cols = `2002`:`2022`, names_to = "Year", values_to = "Polstab")

agedep_long <- agedep_africa |>
  pivot_longer(cols = `2002`:`2022`, names_to = "Year", values_to = "Agedep")


# Convert Year to numeric
hexp_long <- hexp_long |> mutate(Year = as.integer(Year))
mort_long <- mort_long |> mutate(Year = as.integer(Year))
oop_long <- oop_long |> mutate(Year = as.integer(Year))
polstab_long <- polstab_long |> mutate(Year = as.integer(Year))
agedep_long <- agedep_long |> mutate(Year = as.integer(Year))


# Data Visualization

# visualize health expenditure
he <- ggplot(hexp_long, aes(x = Year, y = HealthExp, color = Country)) +
  geom_line(linewidth = 0.5, alpha = 0.8) +
  geom_point(size = 0.8)+
  facet_wrap(~Region, scales = "free_y") +
  scale_y_continuous(labels = dollar_format(prefix = "$")) +
  labs(
    title = "Health Expenditure Over Time (2002–2022)",
    subtitle = "Public health spending per capita (PPP-adjusted dollars)",
    x = "Year", y = "Health Expenditure",
    caption = "Source: World Bank"
  ) +
  theme_minimal(base_size = 13) +
  theme(legend.position = "none")  # Turn off legend if too many countries

he
#ggplotly(he)

# visualize mortality rate
mr <- ggplot(mort_long, aes(x = Year, y = Mortality, color = Country)) +
  geom_line(linewidth = 0.5, alpha = 0.8) +
  geom_point(size = 0.8)+
  facet_wrap(~Region, scales = "free_y") +
  labs(
    title = "Mortality Rate Over Time (2002–2022)",
    subtitle = "Crude death rate per 1,000 population",
    x = "Year", y = "Mortality Rate",
    caption = "Source: World Bank"
  ) +
  theme_minimal(base_size = 13) +
  theme(legend.position = "none")

mr

#ggplotly(mr)

# visualize out of pocket expenditure

op <- ggplot(oop_long, aes(x = Year, y = Oop, color = Country)) +
  geom_line(linewidth = 0.5, alpha = 0.8) +
  geom_point(size = 0.8)+
  facet_wrap(~Region, scales = "free_y") +
  labs(
    title = "Out-of-Pocket Health Expenditure Over Time",
    subtitle = "Percentage of total health expenditure",
    x = "Year", y = "Out-of-Pocket (%)",
    caption = "Source: World Bank"
  ) +
  theme_minimal(base_size = 13) +
  theme(legend.position = "none")

op
#ggplotly(op)
# visualize political stability

ps <- ggplot(polstab_long, aes(x = Year, y = Polstab, color = Country)) +
  geom_line(linewidth = 0.5, alpha = 0.8) +
  geom_point(size = 0.8)+
  facet_wrap(~Region, scales = "free_y") +
  labs(
    title = "Political Stability Index Over Time (2002–2022)",
    subtitle = "WGI: Ranges from -2.5 (weak) to 2.5 (strong)",
    x = "Year", y = "Political Stability",
    caption = "Source: World Bank Governance Indicators"
  ) +
  theme_minimal(base_size = 13) +
  theme(legend.position = "none")

ps
#ggplotly(ps)

adr <- ggplot(agedep_long, aes(x = Year, y = Agedep, color = Country)) +
  geom_line(linewidth = 0.5, alpha = 0.8) +
  geom_point(size = 0.8)+
  facet_wrap(~Region, scales = "free_y") +
  labs(
    title = "Age Dependency Ratio Over Time (2002–2022)",
    subtitle = "Proportion of dependents per 100 working-age population.",
    x = "Year", y = "Age Dependency Ratio",
    caption = "Source: World Bank"
  ) +
  theme_minimal(base_size = 13) +
  theme(legend.position = "none")

adr
#ggplotly(adr)

# presenting plots 1


# Filter 2022 data and get top 2 countries by HealthExp
label_data <- hexp_long |>
  filter(Year == 2022) |>
  group_by(Region) |>
  slice_max(order_by = HealthExp, n = 2, with_ties = FALSE) |>
  ungroup()

# Plot with lines + labels
ggplot(hexp_long, aes(x = Year, y = HealthExp, color = Country)) +
  geom_line(linewidth = 0.5, alpha = 0.8) +
  geom_point(size = 0.8)+
  facet_wrap(~Region, scales = "free_y") +
  geom_text_repel(
    data = label_data,
    aes(label = Country),
    nudge_x = 0.5,
    size = 3,
    box.padding = 0.2,
    show.legend = FALSE
  ) +
  scale_y_continuous(labels = scales::dollar_format(prefix = "$")) +
  labs(
    title = "Health Expenditure Over Time (2002–2022)",
    #subtitle = "Top 2 countries labeled per region (based on 2022 values)",
    x = "Year", y = "Health Expenditure",
    caption = "Source: World Bank"
  ) +
  theme_minimal(base_size = 13) +
  theme(legend.position = "none")


# Filter 2022 data and get top 2 countries by mortality data
label_data <- mort_long |>
  filter(Year == 2022) |>
  group_by(Region) |>
  slice_max(Mortality, n = 2, with_ties = FALSE) |>
  ungroup()

ggplot(mort_long, aes(x = Year, y = Mortality, color = Country)) +
  geom_line(linewidth = 0.5, alpha = 0.8) +
  geom_point(size = 0.8)+
  facet_wrap(~Region, scales = "free_y") +
  geom_text_repel(
    data = label_data,
    aes(label = Country),
    nudge_x = 0.5,
    size = 3,
    box.padding = 0.2,
    show.legend = FALSE
  ) +
  labs(
    title = "Mortality Rate Over Time (2002–2022)",
    #subtitle = "Top 2 countries labeled per region (based on 2022 values)",
    x = "Year", y = "Mortality Rate",
    caption = "Source: World Bank"
  ) +
  theme_minimal(base_size = 13) +
  theme(legend.position = "none")

# Get top 2 OOP spenders per region in 2022
oop_label_data <- oop_long |>
  filter(Year == 2022) |>
  group_by(Region) |>
  slice_max(order_by = Oop, n = 2, with_ties = FALSE) |>
  ungroup()

# Plot
ggplot(oop_long, aes(x = Year, y = Oop, color = Country)) +
  geom_line(linewidth = 0.5, alpha = 0.8) +
  geom_point(size = 0.8)+
  facet_wrap(~Region, scales = "free_y") +
  geom_text_repel(
    data = oop_label_data,
    aes(label = Country),
    nudge_x = 0.5,
    size = 3,
    box.padding = 0.2,
    show.legend = FALSE
  ) +
  labs(
    title = "Out-of-Pocket Health Expenditure (% of Current Health Expenditure)",
    #subtitle = "Top 2 countries labeled per region in 2022",
    x = "Year", y = "OOP Expenditure (%)",
    caption = "Source: World Bank"
  ) +
  theme_minimal(base_size = 13) +
  theme(legend.position = "none")

# Get top 2 politically stable countries per region in 2022
polstab_label_data <- polstab_long |>
  filter(Year == 2022) |>
  group_by(Region) |>
  slice_min(order_by = Polstab, n = 2, with_ties = FALSE) |>
  ungroup()

# Plot
ggplot(polstab_long, aes(x = Year, y = Polstab, color = Country)) +
  geom_line(linewidth = 0.5, alpha = 0.8) +
  geom_point(size = 0.8)+
  facet_wrap(~Region, scales = "free_y") +
  geom_text_repel(
    data = polstab_label_data,
    aes(label = Country),
    nudge_x = 0.5,
    size = 3,
    box.padding = 0.2,
    show.legend = FALSE
  ) +
  labs(
    title = "Political Stability in African Countries (2002–2022)",
    #subtitle = "Top 2 most politically stable countries labeled in 2022",
    x = "Year", y = "Political Stability Index",
    caption = "Source: World Bank Governance Indicators"
  ) +
  theme_minimal(base_size = 13) +
  theme(legend.position = "none")


# Get top 2 high age dependent countries per region in 2022
agedep_label_data <- agedep_long |>
  filter(Year == 2022) |>
  group_by(Region) |>
  slice_max(order_by = Agedep, n = 2, with_ties = FALSE) |>
  ungroup()

# Plot
ggplot(agedep_long, aes(x = Year, y = Agedep, color = Country)) +
  geom_line(linewidth = 0.5, alpha = 0.8) +
  geom_point(size = 0.8)+
  facet_wrap(~Region, scales = "free_y") +
  geom_text_repel(
    data = agedep_label_data,
    aes(label = Country),
    nudge_x = 0.5,
    size = 3,
    box.padding = 0.2,
    show.legend = FALSE
  ) +
  labs(
    title = "Age Dependency Ratio Over Time (2002–2022)",
    #subtitle = "Top 2 high age dependent countries labeled in 2022",
    x = "Year", y = "Age Dependency Ratio",
    caption = "Source: World Bank"
  ) +
  theme_minimal(base_size = 13) +
  theme(legend.position = "none")


# Check for correlation between Health expenditure and out of pocket expenditure

# Merge OOP and HealthExp for correlation check
cor_data <- hexp_long |>
  rename(HealthExp = HealthExp) |>
  inner_join(oop_long |> rename(Oop = Oop), by = c("Country", "Year"))

# Correlation
cor(cor_data$HealthExp, cor_data$Oop, use = "complete.obs")

# plot of healthexp vs Oop
ggplot(cor_data, aes(x = log(HealthExp), y = log(Oop))) +
  geom_point(alpha = 0.6) +
  geom_smooth(method = "lm", color = "blue", se = FALSE) +
  labs(
    title = "Relationship between Health Expenditure and Out-of-Pocket Costs",
    x = "Health Expenditure",
    y = "Out-of-Pocket Spending"
  ) +
  theme_minimal()



# Merge on Country + Year

panel <- mort_long %>%
  inner_join(hexp_long, by = c("Country", "Year", "Region")) %>%
  inner_join(oop_long, by = c("Country", "Year", "Region")) %>%
  inner_join(polstab_long, by = c("Country", "Year", "Region")) %>%
  inner_join(agedep_long, by = c("Country", "Year", "Region"))

panel <- panel |>
  mutate(Country = factor(Country))

# Add an indicator for Covid-19: 1 represent covid period, 0 represent pre covid
panel <- panel %>%
  mutate(Covid19 = if_else(Year %in% 2020:2022, 1, 0))

head( panel)
length(unique(panel$Country))

length(unique(panel$Country[panel$Region == "Northern"]))
unique(panel$Country[panel$Region == "Northern"])
# 
# install.packages("writexl")   # Run once if not installed
# library(writexl)
# 
# write_xlsx(panel, "health_financing_africa.xlsx")


# Pairwise scatterplot of variables

# Select only the numeric variables you want
vars <- panel[, c("Mortality", "HealthExp", "Oop", "Polstab", "Agedep")]

# Pairwise scatter plot matrix
ggpairs(vars,
        lower = list(continuous = "points"),   # scatter plots
        diag = list(continuous = "densityDiag"), # density plots on diagonal
        upper = list(continuous = "cor"))        # correlation coefficients


# coloured by regions 1
ggpairs(panel,
        columns = c("Mortality", "HealthExp", "Oop", "Polstab", "Agedep"),
        mapping = aes(color = Region),
        lower = list(continuous = "points"),
        diag  = list(continuous = "densityDiag"),
        upper = list(continuous = "cor"))



# Descriptive Statistics
# Overall summary for Africa
overall_summary <- panel |>
  select(Mortality, HealthExp, Oop, Polstab, Agedep) |>
  psych::describe() |>
  round(2)

overall_summary


# 1. Descriptive statistics (transpose format)
desc <- panel |>
  select(Mortality, HealthExp, Oop, Polstab, Agedep) |>
  psych::describe() |>
  #select(n, mean, sd, median, min, max) |>
  round(2)

desc_t <- as.data.frame(t(desc))  # Transpose
desc_t <- tibble::rownames_to_column(desc_t, "Measure")

# 2. Correlation matrix
corr <- round(cor(panel[, c("Mortality", "HealthExp", "Oop", "Polstab", "Agedep")], use = "complete.obs"), 2)
corr <- tibble::rownames_to_column(as.data.frame(corr), "Variable")

# 3. Create flextables
desc_flex <- flextable(desc_t) |>
  set_caption("Descriptive Statistics for Africa (2002–2022)") |>
  autofit()

corr_flex <- flextable(corr) |>
  set_caption("Correlation Matrix of Key Variables") |>
  autofit()

# # 4. Export to Word
# doc <- read_docx()
# doc <- body_add_flextable(doc, desc_flex)
# doc <- body_add_par(doc, "", style = "Normal")  # space
# doc <- body_add_flextable(doc, corr_flex)
# print(doc, target = "africa_summary_stats.docx")



panel_long <- panel |>
  pivot_longer(cols = c(Mortality, HealthExp, Oop, Polstab, Agedep, Covid19), names_to = "Variable", values_to = "Value")

# boxplot comparing variables bu regions.

# boxplot_grid  <- ggplot(panel_long, aes(x = Region, y = Value, fill = Region)) +
#   geom_boxplot(outlier.size = 0.8) +
#   facet_wrap(~Variable, scales = "free_y") +
#   theme_minimal(base_size = 14) +
#   labs(title = "Distributions of Key Variables by Region", y = NULL) +
#   theme(axis.text.x = element_text(angle = 45, hjust = 1),  
#         plot.title = element_text(hjust = 0.5, size = 14, face = "bold"),
#         panel.background = element_rect(fill = "white", color = NA),
#         plot.background = element_rect(fill = "white", color = NA))

# Define custom labels
var_labels <- c(
  "Agedep"    = "Age Dependency Ratio",
  "HealthExp" = "Health Expenditure",
  "Mortality" = "Mortality (Death) Rate",
  "Oop"       = "Out-of-pocket Expenditure",
  "Polstab"   = "Political Stability"
)
panel_long_boxplot <- panel_long %>%
  filter(Variable != "Covid19")

head(panel_long_boxplot)
# Boxplot with custom facet labels
boxplot_grid <- ggplot(panel_long_boxplot, aes(x = Region, y = Value, fill = Region)) +
  geom_boxplot(outlier.size = 0.8) +
  facet_wrap(~Variable, scales = "free_y", 
             labeller = labeller(Variable = var_labels)) +
  theme_minimal(base_size = 14) +
  labs(title = "Distributions of Key Variables by Region", y = NULL) +
  theme(axis.text.x = element_text(angle = 45, hjust = 1),  
        plot.title = element_text(hjust = 0.5, size = 14, face = "bold"),
        panel.background = element_rect(fill = "white", color = NA),
        plot.background = element_rect(fill = "white", color = NA))

#ggsave("africa_boxplots_highres.png", plot = boxplot_grid, dpi = 600, width = 12, height = 8)

# check for multicolinearity briefly from linear model.

# Fit a basic model without smooth terms just to check VIF
lm_check <- lm(Mortality ~ HealthExp + Oop + Polstab , data = panel)
vif(lm_check)

summary(lm_check)


# add age dependency ratio

lm_check_age <- lm(Mortality ~ HealthExp + Oop + Polstab + Agedep + Covid19, data = panel)
vif(lm_check_age)

summary(lm_check_age)



# gam fits


# Raw variables

gam_fit <- gam(Mortality ~ s(HealthExp) + s(Oop) + s(Polstab) + s(Country, bs = "re") + s(Year) ,
               data = panel) # simple fit to begin with. 

summary(gam_fit)

draw(gam_fit)


# Raw variables + age dependency ratio

gam_fit_age <- gam(Mortality ~ s(HealthExp) + s(Oop) + s(Polstab) + s(Agedep) + Covid19 + s(Country, bs = "re") + s(Year),
               data = panel) # simple fit to begin with. 

summary(gam_fit_age)

draw(gam_fit_age)



# account for expenditure and stability lag

panel_lag <- panel %>%
  group_by(Country) %>%
  arrange(Year) %>%
  mutate(
    HealthExp_lag1 = lag(HealthExp, 1),
    HealthExp_lag2 = lag(HealthExp, 2),
    HealthExp_lag3 = lag(HealthExp, 3),
    Polstab_lag1 = lag(Polstab, 1),
    Polstab_lag2 = lag(Polstab, 2),
    Polstab_lag3 = lag(Polstab, 3)
  ) %>%
  ungroup()



# Initially kept model - without age
gam_fit_lag <- gam(Mortality ~  
                     s(HealthExp_lag1) + 
                     s(Oop) + 
                     s(Polstab_lag1) +
                     ti(HealthExp_lag1, Oop) + 
                     s(Country, bs = "re") + 
                     s(Year),
                   data = panel_lag,
                   method = "REML") # ps: when you use te(a, b), it includes main effects + interaction (if not already included, they’re absorbed).ti(a, b) gives only the interaction (useful if you already have s(a) and s(b) in the model).

summary(gam_fit_lag)



plot(gam_fit_lag, select = 1, shade = TRUE, rug = TRUE) # verifying that the increasing part of the health expenditure occurrs at points with sparse dat.


draw(gam_fit_lag)
vis.gam(gam_fit_lag, view = c("HealthExp_lag1", "Oop"), plot.type = "contour", color = "topo") # 2d interaction effect
vis.gam(gam_fit_lag, view = c("HealthExp_lag1", "Oop"), theta = 30, phi = 40) # 3d interaction effect
summary(gam_fit_lag)$dev.expl
gam.vcomp(gam_fit_lag) # check what proportion of variance is explained by the various variables

appraise(gam_fit_lag)


# Model - with age || take off the covid19 indicator and refit
gam_fit_age_lag <- gam(Mortality ~  
                     s(HealthExp_lag1) + 
                     s(Oop) + 
                     s(Polstab_lag1) +
                     s(Agedep) +
                       Covid19 +
                     ti(HealthExp_lag1, Oop) + 
                     s(Country, bs = "re") + 
                     s(Year),
                   data = panel_lag,
                   method = "REML") # ps: when you use te(a, b), it includes main effects + interaction (if not already included, they’re absorbed).ti(a, b) gives only the interaction (useful if you already have s(a) and s(b) in the model).

summary(gam_fit_age_lag )



plot(gam_fit_age_lag , select = 1, shade = TRUE, rug = TRUE) # verifying that the increasing part of the health expenditure occurrs at points with sparse dat.


draw(gam_fit_age_lag )
vis.gam(gam_fit_age_lag , view = c("HealthExp_lag1", "Oop"), plot.type = "contour", color = "topo") # 2d interaction effect
vis.gam(gam_fit_age_lag , view = c("HealthExp_lag1", "Oop"), theta = 30, phi = 40) # 3d interaction effect
summary(gam_fit_age_lag )$dev.expl
gam.vcomp(gam_fit_age_lag ) # check what proportion of variance is explained by the various variables

appraise(gam_fit_age_lag )


unique(panel_lag$Region)



#Regionwise model


# Central Africa
panel_central <- filter(panel_lag, Region == "Central")
gam_central <- gam(Mortality ~ 
                     s(HealthExp_lag1) + 
                     s(Oop) + 
                     s(Polstab_lag1) +
                     ti(HealthExp_lag1, Oop) +
                     s(Country, bs = "re") +
                     s(Year),
                   data = panel_central,
                   method = "REML")

summary(gam_central)
draw(gam_central)

gam.vcomp(gam_central)
# East Africa

panel_east <- filter(panel_lag, Region == "East")
gam_east <- gam(Mortality ~ 
                  s(HealthExp_lag1) + 
                  s(Oop) + 
                  s(Polstab_lag1) +
                  ti(HealthExp_lag1, Oop) +
                  s(Country, bs = "re") +
                  s(Year),
                data = panel_east,
                method = "REML")

summary(gam_east)
draw(gam_east)

# West Africa
panel_west <- filter(panel_lag, Region == "West")
gam_west <- gam(Mortality ~ 
                  s(HealthExp_lag1) + 
                  s(Oop) + 
                  s(Polstab_lag1) +
                  ti(HealthExp_lag1, Oop) +
                  s(Country, bs = "re") +
                  s(Year),
                data = panel_west,
                method = "REML")

summary(gam_west)
draw(gam_west)


# Southern Africa
panel_south <- filter(panel_lag, Region == "Southern")
gam_south <- gam(Mortality ~ 
                   s(HealthExp_lag1) + 
                   s(Oop) + 
                   s(Polstab_lag1) +
                   ti(HealthExp_lag1, Oop) +
                   s(Country, bs = "re") +
                   s(Year),
                 data = panel_south,
                 method = "REML")
summary(gam_south)
draw(gam_south)

# Northern Africa
panel_north <- filter(panel_lag, Region == "Northern")
gam_north <- gam(Mortality ~ 
                   s(HealthExp_lag1) + 
                   s(Oop) + 
                   s(Polstab_lag1) +
                   ti(HealthExp_lag1, Oop) +
                   s(Country, bs = "re") +
                   s(Year),
                 data = panel_north,
                 method = "REML")

summary(gam_north)
draw(gam_north)
gam.vcomp(gam_north)









#==================================================================================================================
#==================================================================================================================
#==================================================================================================================
#==================================================================================================================

# Filter data to where Mortality < 20  and Health Expenditure < 1000 and make analysis


panel_mortless20 <- panel %>%
  filter(Mortality < 20 & HealthExp < 1000)

head(panel_mortless20 )


# Select only the numeric variables you want
vars_less20 <- panel_mortless20[, c("Mortality", "HealthExp", "Oop", "Polstab", "Agedep")]

# Pairwise scatter plot matrix
ggpairs(vars_less20,
        lower = list(continuous = "points"),   # scatter plots
        diag = list(continuous = "densityDiag"), # density plots on diagonal
        upper = list(continuous = "cor"))        # correlation coefficients


# coloured by regions
ggpairs(panel_mortless20,
        columns = c("Mortality", "HealthExp", "Oop", "Polstab", "Agedep"),
        mapping = aes(color = Region),
        lower = list(continuous = "points"),
        diag  = list(continuous = "densityDiag"),
        upper = list(continuous = "cor"))



# Descriptive Statistics
# Overall summary for Africa
overall_summary_less20 <- panel_mortless20 |>
  select(Mortality, HealthExp, Oop, Polstab, Agedep) |>
  psych::describe() |>
  round(2)

overall_summary_less20


# 1. Descriptive statistics (transpose format)
desc_less20 <- panel_mortless20 |>
  select(Mortality, HealthExp, Oop, Polstab, Agedep) |>
  psych::describe() |>
  #select(n, mean, sd, median, min, max) |>
  round(2)

desc_t_less20 <- as.data.frame(t(desc_less20))  # Transpose
desc_t_less20 <- tibble::rownames_to_column(desc_t_less20, "Measure")

# 2. Correlation matrix
corr_less20 <- round(cor(panel_mortless20[, c("Mortality", "HealthExp", "Oop", "Polstab", "Agedep")], use = "complete.obs"), 2)
corr_less20 <- tibble::rownames_to_column(as.data.frame(corr_less20), "Variable")

# 3. Create flextables
desc_flex_less20 <- flextable(desc_t_less20) |>
  set_caption("Descriptive Statistics for Africa (2002–2022)") |>
  autofit()

corr_flex_less20 <- flextable(corr_less20) |>
  set_caption("Correlation Matrix of Key Variables") |>
  autofit()

# # 4. Export to Word
# doc <- read_docx()
# doc <- body_add_flextable(doc, desc_flex_less20)
# doc <- body_add_par(doc, "", style = "Normal")  # space
# doc <- body_add_flextable(doc, corr_flex_less20)
# print(doc, target = "africa_summary_stats.docx")



panel_less20_long <- panel_mortless20 |>
  pivot_longer(cols = c(Mortality, HealthExp, Oop, Polstab, Agedep), names_to = "Variable", values_to = "Value")

# boxplot comparing variables bu regions.

# boxplot_grid  <- ggplot(panel_less20_long, aes(x = Region, y = Value, fill = Region)) +
#   geom_boxplot(outlier.size = 0.8) +
#   facet_wrap(~Variable, scales = "free_y") +
#   theme_minimal(base_size = 14) +
#   labs(title = "Distributions of Key Variables by Region", y = NULL) +
#   theme(axis.text.x = element_text(angle = 45, hjust = 1),  
#         plot.title = element_text(hjust = 0.5, size = 14, face = "bold"),
#         panel.background = element_rect(fill = "white", color = NA),
#         plot.background = element_rect(fill = "white", color = NA))

# Define custom labels
var_labels <- c(
  "Agedep"    = "Age Dependency Ratio",
  "HealthExp" = "Health Expenditure",
  "Mortality" = "Mortality (Death) Rate",
  "Oop"       = "Out-of-pocket Expenditure",
  "Polstab"   = "Political Stability"
)

# Boxplot with custom facet labels
boxplot_grid <- ggplot(panel_less20_long , aes(x = Region, y = Value, fill = Region)) +
  geom_boxplot(outlier.size = 0.8) +
  facet_wrap(~Variable, scales = "free_y", 
             labeller = labeller(Variable = var_labels)) +
  theme_minimal(base_size = 14) +
  labs(title = "Distributions of Key Variables by Region", y = NULL) +
  theme(axis.text.x = element_text(angle = 45, hjust = 1),  
        plot.title = element_text(hjust = 0.5, size = 14, face = "bold"),
        panel.background = element_rect(fill = "white", color = NA),
        plot.background = element_rect(fill = "white", color = NA))

#ggsave("africa_boxplots_highres.png", plot = boxplot_grid, dpi = 600, width = 12, height = 8)

# check for multicolinearity briefly from linear model.

# Fit a basic model without smooth terms just to check VIF
lm_check_less20 <- lm(Mortality ~ HealthExp + Oop + Polstab , data = panel_mortless20)
vif(lm_check_less20)

summary(lm_check_less20)


# add age dependency ratio

lm_check_age_less20 <- lm(Mortality ~ HealthExp + Oop + Polstab + Agedep + Covid19  , data = panel_mortless20)
vif(lm_check_age_less20)

summary(lm_check_age_less20)



# gam fits


# Raw variables

gam_fit_less20 <- gam(Mortality ~ s(HealthExp) + s(Oop) + s(Polstab) + s(Country, bs = "re") + s(Year) ,
               data = panel_mortless20) # simple fit to begin with. 

summary(gam_fit_less20)

draw(gam_fit_less20)


# Raw variables + age dependency ratio

gam_fit_age_less20 <- gam(Mortality ~ s(HealthExp) + s(Oop) + s(Polstab) + s(Agedep) + Covid19 + s(Country, bs = "re") + s(Year),
                   data = panel_mortless20) # simple fit to begin with. 

summary(gam_fit_age_less20)

draw(gam_fit_age_less20)



# account for expenditure and stability lag

panel_lag_less20 <- panel_mortless20 %>%
  group_by(Country) %>%
  arrange(Year) %>%
  mutate(
    HealthExp_lag1 = lag(HealthExp, 1),
    HealthExp_lag2 = lag(HealthExp, 2),
    HealthExp_lag3 = lag(HealthExp, 3),
    Polstab_lag1 = lag(Polstab, 1),
    Polstab_lag2 = lag(Polstab, 2),
    Polstab_lag3 = lag(Polstab, 3)
  ) %>%
  ungroup()



# Initially kept model - without age now with filter (mort <20 and Health_Exp < 1000)
gam_fit_lag_less20 <- gam(Mortality ~  
                     s(HealthExp_lag1) + 
                     s(Oop) + 
                     s(Polstab_lag1) +
                     ti(HealthExp_lag1, Oop) + 
                     s(Country, bs = "re") + 
                     s(Year),
                   data = panel_lag_less20,
                   method = "REML") # ps: when you use te(a, b), it includes main effects + interaction (if not already included, they’re absorbed).ti(a, b) gives only the interaction (useful if you already have s(a) and s(b) in the model).

summary(gam_fit_lag_less20)



plot(gam_fit_lag_less20, select = 1, shade = TRUE, rug = TRUE) # verifying that the increasing part of the health expenditure occurrs at points with sparse dat.


draw(gam_fit_lag_less20)
vis.gam(gam_fit_lag_less20, view = c("HealthExp_lag1", "Oop"), plot.type = "contour", color = "topo") # 2d interaction effect
vis.gam(gam_fit_lag_less20, view = c("HealthExp_lag1", "Oop"), theta = 30, phi = 40) # 3d interaction effect
summary(gam_fit_lag_less20)$dev.expl
gam.vcomp(gam_fit_lag_less20) # check what proportion of variance is explained by the various variables

appraise(gam_fit_lag_less20)


# Model - with age
gam_fit_age_lag_less20 <- gam(Mortality ~  
                         s(HealthExp_lag1) + 
                         s(Oop) + 
                         s(Polstab_lag1) +
                         s(Agedep) + 
                           Covid19 +
                         ti(HealthExp_lag1, Oop) + 
                         s(Country, bs = "re") + 
                         s(Year),
                       data = panel_lag_less20,
                       method = "REML") # ps: when you use te(a, b), it includes main effects + interaction (if not already included, they’re absorbed).ti(a, b) gives only the interaction (useful if you already have s(a) and s(b) in the model).

summary(gam_fit_age_lag_less20 )



plot(gam_fit_age_lag_less20 , select = 1, shade = TRUE, rug = TRUE) # verifying that the increasing part of the health expenditure occurrs at points with sparse dat.


draw(gam_fit_age_lag_less20 )
vis.gam(gam_fit_age_lag_less20 , view = c("HealthExp_lag1", "Oop"), plot.type = "contour", color = "topo") # 2d interaction effect
vis.gam(gam_fit_age_lag_less20 , view = c("HealthExp_lag1", "Oop"), theta = 30, phi = 40) # 3d interaction effect
summary(gam_fit_age_lag_less20 )$dev.expl
gam.vcomp(gam_fit_age_lag_less20) # check what proportion of variance is explained by the various variables

appraise(gam_fit_age_lag_less20 )


unique(panel_lag_less20$Region)



# Check data coverage in that corner
panel_lag_less20 %>%
  filter(Oop < 25, HealthExp_lag1 > 200) %>%
  count(Country)

vis.gam(gam_fit_age_lag_less20, view = c("HealthExp_lag1", "Oop"),
        plot.type = "contour", color = "terrain",
        too.far = 0.05, n.grid = 200, se = 0,
        main = "Data density on interaction surface")
points(panel_lag_less20$HealthExp_lag1, panel_lag_less20$Oop, pch = 20, cex = 0.5)




#Regionwise model

#Ps: simpler (gam) models were fitted and checked but we maintained this since it is a follow-up on the African analysis
# Central Africa
panel_central_less20 <- filter(panel_lag_less20, Region == "Central")
gam_central_less20 <- gam(Mortality ~ 
                     s(HealthExp_lag1) + 
                     s(Oop) + 
                     s(Polstab_lag1) +
                       s(Agedep) + 
                       Covid19 +
                     ti(HealthExp_lag1, Oop) +
                     s(Country, bs = "re") +
                     s(Year),
                   data = panel_central_less20,
                   method = "REML")

summary(gam_central_less20)
draw(gam_central_less20)

gam.vcomp(gam_central_less20)



# Check data coverage in that corner
panel_central_less20 %>%
  filter(Oop < 25, HealthExp_lag1 > 200) %>%
  count(Country)

vis.gam(gam_central_less20, view = c("HealthExp_lag1", "Oop"),
        plot.type = "contour", color = "terrain",
        too.far = 0.05, n.grid = 200, se = 0,
        main = "Data density on interaction surface")
points(panel_central_less20$HealthExp_lag1, panel_central_less20$Oop, pch = 20, cex = 0.5)


# East Africa
panel_east_less20 <- filter(panel_lag_less20, Region == "East")
gam_east_less20 <- gam(Mortality ~ 
                  s(HealthExp_lag1) + 
                  s(Oop) + 
                  s(Polstab_lag1) +
                    s(Agedep) + 
                    Covid19 +
                  ti(HealthExp_lag1, Oop) +
                  s(Country, bs = "re") +
                  s(Year),
                data = panel_east_less20,
                method = "REML")

summary(gam_east_less20)
draw(gam_east_less20)


# Check data coverage in that corner
panel_east_less20 %>%
  filter(Oop < 25, HealthExp_lag1 > 200) %>%
  count(Country)

vis.gam(gam_east_less20, view = c("HealthExp_lag1", "Oop"),
        plot.type = "contour", color = "terrain",
        too.far = 0.05, n.grid = 200, se = 0,
        main = "Data density on interaction surface")
points(panel_east_less20$HealthExp_lag1, panel_east_less20$Oop, pch = 20, cex = 0.5)


# West Africa
panel_west_less20 <- filter(panel_lag_less20, Region == "West")
gam_west_less20 <- gam(Mortality ~ 
                  s(HealthExp_lag1) + 
                  s(Oop) + 
                  s(Polstab_lag1) +
                    s(Agedep) + 
                    Covid19 +
                  ti(HealthExp_lag1, Oop) +
                  s(Country, bs = "re") +
                  s(Year),
                data = panel_west_less20,
                method = "REML")

summary(gam_west_less20)
draw(gam_west_less20)


# Check data coverage in that corner
panel_west_less20 %>%
  filter(Oop < 25, HealthExp_lag1 > 200) %>%
  count(Country)

vis.gam(gam_west_less20, view = c("HealthExp_lag1", "Oop"),
        plot.type = "contour", color = "terrain",
        too.far = 0.05, n.grid = 200, se = 0,
        main = "Data density on interaction surface")
points(panel_west_less20$HealthExp_lag1, panel_west_less20$Oop, pch = 20, cex = 0.5)


# Southern Africa
panel_south_less20 <- filter(panel_lag_less20, Region == "Southern")
gam_south_less20 <- gam(Mortality ~ 
                   s(HealthExp_lag1) + 
                   s(Oop) + 
                   s(Polstab_lag1) +
                     s(Agedep) + 
                     Covid19 +
                   ti(HealthExp_lag1, Oop) +
                   s(Country, bs = "re") +
                   s(Year),
                 data = panel_south_less20,
                 method = "REML")
summary(gam_south_less20)
draw(gam_south_less20)


# Check data coverage in that corner
panel_south_less20 %>%
  filter(Oop < 25, HealthExp_lag1 > 200) %>%
  count(Country)

vis.gam(gam_south_less20, view = c("HealthExp_lag1", "Oop"),
        plot.type = "contour", color = "terrain",
        too.far = 0.05, n.grid = 200, se = 0,
        main = "Data density on interaction surface")
points(panel_south_less20$HealthExp_lag1, panel_south_less20$Oop, pch = 20, cex = 0.5)

# Northern Africa
panel_north_less20 <- filter(panel_lag_less20, Region == "Northern")
gam_north_less20 <- gam(Mortality ~ 
                   s(HealthExp_lag1) + 
                   s(Oop) + 
                   s(Polstab_lag1) +
                     s(Agedep) + 
                     Covid19 +
                   ti(HealthExp_lag1, Oop) +
                   s(Country, bs = "re") +
                   s(Year),
                 data = panel_north_less20,
                 method = "REML")

summary(gam_north_less20)
draw(gam_north_less20)
gam.vcomp(gam_north_less20)



# Check data coverage in that corner
panel_north_less20 %>%
  filter(Oop < 25, HealthExp_lag1 > 200) %>%
  count(Country)

vis.gam(gam_north_less20, view = c("HealthExp_lag1", "Oop"),
        plot.type = "contour", color = "terrain",
        too.far = 0.05, n.grid = 200, se = 0,
        main = "Data density on interaction surface")
points(panel_north_less20$HealthExp_lag1, panel_north_less20$Oop, pch = 20, cex = 0.5)

