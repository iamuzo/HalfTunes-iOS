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

import Foundation

//
// MARK: - Download Service
//

/// Downloads song snippets, and stores in local file.
/// Allows cancel, pause, resume download.
class DownloadService {
  //
  // MARK: - Variables And Properties
  var activeDownloads: [URL: Download] = [:]
  
  /// SearchViewController creates downloadsSession
  var downloadsSession: URLSession!
  
  //
  // MARK: - Internal Methods
  //
  ///To cancel a download, you’ll retrieve the download task from
  ///the corresponding Download in the dictionary of active downloads
  ///and call cancel() on it to cancel the task. You’ll then remove the
  ///download object from the dictionary of active downloads.
  func cancelDownload(_ track: Track) {
    guard let download = activeDownloads[track.previewURL] else {
      return
    }
    download.task?.cancel()
    activeDownloads[track.previewURL] = nil
  }
  
  // TODO 10
  ///The key difference here is that you call cancel(byProducingResumeData:)
  ///instead of cancel(). You provide a closure parameter to this method, which
  ///lets you save the resume data to the appropriate Download for future resumption.
  ///You also set the `isDownloading` property of the `Download` to `false`
  ///to indicate that the user has paused the download
  func pauseDownload(_ track: Track) {
    guard let download = activeDownloads[track.previewURL], download.isDownloading else {
      return
    }
    
    download.task?.cancel(byProducingResumeData: { data in
      download.resumeData = data
    })
    
    download.isDownloading = false
  }
  
  // TODO 11
  ///When the user resumes a download, you check the appropriate
  ///Download for the presence of resume data. If found, you’ll create
  ///a new download task by invoking downloadTask(withResumeData:)
  ///with the resume data. If the resume data is absent for any reason,
  ///you’ll create a new download task with the download URL. In either
  ///case, you’ll start the task by calling resume and set the isDownloading
  ///flag of the Download to true to indicate the download has resumed.
  func resumeDownload(_ track: Track) {
    guard let download = activeDownloads[track.previewURL] else {
      return
    }
    
    if let resumeData = download.resumeData {
      download.task = downloadsSession.downloadTask(withResumeData: resumeData)
    } else {
      download.task = downloadsSession.downloadTask(with: download.track.previewURL)
    }
    
    download.task?.resume()
    download.isDownloading = true
  }
  
  // TODO 8
  ///When the user taps a table view cell’s Download button,
  ///SearchViewController, acting as TrackCellDelegate, identifies the
  ///Track for this cell, then calls startDownload(_:) with that Track.
  func startDownload(_ track: Track) {
    let download = Download(track: track)
    download.task = downloadsSession.downloadTask(with: track.previewURL)
    download.task?.resume()
    download.isDownloading = true
    activeDownloads[download.track.previewURL] = download
  }
}
