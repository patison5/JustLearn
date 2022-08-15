//
//  HomeViewController.swift
//  JustLearn
//
//  Created by Fedor Penin on 15.08.2022.
//

import UIKit


extension HomeViewController {

    enum Section: CaseIterable {
        case all
    }

    struct TodoItem: Hashable {
        var title: String
    }
}

final class HomeViewController: UIViewController {

    var dataSource: UITableViewDiffableDataSource<Section, TodoItem>?

    let tableView: UITableView = {
        let view = UITableView()
        return view
    }()

    var items: [TodoItem] = [
        TodoItem(title: UUID().uuidString),
        TodoItem(title: UUID().uuidString),
        TodoItem(title: UUID().uuidString),
        TodoItem(title: UUID().uuidString),
        TodoItem(title: UUID().uuidString),
        TodoItem(title: UUID().uuidString),
    ]

    private let cellReuseIdentifier = "cell"

    override func viewDidLoad() {
        super.viewDidLoad()
        setupLayouts()
        setupConstraints()
        setupTable()

        tableView.delegate = self

        update(with: items)
    }
}

// MARK: - Private methods

private extension HomeViewController {

    func setupLayouts() {
        view.addSubview(tableView)
        tableView.translatesAutoresizingMaskIntoConstraints = false
    }

    func setupConstraints() {
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.topAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }

    func setupTable() {
        tableView.register(HomeTableViewCell.self, forCellReuseIdentifier: cellReuseIdentifier)
        createDataSource()
        tableView.dataSource = dataSource
    }

    func createDataSource() {
        dataSource = UITableViewDiffableDataSource<Section, TodoItem>(
            tableView: tableView,
            cellProvider: { tableView, indexPath, contact in
                let cell = tableView.dequeueReusableCell(withIdentifier: self.cellReuseIdentifier, for: indexPath)
                cell.textLabel?.text = contact.title
                cell.selectionStyle = .none
                cell.backgroundColor = .blue
                return cell
            }
        )
    }

    func update(with list: [TodoItem], animate: Bool = true) {
        var snapshot = NSDiffableDataSourceSnapshot<Section, TodoItem>()
        snapshot.appendSections(Section.allCases)
        snapshot.appendItems(list, toSection: .all)
        guard let dataSource = dataSource else { return }
        dataSource.apply(snapshot, animatingDifferences: animate)
    }

    func remove(contact: TodoItem, animate: Bool = true) {
        guard let dataSource = dataSource else { return }
        var snapshot = dataSource.snapshot()
        snapshot.deleteItems([contact])
        dataSource.apply(snapshot, animatingDifferences: animate)
    }
}

// MARK: - UITableViewDelegate

extension HomeViewController: UITableViewDelegate {

    // MARK: - Выползающие кнопки слева -
    func tableView(_ tableView: UITableView, leadingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        guard tableView.cellForRow(at: indexPath) is HomeTableViewCell else { return nil }

        let acceptButton = UIContextualAction(style: .normal, title: "", handler: { [weak self] (_: UIContextualAction, _: UIView, success: (Bool) -> Void) in
            guard let self = self else { return success(true) }
            self.items[indexPath.row].title = UUID().uuidString
            self.update(with: self.items)
            success(true)
        })
        acceptButton.title = "Save"
        acceptButton.backgroundColor = .green
        return UISwipeActionsConfiguration(actions: [acceptButton])
    }

    // MARK: - Выползающие кнопки справа -
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let deleteButton = UIContextualAction(style: .destructive, title: "", handler: { [weak self] (_: UIContextualAction, _: UIView, success: (Bool) -> Void) in
            guard let self = self else { return success(true) }
//            self.items.remove(at: indexPath.row)
            self.remove(contact: self.items[indexPath.row])
            success(true)
        })
        deleteButton.title = "delete"
        deleteButton.backgroundColor = .red
        return UISwipeActionsConfiguration(actions: [deleteButton])
    }
}
