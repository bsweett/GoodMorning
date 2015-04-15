//
//  XMLParser.swift
//  GoodMorning
//
//  Created by Ben Sweett on 2015-02-18.
//  Copyright (c) 2015 Ben Sweett. All rights reserved.
//

import Foundation

class XMLParser: NSObject {
    
    func checkValidRSSChannel(xml: AEXMLDocument, type: RSSType, url: String) -> RSSFeed? {
        
        var title = xml.root["channel"]["title"].stringValue
        var link = xml.root["channel"]["link"].stringValue
        var lastBuild = xml.root["channel"]["lastBuildDate"].stringValue
        var description = xml.root["channel"]["description"].stringValue
        var language = xml.root["channel"]["language"].stringValue
        
        var activeDate: NSDate!
        if(lastBuild.rangeOfString("not found") == nil) {
            activeDate = NSDate().dateFromInternetDateTimeString(lastBuild, formatHint: .RFC822)
        } else {
            activeDate = NSDate()
        }
        
        var imageURL = xml.root["channel"]["image"]["url"].stringValue
        
        if title.rangeOfString("not found") != nil || link.rangeOfString("not found") != nil {
            return nil
        }
        
        if description.rangeOfString("not found") != nil {
            description = "unknown"
        }
        
        if language.rangeOfString("not found") != nil {
            language = "en"
        }
        
        var rss = RSSFeed(title: title, creation: NSDate(), lastActiveDate: activeDate, type: type, description: description, language: language, link: link, rssLink: url)
        
        if imageURL.rangeOfString("not found") != nil {
            rss.setLogoUrl("")
        } else {
            rss.setLogoUrl(imageURL)
        }
        
        return rss
    }
    
    func parseArticles(xml: AEXMLDocument) -> Dictionary<String, RSSArticle> {
        
        var articles: Dictionary<String, RSSArticle> = Dictionary<String, RSSArticle>()
        
        // Standard RSS 1.0/2.0
        if let items = xml.root["channel"]["item"].all {
            
            for article in items {
                var rssArticle: RSSArticle = RSSArticle()
                
                var title = article["title"].stringValue
                var link = article["link"].stringValue
                var descriptionRaw = article["description"].stringValue
                var nsRawDes: NSString = descriptionRaw
                
                if let catergories = article["category"].all {
                    for category in catergories {
                        
                        if let cat = category.value? {
                            rssArticle.addCategory(cat)
                        }
                    }
                }
                
                var pubString = article["pubDate"].stringValue
                var creator = article["dc:creator"].stringValue
                var mediaContent: AnyObject? = article["media:content"].attributes["url"]
                
                rssArticle.title = title
                rssArticle.link = link
                rssArticle.rawDescription = descriptionRaw
                rssArticle.pubdate = NSDate().dateFromInternetDateTimeString(pubString, formatHint: .RFC822)
                
                if creator.rangeOfString("not found") != nil {
                    rssArticle.creator = "Unknown"
                } else {
                    rssArticle.creator = creator
                }
                
                rssArticle.textDescription = nsRawDes.stringByConvertingHTMLToPlainText()
                
                if let media = mediaContent as? String {
                    if media.rangeOfString("not found") != nil {
                        //String().fromHtmlEncodedString(descriptionRaw) //getDescriptionTextFromHTML(descriptionRaw)
                        rssArticle.thumbnailURL = self.getThumbNailUrlFromRaw(descriptionRaw)
                    } else {
                        rssArticle.thumbnailURL = media
                    }
                } else {
                    rssArticle.thumbnailURL = self.getThumbNailUrlFromRaw(descriptionRaw)
                }
                
                articles[rssArticle.title] = rssArticle
                
                println(rssArticle.toString())
                println("")
            }
            
            // RSS 0.91/RDF
        } else if let items = xml.root["item"].all {
            
            for article in items {
                var rssArticle: RSSArticle = RSSArticle()
                
                var title = article["title"].stringValue
                var link = article["link"].stringValue
                var pubString = article["dc:date"].stringValue
                var creator = article["dc:creator"].stringValue
                var description = article["description"].stringValue
                var subject = article["dc:subject"].stringValue
                
                rssArticle.title = title
                rssArticle.link = link
                rssArticle.rawDescription = description
                
                var formatter = NSDateFormatter()
                formatter.dateFormat = "yyyy-mm-dd"
                
                rssArticle.addCategory(subject)
                rssArticle.pubdate = formatter.dateFromString(pubString)
                rssArticle.creator = creator
                rssArticle.textDescription = description
                
                articles[rssArticle.title] = rssArticle
            }
            
        }
        
        
        return articles
    }
    
    func getDescriptionTextFromHTML(html: String) -> String {
        let str = html.stringByReplacingOccurrencesOfString("<[^>]+>", withString: "", options: .RegularExpressionSearch, range: nil)
        return str
    }
    
    
    func getThumbNailUrlFromRaw(html: String) -> String {
        
        //let str = matchesForRegexInText("<img[^>]+src\\s*=\\s*['\"]([^'\"]+)['\"][^>]*>", text: html)
        
        var url: NSString? = ""
        var theScanner = NSScanner(string: html)
        // find start of IMG tag
        theScanner.scanUpToString("<img", intoString:nil)
        
        if (!theScanner.atEnd) {
            
            theScanner.scanUpToString("src", intoString: nil)
            var charset = NSCharacterSet(charactersInString: "\"'")
            theScanner.scanUpToCharactersFromSet(charset, intoString: nil)
            theScanner.scanCharactersFromSet(charset, intoString: nil)
            theScanner.scanUpToCharactersFromSet(charset, intoString: &url)
            // "url" now contains the URL of the img
            if (url != nil) {
                var result = String(url!)
                if(result.rangeOfString("http:", options: NSStringCompareOptions.allZeros) != nil || result.rangeOfString("https:", options: NSStringCompareOptions.allZeros) != nil ) {
                    return result
                } else {
                    return "http:" + result
                }
            } else {
                return ""
            }
        }
        
        return ""
    }
    
}
