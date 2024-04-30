# Food Insecurity Map
> Goals: Provide an interactive map that highlights areas of food insecurity around
> the US to allow food banks, grocery stores, and more to pinpoint high impact areas. 

An example of this map is available at: 
https://rpubs.com/pbray/1180092

A layered map that highlights census tracts as disadvantaged according to each of the
criteria on the Climate and Economic Justice Screening Tool (CEJST).

As a summary, these criteria are: 
> Climate Change
* at or above the 90th percentile for expected agriculture loss rate OR expected building loss rate OR expected population loss rate OR projected
  future flood risk OR projected future wildfire risk
> Energy
* at or above the 90th percentile for energy cost OR PM 2.5 in the air
> Health
* at or above the 90th percentile for asthma OR diabetes OR heart disease OR low life expectancy
> Housing
* Experienced historic underinvestment OR at or above the 90th percentile for housing cost OR lack of green space OR lack of indoor plumbing OR lead paint
> Legacy Pollution
* Have at least one abandoned mine land OR Formerly Used Defense Sites (FUDS) OR are at or above the 90th percentile for proximity to hazardous
  waste facilities OR proximity to Superfund (National Priorities List (NPL)) sites OR proximity to Risk Management Plan (RMP) facilities
> Transportation
* at or above the 90th percentile for diesel particulate matter exposure OR transportation barriers OR traffic proximity and volume
> Water and Wastewater
* at or above the 90th percentile for underground storage tanks and releases OR wastewater discharge
> Workforce Development
* at or above the 90th percentile for linguistic isolation OR low median income OR poverty OR unemployment
* fewer than 10% of people ages 25 or older have a high school education (i.e. graduated with a high school diploma)


## Getting started

Successful CEJST map viewing requires minimal packages:

```shell
library(leaflet)
library(sf)
library(dplyr)
library(htmlwidgets)
```

Further installation of data is required. The CEJST provides Communities List Data, as well as a preloaded shapefile, available at:
https://screeningtool.geoplatform.gov/en/downloads

Visualization of the heat map requires slightly different packages:
```shell
library(ggplot2)
library(sp)
library(sf)
library(ggmap)
```

Visualization of the heat map requires an initial configuration Google Maps API Key, available at: 
https://developers.google.com/maps/documentation/embed/get-api-key

To initialize this key, the user must input:
```shell
register_google(key = "keyvaluehere")
```

## Features

Functionality
* Layered map that enables visualization of census tracts that fulfill certain criteria as established by CEJST
* Drop down menu that enables user adjustment of the map
* Random value heat map to test functionality without grocery store location data base

## Problems

* Merging community data with shapefiles
* Converting community information to logicals
* Layering each indicator on the map
* Creating a working dropdown menu
* Adjusting sensitivity of the heat map
* Layering the heat map with the community map

## Next Steps

As a continuation, we will need to find or create a data base containing grocery store locations. 
(If these locations are in Longitude and Latitude, we will need to convert these to a .shp)

## Interesting Readings:

“Characteristics and Influential Factors of Food Deserts” by Paula Dutko, Michele Ver Ploeg, Tracey Farrigan: 
Examine food deserts based on census tracts in 2000 and 2006, establish trends for income compared to food injustice, and 
examine socioeconomic conditions. <br />
"How the Other Half Eats", Priya Fielding-Singh: explores dietary changes between communities and classes throughout the US,
explores the food inequality problem in a different and broader aspect than just food deserts.

