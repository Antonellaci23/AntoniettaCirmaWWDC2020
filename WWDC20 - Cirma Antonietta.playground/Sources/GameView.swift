
import UIKit
import AVFoundation

public class GameView: UIViewController {
    var numberOfPairsOfCards: Int {
        return (cardButtons.count + 1) / 2
    }
    private lazy var game = MemoryGame(numbersCard: numberOfPairsOfCards)
    private var cardButtons = [UIButton]()
    private var titleLabel: UILabel!
    var attemptsLabel: UILabel!
    var background: UIImageView = UIImageView()
    var card: UIButton!
    var firstTimePressed: Bool = false
    var gameOverImageView = UIImageView()
    var gameOverLabel: UILabel!
    var gameOverView = UIImageView()
    var player: AVAudioPlayer? = AVAudioPlayer()
    var scoreLabel: UILabel!
    var scoreLabelView = UIImageView()
    var soundButton: UIButton!
    var soundImage: UIImage!
    var soundOn: Bool = false
    var soundOnOffButton: UIButton!
    var timerGame : Timer?
    var timerGameLabel: UILabel!
    var timerLabel: Timer?
    
    
    private(set) var flipCount = 0
    var totalTime = 0
    
    public  override func viewDidLoad() {
        super.viewDidLoad()
        title = "Memory Game"
    }
    
    public override func loadView (){
        super.loadView()
        view = UIView()
        view.backgroundColor = .clear
        startGame()
    }
    
