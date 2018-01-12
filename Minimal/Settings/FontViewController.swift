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
    }
}

extension FontViewController: UITableViewDataSource {
    private enum FontTableViewSections: Int {
        case font
        case size
        
        init?(indexPath: IndexPath) {
            self.init(rawValue: indexPath.section)
        }
        
        enum FontSection: Int {
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
        
        enum SizeSection: Int {
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
            
            static let allValues = [small, normal, large, huge]
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
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return FontTableViewSections.allValues[section].titleValue
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return FontTableViewSections.allValues.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if FontTableViewSections.allValues[section] == .font {
            return FontTableViewSections.FontSection.allValues.count
        }
        return FontTableViewSections.SizeSection.allValues.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "LabelBaseCell", for: indexPath) as! LabelBaseCell
        cell.setSeparatorInset(forInsetValue: .none)
        cell.selectionImage = .checkmark
        switch FontTableViewSections(indexPath: indexPath) {
        case .font?:
            let fontForRow = FontTableViewSections.FontSection.allValues[indexPath.row]
            cell.selectionImageButton.isHidden = fontForRow.rawValue != themeManager.font.rawValue
            cell.titleLabel.text = FontTableViewSections.FontSection.allValues[indexPath.row].titleValue
            cell.titleLabel.defaultFont = FontType(rawValue: fontForRow.rawValue)?.font
        case .size?:
            cell.titleLabel.text = FontTableViewSections.SizeSection.allValues[indexPath.row].titleValue
        default:
            break
        }
        return cell
    }
}

extension FontViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let cell = self.tableView.cellForRow(at: indexPath) as? LabelBaseCell {
            let fontType = FontType.allValues[indexPath.row]
            themeManager.font = fontType
            reloadViews()
            view.layoutIfNeeded()
            cell.selectionImageButton.isHidden = false
            let deselectedCells = tableView.visibleCells.flatMap({ $0 as? LabelBaseCell }).filter({ $0 != cell })
            deselectedCells.forEach({ $0.selectionImageButton.isHidden = true })
            self.tableView.reloadSections([0, 1], with: .none)
        }
    }
}
