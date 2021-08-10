//
//  ViewController.swift
//  WeKnowItAll
//
//  Created by Nadia Ahmadian on 2021-08-06.
//

import UIKit
import SwifteriOS
import CoreML
import SwiftyJSON


class ViewController: UIViewController {
    @IBOutlet weak var sentimentLabel: UILabel!
    @IBOutlet weak var textField: UITextField!
    let tweetCount = 100
    let swifter = Swifter(consumerKey: "XMwpVBZBiat3W9WD42OacJrWE", consumerSecret: "Bzq5DewhZMr0AmAj0Fj1mWrcISMupTYZsE9IAjJwCzLGUi42Jq")
    let sentimentClassifier = TweetSentimentClassifier()
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    @IBAction func predictPressed(_ sender: UIButton) {
        fetchTweets()
        
    }
    func fetchTweets(){
        if let searchText = textField.text {
            swifter.searchTweet(using: searchText ,lang : "en" ,  count : tweetCount ,tweetMode:.extended , success:
                                    { (results, metadata ) in
                                        var tweets = [TweetSentimentClassifierInput]()
                                        //Using SwiftyJSON to parse
                                        for i in 0..<self.tweetCount{
                                            if let tweet = results[i]["full_text"].string{
                                                let tweetForClassification = TweetSentimentClassifierInput(text: tweet)
                                                tweets.append(tweetForClassification)
                                                //I want to give tweets to my classifier and get an array of the results for each tweet!
                                            }
                                        }
                                        self.makePrediction(with: tweets)
                                    })
            { error in
                print("There was an error with the Twitter API request!, \(error)")
            }
            
        }
        
    }
    func makePrediction(with tweets : [TweetSentimentClassifierInput]) {
        
        do{
            let predictions = try self.sentimentClassifier.predictions(inputs: tweets)
            //print(predictions[0].label)
            var sentimentScore = 0
            for prediction in predictions {
                let sentiment = prediction.label
                
                if sentiment == "Pos"{
                    sentimentScore += 1
                }
                else if sentiment == "Neg" {
                    sentimentScore -= 1
                }
                
                updateUI(with : sentimentScore)
            }
        }
        catch{
            print("There was an error with making a prediction, \(error)")
        }
        
        
    }
    func updateUI(with sentimentScore : Int ){
        
        if sentimentScore > 20{
            self.sentimentLabel.text = "😍"
        }
        else if sentimentScore > 10 {
            self.sentimentLabel.text = "😀"
        }
        else if sentimentScore > 0 {
            self.sentimentLabel.text = "🙂"
        }
        else if sentimentScore == 0 {
            self.sentimentLabel.text = "😐"
        }
        else if sentimentScore > -10 {
            self.sentimentLabel.text = "☹️"
        }
        else if sentimentScore > -20 {
            self.sentimentLabel.text = "🤬"
        }
        else {
            self.sentimentLabel.text = "🤮"
        }
        
    }
    
}

