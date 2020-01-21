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

import AVFoundation
import AVKit
import UIKit

//
// MARK: - Search View Controller
//
class SearchViewController: UIViewController {
  //
  // MARK: - Constants
  //
  
  /// Get local file path: download task stores tune here; AV player plays it.
  let documentsPath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
  
  let downloadService = DownloadService()
  let queryService = QueryService()
  
  //
  // MARK: - IBOutlets
  //
  @IBOutlet weak var tableView: UITableView!
  @IBOutlet weak var searchBar: UISearchBar!
  
  //
  // MARK: - Variables And Properties
  
  ///Note the lazy creation of downloadsSession;
  ///this lets you delay the creation of the session until after you initialize the view controller.
  ///Doing that allows you to pass self as the delegate parameter to the session initializer.
  lazy var downloadsSession: URLSession = {
    ///used default configuration before but changed to background
    ///in order to enable background downloads/transfers. Note that
    ///you also set a unique identifier for the session to allow your
    ///app to create a new background session, if needed.
    ///NOTE: you must not crerate more than one session for a background
    ///configuration because the system uses the configuration's identifier to
    ///associated tasks with the session
    let configuration = URLSessionConfiguration.background(withIdentifier: "guidedProjectHalfTunesByRayWenderlishDotCom")
    
    /// initialize a separate session with a default configuration
    /// specify a delegate which lets you receive `URLSession` events via delegate calls (useful for monitoring task progess)
    /// Setting the delegate queue to nil causes the session to create a serial operation queue to perform all calls to delegate methods and completion handlers.
    return URLSession(configuration: configuration, delegate: self, delegateQueue: nil)
  }()
  
  var searchResults: [Track] = []
  
  lazy var tapRecognizer: UITapGestureRecognizer = {
    var recognizer = UITapGestureRecognizer(target:self, action: #selector(dismissKeyboard))
    return recognizer
  }()
  
  //
  // MARK: - Internal Methods
  //
  @objc func dismissKeyboard() {
    searchBar.resignFirstResponder()
  }
  
  func localFilePath(for url: URL) -> URL {
    return documentsPath.appendingPathComponent(url.lastPathComponent)
  }
  
  func playDownload(_ track: Track) {
    let playerViewController = AVPlayerViewController()
    present(playerViewController, animated: true, completion: nil)
    
    let url = localFilePath(for: track.previewURL)
    let player = AVPlayer(url: url)
    playerViewController.player = player
    player.play()
  }
  
  func position(for bar: UIBarPositioning) -> UIBarPosition {
    return .topAttached
  }
  
  func reload(_ row: Int) {
    tableView.reloadRows(at: [IndexPath(row: row, section: 0)], with: .none)
  }
  
  //
  // MARK: - View Controller
  //
  override func viewDidLoad() {
    super.viewDidLoad()
    tableView.tableFooterView = UIView()
    downloadService.downloadsSession = downloadsSession
  }
  
}

//
// MARK: - Search Bar Delegate
//
extension SearchViewController: UISearchBarDelegate {
  func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
    dismissKeyboard()
    
    guard let searchText = searchBar.text, !searchText.isEmpty else {
      return
    }
    
    UIApplication.shared.isNetworkActivityIndicatorVisible = true
    
    queryService.getSearchResults(searchTerm: searchText) { [weak self] results, errorMessage in
      UIApplication.shared.isNetworkActivityIndicatorVisible = false
      
      if let results = results {
        self?.searchResults = results
        self?.tableView.reloadData()
        self?.tableView.setContentOffset(CGPoint.zero, animated: false)
      }
      
      if !errorMessage.isEmpty {
        print("Search error: " + errorMessage)
      }
    }
  }
  
  func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
    view.addGestureRecognizer(tapRecognizer)
  }
  
  func searchBarTextDidEndEditing(_ searchBar: UISearchBar) {
    view.removeGestureRecognizer(tapRecognizer)
  }
}

//
// MARK: - Table View Data Source
//
extension SearchViewController: UITableViewDataSource {
  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let cell: TrackCell = tableView.dequeueReusableCell(withIdentifier: TrackCell.identifier,
                                                        for: indexPath) as! TrackCell
    // Delegate cell button tap events to this view controller.
    cell.delegate = self
    
    let track = searchResults[indexPath.row]
    
    // TODO 13
    cell.configure(track: track, downloaded: track.downloaded, download: downloadService.activeDownloads[track.previewURL])
    
    return cell
  }
  
  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return searchResults.count
  }
}

//
// MARK: - Table View Delegate
//
extension SearchViewController: UITableViewDelegate {
  func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    //When user taps cell, play the local file, if it's downloaded.
    
    let track = searchResults[indexPath.row]
    
