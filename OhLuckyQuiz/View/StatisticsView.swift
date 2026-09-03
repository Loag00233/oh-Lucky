//
//  StatisticsView.swift
//  OhLuckyQuiz
//

import UIKit

/// Статистика и достижения — один экран: достижение это порог над той же цифрой,
/// что уже лежит в статистике. Разделы переключаются сегментами, данные общие.
final class StatisticsView: ScrollableCardsView {

    private enum Tab: Int { case statistics, achievements }

    override var backButtonIdentifier: String { "statistics.backButton" }

    private var stats = QuizStats()
    private var tab: Tab = .statistics

    private lazy var tabs: SegmentedTabs = {
        let control = SegmentedTabs(titles: [localized("Statistics"), localized("Achievements")],
                                    identifiers: ["statistics.tab.statistics", "statistics.tab.achievements"])
        control.onSelect = { [weak self] index in
            self?.tab = Tab(rawValue: index) ?? .statistics
            self?.rebuild()
        }
        return control
    }()

    func render(_ stats: QuizStats) {
        self.stats = stats
        rebuild()
    }

    private func rebuild() {
        resetContent()

        let title = label(localized("My Statistics"), size: 26, color: .white, align: .left)
        contentStack.addArrangedSubview(title)
        contentStack.setCustomSpacing(16, after: title)

        contentStack.addArrangedSubview(tabs)
        contentStack.setCustomSpacing(20, after: tabs)

        switch tab {
        case .statistics: appendStatistics()
        case .achievements: appendAchievements()
        }
    }

    // MARK: - Статистика

    private func appendStatistics() {
        let tilesRow = UIStackView(arrangedSubviews: [
            tile(number: "\(stats.gamesPlayed)", caption: localized("games played"), style: .yellow),
            tile(number: "\(stats.totalCorrect)", caption: localized("correct answers"), style: .yellow)
        ])
        tilesRow.axis = .horizontal
        tilesRow.spacing = 14
        tilesRow.distribution = .fillEqually
        contentStack.addArrangedSubview(tilesRow)

        let accuracyTile = tile(number: "\(stats.overallAccuracyPercent)%", caption: localized("accuracy"), style: .purple)
        contentStack.addArrangedSubview(accuracyTile)
        contentStack.setCustomSpacing(20, after: accuracyTile)

        contentStack.addArrangedSubview(summaryRow(title: localized("Total questions"), value: "\(stats.totalAnswered)"))
        contentStack.addArrangedSubview(summaryRow(title: localized("Total winnings"), value: stats.totalEarned.formattedScore))
        contentStack.addArrangedSubview(summaryRow(title: localized("Best win"), value: stats.bestWin.formattedScore))
        contentStack.addArrangedSubview(summaryRow(title: localized("Avg. win per game"), value: stats.averageWinPerGame.formattedScore))
        let lastSummary = summaryRow(title: localized("Avg. answer time"),
                                     value: localized("\(stats.averageAnswerSeconds) s"))
        contentStack.addArrangedSubview(lastSummary)
        contentStack.setCustomSpacing(24, after: lastSummary)

        let categoriesHeader = label(localized("By category"), size: 17, color: .white, align: .left)
        contentStack.addArrangedSubview(categoriesHeader)
        contentStack.setCustomSpacing(12, after: categoriesHeader)

        for category in QuizCategory.allCases {
            contentStack.addArrangedSubview(
                categoryRow(name: category.displayName, percent: stats.accuracyPercent(for: category))
            )
        }
    }

    private enum TileStyle { case yellow, purple }

    private func tile(number: String, caption: String, style: TileStyle) -> UIView {
        let card: UIView
        switch style {
        case .yellow:
            card = UIView()
            card.backgroundColor = .menuBtns
        case .purple:
            card = GradientView()
        }
        card.layer.cornerRadius = Radius.card
        card.layer.masksToBounds = true

        let numberColor: UIColor = style == .yellow ? .black : .white
        let captionColor: UIColor = style == .yellow ? .darkGray : UIColor(white: 1, alpha: 0.85)

        let numberLabel = label(number, size: 28, color: numberColor, align: .center)
        let captionLabel = label(caption, size: 12, color: captionColor, align: .center)

        let stack = UIStackView(arrangedSubviews: [numberLabel, captionLabel])
        stack.axis = .vertical
        stack.spacing = 6
        stack.alignment = .center
        pin(stack, in: card, insetsV: 20, insetsH: 14)
        return card
    }

