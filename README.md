# ReleaseNotesKit
This is ReleaseNotesKit, a brand new, elegant, and extremely simple way to present the recent version’s release notes to your users. `ReleaseNotesKit` uses the iTunesSearchAPI to access information about the app. It has methods for caching data, presenting once on a version change, accessing just the data, and presenting the sheet without any preconditions. 

## Configuration
`ReleaseNotesKit` can be initialized using:

```swift
ReleaseNotesKit.shared.setApp(with: "1548193451") //Replace with your app's ID
```
Ideally, you'd like to set this once per app launch. Therefore, a good place to set this code would be in your App's `AppDelegate` file.

## Usage
> Note: Before accessing any of `ReleaseNotesKit`’s methods, you have to initialize the shared instance with the app ID. Failure to do this will throw an assertion failure during DEBUG and will do nothing during PROD.

`ReleaseNotesKit` can provide you both the data in a Swift Struct and also present a sheet with the data in a pre-styled format. 

### Just the data 
To access just the data call `parseCacheOrFetchNewData`. This method has a default parameter `precondition` that is set to `false` by default. For simply accessing the data, precondition can remain false. This check is useful for our subsequent usage types.

```swift
ReleaseNotesKit.shared.parseCacheOrFetchNewData { result in
            switch result {
            case .success(let response):
                print(response.releaseNotes)
            case .failure(let error):
                print(error.rawValue)
            }
}
```

The completion returns a Swift `Result` type with `ITunesLookupResult` for the success case and `ReleaseNotesError` in case of failure. `ReleaseNotesError` is defined in the following way:
```swift
enum ReleaseNotesError: String, Error {
    case malformedURL
    case malformedData
    case parsingFailure
    case noResults
}
```
Let’s quickly go over each of these cases and what they mean so that it’ll be easy for you to handle it in your code: 

* `malformedURL`: The iTunesSearchAPI’s URL failed to get constructed. This will never happen if a properly formatted App ID is passed in the singleton’s `setApp` method. 
* `malformedData`: The data that is returned from the iTunesSearchAPI is corrupted or not readable. 
* `parsingFailure`: JSONDecoder failed to parse the data into `ITunesLookup`.
* `noResults`: There was no available results returned for this particular appID. Please check if the appID is correct or if the app is brand new, please wait for a few hours for AppStore to index your app.

### Presenting the ReleaseNotesView for the first time
`ReleaseNotesKit` can present the `ReleaseNotesView	` when the version changes. To present the sheet once per version update, you can call `presentReleaseNotesForTheFirstTime`. 
```swift
ReleaseNotesKit.shared.presentReleaseNotesForTheFirstTime()
```
There’s two checks that happen in this method: 

```swift
guard let lastVersionSheetShownFor = UserDefaults.standard.string(forKey: "lastVersionSheetShownFor") else {
    presentReleaseNotesView(precondition: true, in: UIApplication.topViewController())
    return
}
```
In this first case, we check if the UserDefaults string for `lastVersionSheetShownFor` is nil which can happen when the user has installed the app for the first time.

```swift
if lastVersionSheetShownFor != Bundle.main.releaseVersionNumber {
    presentReleaseNotesView(precondition: true, in: UIApplication.topViewController())
}
```
In this final check, we check if the sheet was last presented for a different version but now a new version is available from the API. 

### Presenting `ReleaseNotesView` without Preconditions
It is possible to present the `ReleaseNotesView` without any version check preconditions. To call this, simply call `presentReleaseNotesView`. You may choose to pass a `controller: UIViewController` or let it be nil and the framework will access the UIApplication’s top view controller and present the `ReleaseNotesView` on that top controller. 

```swift
ReleaseNotesKit.shared.presentReleaseNotesView(in: self)
```
Or, without the controller to present.
```swift
ReleaseNotesKit.shared.presentReleaseNotesView()
```

## Testing
There has been some manual testing done by myself. However, I am looking for contributions that will add a good testing suite. If you’re willing, please feel free to open a PR!

## Like the framework?
If you like `ReleaseNotesKit` please consider buying me a coffee 🥰

<a href="https://www.buymeacoffee.com/swapnanildhol"><img src="https://img.buymeacoffee.com/button-api/?text=Buy me a coffee&emoji=&slug=swapnanildhol&button_colour=5F7FFF&font_colour=ffffff&font_family=Cookie&outline_colour=000000&coffee_colour=FFDD00"></a>

## Contribution
Contributions are always welcome. Please follow the following convention if you’re contributing:

NameOfFile: Changes Made
One commit per feature
For issue fixes: #IssueNumber NameOfFile: ChangesMade

## License
This project is licensed under the MIT License - see the  [LICENSE](https://github.com/SwapnanilDhol/ReleaseNotesKit/blob/main/Resources/LICENSE.md)  file for details

## Apps using ReleaseNotesKit
* [Neon: Color Picker & Social](https://apps.apple.com/us/app/neon-real-time-color-picker/id1480273650?ls=1)
* [Sticker Card](https://apps.apple.com/us/app/sticker-cards/id1522226018)

If you’re using `ReleaseNotesKit` in your app please open a PR to edit this Readme. I’ll be happy to include you in this list :D 
