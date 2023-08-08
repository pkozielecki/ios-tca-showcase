# Total Composable Architecture Showcase

Welcome to the demonstration of **Total Composable Architecture** in a **SwiftUI** project.

[![Build & Test](https://github.com/pkozielecki/ios-tca-showcase/actions/workflows/ios.yml/badge.svg)](https://github.com/pkozielecki/ios-tca-showcase/actions/workflows/ios.yml)

## Main app features
* Create a list of your favourite assets (gold, silver, bitcoin, etc.)...
* ... and see how they are valuated against a reference asset (USD).
* Personalise how an asset is displayed: choose a name, lead color and position on the list.
* Get historical data for each asset.
* See if there's an update available for the app.
* Based 100% **Total Composable Architecture** and **SwiftUI**.
* https://metalpriceapi.com/ API used as an asset prices provider.
* Uses **SwiftUIRouter** component for navigation.

| ![](External%20Resources/favourite-assets.gif) | ![](External%20Resources/update-app.gif) | ![](External%20Resources/edit.gif) |
|----------------------------------------|----------------------------------------------|---------------------------------|


## Integration

### Requirements
* iOS 16.0

### Running the app

* Clone the repo.
* Open `TCAShowcase.xcodeproj` file.
* Edit `AppConfiguration.swift` file and enter valid https://metalpriceapi.com/ API key.
* Use `TCAShowcase` scheme to run the application.
* Use `TCAShowcaseTests` scheme to run unit tests.

## Next steps:

* Refactor **main app state** to be composed of sub-features states.
* Extract **Features** into separate **modules**.
* Add a dedicated app build flow for **GitHub Actions** PR-check to show e.g. code coverage report.
* Add an option to change **reference asset**.

## Project maintainer

- [Pawel Kozielecki](https://github.com/pkozielecki)

See also the list of [contributors](https://github.com/pkozielecki/ios-tca-showcase/graphs/contributors) who participated in this project.

## License

This project is licensed under the MIT License.
[More info](LICENSE.md)