    private func summaryRow(title: String, value: String) -> UIView {
        let card = UIView()
        card.backgroundColor = .white
        card.layer.cornerRadius = Radius.card

        let titleLabel = label(title, size: 14, color: .bgCol, align: .left)
        let valueLabel = label(value, size: 19, color: .bgCol, align: .right)
        valueLabel.setContentHuggingPriority(.required, for: .horizontal)

        let stack = UIStackView(arrangedSubviews: [titleLabel, valueLabel])
        stack.axis = .horizontal
        stack.alignment = .center
        pin(stack, in: card, insetsV: 16, insetsH: 20)
        return card
    }

    private func categoryRow(name: String, percent: Int) -> UIView {
        let card = UIView()
        card.backgroundColor = .white
        card.layer.cornerRadius = Radius.card

        let nameLabel = label(name, size: 13, color: .bgCol, align: .left)
        let percentLabel = label("\(percent)%", size: 13, color: .bgCol, align: .right)
        percentLabel.setContentHuggingPriority(.required, for: .horizontal)
        let header = UIStackView(arrangedSubviews: [nameLabel, percentLabel])
        header.axis = .horizontal
        header.alignment = .center

        let track = UIView()
        track.backgroundColor = .bank
        track.layer.cornerRadius = Radius.pill(8)
        track.translatesAutoresizingMaskIntoConstraints = false
        track.heightAnchor.constraint(equalToConstant: 8).isActive = true

        let fillWidth = CGFloat(max(0, min(percent, 100))) / 100.0
        if fillWidth > 0 {
            let fill = UIView()
            fill.backgroundColor = .menuBtns
            fill.layer.cornerRadius = Radius.pill(8)
            fill.translatesAutoresizingMaskIntoConstraints = false
            track.addSubview(fill)
            NSLayoutConstraint.activate([
                fill.leadingAnchor.constraint(equalTo: track.leadingAnchor),
                fill.topAnchor.constraint(equalTo: track.topAnchor),
                fill.bottomAnchor.constraint(equalTo: track.bottomAnchor),
                fill.widthAnchor.constraint(equalTo: track.widthAnchor, multiplier: fillWidth)
            ])
        }

        let stack = UIStackView(arrangedSubviews: [header, track])
        stack.axis = .vertical
        stack.spacing = 6
        pin(stack, in: card, insetsV: 12, insetsH: 16)
        return card
    }

    // MARK: - Достижения

    private func appendAchievements() {
        let unlocked = Achievement.allCases.filter { $0.isUnlocked(in: stats) }

        let counter = label(localized("\(unlocked.count) of \(Achievement.allCases.count)"),
                            size: 14, color: UIColor(white: 1, alpha: 0.7), align: .left)
        contentStack.addArrangedSubview(counter)
        contentStack.setCustomSpacing(16, after: counter)

        // заблокированные не прячем: без них непонятно, к чему стремиться
        Achievement.allCases.forEach { contentStack.addArrangedSubview(achievementCard($0)) }
    }

    private func achievementCard(_ achievement: Achievement) -> UIView {
        let progress = achievement.progress(in: stats)
        let isUnlocked = progress.current >= progress.goal

        let card = UIView()
        card.backgroundColor = .white
        card.layer.cornerRadius = Radius.card
        card.alpha = isUnlocked ? 1 : 0.55
        card.accessibilityIdentifier = "achievements.card.\(achievement.rawValue)"

        let iconView = UIImageView(image: UIImage(systemName: isUnlocked ? achievement.icon : "lock.fill"))
        iconView.tintColor = isUnlocked ? .exitBtnC : .darkGray
        iconView.contentMode = .scaleAspectFit
        iconView.translatesAutoresizingMaskIntoConstraints = false
        iconView.widthAnchor.constraint(equalToConstant: 28).isActive = true
        iconView.setContentHuggingPriority(.required, for: .horizontal)

        let titleLabel = label(achievement.title, size: 16, color: .bgCol, align: .left)
        let detailsLabel = label(achievement.details, size: 12, color: .darkGray, align: .left)

        let textStack = UIStackView(arrangedSubviews: [titleLabel, detailsLabel])
        textStack.axis = .vertical
        textStack.spacing = 2

        // у взятого достижения цифры уже ничего не сообщают — там галочка
        let statusText = isUnlocked ? "✓" : localized("\(progress.current) of \(progress.goal)")
        let statusLabel = label(statusText, size: 13, color: .bgCol, align: .right)
        statusLabel.setContentHuggingPriority(.required, for: .horizontal)

        let row = UIStackView(arrangedSubviews: [iconView, textStack, statusLabel])
        row.axis = .horizontal
        row.alignment = .center
        row.spacing = 14
        pin(row, in: card, insetsV: 14, insetsH: 18)

        return card
    }
}
