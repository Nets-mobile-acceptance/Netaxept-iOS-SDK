//
//  PaymentSelectionController.swift
//  PiaSample
//
//  Created by Luke on 18/07/2019.
//  Copyright © 2019 Luke. All rights reserved.
//

import UIKit

protocol PaymentSelectionControllerDelegate: AnyObject {
    var phoneNumber: String? { get }

    func fetchPaymentMethods(
        sender: PaymentSelectionController,
        success: ((PaymentMethodList) -> Void)?,
        failure: ((String) -> Void)?)

    func openTokenizedCardPayment(sender: PaymentSelectionController, card: TokenizedCard, cvcRequired: Bool)
    func openCardPayment(sender: PaymentSelectionController)
    func openApplePayment(sender: PaymentSelectionController, methodID: PaymentMethodID)
    func openPayPalPayment(sender: PaymentSelectionController, methodID: PaymentMethodID)
    func openVippsPayment(sender: PaymentSelectionController, methodID: PaymentMethodID, phoneNumber: PhoneNumber)
    func openSwishPayment(sender: PaymentSelectionController, methodID: PaymentMethodID)
}

class PaymentSelectionController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    weak var delegate: PaymentSelectionControllerDelegate!

    required init(delegate: PaymentSelectionControllerDelegate) {
        self.delegate = delegate
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        return nil
    }

    private enum MobileWallet: String, CaseIterable {
        case applePay = "ApplePay"
        case payPal = "PayPal"
        case vipps = "Vipps"
        case swish = "SwishM"
    }

    // MARK: Actions

    @objc private func fetchPaymentMethods() {
        if !refreshControl.isRefreshing { refreshControl.beginRefreshing() }
        delegate.fetchPaymentMethods(sender: self, success: updateUI(_:), failure: updateUI(withError:))
    }

    /// Initiate payment (with Pia) for selected payment method.
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        switch TableViewSection(rawValue: indexPath.section)! {
        case .tokenizedCards:
            let card: TokenizedCard = tokenizedCards[indexPath.row]
            delegate.openTokenizedCardPayment(sender: self, card: card, cvcRequired: cvcRequired)
        case .addNewCardButton:
            delegate.openCardPayment(sender: self)
        case .mobileWallets:
            didSelectMobileWallet(withID: mobileWallets[indexPath.row])
        }
    }

    private func didSelectMobileWallet(withID methodID: PaymentMethodID) {
        guard let mobileWallet = MobileWallet(rawValue: methodID.id) else {
            assertionFailure()
            return
        }
        switch mobileWallet {
        case .applePay:
            delegate.openApplePayment(sender: self, methodID: methodID)
        case .payPal:
            delegate.openPayPalPayment(sender: self, methodID: methodID)
        case .swish:
            delegate.openSwishPayment(sender: self, methodID: methodID)
        case .vipps:
            obtainPhoneNumber {
                self.delegate.openVippsPayment(sender: self, methodID: methodID, phoneNumber: $0)
            }
        }
    }

    // MARK: Views

    private lazy var tableView: UITableView = {
        let tableView = UITableView(frame: .zero, style: .grouped)
        tableView.register(CommonCell.self, forCellReuseIdentifier: CommonCell.className)
        tableView.rowHeight = max(view.bounds.height, view.bounds.width) / 10
        tableView.dataSource = self
        tableView.delegate = self
        tableView.addRefreshControl(refreshControl)
        return tableView
    }()

    private lazy var newCardCell: CardIconsCell = {
        let cell = CardIconsCell()
        cell.setAccessibility(label: "New card button", hint: "Pay with new card button")
        return cell
    }()

    private let refreshControl: UIRefreshControl = {
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(fetchPaymentMethods), for: .valueChanged)
        refreshControl.attributedTitle = NSAttributedString(string: .refreshFetchingPaymentMethods)
        return refreshControl
    }()

    // MARK: Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        title = .titlePaymentMethods
        view.addSubview(tableView)
        fetchPaymentMethods()
    }

    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        tableView.frame = view.bounds
        tableView.separatorInset = UIEdgeInsets(top: 0, left: 15, bottom: 0, right: 0)
    }

    // MARK: Datasources

    /// Is CVC required for tokenized cards. (single value used for the array of tokenized cards)
    private var cvcRequired: Bool = true
    private var tokenizedCards: [TokenizedCard] = []
    private var mobileWallets: [PaymentMethodID] = []

    // MARK: Update UI
    
    private func updateUI(_ paymentMethods: PaymentMethodList) {
        cvcRequired = paymentMethods.cardVerificationRequired ?? true
        tokenizedCards = (paymentMethods.tokens ?? []).sorted { $0.tokenId < $1.tokenId }

        let mixedPaymentTypes = (paymentMethods.methods ?? [])
            .filter { $0.id != PaymentMethodID.easyPay.id }
            .sorted { $0.id < $1.id }

        (mobileWallets, newCardCell.iconNames) = mixedPaymentTypes.reduce(([], [])) {
            var (paymentMethods, cards) = ($0.0, $0.1)
            let wallets = MobileWallet.allCases.map { $0.rawValue }
            wallets.contains($1.id) ? paymentMethods.append($1) : cards.append($1.id.lowercased())
            return (paymentMethods, cards)
        }

        tableView.performBatchUpdate {
            let newContent: [(section: TableViewSection, data: [Any])] = [
                (.tokenizedCards, tokenizedCards), (.mobileWallets, mobileWallets)
            ]
            newContent.forEach { new in
                let section = new.section.rawValue
                let oldCount = self.tableView.numberOfRows(inSection: section)
                guard oldCount <= new.data.count else {
                    let deletes = (new.data.count..<oldCount)
                        .map { IndexPath(row: $0, section: section) }
                    tableView.deleteRows(at: deletes, with: .automatic)
                    return
                }
                let inserts = (oldCount..<new.data.count)
                    .map { IndexPath(row: $0, section: section) }
                let reloads = (0..<oldCount)
                    .map { IndexPath(row: $0, section: section) }
                tableView.insertRows(at: inserts, with: .automatic)
                tableView.reloadRows(at: reloads, with: .automatic)
            }
        }

        refreshControl.endRefreshing()
    }

    private func updateUI(withError message: String) {
        if refreshControl.isRefreshing { refreshControl.endRefreshing() }
        let errorAlert = UIAlertController(title: .titleError, message: message, preferredStyle: .alert)
        errorAlert.addAction(UIAlertAction(title: .titleOk, style: .default, handler: nil))
        present(errorAlert, animated: true, completion: nil)
    }

    // MARK: UITableViewDataSource

    private enum TableViewSection: Int, CaseIterable {
        case tokenizedCards, addNewCardButton, mobileWallets
    }

    func numberOfSections(in tableView: UITableView) -> Int {
        return TableViewSection.allCases.count
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch TableViewSection(rawValue: section)! {
        case .tokenizedCards: return tokenizedCards.count
        case .addNewCardButton: return [newCardCell].count
        case .mobileWallets: return mobileWallets.count
        }
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cellValues: (image: UIImage?, title: String?)
        let accessibilityLabel: String
        let section = TableViewSection(rawValue: indexPath.section)!
        switch section {
        case .addNewCardButton: return newCardCell
        case .tokenizedCards:
            let card = tokenizedCards[indexPath.row]
            cellValues = card.displayValues
            accessibilityLabel = card.displayValues.title
        case .mobileWallets:
            let walletID = mobileWallets[indexPath.row].id
            cellValues = (UIImage(named: walletID.lowercased()), "")
            accessibilityLabel = walletID
        }
        let cell = tableView.dequeueReusableCell(withIdentifier: CommonCell.className, for: indexPath)
        cell.imageView?.contentMode = .scaleAspectFit
        cell.imageView?.image = cellValues.image
        cell.textLabel?.text = cellValues.title
        cell.textLabel?.adjustsFontSizeToFitWidth = true
        cell.setNeedsDisplay()
        cell.setAccessibility(label: accessibilityLabel, hint: "")
        return cell
    }

    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        switch TableViewSection(rawValue: section)! {
        case .tokenizedCards: return tokenizedCards.isEmpty ? "" : .titleStoredCards
        case .addNewCardButton: return .titleAddCard
        case .mobileWallets: return .titleMobileWallets
        }
    }

    // MARK: Obtain Phone Number

    private func obtainPhoneNumber(success: @escaping (PhoneNumber) -> Void) {
        if let phoneNumber = delegate.phoneNumber {
            success(phoneNumber)
            return
        }
        let textEntry = TextEntry(title: .titleVippsRequiresPhoneNumber, message: nil, keyboardType: .phonePad)
        textEntry.callback = { phoneNumber in
            guard let phoneNumber = phoneNumber else { return }
            success(phoneNumber)
        }
        present(textEntry.alert, animated: true, completion: nil)
    }
}

