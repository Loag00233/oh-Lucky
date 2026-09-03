//
//  SourceInfoViewController.swift
//  OhLuckyQuiz
//

import UIKit

final class SourceInfoViewController: UIViewController {

    private let infoView = SourceInfoView()

    override func viewDidLoad() {
        super.viewDidLoad()
        view = infoView
        infoView.onCloseTapped = { [weak self] in self?.dismiss(animated: true) }
    }

    init() {
        super.init(nibName: nil, bundle: nil)
        modalPresentationStyle = .overFullScreen
        modalTransitionStyle = .crossDissolve
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