    func startGame (){
        
        background = UIImageView()
        //        Choose background randomly
        background.image = UIImage(named: "image\(arc4random_uniform(3) + 1).png")
        self.background.frame = CGRect(x: 0, y: 0, width: 600, height: 600)
        view.addSubview(self.background)
        
        //        Title image
        let titleName = "title.png"
        let title = UIImage(named: titleName)
        let titleView = UIImageView(image: title!)
        uploadView(titleView, 50, -15, 500, 150, .clear, 0, 1)
        
        //        Create attempts label
        attemptsLabel = UILabel()
        updateLabel(35, "Attempts: 0", attemptsLabel, 350, 540, 200, 50,  #colorLiteral(red: 0.8404758573, green: 0.04288882762, blue: 0.3216581941, alpha: 1), 8)
        view.addSubview(attemptsLabel)
        
        //        Create timer Label
        timerGameLabel = UILabel()
        updateLabel(35, "00:00", timerGameLabel, 50, 540, 200, 50,  #colorLiteral(red: 0.8404758573, green: 0.04288882762, blue: 0.3216581941, alpha: 1), 8)
        view.addSubview(timerGameLabel)
        
        //        The label must be updated every second
        updateTimerLabel()
        
        //        Button Sound On and Sound Off
        let soundButton = UIButton(type: .roundedRect)
        updateButton(soundButton, 54, 8, .clear)
        soundImage = UIImage.init(named: "soundOn.png")
        soundButton.setImage(soundImage.withRenderingMode(.alwaysOriginal), for: .normal)
        
        //        Change image when button is tapped
        soundButton.addTarget(self, action: #selector(soundOnOff), for: .touchUpInside)
        soundButton.isUserInteractionEnabled = true
        view.addSubview(soundButton)
        //        Button constraint for not to change the dimension and disposition
        buttonConstraint(soundButton, 50, 50, 250, -250)
        
        //      Cards creation
        createCard()
    }
    
    let cardsView = UIView()
    
    func createCard() {
        
        cardsView.translatesAutoresizingMaskIntoConstraints = false
        cardsView.backgroundColor = .clear
        cardsView.layer.masksToBounds = true
        cardsView.layer.cornerRadius = 9
        view.addSubview(cardsView)
        
        buttonViewConstraint(cardsView, 400, 400, 0)
        
        //        Cards dimensions
        let width = 100
        let height = 100
        
        //         Create 16 buttons for Memory cards
        for row in 0..<4 {
            for column in 0..<4 {
                
                // Create a new button and give it a big font size
                let cards = UIButton(type: .roundedRect)
                cards.titleLabel?.font = UIFont.systemFont(ofSize: 54)
                cards.backgroundColor = #colorLiteral(red: 0.8879398704, green: 0.3058796525, blue: 0.459605217, alpha: 1)
                cards.layer.shadowOffset = CGSize(width: 0.0, height: 3.0)
                cards.layer.shadowOpacity = 0.75
                cards.layer.shadowRadius = 3
                cards.layer.masksToBounds = false
                cards.layer.cornerRadius = 8
                
                // Calculate the frame of this button using its column and row
                let frame = CGRect(x: column * width + 5 , y: row * height + 5, width: width - 10, height: height - 10)
                cards.frame = frame
                
                // Add it to the buttons view
                cardsView.addSubview(cards)
                cards.addTarget(self, action: #selector(touchCard), for: .touchUpInside)
                
                // And also to our cards array
                cardButtons.append(cards)
            }
        }
        //       Animation of cards entry
        UIViewPropertyAnimator.runningPropertyAnimator(withDuration: 1 , delay: 0, options: [], animations: {
            self.cardButtons.forEach {
                $0.transform = CGAffineTransform.identity.scaledBy(x: 0.1, y: 0.1)
            }
        }) { (position) in
            UIViewPropertyAnimator.runningPropertyAnimator(withDuration: 1, delay: 0, options: [], animations: {
                self.cardButtons.forEach {
                    $0.transform = CGAffineTransform.identity.scaledBy(x: 1, y: 1)
                }
            })
        }
        
        //        The sound starts two seconds after the game starts
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            self.playSound("sunnyDay", "mp3")
        }
    }
    
    //    Function to start the sound
    func playSound(_ nameSound :String, _ extention: String) {
        guard let url = Bundle.main.url(forResource: nameSound, withExtension: extention) else { return }
        
        do {
            try AVAudioSession.sharedInstance().setCategory(.playback, mode: .default)
            try AVAudioSession.sharedInstance().setActive(true)
            player = try AVAudioPlayer(contentsOf: url, fileTypeHint: AVFileType.mp3.rawValue)
            
            guard let player = player else { return }
            player.play()
        } catch let error {
            print(error.localizedDescription)
        }
        player?.numberOfLoops = 20
    }
    
    //    Change volume and image when sound button is tapped
    @objc func soundOnOff(_ sender: Any) {
        
        if let button = sender as? UIButton {
            button.isSelected = !button.isSelected
            if (button.isSelected)
            {
                player?.volume = 0
                soundImage = UIImage.init(named: "soundOff.png")
                button.setImage(soundImage.withRenderingMode(.alwaysOriginal), for: .normal)
                button.tintColor = UIColor.clear
            }
            else
            {
                player?.volume = 1
                soundImage = UIImage.init(named: "soundOn.png")
                button.setImage(soundImage.withRenderingMode(.alwaysOriginal), for: .normal)
            }
        }
    }
    
    // When the card is face up, change the background and add the emojis as the button title, if the cards are not the same, the background turns pink and the title returns empty
    func updateViewFromModel(){
        for index in cardButtons.indices {
            let cardState = cardButtons[index]
            let card = game.cards[index]
            if card.isFaceUp {
                cardState.setTitle(emoji(for: card), for: .normal)
                cardState.backgroundColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
                cardState.setImage(nil, for: .normal)
            } else {
                cardState.setTitle("", for: .normal)
                cardState.backgroundColor = card.isMatched ? .clear : #colorLiteral(red: 0.8879398704, green: 0.3058796525, blue: 0.459605217, alpha: 1)
            }
        }
        let attempts = flipCount/2
        attemptsLabel.text = "Attempts: \(attempts)"
    }
    
    var faceUpViews: [Card] {
        return game.cards.filter { $0.isFaceUp }
    }
    
    var emoji = [Card: String]()
    
    //    Choose emoji for cards randomly
    var emojiRandom = "🧚‍♀️🧞‍♀️🐱🐶🐹🦋🐟🌹🌸🌼☀️⭐️🌈🔥🦊🦁🍀🌳🍭🦄🐴🐙🌻🌙🏵🎡🐼🐯🦉🐝🍉🍎🍌🥑🚀🚁🐋🍡🍮🍫🍯☕️"
    
    func emoji(for card: Card) -> String {
        if emoji[card] == nil, emojiRandom.count > 0 {
            let randomIndex = Int.random(in: 0 ..< emojiRandom.count)
            let randomStringIndex = emojiRandom.index(emojiRandom.startIndex, offsetBy: randomIndex)
            emoji[card] = String(emojiRandom.remove(at: randomStringIndex))
        }
        return emoji[card] ?? ""
    }
    
    
    @objc func touchCard(_ sender: UIButton) {
        
        //    When the first card is touched, the timer starts
        if(firstTimePressed == false){
            timerGameStart()
            firstTimePressed = true
        }
        flipCount += 1
        
        if let cardNumber = cardButtons.firstIndex(of: sender) {
            game.chooseCard(at: cardNumber)
            
            //  Flip animation
            UIView.transition(with: sender, duration: 0.5, options: [.transitionFlipFromLeft], animations: {self.updateViewFromModel()}
            )
            
            //  Chack if game is over
            if game.matches == cardButtons.count {
                let identifier = game.cards[cardNumber].identifier
                for cardID in cardButtons.indices {
                    if game.cards[cardID].identifier == identifier{
                        game.cards[cardID].isFaceUp = false
                    }
                }
                game.cards[cardNumber].isFaceUp = false
                DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                    self.gameOver()
                }
            }
        }
    }
    
    //  Add game timer
    func timerGameStart() {
        self.totalTime = 0
        
        //  Timer Game
        self.timerGame = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(updatetimerGame), userInfo: nil, repeats: true)
        
        //  The timer label must be regenerated every second
        self.timerLabel = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(updateTimerLabel), userInfo: nil, repeats: true)
    }
    
