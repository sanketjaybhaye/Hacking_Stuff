##### \# DarkBit Wi-Fi Pentesting Toolkit — Changelog



All notable changes to this project will be documented here.  

The format is based on \[Keep a Changelog](https://keepachangelog.com/en/1.0.0/).  

This project follows \*\*semantic versioning\*\*: `MAJOR.MINOR.PATCH`.



---



\## \[v3.1] — 2025-08-22

\### Added

\- Modular framework core (`darkbit.sh`)

\- Config file auto-generation (`toolkit.conf`)

\- Logging system (`/logs/` with timestamps)

\- Starter module pack:

&nbsp; - `scan.sh` → Passive network scanning  

&nbsp; - `handshake.sh` → Handshake capture placeholder  

&nbsp; - `crack.sh` → Crack placeholder  

&nbsp; - `cleanup.sh` → Restore networking  

&nbsp; - `defensive.sh` → WPA3 / PMF / WPS checks  

&nbsp; - `report.sh` → Generate summary reports  



\### Changed

\- Improved dynamic menu system (auto-loads all modules)

\- Updated log formatting with timestamps  



\### Notes

\- First public \*\*framework release\*\* with modular support  



---



\## \[v3.0] — 2025-08-15

\### Added

\- Basic Bash script automation (scan + handshake capture)

\- Logging to flat files

\- Basic menu system  



---



\## \[v2.0] — 2025-08-10

\### Added

\- Handshake capture + crack workflow (semi-automated)

\- Support for wordlist-based cracking

\- Basic logs for crack attempts  



---



\## \[v1.0] — 2025-08-01

\### Added

\- Initial manual Wi-Fi pentesting script

\- Basic scanning and deauth workflow

\- No modularity (single script)  



