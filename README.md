# ReleaseNotesKit
This is ReleaseNotesKit, a brand new, elegant, and extremely simple way to present the recent version’s release notes to your users. `ReleaseNotesKit` uses the iTunesSearchAPI to access information about the app. It has methods for caching data, presenting once on a version change, accessing just the data, and presenting the sheet without any preconditions. 

## Configuration
`ReleaseNotesKit` can be initialised using:

```swift
ReleaseNotesKit.shared.setApp(with: "1548193451") //Replace with your app's ID
```

## Usage
> Note: Before accessing any of `ReleaseNotesKit`’s methods, you have to initialise the shared instance with the app ID. Failure to do this will throw an assertion failure during DEBUG and will do nothing during PROD.

`ReleaseNotesKit` can provide you both the data in a Swift Struct and also present a sheet with the data in a styled format. 

### Just the data 
To access just the data call `parseCacheOrFetchNewData`. This method has a default parameter `precondition`that is set to `false` by default. For simply accessing the data, precondition can remain false. This check is useful for our subsequent usage types. The completion results a Swift `Result` type with `ITunesLookupResult` for the success case and `ReleaseNotesError` in case of failure. `ReleaseNotesError` is defined in the following way:
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
`ReleaseNotesKit` can present the `ReleaseNotesView	` when the version changes. To present the sheet once per version update, you can call `presentReleaseNotesForTheFirstTime`. There’s two checks that happen in this method: 

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


## Testing
There has been some manual testing done by myself. However, I am looking for contributions that will add a good testing suite. If you’re willing, please feel free to open a PR!

## Contribution
Please feel free to contribute any fixes, or changes that you’d like to see in this framework! If you’re using this framework in your project, and would like to contribute monetarily to its development, you can [Buy Me a Coffee](http://buymeacoffee.com/swapnanildhol) but you totally don’t have to. 

## License
Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the “Software”), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in
all copies or substantial portions of the Software.

```
THE SOFTWARE IS PROVIDED “AS IS”, WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
THE SOFTWARE.
```