// MARK: - Table View Cell Classes

/// Common cell class used to display tokenized-cards and mobile wallet payment methods.
private class CommonCell: TableCell {
    var imageViewMarginY: CGFloat = 10
            
    override func layoutSubviews() {
        super.layoutSubviews()
        guard let imageView = imageView else { return }
        let maxImageHeight = bounds.height - (imageViewMarginY * 2)
        if imageView.bounds.height > maxImageHeight {
            let aspect = maxImageHeight / imageView.bounds.height
            let width = aspect * imageView.bounds.width
            let x = imageView.frame.origin.x
            let y = imageView.frame.origin.y + imageViewMarginY
            imageView.frame = CGRect(x: x, y: y, width: width, height: maxImageHeight)
        }
        textLabel?.frame = {
            let margin: CGFloat = 10
            let x = imageView.frame.origin.x + imageView.bounds.width + margin
            let width = bounds.width - x - margin
            return CGRect(x: x, y: .zero, width: width, height: bounds.height)
        }()
    }
}

/// A cell that displays collection of card scheme logos.
private class CardIconsCell: TableCell {
    var iconNames: [String] = [] {
        didSet {
            containerHStack.arrangedSubviews.forEach { $0.removeFromSuperview() }
            iconNames.forEach {
                containerHStack.addArrangedSubview(UIImageView(
                    image: UIImage(named: $0) ?? TokenizedCard.blankCardIcon,
                    contentMode: .scaleAspectFit))
            }
        }
    }

    let containerHStack = UIStackView(axis: .horizontal, distribution: .fillEqually, spacing: CardIconsCell.marginX)
    static let marginX: CGFloat = 10

    override func didInit() {
        super.didInit()
        contentView.addSubview(containerHStack)
        NSLayoutConstraint.activate(
            containerHStack.fillCentered(in: contentView, marginX: CardIconsCell.marginX * 2),
            for: containerHStack)
    }
}

// MARK: - Card Issuer Icons

private extension TokenizedCard {
    /// Display values for stored card cell.
    var displayValues: (image: UIImage, title: String) {
        guard tokenId != "New Card" else {
            return (TokenizedCard.blankCardIcon, "New Card")
        }
        switch issuer {
        case .some(let scheme):
            let image = UIImage(named: "Background" + scheme) ?? TokenizedCard.blankCardIcon
            let title = "\(scheme) •••• \(tokenId.suffix(4))"
            return (image, title)
        case .none: return (TokenizedCard.blankCardIcon, "unknown")
        }
    }

    static let blankCardIcon = UIImage(named: "Card")!
}
