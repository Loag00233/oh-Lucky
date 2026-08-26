//
//  SettingsViewController.swift
//  OhLuckyQuiz
//

import UIKit

final class SettingsViewController: UIViewController {

    private let settingsView = SettingsView()

    override func viewDidLoad() {
        super.viewDidLoad()
        view = settingsView

        settingsView.onBackTapped = { [weak self] in
            self?.dismiss(animated: true)
        }

        settingsView.onLanguageSelected = { language in
            AppLanguage.select(language)
        }

        NotificationCenter.default.addObserver(self,
                                               selector: #selector(languageDidChange),
                                               name: .appLanguageDidChange,
                                               object: nil)
    }

    @objc private func languageDidChange() {
        settingsView.applyLocalization()
    }
}
