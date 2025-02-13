import UIKit
import ObjectiveC

public class ExampleTableViewController: UITableViewController {

    internal var searchBar = UISearchBar()

    public let allExamples = Examples.all
    public var filteredExamples = [Example]()

    public var isFiltering: Bool {
        let searchText = searchBar.text?.isEmpty ?? true
        return !searchText
    }

    override public func viewDidLoad() {
        super.viewDidLoad()
        title = "Examples"

        searchBar.delegate = self

        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "reuseIdentifier")
    }
}

extension ExampleTableViewController: UISearchBarDelegate {
    public func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if let searchText = searchBar.text {
            filterContentForSearchText(searchText)
        }
    }

    public func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
    }
}

extension ExampleTableViewController {

    public override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        if section == 0 {
            searchBar.placeholder = "Search examples"
            return searchBar
        }

        return nil
    }

    public override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if section == 0 {
            return 60.0
        }

        return 0
    }

    public override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {

        if isFiltering {
          return filteredExamples.count
        }

        return allExamples.count
    }

    public override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        var example: Example

        if isFiltering {
          example = filteredExamples[indexPath.row]
        } else {
          example = allExamples[indexPath.row]
        }

        let cell = UITableViewCell(style: .default, reuseIdentifier: "reuseIdentifier")
        cell.textLabel?.text = example.title
        return cell
    }

    public override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {

        var example: Example

        if isFiltering {
          example = filteredExamples[indexPath.row]
        } else {
          example = allExamples[indexPath.row]
        }

        let exampleViewController = example.makeViewController()
        navigationController?.pushViewController(exampleViewController, animated: true)
    }

    public func filterContentForSearchText(_ searchText: String) {
        filteredExamples = allExamples.filter {
            return $0.title.lowercased().contains(searchText.lowercased())
        }

      tableView.reloadData()
    }
}
