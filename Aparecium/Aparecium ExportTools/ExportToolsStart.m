a=fileChooser()
a.chooseMIDASFile()
file=ans
midasTableController = MidasTableController(uitable())
midasTableController.readMidasFile(file)
ExportTools(midasTableController);
