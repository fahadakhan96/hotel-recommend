module HotelMap where

import qualified Data.Map as M
import Data.PSQueue as PS
import Data.List (sortBy)
import Data.Function (on)

type CityMap a = PSQ a Int
type CountryMap a = M.Map String (CityMap a)
type GlobeMap a = M.Map String (CountryMap a)

--- Increments the priority of a hotel in its city map ---
updateCity :: String -> String -> CountryMap String -> CountryMap String
updateCity city hotel city_map = M.insert city (PS.adjust (+1) hotel hotel_list) city_map
    where (Just hotel_list) = M.lookup city city_map

selectHotel :: String -> String -> String -> GlobeMap String -> GlobeMap String
selectHotel country city hotel our_map = M.insertWith (\_ y -> updateHotel y) country updated_t our_map
    where updated_t = updateHotel M.empty
          updateHotel y = updateCity city hotel y

--- Inserts a hotel in its city map in its country map ---
insertHotel :: String -> Int -> CityMap String -> CityMap String
insertHotel hotel priority h = PS.insert hotel priority h

insertCity :: String -> String -> Int -> CountryMap String -> CountryMap String
insertCity city hotel priority city_m = M.insertWith (\_ y -> addHotel y) city new_t city_m
    where new_t = addHotel PS.empty
          addHotel y = insertHotel hotel priority y

insertCountry :: String -> String -> String -> Int -> GlobeMap String -> GlobeMap String
insertCountry country city hotel priority country_m = M.insertWith (\_ y -> addCity y) country new_cm country_m
    where new_cm = addCity M.empty
          addCity y = insertCity city hotel priority y

--- Converts the PSQ into a list of hotels in descending order of priority ---
getHotels :: (Ord a) => CityMap a -> [a]
getHotels hotel_list = [ PS.key x | x <- sorted_list ]
    where sorted_list = sortBy (flip compare `on` prio) $ toList hotel_list