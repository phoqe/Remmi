# Remmi

Daily GitHub contributions in your macOS status bar.

## Screenshot

<img width="618" alt="Dark" src="https://user-images.githubusercontent.com/7033377/98924508-332aa980-24d5-11eb-8844-c8b99be3cacd.png">
<img width="618" alt="Light" src="https://user-images.githubusercontent.com/7033377/98924512-34f46d00-24d5-11eb-9234-95bb2d1ac588.png">

## Motivation

A fun way to begin writing macOS apps in Swift. Nothing serious.

## Remarks

- The count refreshes every 5 minutes.
- Clicking the count triggers a refresh and resets the refresh timer.
- SwiftSoup for DOM parsing. Yes, it’s an unnecessary overhead.

## Installation

I recommend installing Remmi with Homebrew for automatic updates.

### Homebrew

```sh
brew install --cask phoqe/cask/phoqe-remmi
```

If you want Remmi to launch at login, add it to Login Items.

### Manual

1. Download the latest stable version of Remmi in the [Releases](https://github.com/phoqe/remmi/releases) section on GitHub.
2. Expand the `Remmi.zip` file.
3. Drag the `Remmi.app` file to the `~/Applications` directory.
4. Start Remmi and enter your GitHub username.

If you want Remmi to launch at login, add it to Login Items.

## Licence

MIT
