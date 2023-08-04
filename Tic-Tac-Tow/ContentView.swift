import SpriteKit
import SwiftUI

enum Block {
    case empty
    case home
    case visitor
}

struct ContentView: View {
    var body: some View {
        SpriteView(scene: TicTacToeScene(size: CGSize(width: 300, height: 300)))
            .frame(width: 300, height: 300)
    }
}

class TicTacToeScene: SKScene {
    var gameBoard: [[Block]] = [[.empty, .empty, .empty],
                                [.empty, .empty, .empty],
                                [.empty, .empty, .empty]]
    var currentPlayer: Block = .home
    var isGameEnded: Bool = false
    var blockNodes: [[SKSpriteNode]] = [] //here
    
    override func didMove(to view: SKView) {
        backgroundColor = .white
        createGameBoard()
    }
    
    func createGameBoard() {
        let blockSize: CGFloat = 100
        //let borderWidth: CGFloat = 2
        let boardSize: CGFloat = blockSize * CGFloat(gameBoard.count)

        let startX = (size.width - boardSize) / 2
        let startY = (size.height - boardSize) / 2

        for row in 0..<gameBoard.count {
            for column in 0..<gameBoard.count {
                let blockNode = SKSpriteNode(color: .gray, size: CGSize(width: blockSize, height: blockSize))
                blockNode.position = CGPoint(x: startX + CGFloat(column) * blockSize + blockSize / 2, y: startY + CGFloat(row) * blockSize + blockSize / 2)
                
                addChild(blockNode)
            }
        }
    }


    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }
        let touchLocation = touch.location(in: self)
        let touchedNode = atPoint(touchLocation)
        
        if !isGameEnded, let blockNode = touchedNode as? SKSpriteNode {
            let row = Int(blockNode.position.y / blockNode.size.height)
            let column = Int(blockNode.position.x / blockNode.size.width)
            
            if gameBoard[row][column] == .empty {
                gameBoard[row][column] = currentPlayer
                addSymbol(for: currentPlayer, at: CGPoint(x: blockNode.position.x, y: blockNode.position.y))
                
                if checkForWinner() {
                    highlightWinningPath()
                    let winnerText = (currentPlayer == .home) ? "X" : "O"
                    print("Player \(winnerText) wins!")
                    isGameEnded = true
                    DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                        self.resetGame()
                    }
                } else if isBoardFull() {
                    print("It's a tie!")
                    isGameEnded = true
                    DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                        self.resetGame()
                    }
                } else {
                    currentPlayer = (currentPlayer == .home) ? .visitor : .home
                }
            }
        }
    }
    
    func addSymbol(for player: Block, at position: CGPoint) {
        let symbolNode = SKLabelNode(text: (player == .home) ? "X" : "O")
        symbolNode.fontColor = .black
        symbolNode.fontSize = 80
        symbolNode.position = position
        addChild(symbolNode)
    }
    
    func checkForWinner() -> Bool {
        // checking for rows here
        for row in 0..<gameBoard.count {
            if gameBoard[row][0] != .empty &&
                gameBoard[row][0] == gameBoard[row][1] &&
                gameBoard[row][0] == gameBoard[row][2] {
                return true
            }
        }
        
        // checking for cols here
        for column in 0..<gameBoard.count {
            if gameBoard[0][column] != .empty &&
                gameBoard[0][column] == gameBoard[1][column] &&
                gameBoard[0][column] == gameBoard[2][column] {
                return true
            }
        }
        
        // checking for diagonals here
        if gameBoard[0][0] != .empty &&
            gameBoard[0][0] == gameBoard[1][1] &&
            gameBoard[0][0] == gameBoard[2][2] {
            return true
        }
        
        if gameBoard[0][2] != .empty &&
            gameBoard[0][2] == gameBoard[1][1] &&
            gameBoard[0][2] == gameBoard[2][0] {
            return true
        }
        
        return false
    }
    
    func isBoardFull() -> Bool {
        for row in 0..<gameBoard.count {
            for column in 0..<gameBoard.count {
                if gameBoard[row][column] == .empty {
                    return false
                }
            }
        }
        return true
    }
    
    func highlightWinningPath() {
        // Highlight rows
        for row in 0..<gameBoard.count {
            if gameBoard[row][0] != .empty &&
                gameBoard[row][0] == gameBoard[row][1] &&
                gameBoard[row][0] == gameBoard[row][2] {
                highlightBlock(at: (row, 0))
                highlightBlock(at: (row, 1))
                highlightBlock(at: (row, 2))
                return
            }
        }
        
        // Highlight columns
        for column in 0..<gameBoard.count {
            if gameBoard[0][column] != .empty &&
                gameBoard[0][column] == gameBoard[1][column] &&
                gameBoard[0][column] == gameBoard[2][column] {
                highlightBlock(at: (0, column))
                highlightBlock(at: (1, column))
                highlightBlock(at: (2, column))
                return
            }
        }
        
        // Highlight diagonals
        if gameBoard[0][0] != .empty &&
            gameBoard[0][0] == gameBoard[1][1] &&
            gameBoard[0][0] == gameBoard[2][2] {
            highlightBlock(at: (0, 0))
            highlightBlock(at: (1, 1))
            highlightBlock(at: (2, 2))
            return
        }
        
        if gameBoard[0][2] != .empty &&
            gameBoard[0][2] == gameBoard[1][1] &&
            gameBoard[0][2] == gameBoard[2][0] {
            highlightBlock(at: (0, 2))
            highlightBlock(at: (1, 1))
            highlightBlock(at: (2, 0))
            return
        }
    }
    
    func highlightBlock(at position: (row: Int, column: Int)) {
        let blockSize: CGFloat = 100
        let startX = (size.width - blockSize * CGFloat(gameBoard.count)) / 2
        let startY = (size.height - blockSize * CGFloat(gameBoard.count)) / 2
        
        let highlightNode = SKShapeNode(rect: CGRect(x: startX + CGFloat(position.column) * blockSize, y: startY + CGFloat(position.row) * blockSize, width: blockSize, height: blockSize), cornerRadius: 10)
        highlightNode.strokeColor = .black
        highlightNode.lineWidth = 5
        addChild(highlightNode)
    }
    func resetGame() {
        removeAllChildren()
        gameBoard = [[.empty, .empty, .empty],
                     [.empty, .empty, .empty],
                     [.empty, .empty, .empty]]
        currentPlayer = .home
        isGameEnded = false
        createGameBoard()
        print("Starting a new game")
    }
}


struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
