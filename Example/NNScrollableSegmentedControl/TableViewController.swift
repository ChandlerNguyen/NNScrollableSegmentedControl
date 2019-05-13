//
//  TableViewController.swift
//  NNScrollableSegmentedControl_Example
//
//  Created by Nang Nguyen on 5/13/19.
//  Copyright © 2019 CocoaPods. All rights reserved.
//

import UIKit
import NNScrollableSegmentedControl

class TableViewController: UITableViewController {

    var selectedIndexPath = IndexPath(row: 0, section: 0)
    var selectedAttributesIndexPath = IndexPath(row: 0, section: 1)
    
    let largerRedTextAttributes = [NSAttributedString.Key.font: UIFont.systemFont(ofSize: 16),
                                   NSAttributedString.Key.foregroundColor: UIColor.red]
    let largerRedTextHighlightAttributes = [NSAttributedString.Key.font: UIFont.systemFont(ofSize: 16),
                                            NSAttributedString.Key.foregroundColor: UIColor.blue]
    let largerRedTextSelectAttributes = [NSAttributedString.Key.font: UIFont.systemFont(ofSize: 16),
                                         NSAttributedString.Key.foregroundColor: UIColor.orange]
    
    @IBOutlet weak var containerSegmntView: UIView!
    @IBOutlet weak var removeSegmentButton: UIBarButtonItem!
    @IBOutlet weak var fixedWidthSwitch: UISwitch!
    @IBOutlet weak var showUnderSwitch: UISwitch!
    
    lazy var segmentedControl: NNScrollableSegmentedControl = {
        let ctr = NNScrollableSegmentedControl(segments: [(title:"Segment 1", image: #imageLiteral(resourceName: "segment-1")),
                                                       (title: "S 2", image: #imageLiteral(resourceName: "segment-2")),
                                                       (title: "Long Text Segment 3", image: #imageLiteral(resourceName: "segment-3")),
                                                       (title: "Seg 4", image: #imageLiteral(resourceName: "segment-4")),
                                                       (title: "Segment 5", image: #imageLiteral(resourceName: "segment-5")),
                                                       (title: "Segment 6", image:nil),
                                                       (title: "Segment 7", image: #imageLiteral(resourceName: "segment-6"))])
        
        //let ctr = NNScrollableSegmentedControl(frame: .zero)
        ctr.translatesAutoresizingMaskIntoConstraints = false
        
        ctr.style = .textOnly
        //ctr.tintColor = UIColor.red
        //ctr.backgroundColor = .red
        //ctr.contentColor = .white
        ctr.selectedContentColor = .red
        ctr.selectedSegmentIndex = 0
        ctr.underlineSelected = true
        ctr.fixedWidth = true
        //ctr.insertSegment(withTitle: "Segment 7", at: 6)
        //ctr.addTarget(self, action: #selector(segmentSelected(sender:)), for: .valueChanged)
        
        ctr.valueChanged = { (selectedSegmentIndex) in
            print("Segment at index \(selectedSegmentIndex)  selected")
        }
        
        return ctr
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupViewHierarchy()
        setupConstraints()
        
//        segmentedControl.insertSegment(withTitle: "Segment 1", image: #imageLiteral(resourceName: "segment-1"), at: 0)
//        segmentedControl.insertSegment(withTitle: "S 2", image: #imageLiteral(resourceName: "segment-2"), at: 1)
//        segmentedControl.insertSegment(withTitle: "Segment 3.0001", image: #imageLiteral(resourceName: "segment-3"), at: 2)
//        segmentedControl.insertSegment(withTitle: "Seg 4", image: #imageLiteral(resourceName: "segment-4"), at: 3)
//        segmentedControl.insertSegment(withTitle: "Segment 5", image: #imageLiteral(resourceName: "segment-5"), at: 4)
//        segmentedControl.insertSegment(withTitle: "Segment 6", image: #imageLiteral(resourceName: "segment-6"), at: 5)
    }
    
    private func setupViewHierarchy() {
        containerSegmntView.addSubview(segmentedControl)
    }
    
    private func setupConstraints() {
        let constraints = [
            segmentedControl.leadingAnchor.constraint(equalTo: containerSegmntView.leadingAnchor),
            segmentedControl.trailingAnchor.constraint(equalTo: containerSegmntView.trailingAnchor),
            segmentedControl.topAnchor.constraint(equalTo: containerSegmntView.topAnchor),
            segmentedControl.bottomAnchor.constraint(equalTo: containerSegmntView.bottomAnchor)
        ]
        NSLayoutConstraint.activate(constraints)
    }

    // MARK: - Table view data source
    override func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if indexPath.section == 1 && indexPath.row == 1 {
            cell.textLabel!.attributedText = NSAttributedString(string: cell.textLabel!.text!, attributes: largerRedTextAttributes)
        }
    }
    

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.section == 0 {
            if let cell = tableView.cellForRow(at: selectedIndexPath) {
                cell.accessoryType = .none
            }
            selectedIndexPath = indexPath
            if let cell = tableView.cellForRow(at: selectedIndexPath) {
                cell.accessoryType = .checkmark
            }
            
            var height = 44
            switch indexPath.row {
            case 0:
                segmentedControl.style = .textOnly
            case 1:
                segmentedControl.style = .imageOnly
                height = 52
            case 2:
                segmentedControl.style = .imageOnTop
                height = 60
            case 3:
                segmentedControl.style = .imageOnLeft
            default: break
                
            }
            
            let headerView = tableView.tableHeaderView!
            tableView.tableHeaderView = nil
            var headerFrame = headerView.frame
            
            headerFrame.size.height =  CGFloat(height)
            headerView.frame = headerFrame
            tableView.tableHeaderView = headerView
        } else if indexPath.section == 1  {
            if let cell = tableView.cellForRow(at: selectedAttributesIndexPath) {
                cell.accessoryType = .none
            }
            selectedAttributesIndexPath = indexPath
            if let cell = tableView.cellForRow(at: selectedAttributesIndexPath) {
                cell.accessoryType = .checkmark
            }

            switch indexPath.row {
            case 0:
                segmentedControl.setAttributedTitle(nil, for: .normal)
                segmentedControl.setAttributedTitle(nil, for: .highlighted)
                segmentedControl.setAttributedTitle(nil, for: .selected)
            case 1:
                segmentedControl.setAttributedTitle(largerRedTextAttributes, for: .normal)
                segmentedControl.setAttributedTitle(largerRedTextHighlightAttributes, for: .highlighted)
                segmentedControl.setAttributedTitle(largerRedTextSelectAttributes, for: .selected)
            default: break

            }
        }
        
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    @IBAction func toggleFixedWidth(_ sender: UISwitch) {
        segmentedControl.fixedWidth = sender.isOn
    }
    
    @IBAction func toggleShowUnderline(_ sender: UISwitch) {
        segmentedControl.underlineSelected = sender.isOn
    }
    
    @IBAction func addSegment(_ sender: Any) {
        let index = segmentedControl.numberOfSegments
        segmentedControl.insertSegment(withTitle: "Segment \(index + 1)", image: #imageLiteral(resourceName: "segment-6"), at: index)
    }
    
    @IBAction func removeSegment(_ sender: Any) {
        if segmentedControl.numberOfSegments > 0 {
            segmentedControl.removeSegment(at: 0)
        }
    }
}
