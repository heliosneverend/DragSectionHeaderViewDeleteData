//
//  ViewController.swift
//  通过侧滑组头删除整组的数据
//
//  Created by RRD on 2018/3/23.
//  Copyright © 2018年 RRD. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    
    var tableView:UITableView!
    var adHeaders:[String]!
    var allNames:[[String]]!
    
    override func loadView() {
        super.loadView()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        self.allNames =  [["UILabel 标签","UIButton 按钮"],
                          ["UIDatePiker 日期选择器","UITableView 表格视图"],
                          ["UICollectionView 网格"]]
        self.adHeaders = ["常见 UIKit 控件",
                          "中级 UIKit 控件",
                          "高级 UIKit 控件"]
        
        //
        self.tableView = UITableView(frame:self.view.frame, style:.grouped)
        self.tableView.delegate = self
        self.tableView.dataSource = self
        self.tableView.register(UITableViewCell.self, forCellReuseIdentifier: "SwiftCell")
        self.view.addSubview(self.tableView)

    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}

extension ViewController: UITableViewDelegate,UITableViewDataSource,UIGestureRecognizerDelegate,SwipeableSectionHeaderDelegateData {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return self.adHeaders.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let data = self.allNames[section]
        return data.count
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headerView = SwipeableSectionHeaderView()
        headerView.delegate = self
        headerView.titleLable.text = self.adHeaders[section]
        headerView.section = section
        
        //设置手势优先级
        if let gestureRecongnizers = tableView.gestureRecognizers {
            for recognizer in gestureRecongnizers {
                recognizer.require(toFail: headerView.swipeLeft)
            }
        }
        return headerView
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 40.0
    }
    
    func tableView(_ tableView: UITableView, titleForFooterInSection section: Int) -> String? {
        let data = self.allNames[section]
        return "有\(data.count)控件"
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        //为了提供表格显示性能，已创建完成的单元需重复使用
        let identify:String = "SwiftCell"
        //同一形式的单元格重复使用，在声明时已注册
        let cell = tableView.dequeueReusableCell(withIdentifier: identify,
                                                 for: indexPath)
        cell.accessoryType = .disclosureIndicator
        let secno = indexPath.section
        var data = self.allNames[secno]
        cell.textLabel?.text = data[indexPath.row]
        return cell
    }
    
    //删除整个分区
    func delegateSection(section: Int){
        self.adHeaders.remove(at: section)
        self.allNames.remove(at: section)
        self.tableView.reloadData()
    }
    //设置单元格的编辑样式
    func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCellEditingStyle {
        return UITableViewCellEditingStyle.delete
    }
    
    func tableView(_ tableView: UITableView, titleForDeleteConfirmationButtonForRowAt indexPath: IndexPath) -> String? {
        return "确认删除"
    }
    
    //单元格编辑后（删除或插入）的响应方法
    func tableView(_ tableView: UITableView,
                   commit editingStyle: UITableViewCellEditingStyle,
                   forRowAt indexPath: IndexPath) {
        self.allNames[indexPath.section].remove(at: indexPath.row)
        self.tableView.reloadData()
        print("你确认了删除按钮")
    }
}

protocol SwipeableSectionHeaderDelegateData {
    func delegateSection(section: Int)
}

class SwipeableSectionHeaderView: UIView {
    //组索引
    var section:Int = 0
    
    //放置文本标签和按钮的容器
    var container:UIView!
    var titleLable:UILabel!
    var delegateButton:UIButton!
    
    var delegate:SwipeableSectionHeaderDelegateData?
    
    //手势
    var swipeLeft:UISwipeGestureRecognizer!
    var swipeRight:UISwipeGestureRecognizer!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        self.backgroundColor = UIColor.black
        //初始化容器
        self.container = UIView()
        self.addSubview(container)
        
        //初始标题文本标签
        self.titleLable = UILabel()
        self.titleLable.textColor = UIColor.white
        self.titleLable.textAlignment = .center
        self.container.addSubview(self.titleLable)
        
        //初始化删除按钮
        self.delegateButton = UIButton()
        self.delegateButton.backgroundColor = UIColor(red: 0xfc/255, green: 0x21/255,
                                                      blue: 0x25/255, alpha: 1)
        self.delegateButton.setTitle("删除全部", for: .normal)
        self.delegateButton.titleLabel?.font = UIFont.systemFont(ofSize: 15.0)
        self.delegateButton.addTarget(self, action: #selector(buttonTapped(_:)), for: .touchUpInside)
        self.container.addSubview(self.delegateButton)
        
        self.swipeLeft = UISwipeGestureRecognizer(target:self, action:#selector(headerViewSwiped(_ :)))
        self.swipeLeft.direction = .left
        self.addGestureRecognizer(swipeLeft)
        
        self.swipeRight = UISwipeGestureRecognizer(target:self, action:#selector(headerViewSwiped(_:)))
        self.swipeRight.direction = .right
        self.addGestureRecognizer(swipeRight)
    }
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implementer")
    }
    
    //滑动响应
    @objc func headerViewSwiped(_ recognizer:UISwipeGestureRecognizer){
        if recognizer.state == .ended {
            var newFrame = self.container.frame
            //左滑显示 右滑隐藏
            if recognizer.direction == .left {
                newFrame.origin.x = -self.delegateButton.frame.width
            }else{
                newFrame.origin.x = 0
            }
            //动画
            UIView.animate(withDuration: 0.25, animations: {
                self.container.frame = newFrame
            })
        }
    }
    //删除按钮点击
    @objc func buttonTapped(_ button:UIButton){
        delegate?.delegateSection(section: section)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        self.container.frame = CGRect(x:0, y:0, width:self.frame.width + 74, height:self.frame.height)
        self.titleLable.frame = CGRect(x:0, y:0, width:self.frame.width, height:self.frame.height)
        self.delegateButton.frame = CGRect(x:self.frame.width, y:0, width:74, height:self.frame.height)
    }
}