    @objc func updatetimerGame() {
        if totalTime >= 0 {
            //  Increase counter timer
            totalTime += 1
        } else {
            if let timerGame = self.timerGame {
                timerGame.invalidate()
                self.timerGame = nil
            }
        }
    }
    
    //  Format timer
    @objc func updateTimerLabel() {
        let minutes = Int(self.totalTime) / 60 % 60
        let seconds = Int(self.totalTime) % 60
        self.timerGameLabel.text = String(format:"%02i:%02i", minutes, seconds)
    }
    
    //  Create fireworks effect
    func createFireWorks() {
        
        //        create game over fireworks
        let size = CGSize(width: 600, height: 600)
        let host = UIView(frame: CGRect(x: 0.0, y: 0.0, width: size.width, height: size.height))
        self.view.addSubview(host)
        
        let particlesLayer = CAEmitterLayer()
        particlesLayer.frame = CGRect(x: 0.0, y: 0.0, width: size.width, height: size.height)
        
        host.layer.addSublayer(particlesLayer)
        host.layer.masksToBounds = true
        
        particlesLayer.backgroundColor = UIColor(red: 0.0/255.0, green: 0.0/255.0, blue: 0.0/255.0, alpha: 0.0).cgColor
        particlesLayer.emitterShape = .point
        particlesLayer.emitterPosition = CGPoint(x: 374.7, y: 926.6)
        particlesLayer.emitterSize = CGSize(width: 600.0, height: 600.0)
        particlesLayer.emitterMode = .outline
        particlesLayer.renderMode = .additive
        
        let cell1 = CAEmitterCell()
        emitterCell(cell1, "Parent", 5, 2.5, 0, .infinity, 300, 100, 0, -100, -90.0 * (.pi / 180.0), 45.0 * (.pi / 180.0), 0, 0, 0, 0, 255/255, 255/255, 255/255, 1, 0.9, 0.9, 0.9)
        
        let image1_1 = UIImage(named: "Spark")?.cgImage
        let subcell1_1 = CAEmitterCell()
        subcell1_1.contents = image1_1
        emitterCell(subcell1_1, "Trail", 45, 0.5, 0.01, 1.7, 80, 100, 100, 350, -360.0 * (.pi / 180.0),  22.5 * (.pi / 180.0), 0, 0.5, 0.13, -0.7, 255/255, 255/255, 255/255, 1, 0, 0, 0)
        
        let image1_2 = UIImage(named: "Spark")?.cgImage
        
        let subcell1_2 = CAEmitterCell()
        subcell1_2.contents = image1_2
        
        emitterCell(subcell1_2, "Firework", 20000, 15, 1.6, 0.1, 190, 0, 0, 80, 0, 360.0 * (.pi / 180.0), 114.6 * (.pi / 180.0), 0.1, 0.09, -0.7, (255.0/255.0), (255.0/255.0), (255.0/255.0), 1, 0, 0, 0)
        
        cell1.emitterCells = [subcell1_1, subcell1_2]
        
        particlesLayer.emitterCells = [cell1]
    }
    
