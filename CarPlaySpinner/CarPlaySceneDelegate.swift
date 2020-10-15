import CarPlay

class CarPlaySceneDelegate: UIResponder, CPTemplateApplicationSceneDelegate {

    // Essentials
    private var interfaceController: CPInterfaceController?
    private var tabBar: CPTabBarTemplate?

    // CarPlay connected
    func templateApplicationScene(_ templateApplicationScene: CPTemplateApplicationScene, didConnect interfaceController: CPInterfaceController) {
        self.interfaceController = interfaceController

        let firstList = getFirstListing()
        let tabBar = CPTabBarTemplate(templates: [firstList])
        self.tabBar = tabBar

        interfaceController.setRootTemplate(tabBar, animated: true) { (success, error) in
            debugPrint("Root template is set")
        }

        tabBar.updateTemplates([firstList])
    }

    // CarPlay disconnected
    func templateApplicationScene(_ templateApplicationScene: CPTemplateApplicationScene,
                                  didDisconnectInterfaceController interfaceController: CPInterfaceController) {
        self.interfaceController = nil
    }
}

private extension CarPlaySceneDelegate {

    func infoPage(title: String, detail: String) -> CPInformationTemplate {
        let item = CPInformationItem(title: title, detail: detail)
        return CPInformationTemplate(title: title, layout: .leading, items: [item], actions: [])
    }

    func getFirstListing() -> CPListTemplate {
        let firstSection = getFirstSection()
        let secondSection = getSecondSection()

        return CPListTemplate(title: "First listing", sections: [firstSection, secondSection])
    }

    func updatedListing() -> CPListTemplate {

        let handler: ((CPTextButton) -> Void) = { _ in
            debugPrint("Selected item!")
        }

        let itemOne = CPListItem(text: "Item 1", detailText: "item 1")
        let itemTwo = CPListItem(text: "Item 2", detailText: "item 2")

        let sectionOne = CPListSection(items: [itemOne], header: "Section One", sectionIndexTitle: nil)
        let sectionTwo = CPListSection(items: [itemTwo], header: "Section Two", sectionIndexTitle: nil)

        let template = CPListTemplate(title: "Updating list", sections: [sectionOne, sectionTwo])

        DispatchQueue.main.asyncAfter(deadline: .now() + 4) {
            let updateItemOne = CPListItem(text: "Updated Item 1", detailText: "item 1")
            let updateItemTwo = CPListItem(text: "Updated Item 2", detailText: "item 2")

            let updateSectionOne = CPListSection(items: [updateItemOne])
            let updateSectionTwo = CPListSection(items: [updateItemTwo])

            template.updateSections([updateSectionOne, updateSectionTwo])
        }

        return template
    }

    func showActionSheet() {
        var actions = [CPAlertAction]()

        actions.append(CPAlertAction(title: "Action 1", style: .default, handler: { _ in
            self.pushToInfoPage(title: "First action") { (success, error) in
                if let error = error {
                    debugPrint("There was an error while pushing to next: \(error)")
                } else if success {
                    debugPrint("Push to next was a success!")
                } else if !success {
                    debugPrint("Push to next wss NOT a success, yet no error was given 🤔")
                }
            }
        }))
        actions.append(CPAlertAction(title: "Action 2", style: .default, handler: { _ in
            self.pushToInfoPage(title: "Second action") { (success, error) in
                if let error = error {
                    debugPrint("There was an error while pushing to next: \(error)")
                } else if success {
                    debugPrint("Push to next was a success!")
                } else if !success {
                    debugPrint("Push to next wss NOT a success, yet no error was given 🤔")
                }
            }
        }))
        actions.append(CPAlertAction(title: "Cancel", style: .cancel, handler: { _ in
            self.interfaceController?.dismissTemplate(animated: true, completion: { (success, error) in
                debugPrint("Template was dismissed!")
            })
        }))

        let template = CPActionSheetTemplate(title: "Select action", message: "Any action will do", actions: actions)
        interfaceController?.presentTemplate(template, animated: true, completion: nil)
    }
}

private extension CarPlaySceneDelegate {

    /// Will generate the first section of the list.
    /// This will demo the items both with and without delay, showing a spinner with delay.
    ///
    /// - Returns: The section
    func getFirstSection() -> CPListSection {
        // 3sec delay item
        let firstItem = CPListItem(text: "Delayed item for spinner", detailText: "Tap this, it'll take a 3 sec and than it'll open an action sheet")
        firstItem.handler = { listItem, completion in
            DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                debugPrint("Async after finished.")
                completion()
                self.showActionSheet()
            }
        }

        let secondItem = CPListItem(text: "Direct item", detailText: "Tap this, it'll show an action sheet directly")
        secondItem.handler = { listItem, completion in
            completion()
            self.showActionSheet()
        }

        let sectionItems = [firstItem, secondItem]

        return CPListSection(items: sectionItems, header: "Actionsheet & spinner", sectionIndexTitle: "1")
    }

    /// Will generate the second section of the list
    /// This will have a list of bugs found
    ///
    /// - Returns: The section
    func getSecondSection() -> CPListSection {
        var sectionItems: [CPListItem] = []

        let secondItem = CPListItem(text: "Updating list", detailText: "This will show a list, which should update after 5s")
        secondItem.handler = { listItem, completion in
            completion()
            let template = self.updatedListing()
            self.interfaceController?.pushTemplate(template, animated: true, completion: nil)
        }
        sectionItems.append(secondItem)

        return CPListSection(items: sectionItems, header: "CarPlay examples", sectionIndexTitle: "2")
    }

    /// Will push the stack to an info page
    /// - Parameters:
    ///   - title: The title of the info page
    ///   - completion: The completion of the push
    func pushToInfoPage(title: String, completion: ((Bool, Error?) -> Void)? = nil) {
        interfaceController?.pushTemplate(infoPage(title: title, detail: "Information page with details"), animated: true, completion: completion)
    }
}
