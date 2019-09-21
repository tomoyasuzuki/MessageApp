//
//  AudioController.swift
//  MessageApp
//
//  Created by 鈴木友也 on 2019/09/10.
//  Copyright © 2019 tomoya.suzuki. All rights reserved.
//
import AVFoundation
import MessageKit
import FirebaseStorage

enum AudioState {
    case playing
    case pause
    case stopped
}

final class AudioController: NSObject, AVAudioRecorderDelegate, AVAudioPlayerDelegate, MessagesDisplayDelegate {
    var audioPlayer: AVAudioPlayer?
    var audioRecorder: AVAudioRecorder?
    var state: AudioState = .stopped
    var progressTimer: Timer?
    var playingCell: AudioMessageCell?
    
    var messageCollectionView: MessagesCollectionView?
    
    init(messageCollectionView: MessagesCollectionView) {
        self.messageCollectionView = messageCollectionView
        super.init()
    }
    
    func configureAudioCell(_ cell: AudioMessageCell, message: MessageType) {
        if let audioPlayer = audioPlayer, let collectionView = messageCollectionView {
            playingCell = cell
            
            cell.progressView.progress = (audioPlayer.duration == 0) ? 0 : Float(audioPlayer.currentTime/audioPlayer.duration)
            cell.playButton.isSelected = (audioPlayer.isPlaying == true) ? true : false
            guard let displayDelegate = collectionView.messagesDisplayDelegate else {
                fatalError("MessagesDisplayDelegate has not been set.")
            }
            
            cell.durationLabel.text = displayDelegate.audioProgressTextFormat(Float(audioPlayer.currentTime), for: cell, in: collectionView)
        }
    }
    
    
    func startRecordingAudio(url: URL) {
        let session = AVAudioSession.sharedInstance()
        let settings = [AVFormatIDKey: Int(kAudioFormatMPEG4AAC),
                        AVSampleRateKey: 44100,
                        AVNumberOfChannelsKey: 2,
                        AVEncoderAudioQualityKey: AVAudioQuality.high.rawValue]
        
        try! session.setCategory(AVAudioSession.Category.playAndRecord, mode: .default, options: .defaultToSpeaker)
        try! session.setActive(true, options: .notifyOthersOnDeactivation)
        
        audioRecorder = try! AVAudioRecorder(url: url, settings: settings)
        audioRecorder?.delegate = self
        audioRecorder?.record()
    }
    
    func stopRecordingAudio() {
        audioRecorder?.stop()
    }
    
    func playAudio(message: MessageType, cell: AudioMessageCell) {
        switch message.kind {
        case .audio(let item):
            
            let storageRef = Storage.storage().reference(forURL: item.url.absoluteString)
            
            storageRef.getData(maxSize: 1 * 1024 * 1024) { data, error in
                if let error = error {
                    print(error.localizedDescription)
                    print("fail get data")
                }
                
                guard let data = data else { return }
                guard let player = try? AVAudioPlayer(data: data) else { return }
                
                self.audioPlayer = player
                self.audioPlayer?.prepareToPlay()
                self.audioPlayer?.play()
                self.state = .playing
                
                cell.playButton.isSelected = true
                cell.delegate?.didStartAudio(in: cell)
            }
            
        default:
            break
        }
    }
    
    func pauseAudio(message: MessageType, cell: AudioMessageCell) {
        audioPlayer?.pause()
        state = .pause
        
        progressTimer?.invalidate()
        
        cell.playButton.isSelected = false
        cell.delegate?.didPauseAudio(in: cell)
    }
    
    func resumeAudio(message: MessageType, cell: AudioMessageCell) {
        audioPlayer?.prepareToPlay()
        audioPlayer?.play()
        
        state = .playing
        startProgressTimer()
        cell.playButton.isSelected = true
        cell.delegate?.didStartAudio(in: cell)
    }
    
    func stopAudio() {
        guard let player = audioPlayer, let collectionView = messageCollectionView else { return } // If the audio player is nil then we don't need to go through the stopping logic
        player.stop()
        state = .stopped
        if let cell = playingCell {
            cell.progressView.progress = 0.0
            cell.playButton.isSelected = false
            guard let displayDelegate = collectionView.messagesDisplayDelegate else {
                fatalError("MessagesDisplayDelegate has not been set.")
            }
            cell.durationLabel.text = displayDelegate.audioProgressTextFormat(Float(player.duration), for: cell, in: collectionView)
            cell.delegate?.didStopAudio(in: cell)
        }
        
        progressTimer?.invalidate()
        progressTimer = nil
        audioPlayer = nil
        playingCell = nil
    }
    
    @objc func didFiredTimer(_ timer: Timer) {
        guard let audioPlayer = audioPlayer, let collectionView = messageCollectionView, let cell = playingCell else {
            return
        }
        
        if let playingCellIndexPath = collectionView.indexPath(for: cell) {
            let currentMessage = collectionView.messagesDataSource?.messageForItem(at: playingCellIndexPath, in: collectionView)
            
            if  currentMessage != nil {
                cell.progressView.progress = (audioPlayer.duration == 0) ? 0 : Float(audioPlayer.currentTime/audioPlayer.duration)
                guard let displayDelegate = collectionView.messagesDisplayDelegate else {
                    fatalError("MessagesDisplayDelegate has not been set.")
                }
                cell.durationLabel.text = displayDelegate.audioProgressTextFormat(Float(audioPlayer.currentTime), for: cell, in: collectionView)
            } else {
                stopAudio()
            }
        }
    }
}


extension AudioController {
    func startProgressTimer() {
        progressTimer?.invalidate()
        progressTimer = nil
        progressTimer = Timer(timeInterval: 0.1, target: self, selector: #selector(didFiredTimer), userInfo: nil, repeats: true)
    }
    
    func createLocalURL() -> URL {
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        let documentsDirectory = paths[0].appendingPathComponent(".m4a")
        return documentsDirectory
    }
}
