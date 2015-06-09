//
//  ImageFinderViewController.swift
//  Flick Finder
//
//  Created by Oleksandr Iaroshenko on 09.06.15.
//  Copyright (c) 2015 Oleksandr Iaroshenko. All rights reserved.
//

import UIKit

class ImageFinderViewController: UIViewController {

    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var imageCaption: UILabel!

    @IBOutlet weak var textSearchField: UITextField!
    @IBOutlet weak var latitudeSearchField: UITextField!
    @IBOutlet weak var longitudeSearchField: UITextField!

    @IBAction func searchText(sender: UIButton) {
    }

    @IBAction func searchCoordinates(sender: UIButton) {
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}