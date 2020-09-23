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
                debugPrint("Sat root template")
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
            var listItems: [CPListItem] = []

            let item = CPListItem(text: "Delayed item for spinner", detailText: "Tap this, it'll take a 3 sec and than it'll push to the next list")
            item.handler = { listItem, completion in
                DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                    debugPrint("Async after finished.")
                    completion()
                    self.showActionSheet()
                }
            }

            var secondListItems: [CPListItem] = []

            let secondItem = CPListItem(text: "Direct item", detailText: "Tap this, it'll take a 2 sec and push to the next list")
            secondItem.handler = { listItem, completion in
                completion()
                self.showActionSheet()
            }

            listItems.append(item)
            secondListItems.append(secondItem)

            let firstSection = CPListSection(items: listItems, header: "First section", sectionIndexTitle: "Section Index Title 1")
            let secondSection = CPListSection(items: secondListItems, header: "Second section", sectionIndexTitle: "Section Index Title 2")

            return CPListTemplate(title: "First listing", sections: [firstSection, secondSection])
        }

        func showActionSheet() {
            var actions = [CPAlertAction]()

            actions.append(CPAlertAction(title: "Action 1", style: .default, handler: { _ in
                self.pushToNext()
            }))
            actions.append(CPAlertAction(title: "Action 2", style: .default, handler: { _ in
                self.pushToNext()
            }))
            actions.append(CPAlertAction(title: "Cancel", style: .cancel, handler: { _ in
                self.interfaceController?.dismissTemplate(animated: true, completion: { (success, error) in
                    debugPrint("Template was dismissed!")
                })
            }))

            let template = CPActionSheetTemplate(title: "Select action", message: "Any action will do", actions: actions)
            interfaceController?.presentTemplate(template, animated: true, completion: nil)
        }

        func pushToNext(completion: ((Bool, Error?) -> Void)? = nil) {
            interfaceController?.pushTemplate(infoPage(title: "Information page", detail: "With details"), animated: true, completion: completion)
        }
    }
