rm(list = ls())

library(leaflet)
library(sf)
library(dplyr)
library(htmlwidgets)

USA_shape <- st_read("1.0-shapefile-codebook/usa/usa.shp")

cejst_data <- read.csv("1.0-communities.csv")

#california only for community data
ca_cejst_data <- cejst_data %>%
  filter(State.Territory == 'California') %>%
  mutate(`Census.tract.2010.ID` = as.character(`Census.tract.2010.ID`))

#convert all variable names with greater.than... which are the basic classifiers for disadvanted communities to logicals
ca_cejst_data <- ca_cejst_data %>%
  mutate_at(
    vars(contains('Greater.than.or.equal.to.the.90th')),
    as.logical
  ) %>%
  mutate(
    There.is.at.least.one.abandoned.mine.in.this.census.tract.and.the.tract.is.low.income. = as.logical(There.is.at.least.one.abandoned.mine.in.this.census.tract.and.the.tract.is.low.income.),
    There.is.at.least.one.Formerly.Used.Defense.Site..FUDS..in.the.tract.and.the.tract.is.low.income. = as.logical(There.is.at.least.one.Formerly.Used.Defense.Site..FUDS..in.the.tract.and.the.tract.is.low.income.)
  )

#need to convert to logicals first

ca_cejst_data_categorical <- ca_cejst_data %>%
  mutate(
    Climate_Change = ifelse(
      (Greater.than.or.equal.to.the.90th.percentile.for.expected.population.loss.rate.and.is.low.income. |
         Greater.than.or.equal.to.the.90th.percentile.for.share.of.properties.at.risk.of.flood.in.30.years.and.is.low.income. |
         Greater.than.or.equal.to.the.90th.percentile.for.share.of.properties.at.risk.of.fire.in.30.years.and.is.low.income. |
         Greater.than.or.equal.to.the.90th.percentile.for.expected.agriculture.loss.rate.and.is.low.income. |
         Greater.than.or.equal.to.the.90th.percentile.for.expected.building.loss.rate.and.is.low.income. |
         Greater.than.or.equal.to.the.90th.percentile.for.diesel.particulate.matter.and.is.low.income.), TRUE, FALSE),
    
    Energy = ifelse(
      (Greater.than.or.equal.to.the.90th.percentile.for.PM2.5.exposure.and.is.low.income. |
         Greater.than.or.equal.to.the.90th.percentile.for.energy.burden.and.is.low.income. |
         Greater.than.or.equal.to.the.90th.percentile.for.diesel.particulate.matter.and.is.low.income.), TRUE, FALSE),
    
    Health = ifelse(
      (Greater.than.or.equal.to.the.90th.percentile.for.asthma.and.is.low.income. |
         Greater.than.or.equal.to.the.90th.percentile.for.diabetes.and.is.low.income. |
         Greater.than.or.equal.to.the.90th.percentile.for.heart.disease.and.is.low.income. |
         Greater.than.or.equal.to.the.90th.percentile.for.low.life.expectancy.and.is.low.income.), TRUE, FALSE),
    
    Housing = ifelse(
      (Greater.than.or.equal.to.the.90th.percentile.for.lead.paint..the.median.house.value.is.less.than.90th.percentile.and.is.low.income. |
         Greater.than.or.equal.to.the.90th.percentile.for.share.of.the.tract.s.land.area.that.is.covered.by.impervious.surface.or.cropland.as.a.percent.and.is.low.income. |
         Greater.than.or.equal.to.the.90th.percentile.for.housing.burden.and.is.low.income.), TRUE, FALSE),
    
    Legacy_Pollution = ifelse(
      (Greater.than.or.equal.to.the.90th.percentile.for.proximity.to.hazardous.waste.facilities.and.is.low.income. |
         Greater.than.or.equal.to.the.90th.percentile.for.proximity.to.superfund.sites.and.is.low.income. |
         Greater.than.or.equal.to.the.90th.percentile.for.proximity.to.RMP.sites.and.is.low.income. |
         There.is.at.least.one.abandoned.mine.in.this.census.tract.and.the.tract.is.low.income. | 
         There.is.at.least.one.Formerly.Used.Defense.Site..FUDS..in.the.tract.and.the.tract.is.low.income.), TRUE, FALSE),
    
    Transportation = ifelse(
      (Greater.than.or.equal.to.the.90th.percentile.for.traffic.proximity.and.is.low.income. |
         Greater.than.or.equal.to.the.90th.percentile.for.DOT.transit.barriers.and.is.low.income.), TRUE, FALSE),
    
    Water_and_Wastewater = ifelse(
      (Greater.than.or.equal.to.the.90th.percentile.for.wastewater.discharge.and.is.low.income. |
         Greater.than.or.equal.to.the.90th.percentile.for.leaky.underground.storage.tanks.and.is.low.income.), TRUE, FALSE),
    
    Workforce_Development = ifelse(
      (Greater.than.or.equal.to.the.90th.percentile.for.low.median.household.income.as.a.percent.of.area.median.income.and.has.low.HS.attainment. |
         Greater.than.or.equal.to.the.90th.percentile.for.households.in.linguistic.isolation.and.has.low.HS.attainment. |
         Greater.than.or.equal.to.the.90th.percentile.for.unemployment.and.has.low.HS.attainment. |
         Greater.than.or.equal.to.the.90th.percentile.for.households.at.or.below.100..federal.poverty.level.and.has.low.HS.attainment.), TRUE, FALSE)
  )


#california only for shape file
ca_shape <- USA_shape %>%
  filter(SF == 'California') %>%
  rename('Census.tract.2010.ID' = 'GEOID10')