    func emitterCell (_ nameCell: CAEmitterCell, _ name: String, _ birthRate: CGFloat, _ lifetime: CGFloat, _ beginTime: CGFloat, _ duration: CGFloat, _ velocity: CGFloat, _ velocityRange: CGFloat, _ xAcceleration: CGFloat, _ yAcceleration: CGFloat, _ emissionLongitude: CGFloat, _ emissionRange: CGFloat, _ spin: CGFloat, _ scale: CGFloat, _ scaleSpeed: CGFloat, _ alphaSpeed: Float, _ red: CGFloat, _ green: CGFloat, _ blue: CGFloat, _ alpha: CGFloat, _ redRange: Float, _ greenRange: Float, _ blueRange: Float) {
        
        nameCell.name = name
        nameCell.birthRate = Float(birthRate)
        nameCell.lifetime = Float(lifetime)
        nameCell.beginTime = CFTimeInterval(beginTime)
        nameCell.duration = CFTimeInterval(duration)
        nameCell.velocity = CGFloat(velocity)
        nameCell.velocityRange = CGFloat(velocityRange)
        nameCell.xAcceleration = CGFloat(xAcceleration)
        nameCell.yAcceleration = CGFloat(yAcceleration)
        nameCell.emissionLongitude = CGFloat(emissionLongitude)
        nameCell.emissionRange = CGFloat(emissionRange)
        nameCell.spin = CGFloat(spin)
        nameCell.scale = CGFloat(scale)
        nameCell.scaleSpeed = CGFloat(scaleSpeed)
        nameCell.alphaSpeed = alphaSpeed
        nameCell.color = UIColor(red: red, green: green, blue: blue, alpha: alpha).cgColor
        nameCell.redRange = redRange
        nameCell.greenRange = greenRange
        nameCell.blueRange = blueRange
    }
    
