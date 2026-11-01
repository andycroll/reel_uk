# Change Log
All notable changes to this project will be documented in this file.
This project adheres to [Semantic Versioning](http://semver.org/).

## [1.0.0] - 2026-11-01

### Added
- `ReelUk::Cinema.all` and `ReelUk::Cinema.new(id)` for Reel's cinemas, keyed by each venue's path on the website, from the cinema menu on the Reel home page, with addresses from each venue's page footer and coordinates from OpenStreetMap (Burnley's from its postcode).
- `ReelUk::Performance.at(id, from:, to:)` for every advertised date. Venues on Reel's WordPress website, built on Jacro's cinema plugin with TapOS ticketing, are read from the what's on and coming soon pages and the quick booking menu's showtimes for each film. Venues still on the old Admit One A1Web website are read through cinebase 5.7's shared A1Web support, with booking links to their Admit One ticketing sites.
- Variants for Reel's showtime labels, A1Web group headings and titles, and film years from titles.
- Fixtures trimmed from live pages, a live shape test that checks real responses without storing them, and GitHub Actions CI and release workflows.