#adjust census tract so that it matches the same values exclusing the first zero
ca_shape <- ca_shape %>%
  mutate(`Census.tract.2010.ID` = substr(`Census.tract.2010.ID`, 2, 11))

#join shape file and community information, adjust logicals
ca_community_data <- left_join(ca_cejst_data_categorical, ca_shape, by = 'Census.tract.2010.ID') %>%
  mutate(`Identified.as.disadvantaged` = as.logical(`Identified.as.disadvantaged`))

#switch from data frame to shape frame containing geometric data
ca_community_data_sf <- st_as_sf(ca_community_data)


#setting up color palate
pal <- colorNumeric("Reds", domain = ca_community_data$Identified.as.disadvantaged)

map <- leaflet() %>%
  addTiles()

map <- map %>%
  addPolygons(
  data = subset(ca_community_data_sf, Climate_Change == TRUE),
  fillColor = ~pal(Identified.as.disadvantaged),
  weight = 2,
  opacity = 1,
  color = "white",
  group = "Climate Change",
  dashArray = "3",
  fillOpacity = 0.7,
  highlight = highlightOptions(
    weight = 5,
    color = "#666",
    dashArray = "",
    fillOpacity = 0.7,
    bringToFront = TRUE
  ),
  label = ~paste("Climate Change: ", ifelse(Climate_Change, "True", "False"))
)

map <- map %>%
  addPolygons(
  data = subset(ca_community_data_sf, Energy == TRUE),
  fillColor = ~pal(Identified.as.disadvantaged),
  weight = 2,
  opacity = 1,
  color = "white",
  group = "Energy",
  dashArray = "3",
  fillOpacity = 0.7,
  highlight = highlightOptions(
    weight = 5,
    color = "#666",
    dashArray = "",
    fillOpacity = 0.7,
    bringToFront = TRUE
  ),
  label = ~paste("Energy: ", ifelse(Energy, "True", "False"))
)

map <- map %>%
  addPolygons(
  data = subset(ca_community_data_sf, Health == TRUE),
  fillColor = ~pal(Identified.as.disadvantaged),
  weight = 2,
  opacity = 1,
  color = "white",
  group = "Health",
  dashArray = "3",
  fillOpacity = 0.7,
  highlight = highlightOptions(
    weight = 5,
    color = "#666",
    dashArray = "",
    fillOpacity = 0.7,
    bringToFront = TRUE
  ),
  label = ~paste("Health: ", ifelse(Health, "True", "False"))
)

map <- map %>%
  addPolygons(
  data = subset(ca_community_data_sf, Housing == TRUE),
  fillColor = ~pal(Identified.as.disadvantaged),
  weight = 2,
  opacity = 1,
  color = "white",
  group = "Housing",
  dashArray = "3",
  fillOpacity = 0.7,
  highlight = highlightOptions(
    weight = 5,
    color = "#666",
    dashArray = "",
    fillOpacity = 0.7,
    bringToFront = TRUE
  ),
  label = ~paste("Housing: ", ifelse(Housing, "True", "False"))
)

map <- map %>%
  addPolygons(
  data = subset(ca_community_data_sf, Legacy_Pollution == TRUE),
  fillColor = ~pal(Identified.as.disadvantaged),
  weight = 2,
  opacity = 1,
  color = "white",
  group = "Legacy Pollution",
  dashArray = "3",
  fillOpacity = 0.7,
  highlight = highlightOptions(
    weight = 5,
    color = "#666",
    dashArray = "",
    fillOpacity = 0.7,
    bringToFront = TRUE
  ),
  label = ~paste("Legacy Pollution: ", ifelse(Legacy_Pollution, "True", "False"))
)

map <- map %>%
  addPolygons(
  data = subset(ca_community_data_sf, Transportation == TRUE),
  fillColor = ~pal(Identified.as.disadvantaged),
  weight = 2,
  opacity = 1,
  color = "white",
  group = "Transportation",
  dashArray = "3",
  fillOpacity = 0.7,
  highlight = highlightOptions(
    weight = 5,
    color = "#666",
    dashArray = "",
    fillOpacity = 0.7,
    bringToFront = TRUE
  ),
  label = ~paste("Transportation: ", ifelse(Transportation, "True", "False"))
)

map <- map %>%
  addPolygons(
  data = subset(ca_community_data_sf, Water_and_Wastewater == TRUE),
  fillColor = ~pal(Identified.as.disadvantaged),
  weight = 2,
  opacity = 1,
  color = "white",
  group = "Water and Wastewater",
  dashArray = "3",
  fillOpacity = 0.7,
  highlight = highlightOptions(
    weight = 5,
    color = "#666",
    dashArray = "",
    fillOpacity = 0.7,
    bringToFront = TRUE
  ),
  label = ~paste("Water and Waste Water: ", ifelse(Water_and_Wastewater, "True", "False"))
)

map <- map %>%
  addPolygons(
  data = subset(ca_community_data_sf, Workforce_Development == TRUE),
  fillColor = ~pal(Identified.as.disadvantaged),
  weight = 2,
  opacity = 1,
  color = "white",
  group = "Workforce Development",
  dashArray = "3",
  fillOpacity = 0.7,
  highlight = highlightOptions(
    weight = 5,
    color = "#666",
    dashArray = "",
    fillOpacity = 0.7,
    bringToFront = TRUE
  ),
  label = ~paste("Workforce Development: ", ifelse(Workforce_Development, "True", "False"))
)

# Add layers control
map <- addLayersControl(
  map = map,
  overlayGroups = c(
    "Climate Change",
    "Energy",
    "Health",
    "Housing",
    "Legacy Pollution",
    "Transportation",
    "Waste and Wastewater",
    "Workforce Development"
  ),
  options = layersControlOptions(collapsed = FALSE)
)


print(map)
