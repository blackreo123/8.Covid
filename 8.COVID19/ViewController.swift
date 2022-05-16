//
//  ViewController.swift
//  8.COVID19
//
//  Created by JIHA on 2022/05/16.
//

import UIKit
import Charts
import Alamofire

class ViewController: UIViewController {
    @IBOutlet weak var totalCaseLabel: UILabel!
    @IBOutlet weak var newCaseLabel: UILabel!
    @IBOutlet weak var pieChartView: PieChartView!
    override func viewDidLoad() {
        super.viewDidLoad()
        self.fetchCovidOverView { [weak self] result in
            guard let self = self else {return}
            switch result {
            case let .success(result):
                self.configureStackView(koreaCovidOverView: result.korea)
                let covidOverViewList = self.makeCovidOverViewList(cityCovidOverView: result)
                self.configureChart(covidOverViewList: covidOverViewList)
            case let .failure(error):
                debugPrint("error: \(error)")
            }
        }
    }
    
    func removeformatString(string: String) -> Double {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        return formatter.number(from: string)?.doubleValue ?? 0
    }
    
    func configureChart(covidOverViewList: [CovidOverView]) {
        let entries = covidOverViewList.compactMap{ [weak self] overView -> PieChartDataEntry? in
            guard let self = self else {return nil}
            return PieChartDataEntry(value: self.removeformatString(string: overView.newCase),
                                     label: overView.countryName,
                                     data: overView)
        }
        let dataSet = PieChartDataSet(entries: entries, label: "코로나 발생 현황")
        dataSet.sliceSpace = 1
        dataSet.entryLabelColor = .black
        dataSet.xValuePosition = .outsideSlice
        dataSet.valueLinePart1OffsetPercentage = 0.8
        dataSet.valueLinePart1Length = 0.2
        dataSet.valueLinePart2Length = 0.3
        dataSet.valueTextColor = .black
        dataSet.colors = ChartColorTemplates.vordiplom()
                            + ChartColorTemplates.joyful()
                            + ChartColorTemplates.liberty()
                            + ChartColorTemplates.pastel()
                            + ChartColorTemplates.material()
        self.pieChartView.data = PieChartData(dataSet: dataSet)
        self.pieChartView.spin(duration: 0.3, fromAngle: self.pieChartView.rotationAngle, toAngle: self.pieChartView.rotationAngle + 80)
    }
    
    func makeCovidOverViewList(cityCovidOverView: CityCovidOverView) -> [CovidOverView] {
        return [
            cityCovidOverView.seoul,
            cityCovidOverView.busan,
            cityCovidOverView.daegu,
            cityCovidOverView.incheon,
            cityCovidOverView.gwangju,
            cityCovidOverView.daejeon,
            cityCovidOverView.ulsan,
            cityCovidOverView.sejong,
            cityCovidOverView.gyeonggi,
            cityCovidOverView.chungbuk,
            cityCovidOverView.chungnam,
            cityCovidOverView.gyeongbuk,
            cityCovidOverView.gyeongnam,
            cityCovidOverView.jeju
        ]
    }
    
    func configureStackView(koreaCovidOverView: CovidOverView) {
        self.totalCaseLabel.text = "\(koreaCovidOverView.totalCase)명"
        self.newCaseLabel.text = "\(koreaCovidOverView.newCase)명"
    }
    
    func fetchCovidOverView(completionHandler: @escaping (Result<CityCovidOverView, Error>) -> Void) {
        let url = "https://api.corona-19.kr/korea/country/new/"
        let param = [
            "serviceKey" : "5GyS12zQNk4f3HRoFYPAm8wV6eWbhcMDC"
        ]
        
        AF.request(url, method: .get, parameters: param)
            .responseData { response in
                switch response.result {
                case let .success(data):
                    do {
                        let decoder = JSONDecoder()
                        let result = try decoder.decode(CityCovidOverView.self, from: data)
                        completionHandler(.success(result))
                    } catch {
                        completionHandler(.failure(error))
                    }
                    
                case let .failure(error):
                    completionHandler(.failure(error))
                }
            }
    }


}

