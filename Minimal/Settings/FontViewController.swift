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
        self.navigationController?.navigationBar.topItem?.title = ""
        self.navigationItem.title = "Font"
        tableView.tableFooterView = UIView(frame: .zero)
    }
    
    func configure(cellForFont cell: LabelBaseCell, indexPath: IndexPath) {
        let fontForRow = FontSection.allValues[indexPath.row]
        cell.selectionImageButton.isHidden = fontForRow.rawValue != themeManager.font.rawValue
        cell.titleLabel.text = FontSection.allValues[indexPath.row].titleValue
        cell.titleLabel.defaultFont = FontType(rawValue: fontForRow.rawValue)?.font
    }
    
    func configure(cellForSize cell: LabelBaseCell, indexPath: IndexPath) {
        let sizeForRow = SizeSection.allValues[indexPath.row]
        cell.selectionImageButton.isHidden = sizeForRow.size != themeManager.fontSize.rawValue
        cell.titleLabel.text = SizeSection.allValues[indexPath.row].titleValue
        cell.titleLabel.font = themeManager.font(fontStyle: .primary)
    }
}

extension FontViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return FontTableViewSections(rawValue: section)?.titleValue
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return FontTableViewSections.allValues.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if FontTableViewSections(rawValue: section) == .font {
            return FontSection.allValues.count
        }
        return SizeSection.allValues.count
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
                let fontSize = SizeSection.allValues[indexPath.row]
                themeManager.fontSize = FontSize(rawValue: fontSize.size)!
                configureSelectedCell(cell: cell)
            }
        }
    }
    
    func configureSelectedCell(cell: LabelBaseCell) {
        reloadViews()
        view.layoutIfNeeded()
        cell.selectionImageButton.isHidden = false
        let deselectedCells = tableView.visibleCells.flatMap({ $0 as? LabelBaseCell }).filter({ $0 != cell }).filter({ self.tableView.indexPath(for: $0)?.section != FontTableViewSections.font.rawValue })
        deselectedCells.forEach({ $0.selectionImageButton.isHidden = true })
        self.tableView.reloadSections([0, 1], with: .none)
    }
}

private enum FontTableViewSections: Int {
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
    
    static let allValues = [font, size]
}

private enum FontSection: Int {
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
    
    static let allValues = [avenir, sanFrancisco, georgia, helveticaNeue]
}

private enum SizeSection: Int {
    case small
    case normal
    case large
    case huge
    
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
        }
    }
    
    var size: CGFloat {
        switch self {
        case .small: return 12
        case .normal: return 14
        case .large: return 18
        case .huge: return 22
        }
    }
    
    static let allValues = [small, normal, large, huge]
}
