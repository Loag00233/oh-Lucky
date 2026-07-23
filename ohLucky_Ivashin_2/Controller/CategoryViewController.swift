//
//  CategoryViewController.swift
//  ohLucky_Ivashin_2
//

import UIKit

class CategoryViewController: UIViewController {

    let categoryView = CategoryView()
    let categories = QuizCategory.allCases

    override func viewDidLoad() {
        super.viewDidLoad()
        self.view = categoryView
        categoryView.categoriesTableView.dataSource = self
        categoryView.categoriesTableView.delegate = self
        categoryView.onBackTapped = { [weak self] in
            self?.dismiss(animated: true)
        }
    }

    func startGame(with category: QuizCategory) {
        let vc = GameViewController(networkService: QuestionNetworkService(), category: category)
        vc.modalPresentationStyle = .fullScreen
        present(vc, animated: true)
    }
}

extension CategoryViewController: UITableViewDataSource, UITableViewDelegate {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        categories.count
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        UITableView.automaticDimension
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: CategoryCell.reusedID) as! CategoryCell
        cell.nameLabel.text = categories[indexPath.row].displayName
        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        startGame(with: categories[indexPath.row])
    }
}
