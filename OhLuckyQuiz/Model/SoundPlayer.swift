//
//  SoundPlayer.swift
//  OhLuckyQuiz
//

import AVFoundation

/// Короткие звуки интерфейса. Если файла в бандле нет — метод молча ничего не делает:
/// звук здесь украшение, ронять из-за него игру незачем.
@MainActor
enum SoundPlayer {

    enum Sound: String {
        case correct, wrong, tick, gameover
    }

    private static var players: [Sound: AVAudioPlayer] = [:]

    /// Категория `.ambient`: игра глушится переключателем «без звука» и не обрывает чужой подкаст.
    /// `.playback`, который советуют туториалы, подкаст выключил бы.
    static func configureSession() {
        let session = AVAudioSession.sharedInstance()
        try? session.setCategory(.ambient, mode: .default)
        try? session.setActive(true)
    }

    static func play(_ sound: Sound) {
        guard AppSettings.soundEnabled, let player = player(for: sound) else { return }
        player.currentTime = 0
        player.play()
    }

    private static func player(for sound: Sound) -> AVAudioPlayer? {
        if let ready = players[sound] { return ready }

        guard let url = Bundle.main.url(forResource: sound.rawValue, withExtension: "wav"),
              let player = try? AVAudioPlayer(contentsOf: url) else { return nil }

        player.prepareToPlay()
        players[sound] = player
        return player
    }
}
