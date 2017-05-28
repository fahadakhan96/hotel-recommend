''' A function to get all hotels located in a given city '''

import sys
from googleplaces import GooglePlaces, types

# GOOGLE_API_KEY = 'Put key here'
PLACEHOLDER_PRIORITY = 100

def write_hotels(region, query_result, hotel_csv):
    ''' Writes the query results in the csv file '''
    global PLACEHOLDER_PRIORITY
    city_name, country_name = map(lambda x: x.strip(), region.split(','))
    for hotel in query_result.places:
        hotel_csv.write('{};{};{};{}\n'.format(country_name, city_name, hotel.name, PLACEHOLDER_PRIORITY))
        PLACEHOLDER_PRIORITY -= 1

def get_hotels(region):
    ''' Makes a query and gets result '''
    hotel_locator = GooglePlaces(GOOGLE_API_KEY)
    hotel_csv = open('hotels.csv', 'a')
    query_result = hotel_locator.nearby_search(location=region, types=[types.TYPE_LODGING])
    write_hotels(region, query_result, hotel_csv)

    while query_result.has_next_page_token:
        query_result = hotel_locator.nearby_search(pagetoken=query_result.next_page_token)
        write_hotels(region, query_result, hotel_csv)

    hotel_csv.close()

def main(region):
    ''' MAIN function '''
    get_hotels(region)

if __name__ == '__main__':
    main(sys.argv[1])
