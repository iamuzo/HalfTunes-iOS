/// Copyright (c) 2019 Razeware LLC
/// 
/// Permission is hereby granted, free of charge, to any person obtaining a copy
/// of this software and associated documentation files (the "Software"), to deal
/// in the Software without restriction, including without limitation the rights
/// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
/// copies of the Software, and to permit persons to whom the Software is
/// furnished to do so, subject to the following conditions:
/// 
/// The above copyright notice and this permission notice shall be included in
/// all copies or substantial portions of the Software.
/// 
/// Notwithstanding the foregoing, you may not use, copy, modify, merge, publish,
/// distribute, sublicense, create a derivative work, and/or sell copies of the
/// Software in any work that is designed, intended, or marketed for pedagogical or
/// instructional purposes related to programming, coding, application development,
/// or information technology.  Permission for such use, copying, modification,
/// merger, publication, distribution, sublicensing, creation of derivative works,
/// or sale is expressly withheld.
/// 
/// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
/// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
/// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
/// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
/// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
/// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
/// THE SOFTWARE.

import UIKit

//
// MARK: - App Delegate
//
@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
  //
  // MARK: - Constants
  //
  let tintColor =  UIColor(red: 242/255, green: 71/255, blue: 63/255, alpha: 1)
  
  //
  // MARK: - Variables And Properties
  // TODO 17
  ///If a background task completes when the app
  /// isn’t running, the app will relaunch in the
  /// background. You’ll need to handle this event
  /// from your app delegate.
  var backgroundSessionCompletionHandler: (() -> Void)?

  var window: UIWindow?
  
  //
  // MARK: - Application Delegate
  //
  func application(_ application: UIApplication,
                   didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
    customizeAppearance()
    return true
  }
  
  // TODO 18
  ///Here, you save the provided completionHandler as a variable in your app delegate for later use.
  ///application(_:handleEventsForBackgroundURLSession:) wakes up the app to deal with the
  ///completed background task. You’ll need to handle two items in this method:
  ///First, the app needs to recreate the appropriate background configuration and session using
  ///the identifier provided by this delegate method. But since this app creates the background session
  ///when it instantiates SearchViewController, you’re already reconnected at this point!
  ///Second, you’ll need to capture the completion handler provided by this delegate method. Invoking
  ///the completion handler tells the OS that your app’s done working with all background activities for
  ///the current session. It also causes the OS to snapshot your updated UI for display in the app switcher.
  func application(
    _ application: UIApplication,
    handleEventsForBackgroundURLSession
      handleEventsForBackgroundURLSessionidentifier: String,
    completionHandler: @escaping () -> Void) {
      backgroundSessionCompletionHandler = completionHandler
  }
  ///The place to invoke the provided completion handler is:
  ///urlSessionDidFinishEvents(forBackgroundURLSession:), which is a URLSessionDelegate method
  ///that fires when all tasks on the background session have finished.

  //
  // MARK - Private Methods
  //
  private func customizeAppearance() {
    window?.tintColor = tintColor
    
    UISearchBar.appearance().barTintColor = tintColor
    
    UINavigationBar.appearance().barTintColor = tintColor
    UINavigationBar.appearance().tintColor = UIColor.white
    
    let titleTextAttributes = [NSAttributedString.Key(rawValue: NSAttributedString.Key.foregroundColor.rawValue) : UIColor.white]
    UINavigationBar.appearance().titleTextAttributes = titleTextAttributes
  }
}
