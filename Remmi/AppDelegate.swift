//
//  AppDelegate.swift
//  Remmi
//
//  Created by Linus Långberg on 2020-11-11.
//
import Cocoa
import SwiftUI
import SwiftSoup

@main
class AppDelegate: NSObject, NSApplicationDelegate {
    var statusItem: NSStatusItem?
    var refreshTimer: Timer?
    var username = UserDefaults.standard.string(forKey: "username")!

    // The minutes between each refresh. Default is 5.
    let refreshInterval = 5

    @IBOutlet weak var menu: NSMenu?
    @IBOutlet weak var userMenuItem: NSMenuItem?
    @IBOutlet weak var refreshMenuItem: NSMenuItem?
    @IBOutlet weak var changeUsernameMenuItem: NSMenuItem?

    func applicationDidFinishLaunching(_ aNotification: Notification) {
        UserDefaults.standard.register(defaults: [
            "username": "phoqe"
        ])

        if username.isEmpty {
            showChangeUsernameAlert()

            return
        }

        setupStatusItem()
        fetchContributions()
        setupRefreshTimer()
    }

    func applicationWillTerminate(_ aNotification: Notification) {
        invalidateRefreshTimer()
        destroyStatusItem()
    }

    func setupStatusItem() {
        statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)

        if let menu = menu {
            userMenuItem?.title = "User: \(username)"
            refreshMenuItem?.action = #selector(onRefreshClick)
            changeUsernameMenuItem?.action = #selector(onChangeUsernameClick)
            statusItem?.menu = menu
        }
    }

    func destroyStatusItem() {
        statusItem = nil
    }

    @objc func onRefreshClick() {
        refresh()
    }

    @objc func onChangeUsernameClick() {
        showChangeUsernameAlert()
    }

    private func showChangeUsernameAlert() {
        let alert = NSAlert()
        let usernameTextField = NSTextField(frame: NSRect(x: 0, y: 0, width: 300, height: 20))

        usernameTextField.placeholderString = username

        alert.messageText = "Change Username"
        alert.informativeText = "Enter your GitHub username."
        alert.alertStyle = .informational
        alert.accessoryView = usernameTextField
        alert.addButton(withTitle: "OK")
        alert.addButton(withTitle: "Cancel")
        alert.window.initialFirstResponder = alert.accessoryView

        if alert.runModal() == .alertFirstButtonReturn {
            changeUsername(withUsername: usernameTextField.stringValue)
        }
    }

    private func changeUsername(withUsername username: String) {
        UserDefaults.standard.setValue(username, forKey: "username")

        self.username = UserDefaults.standard.string(forKey: "username")!

        userMenuItem?.title = "User: \(username)"

        refresh()
    }

    private func refresh() {
        invalidateRefreshTimer()
        fetchContributions()
        setupRefreshTimer()
    }

    private func fetchContributions() {
        URLSession.shared.dataTask(with: contributionsUrl()) { data, response, error in
            if error != nil {
                self.showError()

                return
            }

            guard let httpResponse = response as? HTTPURLResponse, (200...299).contains(httpResponse.statusCode) else {
                self.showError()

                return
            }

            guard let mimeType = httpResponse.mimeType, mimeType == "text/html", let data = data, let html = String(data: data, encoding: .utf8) else {
                self.showError()

                return
            }

            do {
                let doc = try SwiftSoup.parse(html)
                let days = try doc.getElementsByTag("rect")
                let today = days[days.size() - 1]

                guard let attrs = today.getAttributes() else {
                    self.showError()

                    return
                }

                self.showContributions(count: attrs.get(key: "data-count"))
            } catch {
                self.showError()
            }
        }
        .resume()
    }

    private func setupRefreshTimer() {
        refreshTimer = Timer.scheduledTimer(withTimeInterval: TimeInterval(refreshInterval * 60), repeats: true, block: { (timer) in
            self.fetchContributions()
        })
    }

    private func invalidateRefreshTimer() {
        refreshTimer?.invalidate()
    }

    private func contributionsUrl() -> URL {
        let dateFormatter = DateFormatter()

        dateFormatter.dateFormat = "yyyy-MM-dd"

        let to = dateFormatter.string(from: Date())

        return URL(string: "https://github.com/users/\(username)/contributions?to=\(to)")!
    }

    private func showError() {
        DispatchQueue.main.async {
            self.statusItem?.button?.isHidden = true
        }
    }

    private func showContributions(count: String) {
        DispatchQueue.main.async {
            self.statusItem?.button?.title = count
            self.statusItem?.button?.isHidden = false
        }
    }
}
