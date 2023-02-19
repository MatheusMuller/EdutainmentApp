//
//  ContentView.swift
//  EdutainmentApp
//
//  Created by Matheus Müller on 14/02/23.
//

import SwiftUI

struct AnswersImage: View {
    var image: String
    
    var body: some View {
        Image(image)
            .renderingMode(.original)
            .scaleEffect(0.5)
            .frame(width: 80, height: 80)
    }
}

struct AnswerButton: ViewModifier {
    func body(content: Content) -> some View {
        content
            .frame(width: 300, height: 100, alignment: .center)
            .background(Color.gray)
            .clipShape(Capsule())
            .overlay(Capsule().stroke(Color.black, lineWidth: 1))
    }
}

extension View {
    func drawAnswerButton() -> some View {
        self.modifier(AnswerButton())
    }
}

struct GameLabel: ViewModifier {
    func body(content: Content) -> some View {
        content
            .padding()
            .background(Color.indigo)
            .clipShape(Capsule())
            .overlay(Capsule().stroke(Color.black, lineWidth: 2))
            .padding(.bottom, 10)
            .padding(.top, 50)
    }
}

extension View {
    func drawGameLabel() -> some View {
        self.modifier(GameLabel())
    }
}

struct StartToEndButton: ViewModifier {
    var whatColor: Bool
    
    func body(content: Content) -> some View {
        content
            .padding()
            .background(whatColor ? Color.mint : Color.green)
            .clipShape(Capsule())
            .overlay(Capsule().stroke(Color.black, lineWidth: 2))
            .font(.title)
            .padding(.top, 10)
            .foregroundColor(.black)
    }
}

extension View {
    func drawStartAndEndButton(whatColor: Bool) -> some View {
        self.modifier(StartToEndButton(whatColor: whatColor))
    }
}

struct GamePicker: ViewModifier {
    func body(content: Content) -> some View {
        content
            .pickerStyle(SegmentedPickerStyle())
            .colorMultiply(.red)
            .padding(.bottom, 50)
    }
}

extension View {
    func drawGamePicker() -> some View {
        self.modifier(GamePicker())
    }
}

struct FontText: ViewModifier {
    let font = Font.system(size: 22, weight: .heavy, design: .default)
    
    func body(content: Content) -> some View {
        content
            .font(font)
    }
}

extension View {
    func setFontText() -> some View {
        self.modifier(FontText())
    }
}

struct DrawHorizontalText: View {
    var text: String
    var textResult: String
    
    var body: some View {
        HStack {
            Text(text)
                .modifier(FontText())
                .foregroundColor(Color.green)
            
            Text(textResult)
                .modifier(FontText())
                .foregroundColor(Color.white)
        }
        .padding(.top, 10)
    }
}

struct ContentView: View {
    @State private var showGame = false
    @State private var countOfQuestions = "5"
    @State private var questions = ["5", "10", "15", "20"]
    @State private var score = 0
    @State private var multiplicationTable = 1
    @State private var arrayOfQuestions = [Question]()
    @State private var answerArray = [Question]()
    @State private var currentQuestion = 0
    @State private var remainingQuestions = 0
    @State private var selectedNumber = 0
    
    @State private var isCorrect = false
    @State private var isWrong = false
    
    @State private var isShowAlert = false
    @State private var alertTitle = ""
    @State private var buttonAlertTitle = ""
    
    @State private var winTheGame = false
    
    let tableToPractice = Range(1...12)
    
    //    let testArray = [Question(text: "2 * 2", answer: 4), Question(text: "5 * 5", answer: 25)]
    
