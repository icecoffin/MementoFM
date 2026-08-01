# MementoFM

Have you ever tried to find a music band that is similar to the one you're currently listening to? What if you had already listened to many of those _before_? Trying to recall the exact artists can become a real problem when your music library is vast. If you're an avid [Last.fm](https://www.last.fm/) user, MementoFM is here to help you.

**Features:**

* Browse and search your Last.fm library
* Find similar artists based on tag intersection
* Search artists by tag
* Browse artists by country
* Set up tags which will be ignored during similarity check (e.g. too broad ones or irrelevant to the actual music content)

## Screenshots

<img src="Screenshots/screen_1.png" width="190"> <img src="Screenshots/screen_2.png" width="190"> <img src="Screenshots/screen_3.png" width="190"> <img src="Screenshots/screen_4.png" width="190">

(Originally there were also photos of the artists, but then Last.fm started to return placeholders instead of actual photos. Turns out they don't allow to use those photos anymore.)

## mise

[mise](https://mise.jdx.dev/) is used to install development tools like SwiftLint and XcodeGen. Tool versions are defined in `mise.toml`.

```sh
$ mise install
```

You can also enable mise environment integration so tools from `mise.toml` are available automatically in this project directory. For zsh, add this to `~/.zshrc`:
```sh
eval "$(mise activate zsh)"
```

Without shell integration, run tools through `mise exec`:
```sh
$ mise exec -- swiftlint
```

## XcodeGen

This project uses [XcodeGen](https://github.com/yonaskolb/XcodeGen/) to generate the Xcode project from `project.yml`. The `.xcodeproj` file is not committed to the Git repository.

After installing the development tools with mise, regenerate the project with:

```sh
$ mise exec -- xcodegen generate
```

If you have mise environment integration enabled, this also works:

```sh
$ xcodegen generate
```

## Running the app

You'll need a Last.fm API key in order to run this app. Here's how to obtain it:

1. Create a regular user account on [Last.fm](https://www.last.fm/).
2. Create an API account on [http://www.last.fm/api/account/create](http://www.last.fm/api/account/create).
3. Find the `Keys.example.swift` file in `Sources/Application/` and copy it to `Keys.swift`. Use the API key from the previous step to replace the `YOUR_API_KEY` placeholder.