    if track.downloaded {
      playDownload(track)
    }
    
    tableView.deselectRow(at: indexPath, animated: true)
  }
  
  func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
    return 62.0
  }
}

//
// MARK: - Track Cell Delegate
//
extension SearchViewController: TrackCellDelegate {
  func cancelTapped(_ cell: TrackCell) {
    if let indexPath = tableView.indexPath(for: cell) {
      let track = searchResults[indexPath.row]
      downloadService.cancelDownload(track)
      reload(indexPath.row)
    }
  }
  
  func downloadTapped(_ cell: TrackCell) {
    if let indexPath = tableView.indexPath(for: cell) {
      let track = searchResults[indexPath.row]
      downloadService.startDownload(track)
      reload(indexPath.row)
    }
  }
  
  func pauseTapped(_ cell: TrackCell) {
    if let indexPath = tableView.indexPath(for: cell) {
      let track = searchResults[indexPath.row]
      downloadService.pauseDownload(track)
      reload(indexPath.row)
    }
  }
  
  func resumeTapped(_ cell: TrackCell) {
    if let indexPath = tableView.indexPath(for: cell) {
      let track = searchResults[indexPath.row]
      downloadService.resumeDownload(track)
      reload(indexPath.row)
    }
  }
}

// TODO 19
///The code below grabs the stored completion handler from the app delegate and
///invokes it on the main thread. You find the app delegate by getting the shared
///instance of UIApplication, which is accessible thanks to the UIKit import.
extension SearchViewController: URLSessionDelegate {
  func urlSessionDidFinishEvents(forBackgroundURLSession session: URLSession) {
    DispatchQueue.main.async {
      if let appDelegate = UIApplication.shared.delegate as? AppDelegate,
        let completionHandler = appDelegate.backgroundSessionCompletionHandler {
        appDelegate.backgroundSessionCompletionHandler = nil
        
        completionHandler()
      }
    }
  }
}



extension SearchViewController: URLSessionDownloadDelegate {
  
  ///the only non-optional `URLSessionDownloadDelegate`; is called when download finishes
  // when a download task completes, `urlSession(_:downloadTask:didFinishDownloadingTo:)`
  // provides a URL to the temporary file location. Your job is to move it to a permanent
  // location in your app’s sandbox container directory before you return from the method.
  func urlSession(_ session: URLSession,
                  downloadTask: URLSessionDownloadTask,
                  didFinishDownloadingTo location: URL) {
    
    guard let sourceURL = downloadTask.originalRequest?.url else {
      return
    }
    
    let download = downloadService.activeDownloads[sourceURL]
    downloadService.activeDownloads[sourceURL] = nil
    
    let destinationURL = localFilePath(for: sourceURL)
    print(destinationURL)
    
    let fileManager = FileManager.default
    try? fileManager.removeItem(at: destinationURL)
    
    do {
      try fileManager.copyItem(at: location, to: destinationURL)
      download?.track.downloaded = true
    } catch let error {
      print("Could not copy file to disk: \(error.localizedDescription)")
    }
    
    if let index = download?.track.index {
      DispatchQueue.main.async {
        [weak self] in
        self?.tableView.reloadRows(at: [IndexPath(row: index, section: 0)], with: .none)
      }
    }
  }
  
  func urlSession(_ session: URLSession,
                  downloadTask: URLSessionDownloadTask,
                  didWriteData bytesWritten: Int64,
                  totalBytesWritten: Int64,
                  totalBytesExpectedToWrite: Int64) {
    
    ///extract the URL of the provided downloadTask and use it to find the
    ///matching Download in your dictionary of active downloads.
    guard
      let url = downloadTask.originalRequest?.url,
      let download = downloadService.activeDownloads[url] else { return }
    
    /// detemine download progress . TrackCell will use this to update the progress view
    download.progress = Float(totalBytesWritten) / Float(totalBytesExpectedToWrite)
    
    ///ByteCountFormatter takes a byte value and generates a human-readable
    ///string showing the total download file size.
    ///You’ll use this string to show the size of the download alongside the percentage complete.
    let totalSize = ByteCountFormatter.string(fromByteCount: totalBytesExpectedToWrite, countStyle: .file)
    
    ///Finally, you find the cell responsible for displaying the Track and call the cell’s helper method to
    ///update its progress view and progress label with the values derived from the previous steps.
    ///This involves the UI, so you do it on the main queue.
    DispatchQueue.main.async {
      if let trackCell = self.tableView.cellForRow(at: IndexPath(row: download.track.index, section: 0)) as? TrackCell {
        trackCell.updateDisplay(progress: download.progress, totalSize: totalSize)
      }
    }
  }
  
}
