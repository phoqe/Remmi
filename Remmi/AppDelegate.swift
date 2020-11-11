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

    // TODO: Turn into setting.
    let username = "phoqe"

    // The minutes between each refresh. Default is 5.
    let refreshInterval = 5

    func applicationDidFinishLaunching(_ aNotification: Notification) {
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

        statusItem?.button?.action = #selector(onStatusItemButtonClick)
    }

    func destroyStatusItem() {
        statusItem = nil
    }

    @objc func onStatusItemButtonClick() {
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
