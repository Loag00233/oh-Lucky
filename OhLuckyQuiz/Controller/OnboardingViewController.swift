//
//  OnboardingViewController.swift
//  OhLuckyQuiz
//

import UIKit

final class OnboardingViewController: UIViewController {

    private let onboardingView = OnboardingView()

    override func viewDidLoad() {
        super.viewDidLoad()
        view = onboardingView

        onboardingView.onFinishTapped = { [weak self] in self?.finish() }
        onboardingView.onSkipTapped = { [weak self] in self?.finish() }
    }

    private func finish() {
        AppSettings.hasSeenOnboarding = true
        dismiss(animated: true)
    }
}
