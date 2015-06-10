//
//  ImageFinderViewController.swift
//  Flick Finder
//
//  Created by Oleksandr Iaroshenko on 09.06.15.
//  Copyright (c) 2015 Oleksandr Iaroshenko. All rights reserved.
//

import UIKit

class ImageFinderViewController: UIViewController, UIGestureRecognizerDelegate {

    private struct Defaults {
        static let NoImagesFound = "No Images Found"

        static let KeyboardWillShowSelector: Selector = "keyboardWillShow:"
        static let KeyboardWillHideSelector: Selector = "keyboardWillHide:"
        static let OnTapSelector: Selector = "onTap:"
    }

    // MARK: - Actions and Outlets

    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var imageCaption: UILabel!

    @IBOutlet weak var textSearchField: UITextField!
    @IBOutlet weak var latitudeSearchField: UITextField!
    @IBOutlet weak var longitudeSearchField: UITextField!

    @IBAction func searchText(sender: UIButton) {
        let textToSearch = textSearchField.text
        FlickrAPI.searchPhotosByPhrase(textToSearch, completion: pickUpAndSetRandomPhoto)
    }

    @IBAction func searchCoordinates(sender: UIButton) {
        if let latitude = NSNumberFormatter().numberFromString(latitudeSearchField.text)?.doubleValue, longitude = NSNumberFormatter().numberFromString(longitudeSearchField.text)?.doubleValue {
            FlickrAPI.searchPhotosByCoordinates(latitude: latitude, longitude: longitude, completion: pickUpAndSetRandomPhoto)
        }
    }

    private func pickUpAndSetRandomPhoto(photos: [FlickrPhoto]) {
        if photos.count > 0 {
            let index = Int(arc4random_uniform(UInt32(photos.count)))
            loadAndSetPhoto(photos[index])
        } else {
            setPhoto(Defaults.NoImagesFound, image: nil)
        }
    }

    private func loadAndSetPhoto(photo: FlickrPhoto) {
        let qos = Int(QOS_CLASS_USER_INITIATED.value)
        let queue = dispatch_get_global_queue(qos, 0)
        dispatch_async(queue) {
            if let imageData = NSData(contentsOfURL: photo.url) {
                let image = UIImage(data: imageData)
                self.setPhoto(photo.title, image: image)
            }
        }
    }

    private func setPhoto(title: String, image: UIImage?) {
        dispatch_async(dispatch_get_main_queue()) {
            self.imageCaption.text = title
            self.imageView.image = image
        }
    }

    // MARK: - Fields

    var tapGestureRecognizer: UITapGestureRecognizer! {
        didSet {
            tapGestureRecognizer.delegate = self
        }
    }

    // MARK: - Keyboard-dependent layout

    func textFieldShouldReturn(textField: UITextField) -> Bool {
        return textField.resignFirstResponder()
    }

    func keyboardWillShow(notification: NSNotification) {
        self.view.frame.origin.y -= getKeyboardHeight(notification)
        addTapGestureRecognizer()
    }

    func keyboardWillHide(notification: NSNotification) {
        self.view.frame.origin.y += getKeyboardHeight(notification)
        removeTapGestureRecognizer()
    }

    func getKeyboardHeight(notification: NSNotification) -> CGFloat {
        let keyboardSize = notification.userInfo?[UIKeyboardFrameEndUserInfoKey] as? NSValue
        return keyboardSize?.CGRectValue().height ?? 0
    }

    func subscribeToKeyboardNotifications() {
        NSNotificationCenter.defaultCenter().addObserver(self, selector: Defaults.KeyboardWillShowSelector, name: UIKeyboardWillShowNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: Defaults.KeyboardWillHideSelector, name: UIKeyboardWillHideNotification, object: nil)
    }

    func unsubscribeFromKeyboardNotifications() {
        NSNotificationCenter.defaultCenter().removeObserver(self, name: UIKeyboardWillShowNotification, object: nil)
        NSNotificationCenter.defaultCenter().removeObserver(self, name: UIKeyboardWillHideNotification, object: nil)
    }

    func addTapGestureRecognizer() {
        self.view.addGestureRecognizer(tapGestureRecognizer)
    }

    func removeTapGestureRecognizer() {
        self.view.removeGestureRecognizer(tapGestureRecognizer)
    }

    func onTap(gesture: UITapGestureRecognizer) {
        self.view.endEditing(true)
    }

    // MARK: - Lifecycle Methods

    override func viewDidLoad() {
        super.viewDidLoad()

        tapGestureRecognizer = UITapGestureRecognizer(target: self, action: Defaults.OnTapSelector)
    }

    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)

        subscribeToKeyboardNotifications()
    }

    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)

        unsubscribeFromKeyboardNotifications()
    }
}