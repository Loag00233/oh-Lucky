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

        settingsView.onSoundToggled = { AppSettings.soundEnabled = $0 }
        settingsView.onHapticsToggled = { AppSettings.hapticsEnabled = $0 }
        settingsView.onOfflineToggled = {AppSettings.playOfflineEnabled = $0 }

        settingsView.onPrivacyTapped = { UIApplication.shared.open(AppLinks.privacyPolicy) }
        settingsView.onSupportTapped = { UIApplication.shared.open(AppLinks.support) }
        settingsView.onTermsOfServiceTapped = { UIApplication.shared.open(AppLinks.termsOfService) }
        settingsView.onResetStatsTapped = { [weak self] in self?.confirmStatsReset() }

        settingsView.onHowToPlayTapped = { [weak self] in
            let vc = OnboardingViewController()
            vc.modalPresentationStyle = .fullScreen
            self?.present(vc, animated: true)
        }

        NotificationCenter.default.addObserver(self,
                                               selector: #selector(languageDidChange),
                                               name: .appLanguageDidChange,
                                               object: nil)
    }

    @objc private func languageDidChange() {
        settingsView.applyLocalization()
    }

    private func confirmStatsReset() {
        let alert = UIAlertController(title: nil,
                                      message: localized("Delete all results and achievements?"),
                                      preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: localized("Yes"), style: .destructive) { _ in
            StatsStore.reset()
            AchievementsStore.reset()
        })
        alert.addAction(UIAlertAction(title: localized("No"), style: .cancel) { _ in })
        present(alert, animated: true)
    }
}
