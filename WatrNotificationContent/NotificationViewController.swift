//
//  NotificationViewController.swift
//  WatrNotificationContent
//
//  Created by Vincent Todd on 6/16/26.
//

import UIKit
import UserNotifications
import UserNotificationsUI

class NotificationViewController: UIViewController, UNNotificationContentExtension {

    // MARK: - UI

    private let titleLabel: UILabel = {
        let l = UILabel()
        l.font = UIFont(name: "Unica77LL-Regular", size: 16) ?? .systemFont(ofSize: 16)
        l.textColor = .label
        l.numberOfLines = 0
        l.translatesAutoresizingMaskIntoConstraints = false
        return l
    }()

    private let bodyLabel: UILabel = {
        let l = UILabel()
        l.font = UIFont(name: "Unica77LL-Regular", size: 14) ?? .systemFont(ofSize: 14)
        l.textColor = .secondaryLabel
        l.numberOfLines = 0
        l.translatesAutoresizingMaskIntoConstraints = false
        return l
    }()

    private let doneButton: UIButton = {
        let b = UIButton(type: .system)
        b.setTitle("Done", for: .normal)
        b.titleLabel?.font = UIFont(name: "Unica77LL-Regular", size: 17) ?? .systemFont(ofSize: 17)
        b.backgroundColor = UIColor.systemBackground
        b.layer.cornerRadius = 14
        b.translatesAutoresizingMaskIntoConstraints = false
        return b
    }()

    private let snoozeButton: UIButton = {
        let b = UIButton(type: .system)
        b.setTitle("Remind Me Later", for: .normal)
        b.titleLabel?.font = UIFont(name: "Unica77LL-Regular", size: 17) ?? .systemFont(ofSize: 17)
        b.backgroundColor = UIColor.systemBackground
        b.layer.cornerRadius = 14
        b.translatesAutoresizingMaskIntoConstraints = false
        return b
    }()

    private let divider: UIView = {
        let v = UIView()
        v.backgroundColor = UIColor.separator
        v.translatesAutoresizingMaskIntoConstraints = false
        return v
    }()

    private let buttonDivider: UIView = {
        let v = UIView()
        v.backgroundColor = UIColor.separator
        v.translatesAutoresizingMaskIntoConstraints = false
        return v
    }()

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        setupLayout()

        doneButton.addTarget(self, action: #selector(doneTapped), for: .touchUpInside)
        snoozeButton.addTarget(self, action: #selector(snoozeTapped), for: .touchUpInside)
    }

    // MARK: - Layout

    private func setupLayout() {
        let textStack = UIStackView(arrangedSubviews: [titleLabel, bodyLabel])
        textStack.axis = .vertical
        textStack.spacing = 6
        textStack.translatesAutoresizingMaskIntoConstraints = false

        let buttonStack = UIStackView(arrangedSubviews: [doneButton, buttonDivider, snoozeButton])
        buttonStack.axis = .vertical
        buttonStack.spacing = 0
        buttonStack.translatesAutoresizingMaskIntoConstraints = false

        view.addSubview(textStack)
        view.addSubview(divider)
        view.addSubview(buttonStack)

        NSLayoutConstraint.activate([
            textStack.topAnchor.constraint(equalTo: view.topAnchor, constant: 16),
            textStack.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            textStack.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),

            divider.topAnchor.constraint(equalTo: textStack.bottomAnchor, constant: 16),
            divider.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            divider.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            divider.heightAnchor.constraint(equalToConstant: 0.5),

            buttonStack.topAnchor.constraint(equalTo: divider.bottomAnchor),
            buttonStack.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            buttonStack.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            buttonStack.bottomAnchor.constraint(equalTo: view.bottomAnchor),

            buttonDivider.heightAnchor.constraint(equalToConstant: 0.5),
            doneButton.heightAnchor.constraint(equalToConstant: 52),
            snoozeButton.heightAnchor.constraint(equalToConstant: 52),
        ])
    }

    // MARK: - UNNotificationContentExtension

    func didReceive(_ notification: UNNotification) {
        titleLabel.text = notification.request.content.title
        bodyLabel.text = notification.request.content.body
    }

    func didReceive(_ response: UNNotificationResponse,
                    completionHandler completion: @escaping (UNNotificationContentExtensionResponseOption) -> Void) {
        switch response.actionIdentifier {
        case "DONE":
            completion(.dismissAndForwardAction)
        case "SNOOZE":
            completion(.dismissAndForwardAction)
        default:
            completion(.dismiss)
        }
    }

    // MARK: - Actions

    @objc private func doneTapped() {
        extensionContext?.performNotificationDefaultAction()
    }

    @objc private func snoozeTapped() {
        extensionContext?.performNotificationDefaultAction()
    }
}
