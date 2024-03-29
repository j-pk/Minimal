//
//  FontViewController.swift
//  Minimal
//
//  Created by Jameson Kirby on 1/3/18.
//  Copyright © 2018 Parker Kirby. All rights reserved.
//

import UIKit

class FontViewController: UIViewController {
    @IBOutlet weak var tableView: UITableView!
    
    var themeManager = ThemeManager()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.tableFooterView = UIView(frame: .zero)

        navigationController?.navigationBar.topItem?.title = ""
        navigationItem.title = "Font"
        view.backgroundColor = themeManager.theme.primaryColor
    }
    
    func configure(cellForFont cell: LabelBaseCell, indexPath: IndexPath) {
        let fontForRow = FontSection.allCases[indexPath.row]
        cell.selectionImageButton.isHidden = fontForRow.rawValue != themeManager.font.rawValue
        cell.titleLabel.text = FontSection.allCases[indexPath.row].titleValue
        cell.titleLabel.defaultFont = FontType(rawValue: fontForRow.rawValue)?.font
    }
    
    func configure(cellForSize cell: LabelBaseCell, indexPath: IndexPath) {
        let sizeForRow = SizeSection.allCases[indexPath.row]
        cell.selectionImageButton.isHidden = sizeForRow.size != themeManager.fontSize.rawValue
        cell.titleLabel.text = SizeSection.allCases[indexPath.row].titleValue
        cell.titleLabel.font = themeManager.font(fontStyle: .primary)
    }
}

extension FontViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return FontTableViewSections(rawValue: section)?.titleValue
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return FontTableViewSections.allCases.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if FontTableViewSections(rawValue: section) == .font {
            return FontSection.allCases.count
        }
        return SizeSection.allCases.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 45
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "LabelBaseCell", for: indexPath) as! LabelBaseCell
        cell.setSeparatorInset(forInsetValue: .none)
        cell.selectionImage = .checkmark
        switch FontTableViewSections(indexPath: indexPath) {
        case .font?:
            configure(cellForFont: cell, indexPath: indexPath)
            return cell
        case .size?:
            configure(cellForSize: cell, indexPath: indexPath)
            return cell
        default:
            break
        }
        return cell
    }
}

extension FontViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.section == FontTableViewSections.font.rawValue {
            if let cell = self.tableView.cellForRow(at: indexPath) as? LabelBaseCell  {
                let fontType = FontType.allValues[indexPath.row]
                themeManager.font = fontType
                configureSelectedCell(cell: cell)
            }
        } else {
            if let cell = self.tableView.cellForRow(at: indexPath) as? LabelBaseCell  {
                let fontSize = SizeSection.allCases[indexPath.row]
                themeManager.fontSize = FontSize(rawValue: fontSize.size)!
                configureSelectedCell(cell: cell)
            }
        }
    }
    
    func configureSelectedCell(cell: LabelBaseCell) {
        reloadViews()
        view.layoutIfNeeded()
        cell.selectionImageButton.isHidden = false
        let deselectedCells = tableView.visibleCells.compactMap({ $0 as? LabelBaseCell }).filter({ $0 != cell }).filter({ self.tableView.indexPath(for: $0)?.section != FontTableViewSections.font.rawValue })
        deselectedCells.forEach({ $0.selectionImageButton.isHidden = true })
        self.tableView.reloadSections([0, 1], with: .none)
    }
}

private enum FontTableViewSections: Int, CaseIterable {
    case font
    case size
    
    init?(indexPath: IndexPath) {
        self.init(rawValue: indexPath.section)
    }
    
    var titleValue: String {
        switch self {
        case .font:
            return "Font"
        case .size:
            return "Size"
        }
    }
}

private enum FontSection: Int, CaseIterable {
    case avenir
    case sanFrancisco
    case georgia
    case helveticaNeue
    
    init?(indexPath: IndexPath) {
        self.init(rawValue: indexPath.row)
    }
    
    var titleValue: String {
        switch self {
        case .avenir:
            return "Avenir"
        case .sanFrancisco:
            return "San Francisco"
        case .georgia:
            return "Georgia"
        case .helveticaNeue:
            return "Helvetica Neue"
        }
    }
}

private enum SizeSection: Int, CaseIterable {
    case small
    case normal
    case large
    case huge
    case gigantic
    
    init?(indexPath: IndexPath) {
        self.init(rawValue: indexPath.row)
    }
    
    var titleValue: String {
        switch self {
        case .small:
            return "Small"
        case .normal:
            return "Normal"
        case .large:
            return "Large"
        case .huge:
            return "Huge"
        case .gigantic:
            return "Gigantic"
        }
    }
    
    var size: CGFloat {
        switch self {
        case .small: return FontSize.small.rawValue
        case .normal: return FontSize.normal.rawValue
        case .large: return FontSize.large.rawValue
        case .huge: return FontSize.huge.rawValue
        case .gigantic: return FontSize.gigantic.rawValue
        }
    }
}
