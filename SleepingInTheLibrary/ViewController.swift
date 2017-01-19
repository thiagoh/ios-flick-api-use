//
//  ViewController.swift
//  SleepingInTheLibrary
//
//  Created by Jarrod Parkes on 11/3/15.
//  Copyright © 2015 Udacity. All rights reserved.
//

import UIKit

// MARK: - ViewController: UIViewController

class ViewController: UIViewController {

  // MARK: Outlets

  @IBOutlet weak var photoImageView: UIImageView!
  @IBOutlet weak var photoTitleLabel: UILabel!
  @IBOutlet weak var grabImageButton: UIButton!

  // MARK: Actions

  @IBAction func grabNewImage(_ sender: AnyObject) {

    setUIEnabled(false);
    getImageFromFlickr();
  }

  // MARK: Configure UI

  private func setUIEnabled(_ enabled: Bool) {

    photoTitleLabel.isEnabled = enabled;
    grabImageButton.isEnabled = enabled;

    if enabled {
      grabImageButton.alpha = 1.0
    } else {
      grabImageButton.alpha = 0.5
    }
  }

  // MARK: Make Network Request

  private func getImageFromFlickr() {

    // "https://api.flickr.com/services/rest/?method=flickr.people.getPublicPhotos&api_key=7567ebb75878e35f8a44c7499bc59bea&user_id=47421888%40N07&extras=url_m&format=json&nojsoncallback=1&auth_token=72157675579705654-76ff3601afc87038&api_sig=debe668b2351000e6b0fc457aded8365"
    // let url = NSURL(string: "https://api.flickr.com/services/rest/?method=flickr.people.getPublicPhotos&api_key=7567ebb75878e35f8a44c7499bc59bea&user_id=47421888%40N07&extras=url_m&format=json&nojsoncallback=1&auth_token=72157675579705654-76ff3601afc87038&api_sig=debe668b2351000e6b0fc457aded8365");
    // let url = URL(string: "\(Constants.Flickr.APIBaseURL)?\(Constants.FlickrParameterKeys.Method)=\(Constants.FlickrParameterValues.GalleryPhotosMethod)&\(Constants.FlickrParameterKeys.APIKey)=\(Constants.FlickrParameterValues.APIKey)&\(Constants.FlickrParameterKeys.UserId)=\(Constants.FlickrParameterValues.UserId)&\(Constants.FlickrParameterKeys.Extras)=\(Constants.FlickrParameterValues.MediumURL)&\(Constants.FlickrParameterKeys.Format)=\(Constants.FlickrParameterValues.ResponseFormat)&\(Constants.FlickrParameterKeys.NoJSONCallback)=\(Constants.FlickrParameterValues.DisableJSONCallback)")!

    let methodParameters = [
      Constants.FlickrParameterKeys.Method: Constants.FlickrParameterValues.GalleryPhotosMethod,
      Constants.FlickrParameterKeys.APIKey: Constants.FlickrParameterValues.APIKey,
      Constants.FlickrParameterKeys.UserId: Constants.FlickrParameterValues.UserId,
      Constants.FlickrParameterKeys.Extras: Constants.FlickrParameterValues.MediumURL,
      Constants.FlickrParameterKeys.Format: Constants.FlickrParameterValues.ResponseFormat,
      Constants.FlickrParameterKeys.NoJSONCallback: Constants.FlickrParameterValues.DisableJSONCallback
    ];

    let urlString = Constants.Flickr.APIBaseURL + escapedParameters(methodParameters as [String: AnyObject]);
    let url = URL(string: urlString)!

    print(url);

    // if an error occurs, print it and re-enable the UI
    func displayErrorFunc(_ error: String) {
      print(error)
      print("URL at time of error: \(url)")
      performUIUpdatesOnMain {
        self.setUIEnabled(true)
      }
    }

    let request = URLRequest(url: url);
    let task = URLSession.shared.dataTask(with: request) { (data, response, error) in

      let displayError = displayErrorFunc;

      // no error, woohoo!
      if error == nil {

        // there was data returned
        if let data = data {

          let parsedResult: [String: AnyObject]!
          do {
            parsedResult = try JSONSerialization.jsonObject(with: data, options: .allowFragments) as! [String: AnyObject]
          } catch {
            displayError("Could not parse the data as JSON: '\(data)'")
            return
          }

          print(parsedResult)

          do {
            defer {
              performUIUpdatesOnMain {
                self.setUIEnabled(true);
              }
            }

            if let photosDictionary = parsedResult["photos"] as? [String: AnyObject] {

              print(object_getClass(photosDictionary), photosDictionary.count);

              if let photos = photosDictionary["photo"] as? [[String: AnyObject]] {

                let randomPhotoIndex = Int(arc4random_uniform(UInt32(photos.count)))
                let photo = photos[randomPhotoIndex];

                if let title = photo["title"] as? String,
                  let url_m = photo["url_m"] as? String {
                    print(title, url_m);

                    if let imageData = NSData(contentsOf: URL(string: url_m)!) {

                      performUIUpdatesOnMain {
                        self.photoImageView.image = UIImage(data: imageData as Data)
                        self.photoTitleLabel.text = title;
                      }
                    }
                }
              }
            }
          }
        }
      }
    }

    task.resume();
  }

  private func escapedParameters(_ parameters: [String: AnyObject]) -> String {

    if parameters.isEmpty {
      return "";

    } else {
      var keyValuePairs = [String]();

      for (key, value) in parameters {

        // make sure that it is a string value
        let stringValue = "\(value)";

        // escape it
        let escapedValue = stringValue.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed);

        // append it
        keyValuePairs.append(key + "=" + "\(escapedValue!)")

      }

      return "?\(keyValuePairs.joined(separator: "&"))"
    }
  }
}
