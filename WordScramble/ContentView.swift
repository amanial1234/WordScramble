//
//  ContentView.swift
//  WordScramble
//
//  Created by Aman Abraham on 8/28/25.
//

import SwiftUI

struct ContentView: View {
    @State private var usedWords = [String]()
    @State private var rootWord = ""
    @State private var newWord = ""
    
    @State private var errorTitle = ""
    @State private var errorMessage = ""
    @State private var showingError = false
    
    var body: some View {
        NavigationStack{
            List{
                Section{
                    TextField("Enter you word", text: $newWord)
                        .textInputAutocapitalization(.never)
                }
                Section{
                    ForEach(usedWords, id: \.self){ word in
                        HStack {
                            Image(systemName: "\(word.count).circle")
                            Text(word)
                        }
                    }
                }
            }
            .navigationTitle(rootWord)
            .onSubmit(addNewWord)
            .onAppear(perform: startGame)
            .alert(errorTitle, isPresented: $showingError){
                Button("OK"){ }
            } message: {
            Text(errorMessage)
            }
        }
    }
    
    private func addNewWord(){
        let answers = newWord.lowercased().trimmingCharacters(in: .whitespacesAndNewlines)
        guard answers.count > 0 else { return }
        
        guard isOriginal(word: answers) else {
            wordError(title: "Word is used already", message: "Be more original")
            return
        }
        
        guard isPossible(words: answers) else {
            wordError(title: "Word isn't possible", message: "you can't spell that word for \(rootWord)")
            return
        }
        
        guard isWordSpelledCorrectly(answers) else {
            wordError(title: "Word not recognized", message: "Don't make up words!")
            return
        }
        withAnimation{
            usedWords.insert(answers, at: 0)
        }
        
        newWord = ""
    }
    
    func startGame(){
        if let startWordsUrl = Bundle.main.url(forResource: "start", withExtension: "txt") {
            if let startWords = try? String(contentsOf: startWordsUrl) {
                let allWords = startWords.components(separatedBy: .newlines)
                rootWord = allWords.randomElement() ?? "silworm"
                return
            }
            
        }
        fatalError("Could not load file")
    }
    
    func isOriginal(word:String) -> Bool {
        !usedWords.contains(word)
    }
    
    func isPossible(words:String) -> Bool {
        var tempword = rootWord
        for letter in words {
            if let pos = tempword.firstIndex(of: letter) {
                tempword.remove(at: pos)
            } else {
                return false
            }
        }
        return true
        
    }
    
    func isWordSpelledCorrectly(_ word: String) -> Bool {
        let checker = UITextChecker()
        let range = NSRange(word.startIndex..<word.endIndex, in: word)
        let misspelledRange = checker.rangeOfMisspelledWord(
            in: word,
            range: range,
            startingAt: 0,
            wrap: false,
            language: "en"
        )
        return misspelledRange.location == NSNotFound
    }
    
    func wordError(title: String, message: String){
        errorTitle = title
        errorMessage = message
        showingError = true
    }

}

#Preview {
    ContentView()
}
