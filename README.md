# Hotel Recommendation System

This Haskell program was developed as a project for the course "CS 200 - Functional Data Structures" offered at Habib University, Pakistan. The program asks the user for a country and one of its cities and returns a list of hotels in that city. The list is ordered in ascending order of the priority assigned to each hotel. Once the user selects a hotel, the priority of that hotel is incremented by one which may affect the ordering of the hotels

## Requirements

- A *hotels.csv* file that contains the data.
- All files should be in the same folder as *Main.hs*.
- GHC
	- Packages:
		- threepenny-gui
		- cassava
		- PSQueue

## How to get more data?

- A *hotels.csv* file is required to get the program to run. The data in the file is in format ```<country>;<city>;<hotel>;<priority>```.
- A *gethotels.py* file is included which will get data from Google Maps and append the data to *hotels.csv*.
- In order to use this python file, you will need a Google Maps API key that you can get from [here](https://developers.google.com/maps/documentation/javascript/get-api-key). Once you have the key, simply add the key as a string in the *gethotels.py* file.
```python
GOOGLE_API_KEY = "XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX"
```
- To use *gethotels.py*, type in cmd: 
```cmd
python <path to gethotels.py> "<city>, <country>"
```
									
For example:
```cmd
python gethotels.py "New York, United States of America"
```

- The program will automatically add the new countries and cities to the drop-down menus.

## How to run the program?

1. 
```cmd
	cabal update
	cabal install threepenny-gui
	cabal install cassava
	cabal install PSQueue
	git clone https://github.com/fahadakhan96/hotel-recommend
	cd hotel-recommend/src
	ghc --make Main
	Main
```
2. Open a browser and goto ```localhost:8023```.

## How to use the program?

1. Select country from the drop-down menu.
2. Select city from the drop-down menu.
3. Click on 'Search'.
4. Select hotel from the listbox.
5. Click on 'Go!'.
6. Reload the page.
7. Repeat, if you wish.

## Bugs

- The UI is buggy. Once chosen, a selection should not be changed. A button should not be clicked on more than once.
- The data written in the CSV might sometimes include accented characters that cannot be read/parsed by Haskell and the Cassava (Data.Csv) module. In such cases, these accented characters should be manually edited.