    var body: some View {
        Group {
            ZStack {
                LinearGradient(colors: [Color(red: 0.5, green: 0.1, blue: 0.6), Color(red: 0.8, green: 0.1, blue: 0.2)], startPoint: .top, endPoint: .bottom)
                    .ignoresSafeArea()
                
                if showGame {
                    VStack {
                        Text("\(arrayOfQuestions[currentQuestion].text)")
                            .drawGameLabel()
                            .font(.largeTitle)
                        VStack {
                            ForEach(0..<4, id: \.self) { number in
                                HStack {
                                    Button(action: {
                                        self.checkAnswer(number)
                                    }) {
                                        Text("\(self.answerArray[number].answer)")
                                            .foregroundColor(.black)
                                            .font(.title)
                                            .padding(30)
                                            .background(Color.white)
                                            .clipShape(Circle())
                                    }
                                }
                            }
                        }
                        
                        Button(action: {
                            self.showGame = false
                        }) {
                            Text("End Game")
                                .drawStartAndEndButton(whatColor: showGame)
                        }
                        
                        VStack {
                            DrawHorizontalText(text: "Total Score: ", textResult: "\(score)")
                            DrawHorizontalText(text: "Questions Remaining", textResult: "\(remainingQuestions)")
                        }
                        
                        Spacer()
                    }
                } else {
                    VStack {
                        Text("Select the table to practice")
                            .drawGameLabel()
                        
                        Picker("", selection: $multiplicationTable) {
                            ForEach(tableToPractice, id: \.self) {
                                Text("\($0)")
                            }
                        }
                        .drawGamePicker()
                        
                        Text("How many questions you want to be asked?")
                            .drawGameLabel()
                        
                        Picker("", selection: $countOfQuestions) {
                            ForEach(questions, id: \.self) {
                                Text("\($0)")
                            }
                        }
                        .drawGamePicker()
                        
                        Button(action: {
                            self.newGame()
                        }) {
                            Text("Start Game")
                                .drawStartAndEndButton(whatColor: showGame)
                        }
                        Spacer()
                    }
                }
                
            }
        }
        .alert(isPresented: $isShowAlert) { () -> Alert in
            Alert(title: Text("\(alertTitle)"),
                  message: Text("Your score is: \(score)"),
                  dismissButton: .default(Text("\(buttonAlertTitle)")){
                if self.winTheGame {
                    self.newGame()
                    self.winTheGame = false
                    self.isCorrect = false
                } else if self.isCorrect {
                    self.isCorrect = false
                    self.newQuestion()
                } else {
                    self.winTheGame = false
                }
            })
        }
    }
    
    func newGame() {
        self.showGame = true
        self.currentQuestion = 0
        self.score = 0
        self.answerArray = []
        self.arrayOfQuestions = []
        self.createArrayOfQuestions()
        self.setCountOfQuestions()
        self.createAnswerArray()
    }
    
    func setCountOfQuestions() {
        guard let count = Int(self.countOfQuestions) else {
            remainingQuestions = arrayOfQuestions.count
            return
        }
        remainingQuestions = count
    }
    
    func createArrayOfQuestions() {
        for i in 1...multiplicationTable {
            for j in 1...12 {
                let newQuestion = Question(text: "How much is \(i) * \(j) ?", answer: i * j)
                arrayOfQuestions.append(newQuestion)
            }
        }
        self.arrayOfQuestions.shuffle()
        self.currentQuestion = 0
        self.answerArray = []
    }
    
    func createAnswerArray() {
        if currentQuestion + 4 < arrayOfQuestions.count {
            for i in currentQuestion ... currentQuestion + 3 {
                answerArray.append(arrayOfQuestions[i])
            }
        } else {
            for i in arrayOfQuestions.count - 4 ... arrayOfQuestions.count {
                answerArray.append(arrayOfQuestions[i])
            }
        }
        
        answerArray.shuffle()
    }
    
    func newQuestion() {
        self.currentQuestion += 1
        self.answerArray = []
        self.createAnswerArray()
    }
    
    func checkAnswer(_ number: Int) {
        self.selectedNumber = number
        if answerArray[number].answer == arrayOfQuestions[currentQuestion].answer {
            self.isCorrect = true
            self.remainingQuestions -= 1
            DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                if self.remainingQuestions == 0 {
                    self.alertTitle = "You Win!"
                    self.buttonAlertTitle = "Start new Game"
                    self.score += 1
                    self.winTheGame = true
                    self.isShowAlert = true
                } else {
                    self.score += 1
                    self.alertTitle = "Correct!"
                    self.buttonAlertTitle = "New Question"
                    self.isShowAlert = true
                }
            }
        } else {
            self.isWrong = true
            DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                self.alertTitle = "Wrong!"
                self.buttonAlertTitle = "Try Again"
                self.isShowAlert = true
            }
        }
    }
}

struct Question {
    var text: String
    var answer: Int
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
