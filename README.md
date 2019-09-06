
## Scouting
This application aggregates and displays scouting data for the 2019 FRC game "Destination: Deep Space Presented By The Boeing Company".

To collect said data, use of the companion mobile app is highly recommended (unless you wish to either manually patch together a QR code or write your own mobile app).

## Storage
All data files, including CSVs and robot images, are stored at:

    ~/Library/Containers/com.aydintiritoglu.scouting1072-mac/Data/Library/Application Support/com.aydintiritoglu.scouting1072-mac/

`com.aydintiritoglu.scouting1072-mac` may be a different value depending on what you set the app's bundle ID to be.

## Usage
To scan a QR code, click the Scan button and then click Ready. You will have to click Ready for each QR code you wish to scan; this is to prevent the same QR code from accidentally being scanned multiple times.

To create a fake dataset for use with the radar chart, type ⌘N and enter the desired values, then click Save.

To view graphs, type ⌘⇧G and enter team numbers separated by commas, e.g. `254, 1678, 1323` and press enter.

## License
This code is distributed under the GNU GPLv3. A copy of this license is included in the repository.

## More Info
This code is largely undocumented and uses some weird tricks to avoid lengthy code, so parts of it may be hard to understand. I intend to document it at some point, but until that time, feel free to send me a message on Discord at `@dropbear#2341` if you'd like me to explain my spaghetti.
