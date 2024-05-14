//
//  ContentView.swift
//  Calculator_App
//
//  Created by R95 on 14/05/24.
//

import SwiftUI

struct ContentView: View {
    
    let grid = [
        ["AC", "⌦", "%", "/"],
        ["7", "8", "9", "*"],
        ["4", "5", "6", "-"],
        ["1", "2", "3", "+"],
        [".", "0", "", "="]
    ]
    
    let operatorSymbols = ["/", "*", "-", "+", "%"]
    
    @State var visibleWorking = ""
    @State var visibleResult = ""
    @State var history: [String] = []
    @State var showAlert = false
    @State var showHistoryPage = false
    
    var body: some View {
        ZStack {
            VStack {
                Button(action: {
                    showHistoryPage.toggle()
                }) {
                    Text("History")
                        .foregroundColor(.white)
                        .font(.title2)
                        .bold()
                        .padding()
                }
                .padding(.leading, 250)
                .sheet(isPresented: $showHistoryPage) {
                    HistoryView(history: history)
                }
                
                Text(!visibleResult.isEmpty ? visibleWorking : visibleResult)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .foregroundColor(.white)
                    .font(.system(size: 50, weight: .heavy))
                
                Text(visibleResult.isEmpty ? visibleWorking : visibleResult)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .foregroundColor(.white)
                    .font(.system(size: 50, weight: .heavy))
                
                ForEach(grid, id: \.self) { row in
                    HStack {
                        ForEach(row, id: \.self) { cell in
                            Button(action: { buttonPressed(cell: cell) }) {
                                Text(cell)
                                    .foregroundColor(buttonColor(cell))
                                    .font(.system(size: 40, weight: .heavy))
                                    .frame(width: 90, height: 90)
                            }
                            .background(buttonBackgroundColor(cell))
                            .cornerRadius(60)
                        }
                    }
                }
            }
            .background(Color.black)
            .cornerRadius(50)
            .alert(isPresented: $showAlert) {
                Alert(
                    title: Text("Invalid Input"),
                    message: Text("Please enter a valid expression."),
                    dismissButton: .default(Text("OK"))
                )
            }
        }
        .padding()
        .background(Color.black)
    }
    
    func buttonColor(_ cell: String) -> Color {
        return Color.white
    }
    
    func buttonBackgroundColor(_ cell: String) -> Color {
        switch cell {
        case "AC", "⌦":
            return Color.gray.opacity(0.3) // Adjust opacity as needed
        case "/", "*", "-", "+", "%":
            return Color.orange
        default:
            return Color.gray
        }
    }
    
    func buttonPressed(cell: String) {
        switch cell {
        case "AC":
            visibleWorking = ""
            visibleResult = ""
        case "⌦":
            visibleWorking = String(visibleWorking.dropLast())
        case "=":
            visibleResult = calculatorResult()
            history.append("\(visibleWorking) = \(visibleResult)")
        case "/", "*", "%", "+", "-":
            addOperator(cell)
        default:
            visibleWorking += cell
        }
    }
    
    func addOperator(_ cell: String) {
        if visibleWorking.isEmpty {
            return
        }
        let lastCharacter = String(visibleWorking.last!)
        if operatorSymbols.contains(lastCharacter) {
            visibleWorking.removeLast()
        }
        visibleWorking += cell
    }
    
    func calculatorResult() -> String {
        if !validInput() {
            showAlert = true
            return ""
        }
        
        var working = visibleWorking.replacingOccurrences(of: "%", with: "*0.01")
        working = working.replacingOccurrences(of: "*", with: "*")
        
        let expression = NSExpression(format: working)
        if let result = expression.expressionValue(with: nil, context: nil) as? Double {
            return formatResult(value: result)
        } else {
            showAlert = true
            return ""
        }
    }
    
    func validInput() -> Bool {
        if visibleWorking.isEmpty {
            return false
        }
        let lastCharacter = String(visibleWorking.last!)
        if operatorSymbols.contains(lastCharacter) || lastCharacter == "-" {
            if lastCharacter != "%" || visibleWorking.count == 1 {
                return false
            }
        }
        return true
    }
    
    func formatResult(value: Double) -> String {
        if value.truncatingRemainder(dividingBy: 1) == 0 {
            return String(format: "%.0f", value)
        }
        return String(format: "%.2f", value)
    }
}

struct HistoryView: View {
    var history: [String]
    var body: some View {
        VStack {
            Text("History")
                .font(.title)
                .padding()
            
            List(history, id: \.self) { calculation in
                Text(calculation)
            }
            .padding(.horizontal)

            Spacer()
        }
    }
}

#Preview {
    ContentView()
}
