//
//  ViewController.swift
//  sampleApp
//
//  Created by Logan, Kevin on 7/26/18.
//  Copyright © 2018 Kevin M Logan. All rights reserved.
//

import UIKit

class ViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UITextFieldDelegate {
    @IBOutlet weak var mySwitch: UISwitch!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var newListItem: UITextField!
    @IBOutlet weak var plusButton: UIButton!
    @IBOutlet weak var stackView: UIStackView!
    var weatherData : Weather?
    
    var tasks1 = ["Check the cameras", "Take down bad guys", "Admire yourself in the mirror"];
    
    var tasks = [
        task(name: "Check the cameras", complete: false),
        task(name: "Take down bad guys", complete: false),
        task(name: "Admire yourself in the mirror", complete: false )
    ];
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tasks.count;
    }
    
    // Define table rows
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        //We want to use the dequeueresuablecell because it allows us to reuse cells that aren't on the viewport.
        let cell = tableView.dequeueReusableCell(withIdentifier: "standardCell", for: indexPath)
        cell.backgroundColor = UIColor.clear;
        cell.textLabel?.text = tasks[indexPath.row].name;
        
        //Handle checkmark
        if(tasks[indexPath.row].complete) {
            cell.accessoryType = .checkmark;
        } else {
            cell.accessoryType = .none;
        }
        
        //Night mode text color
        if(mySwitch.isOn) {
            cell.textLabel?.textColor = UIColor.green;
        } else {
            cell.textLabel?.textColor = UIColor.black;
        }
        return cell;
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tasks[indexPath.row].complete = !tasks[indexPath.row].complete;
        
        tableView.beginUpdates()
        tableView.reloadRows(at: [indexPath], with: .none)
        tableView.endUpdates()
    }
//  ------------------ ADD NEW TASKS ------------------------------
    
    @IBAction func addListItem(_ sender: Any) {
        if(newListItem.text == "") { return; }
        let newTask = task(name: newListItem.text!, complete: false);
        tasks.append(newTask);

        //Add new list item to table view.
        let indexPath = IndexPath(row: tasks.count-1, section: 0);
        tableView.beginUpdates();
        tableView.insertRows(at: [indexPath], with: .automatic);
        tableView.endUpdates();
        
        //Clean up text field
        newListItem.text = "";
        
        //Dismiss the keyboard
        view.endEditing(true);
    }
    
//  ------------------ SWIPE LEFT TO DELETE ------------------------
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true;
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            //Update array
            tasks.remove(at: indexPath.row);
            
            //Delete row from table view
            tableView.beginUpdates()
            tableView.deleteRows(at: [indexPath], with: .automatic)
            tableView.endUpdates()
        }
    }
    
//  ----------------------- NIGHT MODE -------------------------------
    
    @IBAction func nightModeButton(_ sender: Any) {
        if mySwitch.isOn {
            view.backgroundColor = UIColor.darkGray;
            updateTableViewCellColor(UIColor.green);
            tableView.tintColor = UIColor.white;
            plusButton.setBackgroundImage( #imageLiteral(resourceName: "whitePlus"), for: .normal);
            stackView.backgroundColor = UIColor.darkGray;
            newListItem.textColor = UIColor.white;
//            newListItem.attributedPlaceholder = NSAttributedString(string: newListItem.placeholder!, attributes: [NSAttributedStringKey.foregroundColor: UIColor(red: 0.004, green: 0.706, blue: 0.06, alpha: 1.0)]);
        } else {
            view.backgroundColor = UIColor.white;
            updateTableViewCellColor(UIColor.black);
            tableView.tintColor = view.tintColor;
            plusButton.setBackgroundImage( #imageLiteral(resourceName: "Plus"), for: .normal);
            stackView.backgroundColor = UIColor.white;
            newListItem.textColor = UIColor.black;
        }
    }
    
    //function to change the color of the tableViewCell textLabels
    func updateTableViewCellColor(_ color: UIColor) {
        for tableViewCell in tableView.subviews {
            //tableViewCells
            if tableViewCell is UITableViewCell {
                let currentTableViewCell = tableViewCell as! UITableViewCell;
                currentTableViewCell.textLabel?.textColor = color;
            }
        }
    }
    
// ----------------------- UITextField Delegate ------------------------------------
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        newListItem.resignFirstResponder();
        return true;
    }
    
// ----------------------- WeatherData HTTP Request ------------------------------------
    
    func weatherDataRequest() {
        let url = URL(string: "https://api.openweathermap.org/data/2.5/forecast?id=4508722&units=imperial&appid=121a79cf9b7fef4ec153e74f8186d76d")!
        
        print("----- Perform weather http request -----");
        
        URLSession.shared.dataTask(with: url) {(data, response, error) in
            guard let data = data else { return }
            //            let dataAsString = String(data: data, encoding: .utf8);
            //            print(dataAsString as Any);
            
            do {
                print("----- Serialize to JSON object -----");
                self.weatherData = try JSONDecoder().decode(Weather.self, from: data);
                
                print("The Temperature is \(self.weatherData?.list[0].main.temp ?? -1)");
                print("We got \(self.weatherData?.list.count ?? -1) instances of weather data.")
                
//                for index in 0...((self.weatherData?.list.count)!-1) {
//                    print("\(self.weatherData?.list[index].dt_txt ?? "NA") with temp \(self.weatherData?.list[index].main.temp ?? -1)");
//                }
                
                //This function is performed outside of the main.
                //Send an async request to the main to add the weather tasks and reload the tableView.
                DispatchQueue.main.async{
                    print("----- Add dynamic Weather tasks -----");
                    //Add weatherTasks to global tasks object.
                    if(self.weatherData?.list.count != nil) {self.addWeatherTasks()};
                    
                    self.tableView.reloadData()
                }
                
                print("----- Remove Loading Indicator ------");
            } catch let jsonErr {
                print("Error Serializing to JSON Object: \(jsonErr)");
            }
            }.resume()
        print("----- Loading Indicator ------");
    }
    
    func addWeatherTasks() {
        //Add new task to tasks array based on weather.
        if ((weatherData?.list[0].main.temp)! < Float(65)) {
            tasks.append(task(name: "WT - Check the Heater", complete: false));
        } else {
            tasks.append(task(name: "WT - Check the Air Conditioner", complete: false));
        }
        
        if ((weatherData?.list[0].weather[0].main)! == "Rain" || (weatherData?.list[0].weather[0].main)! == "Snow") {
            tasks.append(task(name: "WT - Close the windows", complete: false));
        } else if((weatherData?.list[0].weather[0].main)! == "Extreme"){
            tasks.append(task(name: "WT - Check the backup Generator", complete: false));
        }

    }
    
//  ----------------------- EXTRAS ------------------------------------
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //Tell the controller we want to support the delegate methods for the newListItem TextField.
        newListItem.delegate = self;
        // Do any additional setup after loading the view, typically from a nib.
        
        //Retreive weatherData
        weatherDataRequest();
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

