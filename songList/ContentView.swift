//
// ContentView.swift
// welcome
//
// Created by 赵禹惟 on 2024/11/2
//

import SwiftUI
import AVFoundation
import UIKit

struct Song: Identifiable, Hashable {
    let id = UUID()
    let title: String
    let author: String
    let releaseDate: String
    let coverImage: String
    let audioName: String
}

struct ContentView: View {
    
    @State private var selectedSong: Song
    @State private var audioPlayer: AVAudioPlayer?
    // 可选类型：可以是AVAudioPlayer实例，也可以是nil没有任何值(阿拉伯语)
    @State private var currentTime: Double = 0.00
    @State private var timer: Timer?
    
    let songs = [
        Song(title: "告白气球", author: "周杰伦", releaseDate: "2016年", coverImage: "告白气球_img", audioName: "告白气球_audio"),
        Song(title: "过火", author: "张信哲", releaseDate: "1995年", coverImage: "过火_img", audioName: "过火_audio"),
        Song(title: "红豆", author: "王菲", releaseDate: "1998年", coverImage: "红豆_img", audioName: "红豆_audio")
    ]
    
    init() {
        _selectedSong = State(initialValue: songs[0]) //存储在 SwiftUI 中的 State 属性的底层表示
    }
    
    var body: some View {
        /* 绝对路径
        let audioPath = "/Users/stanley/Documents/COURSE/PROGRAMME/Swift/songList/songList/AudioSource/" + selectedSong.title + ".mp3"
         */
        
        // 相对路径
        let currentFileURL = URL(fileURLWithPath: #file)
        let projectDirectoryURL = currentFileURL.deletingLastPathComponent()
        let audioRelativeURL = projectDirectoryURL
            .appendingPathComponent("AudioSource")
            .appendingPathComponent("\(selectedSong.title)_audio.mp3")
        // 不实用apple music导出的m4p格式，是因为Apple Music下载的音乐通常是受 DRM（数字版权管理）保护的。这意味着这些音乐文件不能被直接访问、复制或在第三方应用程序中播放。
            
        let audioPath = audioRelativeURL.path
        
        NavigationStack {
            VStack {
//                Picker("请选择曲目", selection: $selectedSong) {
//                    // Picker: 选择器控件，让用户在多个选项中选择一个，支持列表样式、菜单样式等
//                    // $: 绑定，表示Picker会自动更新selectedSong的值
//                    ForEach(songs) { song in
//                        Text(song.title)
//                            .font(.headline)
//                            .tag(song)
//                    }
//                }
//                .pickerStyle(MenuPickerStyle()) // 下拉菜单
//                .padding()
                
                Image("\(selectedSong.coverImage)")
                    .resizable()
                    .aspectRatio(contentMode: .fit) // 保持图片的宽高比
                    .frame(maxWidth: .infinity) // 使图片在水平方向上撑满
                    .shadow(color: .gray, radius: 10, x: 0, y: 0)  // 阴影效果
                    .padding()
                
                Slider(value: $currentTime, in: 0...(audioPlayer?.duration ?? 1.0), onEditingChanged: { editing in
                    // Slider: 选择数值的控件，用于调整数值范围，如音量、亮度等
                    // value: $currentTime 滑块的值与 currentTime 保持同步
                    // in: 0...(...): 定义了滑块的数值范围，从 0 到 audioPlayer 的总时长
                    // onEditingChanged:  这是一个闭包（closure），当用户开始或结束编辑（拖动滑块）时会调用
                    if !editing { // 停止滑动时执行
                        if let player = audioPlayer {
                            player.currentTime = currentTime
                            player.play()
                        }
                    }
                })
                .padding()
                
                HStack {
                    Text(formatTime(time: currentTime))  // 当前播放时间
                    Spacer()
                    Text(formatTime(time: audioPlayer?.duration ?? 0.0))  // 总时长
                }
                .padding(.horizontal)
                .font(.system(size: 14))
                .foregroundColor(.gray)
                
                HStack {
                    Button("Play") {
                        if audioPlayer == nil || audioPlayer?.url?.lastPathComponent != "\(selectedSong.title)_audio.mp3" {
                            audioPlay(audioPath: audioPath)
                        }
                        audioPlayer?.play()
                        startTimer()
                    }
                    .padding()
                    .foregroundStyle(.tint)
                    .font(.system(size: 18))
                    
                    Button("Pause") {
                        audioPlayer?.pause()
                    }
                    .padding()
                    .foregroundStyle(.tint)
                    .font(.system(size: 18))
                }
                
                List {
                    HStack {
                        Text("曲目:")
                            .fontWeight(.bold)
                        Text(selectedSong.title)
                    }
                    .padding()
                    
                    HStack {
                        Text("作者:")
                            .fontWeight(.bold)
                        Text(selectedSong.author)
                    }
                    .padding()
                    
                    HStack {
                        Text("创曲时间:")
                            .fontWeight(.bold)
                        Text(selectedSong.releaseDate)
                    }
                    .padding()
                }
            }
            .navigationTitle(Text("歌曲栏目"))
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(action: {
                        navigateToPreviousSong()
                    }) {
                        VStack {
                            Image(systemName: "arrow.left.circle")
                            Text("Back")
                        }
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        navigateToNextSong()
                    }) {
                        VStack {
                            Image(systemName: "arrow.right.circle")
                            Text("Next")
                        }
                    }
                }
            }
        }
        .onDisappear() {
            stopTimer() // 当用户导航到其他页面或者关闭当前视图时，里面的代码将会执行
        }
    }
    
    private func audioPlay(audioPath: String) {
        if FileManager.default.fileExists(atPath: audioPath) {
            do {
                let url = URL(fileURLWithPath: audioPath)
                audioPlayer = try AVAudioPlayer(contentsOf: url)
                audioPlayer?.prepareToPlay()
                currentTime = 0.00  // 重置进度条
            } catch {
                print("Error loading audio file: \(error)")
            }
        } else {
            print("Audio file does not exist at path: \(audioPath)")
        }
    }
    
    private func formatTime(time: Double) -> String {
        let minutes = Int(time) / 60
        let seconds = Int(time) % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }
    
    private func navigateToPreviousSong() {
        if let currentIndex = songs.firstIndex(
            where: {
                $0.id == selectedSong.id
            }) {
            let previousIndex = (currentIndex - 1 + songs.count) % songs.count // 处理循环
            selectedSong = songs[previousIndex]
            audioPlayer?.pause()
            stopTimer()
            currentTime = 0.00
        }
    }
    
    private func navigateToNextSong() {
        if let currentIndex = songs.firstIndex(
            where: {
                $0.id == selectedSong.id
            }) {
            let nextIndex = (currentIndex + 1) % songs.count
            selectedSong = songs[nextIndex]
            audioPlayer?.pause()
            stopTimer()
            currentTime = 0.00
        }
    }
    
    private func startTimer() {
        stopTimer()
            
        timer = Timer.scheduledTimer(withTimeInterval: 0.50, repeats: true) { _ in
            if let player = self.audioPlayer {
                self.currentTime = player.currentTime
            }
        }
    }
        
    private func stopTimer() {
        timer?.invalidate()
        timer = nil
    }
}

#Preview {
    ContentView()
}

