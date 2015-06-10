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
        let textToSearch = textSearchField.text
        FlickrAPI.searchPhotosByPhrase(textToSearch) { photos in
            let index = Int(arc4random_uniform(UInt32(photos.count)))
            self.setPhoto(photos[index])
        }
    }

    @IBAction func searchCoordinates(sender: UIButton) {
        if let latitude = NSNumberFormatter().numberFromString(latitudeSearchField.text)?.doubleValue, longitude = NSNumberFormatter().numberFromString(longitudeSearchField.text)?.doubleValue {
            
        }
    }

    private func setPhoto(photo: FlickrPhoto) {
        imageCaption.text = photo.title

        let qos = Int(QOS_CLASS_USER_INITIATED.value)
        let queue = dispatch_get_global_queue(qos, 0)
        dispatch_async(queue) {
            if let imageData = NSData(contentsOfURL: photo.url) {
                dispatch_async(dispatch_get_main_queue()) {
                    self.imageView.image = UIImage(data: imageData)
                }
            }
        }
    }

    // MARK: - Lifecycle Methods

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