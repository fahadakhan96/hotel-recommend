import Control.Monad

import qualified Data.ByteString.Lazy as BL
import qualified Data.Vector as V
import qualified Data.Map as M
import qualified Data.PSQueue as PS
import qualified HotelMap as H

import Data.Csv

import qualified Graphics.UI.Threepenny as UI
import Graphics.UI.Threepenny.Core

myOptions = defaultDecodeOptions {
    -- Change the csv delimiter to ';'
      decDelimiter = fromIntegral $ fromEnum ';'
    }

myEncodeOptions = defaultEncodeOptions {
    -- Change the csv delimiter to ';'
      encDelimiter = fromIntegral $ fromEnum ';'
    }
    
--- Takes a Maybe and returns value without Just ---
removeJust :: Maybe a -> a
removeJust Nothing = error "Nothing on removeJust"
removeJust (Just x) = x

-------------------------------- Functions to convert our map into a list that can be encoded into a csv -------------------------------------

convertMap2List :: H.GlobeMap String -> [(String, String, String, Int)]
convertMap2List globe_map = M.foldWithKey (\k x ks -> (convertCountry2List k x) ++ ks) [] globe_map

convertCountry2List :: String -> H.CountryMap String -> [(String, String, String, Int)]
convertCountry2List country city_map = M.foldWithKey (\k x ks -> (convertCity2List k country x) ++ ks) [] city_map

convertCity2List :: String -> String -> H.CityMap String -> [(String, String, String, Int)]
convertCity2List city country hotel_list = [ (country, city, hotel, priority) | (hotel PS.:-> priority) <- PS.toList hotel_list  ]

------------------------------------ Creates a listbox element where options are taken from the list -------------------------------------------

mkSelect :: [String] -> UI (UI.ListBox String)
mkSelect options_list = do
    UI.listBox (pure options_list) (pure Nothing) (pure UI.string)

------------------------------------ Functions to return a list of hotels in a given city from our map ---------------------------------------------

getList :: String -> String -> H.GlobeMap String -> [String]
getList country city co_m = searchCity city ci_m
     where (Just ci_m) = M.lookup country co_m

searchCity :: String -> H.CountryMap String -> [String]
searchCity city ci_m = H.getHotels ci_heap
    where (Just ci_heap) = M.lookup city ci_m

------------------------ Given a map of countries and a country name, returns the list of cities in that country ----------------------------------

getCityList :: String -> H.GlobeMap String -> [String]
getCityList country our_map = M.keys city_m
    where (Just city_m) = M.lookup country our_map

----------------------------- Given a vector in the form (<country>, <city>, <hotel>, <priority>), converts it into a map ------------------------------

generateMap :: V.Vector (String, String, String, Int) -> H.GlobeMap String
generateMap v = V.foldl' (\acc (co, ci, ho, pr) -> H.insertCountry co ci ho pr acc) M.empty v

------------------------------------------------------------ THE GUI part ------------------------------------------------------

makeLabel :: Window -> UI.ListBox String -> [String] -> String -> String -> H.GlobeMap String -> UI Element
makeLabel rootWindow hotelBox hotelLst country city our_map = do
    hotelChoice <- get UI.selection $ getElement hotelBox
    case hotelChoice of
        Nothing -> error "Not Found"
        (Just h) -> do
            let hotelName = hotelLst !! h   -- Get name of selected hotel
            let new_map = H.selectHotel country city hotelName our_map  -- Increment the priority of the selected hotel by 1
            liftIO $ BL.writeFile "hotels.csv" $ encodeWith myEncodeOptions $ convertMap2List new_map -- Write updated map to CSV
            header <- UI.h1 #+ [ string $ hotelName ++ " selected. Please reload page!" ]   -- Create <h1>
            getBody rootWindow #+ [element header]  -- draw

makeHotelsList :: Window -> UI.ListBox String -> UI.ListBox String -> [String] -> [String] -> H.GlobeMap String -> UI ()
makeHotelsList rootWindow countryInput cityInput countries cities our_map = do
    countryChoice <- get UI.selection $ getElement countryInput -- Get selected country index
    cityChoice <- get UI.selection $ getElement cityInput   -- Get selected city index

    let country = countries !! (removeJust countryChoice)   -- Get selected country name
    let city = cities !! (removeJust cityChoice)    -- Get selected city name
    let hotelLst = getList country city our_map                     -- Get list of hotels in city

    hotelBox <- mkSelect hotelLst -- Make listbox of hotels
    element hotelBox # set (attr "size") "20"   -- set size attribute of listbox to 20
    goBtn <- UI.button #+ [ string "Go!" ]  -- Make button
    getBody rootWindow #+ [element hotelBox, element goBtn] -- Draw

    on UI.click goBtn $ \_ ->   --on clicking Go!
        makeLabel rootWindow hotelBox hotelLst country city our_map
    

makeCityS :: Window -> Maybe Int -> UI.ListBox String -> H.GlobeMap String -> [String] -> UI ()
makeCityS rootWindow x countryInput our_map countries = do
    case x of
        Nothing -> return ()
        Just ix -> do
            let countryName = countries !! ix   -- get selected country name from the list of countries
            let cities = getCityList countryName our_map    -- get list of cities in the selected country
            cityInput <- mkSelect cities    -- makes a drop-down menu of cities
            searchBtn <- UI.button #+ [ string "Search" ]  -- make button

            getBody rootWindow #+ [element cityInput, element searchBtn] -- draw drop-down menu and button

            on UI.click searchBtn $ \_ -> -- on clicking Search button
                makeHotelsList rootWindow countryInput cityInput countries cities our_map

makeCountryS :: Window -> V.Vector (String, String, String, Int) -> UI ()
makeCountryS rootWindow v = do
    let our_map = generateMap v         -- Inserts vector data into our data structure i.e. a map of countries
    let countries = M.keys our_map      -- Gets list of countries in the generetad map
    countryInput <- mkSelect countries  -- Makes a drop-down menu of countries
    getBody rootWindow #+ [element countryInput]    -- Draw the drop-drown menu of countries
    
    on UI.selectionChange (getElement countryInput) $ \x ->     -- When user selects a country
        makeCityS rootWindow x countryInput our_map countries

setup :: Window -> UI ()
setup rootWindow = void $ do
    -- Reads and parses CSV file and returns a vector of data in each line --
    csv <- liftIO $ BL.readFile "hotels.csv"
    case decodeWith myOptions NoHeader csv of
        Left err -> liftIO $ putStrLn err
        Right v -> makeCountryS rootWindow v

main :: IO ()
main = startGUI defaultConfig $ setup