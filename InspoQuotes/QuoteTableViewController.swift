
import UIKit
import StoreKit

class QuoteTableViewController: UITableViewController, SKPaymentTransactionObserver {
    
    let productID = "com.londonappbrewery.InspoQuotes.PremiumQuotes"
    
    var quotesToShow = [
                "Наша величайшая слава не в том, чтобы никогда не падать, а в том, чтобы подниматься каждый раз, когда мы падаем. — Конфуций",
                "Все наши мечты могут сбыться, если у нас хватит смелости их осуществить. — Уолт Дисней",
                "Неважно, как медленно ты идешь, главное, чтобы ты не останавливался. — Конфуций",
                "Все, чего вы когда-либо хотели, находится по ту сторону страха. — Джордж Аддер",
                "Успех не окончателен, неудача не фатальна: главное — мужество продолжать. — Уинстон Черчилль",
                "Трудности часто готовят обычных людей к необычной судьбе. - К. С. Льюис"
    ]
    
    let premiumQuotes = [
                "Верьте в себя. Вы смелее, чем вы думаете, талантливее, чем вы думаете, и способны на большее, чем вы себе представляете. ― Рой Т. Беннетт",
                "Я узнал, что мужество — это не отсутствие страха, а победа над ним. Смелый человек — это не тот, кто не испытывает страха, а тот, кто побеждает этот страх. — Нельсон Мандела",
                "Есть только одна вещь, которая делает мечту невозможной: страх неудачи. ― Пауло Коэльо",
                "Дело не в том, что тебя сбили с ног. Дело в том, встанешь ли ты. — Винс Ломбарди",
                "Ваш настоящий успех в жизни начинается только тогда, когда вы берете на себя обязательство стать лучшим в том, что вы делаете. — Брайан Трейси",
                "Верьте в себя, принимайте вызовы, копайте глубоко в себе, чтобы победить страхи. Никогда не позволяйте никому сломить вас. Вы должны продолжать идти. — Шанталь Сазерленд"
    ]

    override func viewDidLoad() {
        super.viewDidLoad()
        
        SKPaymentQueue.default().add(self)
        
//        если купил, показать платный контент
        if isPurchased() {
            showPremiumQuotes()
        }
        }

    // MARK: - Table view data source

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if isPurchased() {
            return quotesToShow.count
        } else {
            return quotesToShow.count + 1
        }
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "QuoteCell", for: indexPath)

        if indexPath.row < quotesToShow.count {
            cell.textLabel?.text = quotesToShow[indexPath.row]
            cell.textLabel?.numberOfLines = 0
            cell.textLabel?.textColor = UIColor.black
            cell.accessoryType = .none
        } else {
            cell.textLabel?.text = "Получить Больше Цитат"
            cell.textLabel?.textColor = UIColor.cyan
            cell.accessoryType = .disclosureIndicator
        }
        return cell
    }
    
//MARK: - Table view delegate methods
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.row == quotesToShow.count {
            buyPremiumQuotes()
        }
        
        tableView.deselectRow(at: indexPath, animated: true)
        
    }
    
    //MARK: - In-App Purchase Methods
    
    func buyPremiumQuotes() {
//            проверка возможности оплаты
        if SKPaymentQueue.canMakePayments() {
//            Можно заплатить
//            Весь процесс оплаты
            let paymentRequest = SKMutablePayment()
            paymentRequest.productIdentifier = productID
            SKPaymentQueue.default().add(paymentRequest)
            
        } else {
//            Нельзя заплатить
            print("Пользователь не может воспользоваться оплатой")
        }
    }
    
    func paymentQueue(_ queue: SKPaymentQueue, updatedTransactions transactions: [SKPaymentTransaction]) {
        
        for transaction in transactions {
            if transaction.transactionState == .purchased {
                
//                Оплата прошла успешно
                print("Оплата прошла")
                
                showPremiumQuotes()

                
//                Окончание транзакции
                SKPaymentQueue.default().finishTransaction(transaction)
                
            } else if transaction.transactionState == .failed {
                
//                Оплата не прошла
                
                if let error = transaction.error {
                    let errorDescription = error.localizedDescription
                    print("Оплата не прошла из-за ошибки: \(errorDescription)")
                }
                
                SKPaymentQueue.default().finishTransaction(transaction)
                
            } else if transaction.transactionState == .restored {
                showPremiumQuotes()
                print("Покупки восстановлены!")
//                после восстановления уберёт на экране кнопку восстановления
                navigationItem.setRightBarButton(nil, animated: true)
                
                SKPaymentQueue.default().finishTransaction(transaction)
            }
        }
        
    }
    
    func showPremiumQuotes() {
        
//                проверит купил ли пользователь контент или нет
        UserDefaults.standard.set(true, forKey: productID)
        
        quotesToShow.append(contentsOf: premiumQuotes)
        tableView.reloadData()
        
    }
    
    func isPurchased() -> Bool {
        let purchaseStatus = UserDefaults.standard.bool(forKey: productID)
        
        if purchaseStatus {
            print("Уже куплено!")
            return true
        } else {
            print("Не было куплено!")
            return false
        }
    }
    
//    возвращение покупок
    @IBAction func restorePressed(_ sender: UIBarButtonItem) {
        SKPaymentQueue.default().restoreCompletedTransactions()
    }


}