    func gameOver() {
        
        //        Stop timer
        timerGame?.invalidate()
        
        //        Stop update timer label
        timerLabel?.invalidate()
        
        uploadView(gameOverView, 0, 0, 600, 600, #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1), 0, 0.7)
        createFireWorks()
        
        self.playSound("fireworks", "mp3")
        
        let GameOverImage = UIImage(named: "gameOver.png")
        gameOverImageView = UIImageView(image: GameOverImage!)
        uploadView(gameOverImageView, 50, 200, 500, 144, .clear, 0, 1)
        
        scoreLabel = UILabel()
        updateLabel(55, "Score: 0", scoreLabel, 50, 540, 500, 50, #colorLiteral(red: 0.8404758573, green: 0.04288882762, blue: 0.3216581941, alpha: 1), 8)
        view.addSubview(scoreLabel)
        
        //        Score rule
        let finalScore = (50 * game.matches) - totalTime - flipCount
        scoreLabel.text = "Score: \(finalScore)"
    }
    
    func updateLabel (_ size: Int, _ textLabel: String, _ nameLabel: UILabel, _ x: CGFloat, _ y: CGFloat, _ width: CGFloat, _ height: CGFloat, _ backgroundColor: UIColor, _ cornerRadius: CGFloat) {
        let attScore: [NSAttributedString.Key : Any] = [ .foregroundColor: #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)  , .font: UIFont.systemFont(ofSize: CGFloat(size)) ]
        let attScoreString = NSAttributedString(string: textLabel, attributes: attScore)
        nameLabel.frame = CGRect(x: x, y: y, width: width, height: height)
        nameLabel.translatesAutoresizingMaskIntoConstraints = true
        nameLabel.textAlignment = .center
        nameLabel.attributedText = attScoreString
        nameLabel.backgroundColor = backgroundColor
        nameLabel.layer.masksToBounds = true
        nameLabel.layer.cornerRadius = CGFloat(cornerRadius)
    }
    
    func uploadView (_ nameView: UIImageView, _ x: Int, _ y: Int, _ width: Int, _ height: Int, _ backgroundColor: UIColor, _ cornerRadius: Int, _ alpha: CGFloat) {
        nameView.frame = CGRect(x: x, y: y, width: width, height: height)
        nameView.backgroundColor = backgroundColor
        nameView.layer.cornerRadius = CGFloat(cornerRadius)
        nameView.alpha = alpha
        view.addSubview(nameView)
    }
    
    func updateButton(_ nameButton: UIButton, _ size: CGFloat, _ cornerRadius: CGFloat, _ backgroundColor: UIColor){
        nameButton.translatesAutoresizingMaskIntoConstraints = false
        nameButton.titleLabel?.font = UIFont.systemFont(ofSize: size)
        nameButton.layer.cornerRadius = cornerRadius
        nameButton.backgroundColor = backgroundColor
    }
    
    
    //    Constraints for to fix dimensions and position of buttons, labels and buttonview
    
    func buttonViewConstraint(_ nameView: UIView, _ widthAnchor: Int, _ heightAnchor: Int, _ constant:Int){
        NSLayoutConstraint.activate([
            nameView.widthAnchor.constraint(equalToConstant: CGFloat(widthAnchor)),
            nameView.heightAnchor.constraint(equalToConstant: CGFloat(heightAnchor)),
            nameView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            nameView.centerYAnchor.constraint(equalTo: view.centerYAnchor, constant: CGFloat(constant))
        ])
    }
    
    func buttonConstraint (_ button: UIButton, _ widthAnchor: Int , _ heightAnchor: Int, _ centerXAnchor: Int,_ centerYAnchor: Int){
        NSLayoutConstraint.activate([
            button.widthAnchor.constraint(equalToConstant: CGFloat(widthAnchor)),
            button.heightAnchor.constraint(equalToConstant: CGFloat(heightAnchor)),
            button.centerXAnchor.constraint(equalTo: view.centerXAnchor, constant: CGFloat(centerXAnchor)),
            button.centerYAnchor.constraint(equalTo: view.centerYAnchor, constant: CGFloat(centerYAnchor)),
        ])
    }
    
    func labelConstraint (_ label: UILabel, _ widthAnchor: Int , _ heightAnchor: Int, _ centerXAnchor: Int, _ centerYAnchor: Int, _ topAnchor: Int, _ leftAnchor: Int){
        NSLayoutConstraint.activate([
            label.widthAnchor.constraint(equalToConstant: CGFloat(widthAnchor)),
            label.heightAnchor.constraint(equalToConstant: CGFloat(heightAnchor)),
            label.centerXAnchor.constraint(equalTo: view.centerXAnchor, constant: CGFloat(centerXAnchor)),
            label.centerYAnchor.constraint(equalTo: view.centerYAnchor, constant: CGFloat(centerYAnchor)),
            label.topAnchor.constraint(equalTo: view.layoutMarginsGuide.topAnchor, constant: CGFloat(topAnchor)),
            label.leftAnchor.constraint(equalTo: view.layoutMarginsGuide.leftAnchor, constant: CGFloat(leftAnchor))
        ])
    }
}
