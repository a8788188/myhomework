import UIKit

class ViewController: UIViewController {
    
    
    @IBOutlet weak var laRoundLeft: UILabel!
    @IBOutlet weak var laRoundRight: UILabel!
    @IBOutlet weak var laScoreLeft: UILabel!
    @IBOutlet weak var laScoreRight: UILabel!
    @IBOutlet weak var laServeLeft: UILabel!
    @IBOutlet weak var laServeRight: UILabel!
    @IBOutlet weak var laRewind: UILabel!
    @IBOutlet weak var laChangeSide: UILabel!
    @IBOutlet weak var laReset: UILabel!
    
    var backgroundColor = UIColor.systemBlue // 背景顏色
    var firstServe = 0 // 目前是誰的先發局 (1->左方, 2->右方)
    var serveState = 0 // 目前誰發球 (1->左方發球, 2->右方發球)
    var serveCount = 0 // 發球次數
    var scoreLeft = 0 // 左方選手 分數
    var scoreRight = 0 // 右方選手 分數
    var roundA = 0 // 左方選手 贏得局數
    var roundB = 0 // 右方選手 贏得局數
    var record = [Int]() // 紀錄 (1->左方, 2->右方)
    var playoff = false // 是否為延長賽
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        // 開啟互動功能
        laScoreLeft.isUserInteractionEnabled = true
        laScoreRight.isUserInteractionEnabled = true
        
        laChangeSide.isUserInteractionEnabled = true
        laRewind.isUserInteractionEnabled = true
        laReset.isUserInteractionEnabled = true
        
        // 點擊事件
        let clickScoreA = UITapGestureRecognizer.init(target: self, action: #selector(self.clickScoreLeft))
        let clickScoreB = UITapGestureRecognizer.init(target: self, action: #selector(self.clickScoreRight))
        
        let clickChangeSide = UITapGestureRecognizer.init(target: self, action: #selector(self.clickChangeSide))
        let clickRewind = UITapGestureRecognizer.init(target: self, action: #selector(self.clickRewind))
        let clickReset = UITapGestureRecognizer.init(target: self, action: #selector(self.clickReset))
        
        // 綁定動作
        laScoreLeft.addGestureRecognizer(clickScoreA)
        laScoreRight.addGestureRecognizer(clickScoreB)
        
        laChangeSide.addGestureRecognizer(clickChangeSide)
        laRewind.addGestureRecognizer(clickRewind)
        laReset.addGestureRecognizer(clickReset)
        
        Start();
    }
    

    func Start() {
        // 左方先發局
        firstServe = 1
        // 左方先發球
        serveState = 1
        
        update()
        
    }
    
    func update() {
        // 每兩輪更新一次發球狀態
        if serveState % 2 != 0 {
            laServeLeft.textColor = UIColor.orange
            laServeRight.textColor = backgroundColor
        }else {
            laServeLeft.textColor = backgroundColor
            laServeRight.textColor = UIColor.orange
        }
        // 取得最新分數
        laScoreLeft.text = String(scoreLeft)
        laScoreRight.text = String(scoreRight)
        // 取得局數比分
        laRoundLeft.text = String(roundA)
        laRoundRight.text = String(roundB)
    }
    
    // 新的一局
    func newRound() {
        // 清空延長賽狀態
        playoff = false
        // 清空儲存
        record.removeAll()
        // 清空計分
        scoreLeft = 0
        scoreRight = 0
        // 清空 發球次數
        serveCount = 0
        // 換人先發局
        if firstServe % 2 != 0 {
            // 換右方先發局
            firstServe = 2
            serveState = 2
        }else {
            // 換左方先發局
            firstServe = 1
            serveState = 1
        }
    }
    // 是否進入延長賽
    func isPlayoff() {
        if scoreLeft >= 10 && scoreRight >= 10 {
            playoff = true
        }else {
            playoff = false
        }
    }
    
    // 狀態判斷
    func stateJudgment() {
        // 是否進入延長賽
        isPlayoff()
        // 如果進入延長賽
        if playoff {
            // 每次都更換發球
            serveState = serveState + 1
        }else {
            // 非延長賽 兩輪換一次發球
            serveCount = serveCount + 1
            if serveCount >= 2 {
                serveCount = 0
                serveState = serveState + 1 // 換人發球
            }
        }
    }

    @objc func clickScoreLeft() {
        scoreLeft = scoreLeft + 1
        // 紀錄
        record.append(1)
        // 狀態判斷
        stateJudgment()
        // 檢查分數
        if playoff {
            // 如果是延長賽要贏兩分
            if scoreLeft - scoreRight == 2 {
                roundA = roundA + 1
                
                newRound()
            }
        }else {
            if scoreLeft >= 11 {
                roundA = roundA + 1
                
                newRound()
            }
        }
        update()
    }
    
    @objc func clickScoreRight() {
        scoreRight = scoreRight + 1
        // 紀錄
        record.append(2)
        // 狀態判斷
        stateJudgment()
        // 檢查分數
        if playoff {
            // 檢查有沒有多贏2分
            if scoreRight - scoreLeft == 2 {
                roundA = roundA + 1
                // 如果這局贏了 清空所有計分, 發球次數, 換人發球
                newRound()
            }
        }else {
            if scoreRight >= 11 {
                roundB = roundB + 1
                // 如果這局贏了 清空所有計分, 發球次數, 換人發球
                newRound()
            }
        }

        update()
    }
    
    @objc func clickChangeSide() {
        if backgroundColor == UIColor.systemBlue {
            backgroundColor = UIColor.systemGreen
        }else {
            backgroundColor = UIColor.systemBlue
        }
        self.view.backgroundColor  = backgroundColor

        update()
    }
    
    @objc func clickRewind() {
        //
        let rec =  record.last
        if rec == nil {
            return
        }
        // 是否進入延長賽
        isPlayoff()
        // 如果進入延長賽
        if playoff {
            // 還原狀態
            serveState = serveState - 1
        }else {
            // 還原狀態
            if serveCount == 0 {
                serveCount = 1
                serveState = serveState - 1
            }else {
                serveCount = serveCount - 1
            }
        }
        // 還原分數
        switch rec {
        case 1:
            scoreLeft = scoreLeft - 1
        case 2:
            scoreRight = scoreRight - 1
        default:
            break
        }
        record.removeLast()
        //
        update()
    }
    
    @objc func clickReset() {
        // 清空延長賽狀態
        playoff = false
        // 清空儲存
        record.removeAll()
        // 清空計分
        scoreLeft = 0
        scoreRight = 0
        // 清空 發球次數
        serveCount = 0
        // 是誰的先發局
        switch firstServe {
        case 1:
            serveState = 1
        case 2:
            serveState = 2
        default:
            break
        }
        //
        update()
    }
}

